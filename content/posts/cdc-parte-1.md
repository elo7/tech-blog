---
date: 2019-06-03
category: big-data
tags:
  - cdc
  - debezium
authors: [sardinha]
layout: post
title: Introdução ao CDC (Change Data Capture)
description: Vamos entender como o Change Data Capture _(aka CDC)_ funciona e sua aplicabilidade para resolver nossos problemas.
---

A atual popularidade do termo _Big Data_ veio acompanhado de diversas _buzzwords_, entre elas o _Change Data Capture_, ou simplesmente CDC. Porém esse _design pattern_ é tão antigo quanto os RDBMS, pois os dois estão estritamente ligados.

Como o próprio nome diz, o CDC nada mais é do que uma forma de capturar as mudanças nos dados. Vamos imaginar a seguinte tabela de `produto`

```sql
CREATE TABLE `produto` (
   id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
   nome VARCHAR(30) NOT NULL,
   preco DECIMAL(15,2) NOT NULL,
   quantidade INT NOT NULL,
   data_atualizacao DATETIME
)
```
com o seguinte _insert_:

| id | nome | preco | quantidade | data_atualizacao |
|------|-------|--------|--------|---------|
|   1  |  Amigurumi do Batman     | 79.99 |  30      |   2019-06-01 15:30:00     |

Suponhamos que o vendedor queira atualizar o valor do produto para `59.99`. Após a operação de _update_, teremos o seguinte status:

| id | nome | preco | quantidade | data_atualizacao |
|------|-------|--------|--------|---------|
|   1  |  Amigurumi do Batman     | 59.99 |  30      |   2019-06-02 19:27:00    |

Até aí nenhuma novidade, correto? Agora imagine que queremos tirar algumas métricas com base nessa tabela, tais como:

- diferença de valor quando o preço é alterado
- velocidade em que o estoque diminui
- em qual horário um produto é mais comprado

Apenas com a tabela `produto` não seria possível, porque sempre armazenamos o último estado do registro, mas não as suas alterações.

