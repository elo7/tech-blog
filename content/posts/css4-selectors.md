---
date: 2015-11-16
category: front-end
layout: post
title: 'CSS4 - Seletores nível 4'
description: O CSS3 já está aí com força total, mas poucos sabem que o CSS4 já está em rascunho desde 2011 e muitas funções hoje são usadas sem você saber. Um dos focos dessa versão são os novos seletores. Neste post irei falar um pouco sobre o que vem por aí...
authors: [fellyph]
tags:
  - css
  - front-end
  - tech-talk
---

O **CSS3** já está aí com força total, mas poucos sabem que o **CSS4** já está em rascunho desde 2011 e muitas funções hoje são usadas sem você saber. Um dos focos dessa versão são os novos seletores. Neste post irei falar um pouco sobre o que vem por aí, este tema foi uma apresentação realizada em um TechTalk do Elo7 e os slides estão no final do post.

### Range

Hoje com os novos seletores é possível tratar elementos que estão limitados por um range, com as pseudo-classes **in-range** e **out-of-range**. Esse é um dos recursos que muitos browsers já suportam.

**HTML**

``` html
<form>
    <input type="number" id="quantidade" min="1" max="5" >
</form>
```
**CSS**

``` css
input[type="number"]:in-range {
    border-color: green;
}

input[type="number"]:out-of-range {
    border-color: red;
}
```
**Browsers que suportam:**

  * Chrome 10.0
  * Firefox 28.0
  * Opera 11.0
  * Safari 5.2

### Optionality

As pseudo-classes de "opcionalidade" servem para tratar elementos de inputs e formulários que são obrigatórios ou não.

**HTML**

``` html
<form>
    <input type='email' placeholder='Seu email' required >
    <input type='text' placeholder='Seu nome' optional >
</form>
```

**CSS**

``` css
input:optional {
    border-style: dotted;
}

input:required {
    border-color: red;
}
```

**Browsers que suportam optionality:**

  * Chrome 10.0
  * Firefox 4.0
  * Opera 10.0
  * Safari 5.0
  * Internet Explorer 10.0

### Mutability

As pseudo-classes de "mutabilidade" representam os elementos que permitem ou não alteração pelo usuário.

**HTML**

``` html
<p contenteditable='false'>
    Apenas de leitura
</p>

<p contenteditable='true'>
    Conteúdo editável
</p>

<form>
    <input type='text' value='Olar amigo' readonly>
    <input type='text' value='Olar amigo 2'>
</form>
```

**CSS**

``` css
input:read-only,
p:read-only {
    background: red;
}

input:read-write,
p:read-write {
    background: green;
}
```

No exemplo acima, adicionamos um atributo "contenteditable" para tornar o elemento editável. No HTML5 qualquer elemento pode se tornar editável e este recurso tem suporte em diversos browsers (Firefox 3.5+, Chrome 4.0+, Internet Explorer 5.5+, Safari 3.1+).

### Placeholder

A pseudo-classe **placeholder-shown** seleciona elementos input que estão exibindo o placeholder.

**HMTL**

``` html
<form>
    <input type='text' placeholder='Digite seu nome aqui' />
</form>
```

**CSS**

``` css
input:placeholder-shown {
    background: #000;
    color: #FFF;
}
```

### Matches

A pseudo-classe **matches** ajuda a realizar seletores de agrupamento mais simples. Atualmente nenhum browser suporta esse seletor, eles utilizam **any** com o prefixo para  Webkit e Mozilla.

**HTML**

``` html
<ul>
    <p>Mensagem 1</p>
    <p class='fechado'>Mensagem 2</p>
    <p class='nao-lida'>Mensagem 3</p>
    <p class='cancelado'>Mensagem 4</p>
</ul>
```

**CSS**

``` css
p:matches(.fechado, .cancelado, .nao-lida) {
    color: red;
}

p:-moz-any(.fechado, .cancelado, .nao-lida) {
    color: red;
}

p:-webkit-any(.fechado, .cancelado, .nao-lida) {
    color: red;
}

/* equivalente:

p.fechado,
p.nao-lida,
p.cancelado {
    color: red;
} */
```

**Browsers que suportam any:**

  * Chrome 12.0(-webkit)
  * Firefox 4.0(-moz)
  * Safari 5.0(-webkit)

### Not

Presente no CSS3, agora ele possui suporte para receber **mais de um argumento** essa nova aplicação ainda não é suportada pelos browsers. O comportamento deste seletor é o seguinte: ele aplica a regra aos elementos que não se enquadram ao seletor como nome sugere _uma negação_.

**HTML**

``` html
<ul>
    <li>Compra 1</li>
    <li class='cancelado'>Compra 2</li>
    <li>Compra 3</li>
    <li class='nao-lido'>Compra 4</li>
</ul>
```

**CSS**

``` css
/* suportado */
li:not(.cancelado) {
    color: red;
}

/* ainda não suportado */
li:not(.cancelado, .nao-lido) {
    color: red;
}
```

### Case Insensitive

Um problema antigo na seleção de elementos por parâmetros, muitas vezes o sistema ou usuário adiciona os arquivos com uma variação de caixa alta e baixa não esperada. Com esse novo recurso podemos selecionar itens independente de sua capitalização. Como podemos ver no exemplo abaixo:

**HTML**

``` html
<a href="test.pdf">Test 1</a>
<a href="test.PDF">Test 2</a>
<a href="test.pDF">Test 3</a>
```

**CSS**

``` css
a[href$="pdf" i] {
    color: red;
}
```

No exemplo acima, todos os elementos conseguem ser selecionados. Isso antes não era possível, já que teríamos que criar um seletor para cada situação. Esse recurso ainda não foi implementado pelos browsers.

### Direction

Com HTML é possível especificar a direção do texto. Esse é um recurso usado para alguns idiomas que são lidos em diferentes direções. Porém, ainda não existia um seletor para estilizar um conteúdo de acordo com sua direção. Este recurso ainda não foi implementado pelos browsers.

**HTML**

``` html
<div dir="ltr"> Some text Default writing direction.</div>
<div dir="rtl"> بعض النصوص من اليمين إلى اليسار الاتجاه </div>
```

**CSS**

``` css
:dir(ltr) {
    color: red;
}

:dir(rtl) {
    color: blue;
}
```

Além desses recursos outros estão sendo implementados, mas listei os que mais curti. Abaixo você pode conferir os slides da apresentação:

### Referências:

  * [http://css4selectors.parseapp.com/](http://css4selectors.parseapp.com/)
  * [http://www.sitepoint.com/future-generation-css-selectors-level-4/](http://www.sitepoint.com/future-generation-css-selectors-level-4/)
  * [https://davidwalsh.name/css4-preview](https://davidwalsh.name/css4-preview)
