---
date: 2017-04-17
category: front-end
tags:
  - html
  - semantica
  - acessibilidade
authors: [rapahaeru]
layout: post
title: Os papéis do WAI-ARIA no HTML
description: "O ARIA se divide semanticamente em três partes: seus papéis (roles), estados (states) e suas propriedades (properties). Nesse post vamos focar nas roles (papéis) e entender o seu real papel no HTML."
---

O ARIA se divide semanticamente em três partes: seus papéis (*roles*), estados (*states*) e suas propriedades (*properties*).
As *roles* (papéis) descrevem widgets que não estão disponíveis no HTML 4, como sliders, barras de menus, guias e diálogos. As *properties* (propriedades) descrevem características desses widgets, como se eles são arrastáveis, têm um elemento necessário ou têm um popup associado a eles. Os *states* (estados) descrevem o estado de interação atual de um elemento, informando a tecnologia de assistência se ela estiver ocupada, desativada, selecionada ou ocultada.

No [post anterior](/wai-aria-apanhado-geral/), demos uma introdução conceitual do uso do ARIA. Nesse segundo trataremos das *roles* com alguns estados e propriedades que são necessárias para o uso correto, e o próximo e último post será dedicado exclusivamente aos estados e propriedades.

## As roles

O ARIA permite que os desenvolvedores declarem uma função semântica para um elemento que não possui ou possui uma semântica incorreta. Por exemplo, quando uma lista não ordenada é usada para criar um "menu", deve ser dado ao `<ul>` um papel (role) de "menu" e para cada `<li>` um papel de "menuitem".
```html
<ul role="menu">
    <li role="menuitem">home</li>
    <li role="menuitem">posts</li>
    <li role="menuitem">contato</li>
</ul>
```
As roles são categorizadas em 4 tipos:

1. Abstract
2. Widgets
3. Document Structures
4. Landmarks

