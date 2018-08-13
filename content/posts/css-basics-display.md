---
date: 2017-07-24
category: front-end
tags:
  - css
  - display
  - posicionamento
authors: [fernandabernardo]
layout: post
title: CSS Basics - Display
description: O que cada um dos atributos da propriedade display realmente significa? O objetivo deste post é abordar qual é o melhor uso para cada um deles, e quais são as mudanças de layout causadas por cada possível valor.
cover: display.jpg
---

Este será o primeiro de uma série de posts sobre **CSS Básico**. A ideia desses posts é explicar como funciona cada uma das propriedades do CSS que na teoria "todo mundo conhece". Vamos entender como usar cada uma delas sem ficarmos apenas "chutando" até descobrir o que funciona e nunca mais mexer. Nesse primeiro post falaremos sobre a propriedade **display**.

A propriedade *display* é muito importante para o controle do layout, pois indica a caixa de renderização para cada elemento. Cada elemento HTML possui um valor padrão de *display*, sendo em sua maioria *block* ou *inline*.

## Block

Os elementos que possuem essa propriedade são considerados elementos de bloco. Esses elementos possuem uma quebra de linha (espaço em branco) acima e abaixo, e não permitem que outros elementos sejam posicionados ao lado deles.

Os elementos mais comuns que possuem `display: block` como padrão são: `<div>`, `<p>`, `<form>` e as novas tags do HTML5: `<header>`, `<section>`, `<footer>`, entre outros.

<p data-height="300" data-theme-id="23784" data-slug-hash="egmXBo" data-default-tab="css,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Display Block" class="codepen">Veja o exemplo <a href="http://codepen.io/FernandaBernardo/pen/egmXBo/">Display Block</a> by Fernanda Bernardo (<a href="http://codepen.io/FernandaBernardo">@FernandaBernardo</a>) no <a href="http://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

Uma forma de posicionar elementos ao lado de um elemento com `display: block` é usando propriedades que tiram o elemento do fluxo normal da página. Como, por exemplo, `float` e `position: absolute`. Mas essas propriedades ficam como assunto para futuros posts.

## Inline

Os elementos que possuem essa propriedade são considerados elementos de linha. Isso significa que são renderizados dentro do bloco na mesma linha, ou seja, não tem quebra. `<span>` é o mais conhecido deles, junto com `<a>`, `<b>` e `<i>`. Esses elementos podem ser colocados dentro de um parágrafo (que é um bloco), sem quebrar seu fluxo.

<p data-height="300" data-theme-id="23784" data-slug-hash="WRbmOK" data-default-tab="html,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Display Inline" class="codepen">Veja o exemplo <a href="http://codepen.io/FernandaBernardo/pen/WRbmOK/">Display Inline</a> by Fernanda Bernardo (<a href="http://codepen.io/FernandaBernardo">@FernandaBernardo</a>) on <a href="http://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

## None

Este valor é usado para esconder algum elemento. Existem elementos que possuem esse valor de *display* por padrão, por exemplo, o `<script>`.

<p data-height="300" data-theme-id="23784" data-slug-hash="ygywPw" data-default-tab="html,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Display None" class="codepen">Veja o exemplo <a href="http://codepen.io/FernandaBernardo/pen/ygywPw/">Display None</a> by Fernanda Bernardo (<a href="http://codepen.io/FernandaBernardo">@FernandaBernardo</a>) on <a href="http://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

Uma diferença que causa bastante dúvida quando temos o `display: none`, é quando esse é comparado com o `visibility: hidden`. A diferença entre eles é que o *display* realmente retira todo o elemento da tela, como se ele não existisse; já com *visibility*, o elemento não aparece mas continua ocupando o espaço como se estivesse visível.

## Inline-block

Esses elementos possuem uma mistura de propriedades. Como o próprio nome diz, tem a característica de ser em linha como um elemento *inline* e de ser um elemento em bloco como o *block*. A diferença entre um elemento *inline* e um *inline-block* está em elementos *inline-block* respeitarem os tamanhos personalizáveis, como *width*, *height*… Enquanto os que são *inline* não respeitam, apenas levam em consideração o *line-height*.

<p data-height="300" data-theme-id="23784" data-slug-hash="GrgeQM" data-default-tab="css,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Display Inline-Block" class="codepen">Veja o exemplo <a href="http://codepen.io/FernandaBernardo/pen/GrgeQM/">Display Inline-Block</a> by Fernanda Bernardo (<a href="http://codepen.io/FernandaBernardo">@FernandaBernardo</a>) on <a href="http://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

# Table

Como o próprio nome já diz, esse tipo de display serve para que um elemento se pareça como uma tabela. Apenas essa frase já é suficiente para perceber um problema: se estamos querendo mostrar um elemento qualquer como uma tabela, será que ele não deveria ser uma tabela de fato? Isso pode inclusive gerar um problema de acessibilidade, mas cada caso deve ser analisado isoladamente. Além do `display: table` que seria o semelhante à tag `<table>` do HTML, existem também os displays: `table-row` e `table-cell` que se comparam às tags `<tr>` e `<td>`.

<p data-height="300" data-theme-id="23784" data-slug-hash="JEdxXv" data-default-tab="css,result" data-user="FernandaBernardo" data-embed-version="2" data-pen-title="Display table" class="codepen">Veja o exemplo <a href="http://codepen.io/FernandaBernardo/pen/JEdxXv/">Display table</a> by Fernanda Bernardo (<a href="http://codepen.io/FernandaBernardo">@FernandaBernardo</a>) on <a href="http://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>


Nesse post, falamos um pouco sobre como funcionam alguns atributos da propriedade `display`, e como usá-los. Nos próximos posts abordarei outras propriedades comuns e também novas especificações.