Para resolver esse tipo de problema, foram criadas as famosas tabelas de histórico. Geralmente são utilizadas _triggers_ do próprio BD para realizar essa tarefa e esse padrão leva o nome de [Log Trigger](https://en.wikipedia.org/wiki/Log_trigger).

Nossa tabela `historico_produto` teria a seguinte estrutura
```sql
CREATE TABLE `historico_produto` (
   id INT(6),
   nome VARCHAR(30) NOT NULL,
   preco DECIMAL(15,2) NOT NULL,
   quantidade INT NOT NULL,
   data_inicio DATETIME,
   data_fim DATETIME
)
```
e essas seriam nossas _triggers_:
```sql
/* Trigger  para INSERT */
CREATE TRIGGER HistoricoProdutoInsert AFTER INSERT ON produto FOR EACH ROW BEGIN
   INSERT INTO historico_produto (id, nome, preco, quantidade, data_inicio, data_fim)
   VALUES (New.id, New.nome, New.preco, New.quantidade, now(), NULL);
END;

/* Trigger para UPDATE */
CREATE TRIGGER HistoricoProdutoUpdate AFTER UPDATE ON produto FOR EACH ROW BEGIN
   UPDATE historico_produto
      SET data_fim = now()
   WHERE id = OLD.id
      AND data_fim IS NULL;

   INSERT INTO historico_produto (id, nome, preco, quantidade, data_inicio, data_fim)
   VALUES (New.id, New.nome, New.preco, New.quantidade, now(), NULL);
END;
```
 Agora vamos refazer as operações e observar como ficaria a tabela de histórico:
 ```sql
 INSERT INTO produto (nome, preco, quantidade, data_atualizacao) VALUES ('Amigurumi do Batman', 79.99, 30, now());
 ```
O seguinte _insert_ acionará a _trigger_ `HistoricoProdutoInsert`:

| id | nome | preco | quantidade | data_inicio | data_fim |
|------|-------|--------|--------|---------|---------|
|   1  |  Amigurumi do Batman     | 79.99 |  30      |   2019-06-01 19:27:00    | NULL |

Agora vamos fazer o _update_ no preço _(trigger `HistoricoProdutoUpdate`)_
```sql
UPDATE produto SET preco = 59.99 WHERE id = 1;
```
| id | nome | preco | quantidade | data_inicio | data_fim |
|------|-------|--------|--------|---------|---------|
|   1  |  Amigurumi do Batman     | 79.99 |  30      |   2019-06-01 19:27:00    | 2019-06-02 19:27:00 |
|   1  |  Amigurumi do Batman     | 59.99 |  30      |   2019-06-02 19:27:00    | NULL                |

Podemos ver que a _trigger_ atualizou a coluna `data_fim` do registro anterior e adicionou uma nova com as atualizações. Dessa forma, temos todos os dados de alterações que ocorreram no produto e, com algumas _queries_, podemos responder nossas perguntas. Sempre que quisermos o útimo snapshot do produto, podemos fazer a query `WHERE data_fim = NULL`, ou usuar a combinação das duas colunas _(data\_inicio e data\_fim)_ para obter o estado do produto em um determinado dia/horário.

Essa abordagem é bem simples e pode funcionar para muitos casos, mas ela possui um grande problema: **todas as mudanças ficam visíveis apenas no nível do banco de dados, ou seja, a única interação possível com a tabela `historico_produto` é utilizando _queries_ SQL**. É praticamente impossível um sistema externo reagir à uma mudança no produto. _(seria possível apenas fazendo pooling na tabela, mas convenhamos: não é uma boa ideia né?)_

Como podemos fazer para capturar mudança nos dados e também permitir que sistemas externos reajam à eles? Simples: **eventos!**

Eventos representam ações que ocorreram em um determinado momento e permite, de forma assíncrona, que outros sistemas _(internos ou externos)_ reajam à ele. Geralmente esses eventos trafegam em um sistema de mensageria, tais como: Kafka, RabbitMQ, VerneMQ, Amazon Kinesis...

Os eventos podem trafegar em diversos formatos _(JSON, Avro, Parquet...)_, mas para facilitar a visualização, vamos usar JSON. Um exemplo de evento para o _insert_ do produto poderia ser
```json
{
   "id": 1,
   "nome": "Amigurumi do Batman",
   "preco": 79.99,
   "quantidade": 30,
   "data_atualizacao": "2019-06-01 15:30:00",
   "operacao": "insert"
}
```
e o código para enviar o evento seria parecido com esse:
```java
public class RepositorioProduto {

	private Evento evento;

	public void inserir(final Produto produto) {
		// Salva produto no banco de dados

		//Cria evento
		Map<String, Object> dadosDoEvento = new HashMap<>();
		dadosDoEvento.put("id", produto.getId());
		dadosDoEvento.put("nome", produto.getNome());
		dadosDoEvento.put("preco", produto.getPreco());
		dadosDoEvento.put("quantidade", produto.getQuantidade());
		dadosDoEvento.put("data_atualizacao", produto.getDataAtualizacao());
		dadosDoEvento.put("operacao", "insert");

		//Envia o evento para o sistema de mensageria
		evento.envia("ProdutoCriado", dadosDoEvento);
	}
}
```
Dessa forma conseguimos publicar os eventos com as alterações para quem deseja escutá-los. O evento de `ProdutoAtualizado` por exemplo, poderia ser utilizado para enviar email marketing avisando os clientes que o preço do produto abaixou.

Essa abordagem resolve o problema das _triggers_, possibilitando outros sistemas reagirem às mudanças nos dados. Mas ela acarreta em outros problemas:

- necessita de um grande conhecimento sobre o sistema que irá emitir os eventos, sabendo exatamente onde dispará-los, caso contrário, poderá haver divergências com o banco de dados
- os famosos "updates na mão", que não passam pelo sistema e consequentemente, não irá produzir os eventos necessários
- arquitetura mais complexa do que as _triggers_, pois é necessário um sistema de mensageria

Vimos que tanto a abordagem por _triggers_ quanto a por eventos tem suas limitações _(o que é perfeitamente normal, afinal, não existe bala de prata)_. Mas e se pudessemos fazer um mix das duas abordagem: pegar a consistência do banco de dados com a mensageria dos eventos? É exatamente isso que os frameworks atuais de CDC fazem. Antes de explicá-los, precisamos entender como funciona a replicação de banco de dados, ou mais especificamente, o **_binary log (aka binlog)_**.

Irei explicar como funciona a replicação do MySQL, mas a maioria dos bancos RDBMS seguem o mesmo princípio. Veja a imagem abaixo:

[IMAGEM...AQUI]

1 - A Master recebe o comando SQL

2 - Após executar o comando, a Master escreve no _binlog_ as alterações feitas

3 - A Slave possui um processo que lê o _binlog_ da Master e escreve as alterações em seu _[relay_log](https://dev.mysql.com/doc/refman/5.7/en/slave-logs-relaylog.html) (possui o mesmo formato do binlog)_

4 - A Slave possui outro pocesso que lê o _relay_log_ e aplica as alterações em seu host

_(mais detalhes na [documentação oficial](https://dev.mysql.com/doc/internals/en/replication.html))_

Olhando a imagem acima, podemos afirmar que todas as alterações feitas no banco de dados são escritas no _binlog_. E se conseguíssemos ler esses dados e mandar para um sistema de mensageria? É exatamente isso que o [Debezium](https://debezium.io/) faz.
Atualmente o Debezium é o framework _open source_ mais utilizado para essa finalidade, suportando os seguintes bancos de dados:

- MySQL
- MongoDB
- PostgreSQL
- Oracle
- SQL Server

Sua maior limitação atual é trabalhar apenas com o Kafka para mensageria.