Falarei sobre os **Widgets**, **Document Structures** e **Landmarks**, pois sinceramente não compreendi muito bem a utilidade real dos **Abstract roles**. Posso dizer que eles fazem o papel por trás das cenas, onde os atributos (roles) herdam propriedades desses papéis abstratos, confuso né? Esse [diagrama de taxonomia](https://www.w3.org/TR/wai-aria/rdf_model.png) dá uma noção melhor da sua proposta.

## 1 - Widgets

São widgets normais de interface, como caixas de alerta, botões, progress bar e etc.

Seguem alguns exemplos:

### 1.1 - Tooltips
É um popup que exibe informações relacionadas a um elemento quando recebe foco do teclado ou no mouse hover.

1. O elemento que serve de container para o Tooltip deve possuir a *role* tooltip.
2. O elemento que aciona o Tooltip é referenciado com o atributo `aria-describedby`

```html
<div class="tooltip-info" aria-describedby="tooltip_text">Info
  <span class="tooltip-text" id="tooltip_text" role="tooltip">Informação deste item</span>
</div>
```

Interação com o widget, via teclado:

* `Tab`: Abre o Tooltip. Chega-se ao elemento via tab, o que faz exibir o tooltip no foco.
* `Esc`: Fecha o Tooltip

### 1.2 - Tabs
São um conjunto de seções que exibem um painel com conteúdos diferentes, por vez. Cada tab possui um elemento associado, que quando ativado, exibe o conteúdo correspondente.

```html
<div class="tabs">
    <div role="tablist">
        <button role="tab" aria-selected="true" aria-controls="apple-panel" id="apple-tab">Apple</button>
        <button role="tab" aria-selected="false" aria-controls="orange-panel" id="orange-tab">Orange</button>
    </div>
    <div role="tabpanel" id="apple-panel" aria-labelledby="apple-tab">
        <p>Apple panel content</p>
    </div>
    <div role="tabpanel" id="orange-panel" aria-labelledby="orange-tab">
        <p>Orange panel content</p>
    </div>
</div>
```

 *Roles*, *States* e *Properties* do widget **Tab**.

* `Tablist`: Serve de container para o conjunto dos tabs.
* `Tab`: É o título da tab e exibe o painel (tabpanel) quando ativado.
* `Tabpanel`: Contém o conteúdo associado a tab
* `Aria-labelledby`: Serve para rotular o elemento associado (através do id)

Interação com o widget, via teclado:

* `Tab`: move o foco da aba ativa
* `Seta para esquerda`: move o foco para a aba anterior
* `Seta para direita`: move o foco para a aba seguinte
* `Home`: move o foco para a primeira aba
* `End`: move o foco para a última aba

### 1.3 - Menu
É  um tipo de widget (ferramenta) que oferece uma lista de opções para o usuário.
A *role* "menu" é apropriada quando uma lista de *menuitems* é exibido de forma semelhante a uma aplicação de desktop, ou seja, é o simples menu que conhecemos.

```html
<div role="menubar">
    <ul role="menu" tabindex="1">
        <li role="menuitem">Item 1</li>
        <li role="menuitem">Item 2</li>
        <li role="menuitem">Item 3</li>
    </ul>
</div>
```

Interação com o widget, via teclado:

Se o foco estiver no `menubar`

* `Seta para esquerda`: Item anterior do `menubar`
* `Seta para direita`: próximo item do `menubar`
* `Seta para cima` ou `Seta para baixo`: Abre o submenu do item do menu e seleciona o primeiro `menuitem`
* `Enter` ou `Espaço`: Abre ou fecha o submenu do item do menu. Seleciona o primeiro `menuitem`, caso haja.

Se o foco estiver no `menuitem`

* `Seta para esquerda`: Abre submenu do menu anterior e seleciona primeiro item.
* `Seta para direita`: Abre submenu do menu seguinte e seleciona primeiro item.
* `Seta para cima`: seleciona menu item anterior.
* `Seta para baixo`: seleciona menu item seguinte.
* `Enter` e `esoaço`: Aciona item selecionado e fecha submenu.
* `Esc`: Fecha o menu e retorna o foco para o menubar.

`Tabindex`

* Para os itens do menu receberem foco via teclado, o `tabindex` deve ser setado no elemento.


## 2 - Document Structures

Como o nome diz, são estruturas que organizam o conteúdo em uma página.

### 2.1 - Article
É uma simples seção de uma página que forma uma parte independente de um documento.

```html
<div class="post" role="article">
   <p>Texto</p>
</div>
```
Todos sabemos que já possuímos a tag "article", porém com esta *role*, podemos ampliar para qualquer elemento fazer parte de forma independente, sem que a tag "article" seja implementada de forma errônea.


### 2.2 - Toolbar

Um toolbar pode agrupar botões, links e caixas de seleção em uma única tabulação. Neste caso, um toolbar bem simples com 3 botões para ilustrar a ideia:

```html
<div role="toolbar">
    <div role="button" tabindex="0" aria-selected="true">Tool 1</div>
    <div role="button" tabindex="1">Tool 2</div>
    <div role="button" tabindex="2">Tool 3</div>
</div>
```

Interação com o widget, via teclado:

Os botões do menu podem ser acionados por meio da tecla *enter*, caso em algum deles tenha um popup (submenu), o mesmo pode ser acionado via *enter* ou seta para baixo (*down arrow*)
* `Tab`: Move o foco para dentro e para fora do toolbar. Quando foco move para o toolbar, o primeiro controle habilitado recebe foco.
* `Seta para esquerda`: Move o foco para o controle anterior.
* `Seta para direita`: Move o foco para o controle seguinte.
* `Home`: Move o foco para o primeiro controle.
* `End`: Move o foco para o último controle.

### 2.3 - Presentation

Sabemos que o ARIA é usado principalmente para expressar semântica dos elementos, porém há casos que ocultar a semântica de um elemento é importante e também ajuda algumas tecnologias assistivas.

Quando a `role=presentation` é aplicada a uma imagem, a imagem é completamente escondida das tecnologias assistivas, como se estivesse aplicado o estado de `aria-hidden=true`. Por outro lado, se o mesmo for aplicado a um cabeçalho, o valor semântico do elemento será removido mas o texto continua sendo exibido normalmente.

```html
<h3>Exemplo de presentation</h3>
<p>
    <a href="//link.to.com">primeiro link</a>
    <img role="presentation" alt="descrição da imagem" src="//images.cdn.com">
    <a href="//link.to.com">segundo link</a>
    <img role="presentation" alt="descrição da imagem" src="//images.cdn.com">
</p>
```

Veja como ficou a árvore de acessibilidade:

**h3** .[*text*] Exemplo de presentation<br>
**p**<br>
&nbsp;&nbsp;&nbsp;&nbsp;**a** .[*text*] primeiro link<br>
&nbsp;&nbsp;&nbsp;&nbsp;**a** .[text] segundo link

A `role=presentation` remove o `<img>` da árvore de acessibilidade e com ele o atributo `alt`.


## 3 - Landmarks

Serve para marcar regiões importantes da página, como *forms*, *banners* e etc.

### 3.1 - Complementary

Uma seção de suporte do documento complementa o conteúdo principal em um nível similar na hierarquia DOM. Pode ser usado como artigos relacionados ou arquivo de blogs.

```html
<aside role="complementary">
...
</aside>
```
### 3.2 - Banner

O nome ja diz, é uma seção onde é incluído itens como o logotipo ou a identidade do patrocinador de um site, por exemplo, podemos aplicar em um *footer* com a lista de patrocinadores de um evento.

```html
<footer>
    <div role="banner">
        <img src="//logo.patrocinador.com/image.jpg" alt="Logo do patrocinador">
    </div>
    <div role="banner">
        <img src="//logo.patrocinador.com/image.jpg" alt="Logo do patrocinador">
    </div>
</footer>
```

### 3.3 - Navigation
Agrupa elementos de navegação, que normalmente são links para navegar por um documento ou um documento relacionado. Seria mais ou menos um mix do papel das tags `aside` e `nav`. Como podemos aplicar a qualquer elemento, genericamente poderia ficar assim.

```html
<div role="navigation">
    ...
</div>
```
### 3.4 - Main
Onde fica o conteúdo principal do elemento.

```html
<section role="main">
    ...
</section>
```

## Concluindo...

Aqui vimos como aplicar de forma correta os papéis (*roles*) nos elementos com alguns exemplos básicos. Porém, não só disso vive a acessibilidade no HTML.
No próximo post focaremos nos estados e propriedades dessas *roles*.
Espero que tenha ficado claro o papel das *roles* no ARIA e conceitualmente o real propósito do seu uso.


