---
title: Pareamento quase 100% do tempo, como é isso?
date: 2018-06-05
category: cultura
layout: post
description: Já ouviu falar de pareamento? Todos os dias e não aquele uma vez por ano? Sabe como isso funciona? Nesse post falarei como fazemos isso no time de front end aqui do Elo7 e como há uma rotação de pessoas, o fluxo de tarefas e o que achamos bom e ruim dessa cultura.
authors: [fernandabernardo]
tags:
  - agile
  - cultura
  - metodologias
  - processos
  - pareamento
cover: pareamento.jpeg
---

Geralmente temos a visão dos programadores como sendo aquelas pessoas de fone que se isolam do mundo e de todos.

Mas existem outras formas do trabalho funcionar. Uma delas é a cultura de pareamento. Aqui no Elo7 todos os times tem essa cultura, mudando entre elas apenas a frequência que isso acontece. No meu time, de front end isso acontece em quase 100% do tempo. Ao longo desse post eu vou explicar mais como isso funciona e quais são as vantagens e desvantagens na minha opinião.

# Como funciona?

Para começar, como é isso? Como na imagem abaixo, temos apenas uma máquina (PC), e nessa máquina conectamos dois monitores espelhados. Além disso, cada pessoa tem um teclado e um mouse. Logo, as duas pessoas podem mexer ao mesmo tempo no código.

![Pareamento no Elo7](../images/pareamento-01.png)

Já ouvi muitas pessoas perguntando se não funciona como um dojo, em que cada pessoa tem um tempo determinado para digitar e depois troca. Bom… na verdade não. É bem mais dinâmico que isso. E o nome disso é bom senso. Óbvio que às vezes coincide das duas pessoas mexerem ao mesmo tempo, mas aí entramos em um acordo em que só um mexe. Mas na grande maioria das vezes esse processo acontece de forma intercalada e assim vamos desenvolvendo o código.

# Troca de pareamento

Outro questionamento bem comum é sobre a troca de duplas do pareamento. Não ficamos com as mesmas duplas todos os dias. Existe um revezamento. E isso pode mudar a cada um dia ou até mesmo no mesmo dia. Hoje, estou em um time de 5 pessoas. Isso significa que pode ter 2 duplas e uma pessoa sozinha todo dia.

Uma coisa importante de dizer, é que não temos lugar fixo, temos uma bancada com 6 computadores reservados ao nosso time. Isso facilita a troca de pareamento, porque é possível trocar facilmente de computador sem aquela ideia de "minhas coisas".

A troca de pareamento estimula a troca de conhecimento, já que cada pessoa tem um assunto que é mais especialista e também diminui a entrada de bugs em produção. Além disso, traz uma união maior para o time, já que estamos sempre conversando, discutindo e falando sobre tudo.

Também testamos e fazemos code review das nossas tarefas em duplas. Isso melhora a análise do código, já que duas pessoas podem analisar ou perceber partes diferentes. Além disso, é muito bom para passar conhecimento sobre alguma linguagem, sistema, design de código...

# Fluxo de uma tarefa

O pareamento influencia diretamente na execução de uma tarefa. Imagine o seguinte cenário: temos que desenvolver uma determinada tarefa, em que apenas uma pessoa (João) tem conhecimento do código e seu contexto. João então vai parear com Maria para desenvolver a tarefa. Depois que tudo foi desenvolvido, a tarefa passa para a fase de testes, onde a regra é que nem João e nem Maria podem testar. Logo Pedro e Alice vão testa-la (pois nesta fase também trabalhamos em dupla). A tarefa pode ter vários ciclos de teste, onde os bugs encontrados são reportados e a tarefa é colocada para fix, permanecendo neste ciclo até que a mesma seja aprovada.

Ou seja, pelo menos 3 pessoas vão adquirir um novo conhecimento sobre esse feature, e pelo menos 4 pessoas vão saber sobre essa tarefa. Esse formato, além de passar um conhecimento para outras pessoas do time de uma forma mais simples, também evita que bugs entrem em produção (bugs sempre existem, mas eles diminuem), afinal 4 pessoas olharam aquele código e testaram aquela tarefa.

# Produtividade

A produtivdade é algo muito questionado quando o assunto é pareamento. A parte óbvia é que estamos deixando duas pessoas para produzir apenas uma tarefa, ou seja, precisaríamos do dobro de programadores para fazer o mesmo código que uma empresa que não tem pareamento. Mas não é bem assim... ficamos muito menos dispersos quando estamos pareando, até porque uma pessoa acaba puxando a atenção da outra, então o tempo que estamos focados e efetivamente produzindo código acaba sendo muito maior. Outro fator é que desta forma existe muito menos tempo para procrastinação, como por exemplo ficar olhando nossas redes sociais ou até mesmo ficar encarando o editor de texto em branco em busca de uma determinada solução.


# Conclusão

Essa é a nossa forma de lidar com o pareamento, e para gente funciona bem. É interessante lembrar que não somos tão rígidos nessas regras e que podemos ir mudando conforme nossas necessidades. Para finalizar vou listar o que eu acredito serem vantagens e desvantagens do uso do pareamento.

## Vantagens

- Compartilhamento de conhecimento rápido
- Menos bugs para produção
- Código tende a sair com melhor qualidade na primeira entrega
- Menos tempo travado em uma tarefa por não saber começar
- Foco maior, uma pessoa acaba puxando a outra
- Maior entrosamento do time

## Desvantagens

- Às vezes pode criar uma dependência da sua dupla, pois pode ficar cômodo ter sempre alguém para resolver um problema e não ficar um tempo "quebrando a cabeça". Para contornar isso, às vezes cada um prefere ficar sozinho para fazer uma tarefa.
- Desgastante, pois você pode não estar acostumado a ficar focado por muito tempo, já que o tempo de procrastinação diminuirá e muito.
- Para a pessoa que não está "pilotando", ou seja, que não está digitando no momento, pode ser um pouco massante. O que usamos para tentar evitar isso, é ir intercalando mais rápido, ou até mesmo dar uma parada para tomar um café e voltar melhor.

---

Você já trabalha com pareamento? Como que funciona na sua empresa? Deixe seu feedback ou sua pergunta aqui nos comentários :)
