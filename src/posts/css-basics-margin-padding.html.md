---
title: CSS Basics - Margin x Padding
date: 2017-11-13
category: front-end
layout: post
description: Como funcionam as propriedades de espaçamento de CSS? Elas sempre funcionam como o esperado? Nesse post falaremos sobre as propriedades margin e padding e como elas funcionam em algumas situações.
authors: [fernandabernardo]
tags:
  - css
  - margin
  - padding
  - box sizing
---

Depois de falar sobre a propriedade *display* no [post anterior](/css-basics-display/), continuaremos falando sobre outras propriedades básicas do CSS. Nesse post conheça um pouco mais sobre as propriedades de espaçamento ***margin*** e ***padding***.

## Diferença

Para começar, qual a principal diferença entre *margin* e *padding*? Ao utilizar a propriedade *margin*, você está acrescentando um espaço externo ao elemento, ou seja, para fora (a distância entre um elemento e outro). Enquanto o *padding* acrescenta um espaço interno ao elemento, para dentro (a distância entre o conteúdo e a borda).
![Representação de margin, padding e border](../images/css-basics-margin-padding-1.png)

## Box Sizing
Uma propriedade relacionada com as duas tratadas acima é a *box-sizing*. Ela é utilizada para alterar a forma como o navegador calcula os tamanhos (altura e largura) de um elemento. Ela possui três valores:
- *content-box* (valor padrão)
- *padding-box* (não é muito suportado pelos browsers, apenas o Firefox tem suporte)
- *border-box*

<p data-height="333" data-theme-id="23784" data-slug-hash="vxPyPV" data-default-tab="css,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Box sizing" class="codepen">Veja o exemplo <a href="http://codepen.io/FernandaBernardo/pen/vxPyPV/">Box sizing</a> by Fernanda Bernardo (<a href="http://codepen.io/FernandaBernardo">@FernandaBernardo</a>) no <a href="http://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

Para entender melhor como cada um destes valores funcionam, acima temos duas *sections* (rosa e azul) usando cada um dos valores de box-sizing. Além disso, colocamos um *padding* de *30px* em ambas. Começando pela `<section>` com *content-box* (rosa) para calcular as dimensões dela (altura e largura) é contado apenas o conteúdo. Tanto *margin*, *padding* e *border* são considerados para fora do *box*. Ou seja, se minha `<section>` tem `100x100px` e um *padding* de `30px`, logo o tamanho total será `160x160px` (100 + 30 + 30). Já a `<section>` com *border-box* o tamanho final seria `100x100px`, porque essa propriedade para calcular o tamanho final do elemento utiliza a soma do conteudo + *padding* + *border*. Um pouco confuso? Veja a imagem abaixo que o conceito ficará mais claro:

![Diferenças entre content-box e border-box](../images/css-basics-margin-padding-2.png)

## Centralização horizontal
Um dos valores da propriedade *margin* é *auto*. Para usá-la, precisamos que o elemento seja um bloco, ou seja, tenha a propriedade `display: block`, e tenha um largura (`width`) definida. Dessa forma, o elemento ficará centralizado horizontalmente.

<p data-height="300" data-theme-id="23784" data-slug-hash="XzgJBz" data-default-tab="css,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Margin: auto" class="codepen">Veja o exemplo <a href="https://codepen.io/FernandaBernardo/pen/XzgJBz/">Margin: auto</a> by Fernanda Bernardo (<a href="https://codepen.io/FernandaBernardo">@FernandaBernardo</a>) no <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

## Margin com elementos inline
A propriedade *margin* serve para definir o tamanho da área de margem de um *box* e para todas as direções (*top*, *right*, *bottom*, *left*). Com apenas uma exceção, as margens verticais (*top* e *bottom*) não funcionam para elementos inline. Veja o exemplo abaixo, no primeiro parágrafo, como o *span* está com seu *display* padrão (`inline`) a propriedade *margin* funciona somente nas dimensões horizontais. Já no segundo, como está `inline-block` o *margin* é aplicado em todas as direções.

<p data-height="300" data-theme-id="23784" data-slug-hash="jawrZJ" data-default-tab="css,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="jawrZJ" class="codepen">Veja o exemplo <a href="https://codepen.io/FernandaBernardo/pen/jawrZJ/">Margin inline</a> by Fernanda Bernardo (<a href="https://codepen.io/FernandaBernardo">@FernandaBernardo</a>) no <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

## Collapsed Margin
As margins *top* e *bottom* às vezes são combinadas e colapsadas em apenas uma. Mas como funciona isso?
- **Margens de blocos "empilhados"**: no nosso exemplo o bloco azul tem uma `margin-bottom` de 1em e o bloco rosa uma `margin-top` de `2em`. No final, o espaçamento entre os blocos deveria ser de `3em` (1em + 2em), certo? Mas não é isso que acontece... O espaçamento final é a maior das duas margens, no caso `2em`.
- **Margens com elementos pai e primeiro / último filho**: no nosso exemplo se não tiver nenhuma borda, padding ou elemento inline, acontece o mesmo efeito com as margens, e a de maior valor é aplicada. É aplicada a margem do parágrafo, que tem o maior valor, ao invés do bloco verde. Se descomentar a borda do `.outro-bloco`, as margens serão somadas normalmente.

<p data-height="300" data-theme-id="23784" data-slug-hash="QOgdNV" data-default-tab="css,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Collapsed margin" class="codepen">Veja o exemplo <a href="https://codepen.io/FernandaBernardo/pen/QOgdNV/">Collapsed margin</a> by Fernanda Bernardo (<a href="https://codepen.io/FernandaBernardo">@FernandaBernardo</a>) no <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

Dois casos em que nunca colapsa a margem são com elementos com *float* ou posição absoluta.

## Background com padding
Um caso interessante, é se tentarmos usar um *background* com *padding*. O padding não é aplicado nem para o *top* nem para o *left*. Ao invés disso, esse valor é aplicado para a direção oposta. Para ficar "certo", precisamos adicionar a propriedade `background-origin: content-box`. Experimente comentar essa linha no CSS do exemplo para ver o que acontece.

<p data-height="300" data-theme-id="23784" data-slug-hash="OOgWao" data-default-tab="css,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Background with padding" class="codepen">Veja o exemplo <a href="https://codepen.io/FernandaBernardo/pen/OOgWao/">Background with padding</a> by Fernanda Bernardo (<a href="https://codepen.io/FernandaBernardo">@FernandaBernardo</a>) no <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

## Conclusão
Nesse post, falamos um pouco sobre as diferenças entre margin e padding, suas aplicações e funcionamento. Continuaremos com a nossa série sobre CSS, e se tiver alguma sugestão de tema que queira ver, coloque nos comentários ;D
