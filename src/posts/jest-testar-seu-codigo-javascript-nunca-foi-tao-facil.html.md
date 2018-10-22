---
title: Jest - Testar seu código Javascript nunca foi tão fácil!
date: 2017-08-28
category: front-end
layout: post
description: A grande maioria dos desenvolvedores que conheço não gosta de testar software pelo simples fato de que executar uma bateria de testes de forma manual é extremamente cansativo. Com isso, nós desenvolvedores criamos o péssimo hábito de testar superficialmente tudo que produzimos...
authors: [leonardosouza]
tags:
  - javascript
  - tests
  - tdd
cover: jest-testar-seu-codigo-javascript-nunca-foi-tao-facil.png
---

Trabalhar com desenvolvimento de software é algo que está longe de ser fácil, pois além da parte técnica (que evolui a passadas largas), todo profissional precisa estar minimamente antenado a ponto de perceber qual das suas posturas em relação à execução de suas atividades podem literalmente travá-lo (dentro da carreira) ou levá-lo a outro patamar. Dentre as muitas características valorizadas atualmente pelo mercado, uma importantissíma é ser um profissional adaptável a mudanças, pelo simples fato que **o mundo muda muito rapidamente**, e o jeito que trabalhavámos no passado já não serve e/ou se encaixa com o presente.

Fazendo uma breve reflexão sobre isso, eu me lembro de uma época onde a minha maior gana era produzir o máximo de código que conseguisse por dia. Para mim a efetividade do trabalho e percepção de valor do mesmo estava intrinsecamente ligada à **quantidade**, e não à **qualidade**, do código que eu escrevia.

Então, posso dizer que já "fui um desses"... um cara que rapidamente escrevia uma funcionalidade enorme, com trezentas e tantas linhas de código e, no momento que julgava estar com tudo pronto, abria meu navegador para então executar os meus testes **(manuais)** no software que acabara de construir. E era aí que iniciava-se um ciclo, onde eu encontrava alguns bugs, corrigia-os e testava tudo novamente! Então novos bugs eram encontrados, fazia outras tantas correções até que PÁ... o produto estava **finalmente pronto** (pelo menos no meu ponto de vista) para ir pra produção. Agora, o caminho natural era apenas esperar a validação final do meu trabalho, que seria feita por outro profissional, o famigerado Analista de Qualidade (ou QA).

Essa passagem da minha história é mais comum do que parece, então não ache estranho se isso lhe soou familiar, pois certamente ela deve acontecer até hoje com muitos desenvolvedores por aí (e isso pode até incluir você). Assim sendo, acho que vale ressaltar aqui que estamos em um outro momento, onde o **desenvolvimento de software amadureceu**, e a realidade é que atualmente não basta apenas escrever software. Arregaçar as mangas e implementar **os testes**, com foco total na **qualidade** do que se está produzindo é primordial.

## Começando com testes automatizados

A **grande maioria** dos desenvolvedores que conheço **não gosta de testar software** pelo simples fato de que executar uma bateria de **testes de forma manual** é extremamente cansativo. Com isso, nós desenvolvedores criamos o péssimo hábito de **testar superficialmente** tudo que produzimos, e pela força dos processos inseridos nas empresas acabamos **delegando para um terceiro** a responsabilidade de testar o que acabamos de desenvolver. Mudar essa realidade é complicado, mas não impossível, e certamente uma boa maneira de mudarmos esse paradigma é tornar o **processo de "testar" natural e agradável** ao desenvolvedor. Agora, meu caro, eu te pergunto: que tal utilizar o **seu melhor skill** (que é programar) para tornar os processos de teste manuais em **rotinas automatizadas**? Parece uma boa, não? Pois bem, esse será **nosso desafio** daqui para frente.

