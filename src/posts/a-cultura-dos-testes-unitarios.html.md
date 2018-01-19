---
title: A cultura dos testes unitários
date: 2018-01-19
category: front-end
layout: post
description: Hoje o volume de sistemas e sites utilizando código JavaScript é enorme. Ora do lado do cliente, ora servidor. Como garantir a qualidade de todo esse volume de código? E qual a melhor forma assegurar para tal virtude? Temos os testes automatizados e sendo mais focado ainda, os de unidade.
authors: [rapahaeru]
tags:
  - cultura
  - metodologias
  - JavaScript
  - TDD
---

## Introdução

Todo tipo de iniciativa, parte de uma evolução de algo que gera novas necessidades. Muito vago mas será compreendido.
Hoje o volume de sistemas e sites utilizando código JavaScript é enorme. Ora do lado do cliente, ora servidor.
Como garantir a qualidade de todo esse volume de código? E qual a melhor forma assegurar para tal virtude? Temos os testes automatizados e sendo mais focado ainda, os de unidade.

## Por que testes de unidade? Para que servem?

Pense que você possui um sistema grande com inúmeros métodos e funções. Só que você precisa atualizar uma função no qual gera um resultado de uma simples divisão, que antes exibia com duas casas decimais e agora resulta com números arredondados.
Essa mesma função é usada em outras telas desse sistema, e agora? Como saber que tudo está em ordem como antes? Tudo bem, pode se testar uma por uma, mas e se ela for usada em mais de 40 lugares? Isso sem contar o maior risco de todos, a falha humana.
Nesses casos, desenvolve-se um teste unitário. Nele você simula como o método deveria se comportar, com dados "mockados". Sem a necessidade de alguém descobrir algo só depois que tudo der errado.

<!-- <aprofundar mais sobre testes automatizados> -->

Um bom código é aquele que resguarda cada método e não apenas as ações do sistema, como um clique de botão por exemplo (testes automatizados).
Um teste unitário se resume a fazer um teste automatizado em um trecho de código independente. O código estando bem organizado e modularizado, fica mais simples para se testar.

<!-- <exemplo teste unitario> -->

Imagine no cenário de método que mencionei acima. Um método que recebe dois números e que responde a divisão entre eles.

<!-- </exemplo teste unitario> -->

Mas antes de avançar nos testes unitários, seria interessante conhecermos uma técnica de desenvolvimento que nos ajuda a prever certos problemas com nosso código, chamada Test drive development, o TDD.

## O TDD