Para quem está iniciando nesta jornada, a curva de aprendizado pode parecer um tanto quanto assustadora, e o maior desafio, sem dúvida, é equalizar a sua aparente **falta de conhecimento sobre o tema** a uma nova **filosofia que guiará todo o seu processo de trabalho**. Somado a isso, surgirão uma série de decisões que você precisará tomar para a saída do que eu costumo chamar de "zero absoluto". As perguntas que certamente vêm à tona nesse momento são: **por onde devemos começar e qual caminho devemos seguir???**

Bom, eu acredito que o principal objetivo, inicialmente, seja conseguir configurar corretamente uma **stack mínima para rodar seus testes**. Para isso, existe uma quantidade razoável de **perguntas** que precisam de **respostas**, a fim de nortear o que deve ser feito. Veja se elas fazem sentido para você:

- Que **tipo de teste** eu preciso para o meu software? [**Unitário**](http://blog.caelum.com.br/unidade-integracao-ou-sistema-qual-teste-fazer/), de [**Integração**](http://blog.caelum.com.br/unidade-integracao-ou-sistema-qual-teste-fazer/) ou de [**Aceitação**](http://blog.caelum.com.br/unidade-integracao-ou-sistema-qual-teste-fazer/)?

- Qual **mindset** eu devo utilizar para guiar os meus testes? [**TDD**](http://tdd.caelum.com.br/), [**BDD**](https://tableless.com.br/introducao-ao-behavior-driven-development/) ou um **misto de ambos**?

- Qual biblioteca para de asserção (**expect/should/assertion**) deve ser empregada?

- E testes que dependem de **respostas assíncronas**? Como tratar estes casos? **Spies, stubs e mocks** seria uma opção?

- Será que, além dos testes, seria interessante ter uma idéia sobre o **percentual de cobertura** de tudo que esta sendo testado?

Analisando as perguntas e as prováveis respostas, eu consegui encontrar muitas ferramentas que usaria para responder cada uma delas:

- [**Mocha**](https://mochajs.org/), [**Jasmine**](https://jasmine.github.io/), ... (testing frameworks)

- [**Chai.js**](http://chaijs.com/), [**Should.js**](https://shouldjs.github.io/), ... (para expect/should/assertion)

- [**Sinon.js**](http://sinonjs.org/), [**TestDouble.js**](https://github.com/testdouble/testdouble.js/), ... (para spies, stubs e mocks)

- [**Istanbul.js**](https://istanbul.js.org/), [**Blanket.js**](http://blanketjs.org/), [**JsCover**](https://tntim96.github.io/JSCover/), ... (para code coverage)

Hummm... bom, chegando nesse ponto, deu para perceber que existe um certo nível de complexidade para configurar essa stack. O simples fato de decidir quais ferramentas utilizar (caso alguma escolha não seja a mais acertada) pode trazer consequências futuras para a manutenabilidade dessa stack, uma vez que trocar uma peça que não funcione tão bem pode impactar em uma quantidade significativa de testes já escritos.

## Nossa, que complexo, quero desistir!

É, meu amigo, se você chegou até esse ponto, já deve ter sacado o tamanho da dor que é simplemente configurar uma stack para testes. Com tantas opções e decisões para serem tomadas, isso por si só já seria o suficiente para que essa tarefa seja postergada ao infinito e tornando-se então o famoso [**débito técnico**](https://agilecoachninja.wordpress.com/2016/03/08/debito-tecnico-divida-tecnica/) do seu projeto.

Era exatamente isso que você precisava fazer...até ontem. A boa notícia é que hoje é um belo dia e você já tem opções bem mais elegantes para execução dos seus testes. Então não desista, pois daqui pra frente você vai poder focar no melhor do seu trabalho, que é escrever testes e produzir código de qualidade, sem se preocupar com essa barrreira de entrada!

## Rumo a vitória com Jest!

[**Jest**](https://facebook.github.io/jest/) é um projeto open-source para testes Javascript mantido pelo Facebook, que nasceu com uma filosofia ímpar: prover a seus usuários uma stack completa de testes com zero esforço de configuração.

Além dessa marcante característica, ele possui algumas outras, como:

- **Feedback instantâneo** - monitora alteração nos seus arquivos, e assim que percebe uma mudança dispara os testes

- **Geração de snapshots** - em aplicações escritas em React, snapshots de código podem ser gerados/atualizados para confrontar mudanças que podem quebrar os componentes que compõe a interface final do usuário

- **Ultra Rápido** - testes rodam paralelamente sem interferir um nos outros \o/

- **Code Coverage** - no [**Jest**](https://facebook.github.io/jest/), o relatório de cobertura de código é embutido e habilitado através de uma simples configuração, que pode ser facilmente adicionada utilizando `npm scripts`.

Parece bom demais pra ser verdade, né!? Mas acredite, isso vai facilitar e muito a sua vida.

## Ah não pode ser... venha Jest, que hoje quero lhe usar!!!

Começar a escrever seus testes com [**Jest**](https://facebook.github.io/jest/) é realmente muito fácil. A seguir vou descrever os passos necessários para deixar tudo funcionando.

Vamos começar **instalando o [**Jest**](https://facebook.github.io/jest/)**. Nesse ponto é importante que você entenda que o [**Jest**](https://facebook.github.io/jest/) é distruído como um módulo da plataforma **node.js**. Portanto, é vital certificar-se que esse último está instalado. Você pode abrir seu terminal e digitar o seguinte comando para isso:

```bash
node -v
```

Se tudo estiver certo o número da versão instalada do **node.js** no seu computador será exibida! Caso negativo, você pode dar uma olhadinha [**neste site**](https://nodejs.org/en/download/) e proceder com o processo de instalação de acordo com o seu sistema operacional preferido.

Além da plataforma instalada, precisamos de outra ferramenta para gerenciamento dos módulos. Aqui temos 2 opções, o bom e velho [**npm**](https://www.npmjs.com/) ou o novissímo [**yarn**](https://yarnpkg.com/pt-BR/).

Neste post, nossa opção para gerenciamento dos módulos será feita pelo [**yarn**](https://yarnpkg.com/pt-BR/). Então antes de continuarmos, você precisa garantir que ele esteja instalado no seu ambiente, processo que é muito simples, bastando rodar o seguinte comando (caso você seja usuário da plataforma macOS):

```bash
brew install yarn
```

**Dica 1**: caso você seja usuário macOS e não tenha o [**Homebrew**](https://brew.sh/index_pt-br.html) instalado em seu ambiente a intrução anterior falhará. Caso isso ocorra, rode o seguinte comando e tente novamente:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

**Dica 2**: caso você não seja um usuário macOS, sabia que o [**yarn**](https://yarnpkg.com/pt-BR/) está disponível para todas os principais sistemas operacionais. Siga os passos para instalação no seu sistema operacional [**neste site**](https://yarnpkg.com/pt-BR/docs/install):

Ufa! Agora sim, vamos finalmente instalar o Jest!

## O processo de instalação

Com os pré-requisitos acertados, a instalação é mole. Preparado? Então vamos lá!

Abra seu terminal e crie uma pasta, acessando-a em seguida:

```bash
mkdir elo7-jest-demo && cd elo7-jest-demo
```

Agora instale o [**Jest**](https://facebook.github.io/jest/) usando o [**yarn**](https://yarnpkg.com/pt-BR/):

```bash
yarn add jest
```

Após rodar este comando, você pode conferir o conteúdo deste diretório e encontrará a seguinte estrutura:

```bash
├── package.json
├── yarn.lock
└── node_modules
```

Feito isso, vamos alterar nosso arquivo `package.json`, adicionando a chave `test` com o valor `jest` dentro do objeto `scripts`. Desta forma:

```json
{
  "scripts": {
    "test": "jest"
  },
  "dependencies": {
    "jest": "^20.0.4"
  }
}
```

Essa alteração importante no `package.json` serve para registrar uma espécie de atalho para execução dos seus testes. Logo abaixo, chegará o momento em que vamos utilizá-lo.

## Escrevendo nossos testes

Vamos agora escrever nosso primeiro teste. Utilizaremos o mantra do TDD, que será o seguinte:

![Alt "TDD"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-1.png)

1. RED: escreva um teste que falhe;
2. GREEN: construa um código que funcione;
3. REFACTOR: melhore seu código, eliminando a redundância.

Seguindo a temática do Elo7, vamos supor que você tenha como missão implementar uma das rotinas mais básicas do sistema, que é adicionar um ou mais produtos no carrinho. Para isso, além do `Carrinho`, vamos precisar de um `Produto`. Vamos começar criando o arquivo `carrinho.test.js`:

```js
const Carrinho = require('./carrinho');

test('deve verificar se um carrinho está vazio', () => {
  const carrinho = new Carrinho();
  expect( carrinho.totalDeItens() ).toBe(0);
});
```

É bem fácil entender o teste acima. Primeiramente importamos o arquivo `carrinho.js`, utilizando a função `require`. Nosso teste simplesmente vai verificar que, uma vez instanciado um `Carrinho`, se o número `totalDeItens` é estritamente igual a `0`.

Já podemos rodá-lo, utilizando o seguinte comando no terminal:

```bash
yarn run test
```
O resultado será o seguinte:

![Alt "Falha 1"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-2.png)

Bom, deu para perceber que algo não deu certo. O teste falhou pois não conseguimos importar o módulo `carrinho.js`. Cabe aqui já deixar avisado que o papel final desse arquivo é criar um objeto que representará um carrinho. Então utilizaremos aqui um padrão já bastante conhecido para isto, o [`Constructor Pattern`](https://addyosmani.com/resources/essentialjsdesignpatterns/book/#constructorpatternjavascript):

```js
function Carrinho() {

}

module.exports = Carrinho;
```

Agora, é rodar o teste de novo com `yarn run test` para ver o resultado:

![Alt "Falha 2"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-3.png)

Hummm, continuamos com uma falha. Ela está ocorrendo pois ainda não implementamos o método que vai obter o `totalDeItens` do `Carrinho`. Vamos alterar o arquivo `carrinho.js` de novo:

```js
function Carrinho() {
  this.itens = [];
}

Carrinho.prototype.totalDeItens = function() {
  return this.itens.length;
}

module.exports = Carrinho;
```

Fizemos uma alteração simples aqui. Adicionamos no construtor do objeto `Carrinho` a propriedade `itens` como uma lista vazia. Futuramente, teremos uma forma de `adicionar` itens a esta lista, mais no momento o que precisamos realmente é saber a quantidade `totalDeItens` da mesma. Já implementamos isso, simplesmente retornando o `length` da propriedade `itens` do `Carrinho`. Vamos rodar os testes de novo usando `yarn run test` e ver se deu tudo certo:

![Alt "Sucesso 3"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-4.png)

Muito bom! Nosso primeiro teste está rodando. Então vamos vamos passar para o próximo. Nossa missão agora é verificar se, ao adicionar um `Produto` no `Carrinho`, sua quantidade `totalDeItens` será alterada. Seguindo as práticas do TDD, vamos adicionar um novo teste, rodá-lo e seguir os feedbacks até que tudo esteja OK. Abra novamente o arquivo `carinho.test.js`:

```js
const Carrinho = require('./carrinho');
const Produto = require('./produto'); // aqui importamos o Produto

test('deve verificar se um carrinho está vazio', () => {
  const carrinho = new Carrinho();
  expect( carrinho.totalDeItens() ).toBe(0);
});

// abaixo adicionamos um novo teste
test('deve adicionar um produto ao carrinho', () => {
  let produto = new Produto('Convite Passaporte', 7.50, 5);
  let carrinho = new Carrinho();
  carrinho.adicionar(produto);
  expect( carrinho.totalDeItens() ).toBe(1);
});

```

Uma vez implementado, vamos rodar os testes com `yarn run test`. O resultado será o seguinte:

![Alt "Falha 4"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-5.png)

Conforme esperado, o novo teste está quebrando. Isso ocorreu pois uma nova dependência foi adicionada, o módulo `produto.js`. Bom essa é mole de resolver, vamos implementá-lo:

```js
function Produto(nome, preco, qtd) {
  this.nome = nome;
  this.preco = preco;
  this.qtd = qtd;
}

module.exports = Produto;
```

Já aproveitei para adicionar ao construtor de `Produto` as propriedades `nome`, `preco` e `qtd`. Já que são esses dados iniciais que representam um produto (além de poderem ser utilizados futuramente em novos testes). Rodando os testes novamente temos:

![Alt "Falha 5"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-6.png)

Os testes falharam novamente, agora o problema é que o nosso `Carrinho` não implementa o método de `adicionar`. Vamos resolver isso abrindo o arquivo `carrinho.js`:

```js
function Carrinho() {
  this.itens = [];
}

Carrinho.prototype.totalDeItens = function() {
  return this.itens.length;
}

// adicionamos aqui o método adicionar
Carrinho.prototype.adicionar = function(produto) {
  return this.itens.push(produto);
}

module.exports = Carrinho;
```

Ahaaa! Bom trabalho, agora os testes estão rodando 100% novamente:

![Alt "Sucesso 6"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-7.png)

## Truques finais

Para finalizar, vamos adicionar 2 pequenos detalhes em nosso arquivo `package.json` para deixar o `Jest` mais esperto.

```json
{
  "scripts": {
    "test": "jest --watch",
    "coverage": "jest --coverage"
  },
  "dependencies": {
    "jest": "^20.0.4"
  }
}
```

Conforme você deve ter percebido, adicionamos a flag `--watch` no script de `test`. A vantagem dessa flag é que, a partir de agora, quando novos testes forem adicionados e/ou modificados (bem como os arquivos) os testes rodarão automaticamente. Inclusive, alguns atalhos serão habilitados (letras `p`, `t`, `q`) facilitando a filtragem de arquivos e testes específicos, permitindo ainda que esses testes possam ser facilmente finalizados ou até mesmo rodados outra vez simplesmente pressionando a tecla `Enter`. Rode novamente no terminal `yarn run test` para ver a diferença:

![Alt "Watch Mode"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-8.png)

Outro recurso bacana é a flag `--coverage`. Ela exibe na tela uma grade indicando todos os arquivos cobertos pelos testes do seu projeto, e o percentual de cobertura de cada um. Rode `yarn run coverage` para conferir o resultado:

![Alt "Coverage Mode"](../images/jest-testar-seu-codigo-javascript-nunca-foi-tao-facil-9.png)

Ah e você pode conferir outros recursos também visitando a documentação na página do [**Jest CLI Options**](https://facebook.github.io/jest/docs/en/cli.html).

## Conclusão

Procurei te guiar até aqui para poder mostrar que testes de software, além de necessários, podem ser divertidos. Superada a primeira barreira de entrada, que é configurar a stack de testes (e o [**Jest**](https://facebook.github.io/jest/) foi campeão neste ponto), o próximo desafio é adquirir uma mentalidade para esse fim. As práticas de TDD podem ser uma boa para quem está iniciando, e a minha dica sempre é para que você tente a partir dessa base adicionar novos testes para praticar. Vou deixar de brinde alguns desafios aqui:

1. Adicione um teste para calcular o subtotal de cada produto adicionado ao carrinho. Para isso basta fazer uma multiplicação simples do preço vezes a quantidade.

2. Adicione 3 produtos no carrinho com preços e quantidade diferentes, e calcule o preço total do carrinho a partir dos subtotais de cada produto.

3. Adicione um novo objeto para representar o frete de envio, e faça um novo teste considerando o total do carrinho mais o preço do frete.

Bom, acho que é isso. A mensagem final é:

> ***testar seu software**, além de necessário é **sua responsabilidade**, portanto, não delegue-o a terceiros!*

Caso este artigo tenha sido útil para você, por favor **colabore compartilhando-o** em suas redes sociais! Ah e não deixe de nos contar suas experiências nos comentários logo abaixo!