[Test Driven Development (TDD)](https://pt.wikipedia.org/wiki/Test_Driven_Development) ou em português Desenvolvimento guiado por testes é uma técnica de desenvolvimento de software que baseia em um ciclo curto de repetições: Primeiramente o desenvolvedor escreve um caso de teste automatizado que define uma melhoria desejada ou uma nova funcionalidade. Então, é produzido código que possa ser validado pelo teste para posteriormente o código ser refatorado para um código sob padrões aceitáveis."
O TDD de forma resumida e simples, significa que você começa antes pelo teste, depois parte para o desenvolvimento do código de produção. Você faz um "test-drive" no código antes. Simula situação por situação e prepara tudo para receber da melhor forma e saber como tratar os resultados.

## Certo, mas pra quê?

Ao fazer todos os testes antes do desenvolvimento do código de produção, o desenvolvedor garante que boa parte do seu sistema esteja coberto por testes, muitas vezes soluções de problemas são descobertas ainda nessa fase, ajudando no direcionamento do desenvolvimento. Na minha opinião, existem dois pilares que o TDD endossa:

- A segurança

Ao aplicar TDD, começando por testes sempre que possível, cada módulo do seu código estará coberto. O que é importante deixar claro é a segurança para o desenvolvedor e não apenas do código. Como abordado acima, pense em um sistema antigo e enorme, você se lembrará de cada passo desenvolvido antes? onde cada método é chamado e utilizado? Na maioria das vezes você nem mesmo participou da origem do sistema. Como garantir que uma refatoração não vá afetar tudo o que foi feito lá trás? Testar isso manualmente será bem complicado. Mas se com a prática do TDD aplicada sempre a testar cada trecho de código implementado, a manutenção e refatoração fica muito mais simples, já que o teste automatizado nos mostrará onde esquecemos ou afetamos algo que não deveria. Perceba o quão mais leve é para o desenvolvedor.

- A qualidade do código

Muito se fala no mundo do TDD que se o código não possível ser testado, não é um bom código. Aplicando essa metodologia, o programador tem acesso a uma expansão no raciocínio lógico, podendo desenvolver o design de suas classes de forma muito mais concisas. Ele acaba se atentando a respostas do sistema, que desenvolvendo na forma tradicional talvez passasse desapercebido.
Essa prática gera melhorias muito importantes no processo de desenvolvimento. Quantas vezes uma atualização afetou negativamente funções antigas? Com um simples teste automatizado bem aplicado, evitaria tais transtornos. Além do tempo, se o desenvolvedor percebe algo de errado, será acusado no momento que o teste foi rodado, demonstrando exatamente onde a atualização afetou, bem direto ao ponto. Ao contrário dos testes manuais que gastariam infinitamente mais tempo, não só pra resolver como pra encontrar o problema.

## A mecânica do TDD

A mecânica é sucinta e exatamente nessa sequência, em looping:

1. Escreve um teste que falhe (vermelho);
2. Faça com que esse teste passe de forma simples (verde);
3. Faça um novo teste (refatora);

Toda essa sequência de rodadas chama-se ciclo **<span style="color: red">vermelho</span>-<span style="color: green">verde</span>-refatora**.
<!-- <Imagem vermelho-verde-refatora> -->


Explicitando mais detalhadamente, você escreve um teste sobre determinado método que esteja querendo desenvolver. Ao fazer esse teste, obviamente ele irá falhar pois o método de produção ainda não foi implementado. Implementando o mesmo, verifique se o teste passe. Em seguida, refatore o que já fora feito na possibilidade de melhorar ainda mais seu código. Dando sequência ao looping, escreva um novo teste, pode ser alguma nova questão que você observou ao implementar a funcionalidade com teste ou um novo teste para uma nova funcionalidade, fechando o ciclo.

## Mas e o tempo gasto?

Sim, gasta-se mais, bem mais. Mas poderíamos chamar esse tempo de investimento. Como tudo dito nesse post, pense na diminuição de problemas e necessidade de refatoração de código. Pense em uma das situações antes apresentadas, quanto tempo pouparíamos caso nossa atualização quebrasse algo em produção, tendo nossos testes feitos.
Velocidade não é produtividade.
Pense que o maior tempo investido em um código de qualidade, resultaria em um código mais simples de se refatorar e de fazer manutenção.
Faça testes unitários
Agora que temos uma breve introdução sobre o TDD, podemos pensar em aplicar exatamente nos testes de unidade em JavaScript, como introduzi no início do post.
A premissa de um teste unitário é testar um trecho de código, autônomo, antes de aplicá-lo no sistema em produção. Pode ser feito sem o TDD? Pode, mas aplicar testes unitários depois da aplicação já desenvolvida além de mais trabalhoso, está mais suscetível a falhas.
No caso do JavaScript, os testes de unidade são no navegador, sem, as vezes, iniciar um servidor para tal, apenas um servidor de exemplo, estático.
Para isso, temos uma página separada, como uma cópia da produção, com um JavaScript atrelado, com todos os testes que deseja efetuar.

Bom, esse post, foi apenas um introdutório sobre os testes automatizados e unitários, para nós desenvolvedores refletirmos nas vantagens de os usarmos no desenvolvimento de nossas aplicações. Sabemos das dificuldades, mas sabemos agora das vantagens.
Vamos por na balança?

Próximo post, agruparei alguns exemplos de testes unitários em JavaScript para nos aprofundarmos, utilizando Mocha.

Abs.

