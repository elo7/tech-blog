---
date: 2017-06-12
category: front-end
tags:
  - html
  - semantica
  - acessibilidade
authors: [rapahaeru]
layout: post
title: As "states" e "properties" do atributo role no WAI-ARIA
description: Os termos "estados" e "propriedades" referem-se a características semelhantes. Ambos fornecem informações específicas sobre um objeto, e ambos fazem parte da definição da natureza das roles. Verificaremos como e quando utilizadar cada atributo.

---

Neste terceiro post da série sobre WAI-ARIA, trataremos sobre os estados (*states*) e propriedades (*properties*) das *roles*.
Caso queira saber mais, fizemos um apanhado geral introdutório [sobre o WAI-ARIA](/wai-aria-apanhado-geral/) e sobre o seu [papel no html](/wai-aria-roles/).

Os termos *states* e *properties* referem-se a características semelhantes. Ambos fornecem informações específicas sobre um objeto, e ambos fazem parte da definição da natureza das *roles*. São aplicados como atributos de marcação de *arias* prefixados.
São usados de formas distintas pois os valores das *properties* estão menos propensos a serem alterados/atualizados durante a execução de uma aplicação do que os valores de *states*.

Exemplificando :

a *propertie* `aria-labelledby` permanece fixado como atributo, informando a descrição de um elemento, já o *state* `aria-checked`muda o valor com frequência de acordo com a interação do usuário (pois é um estado de input checkbox).

Explicando alguns estados e propriedades com alguns exemplos:

## Exemplos de *properties*

### &bull; aria-labelledby / aria-describedby

Indica a descrição de um determinado elemento, através do seu ID.
Se quero descrever o que um botão faz, posso usar :

```html
<button aria-describeby="btn-desc">
  send
</button>

<p id="btn-desc">
  Descrição da ação do botão
</p>
```
ou desta forma:
```html
<button id="btn-desc">
  send
</button>

<p aria-labelledby="btn-desc">
  Descrição da ação do botão
</p>
```

Podemos utilizar de forma correta o `label`, tendo o mesmo valor semântico na árvore de acessibilidade:

```html
<label>
    user name
    <input type="text">
</label>
```
ou

```html
<label for="username">user name</label>
<input type="text" id="username">
```

Isso foi explicado no primeiro post introdutório, confere [lá](/wai-aria-apanhado-geral/).

### &bull; aria-activedescendant

É uma opção diferente para trabalharmos com o foco dos elementos.
Ao invés do foco automaticamente ir navegando de forma descendente, o autor pode definir o elemento exato que suporte o `aria-activedescendant`.

```html
<section role="toolbar" aria-activedescendant="btn-3" aria-hidden="true">
    <button id="btn-1"></button>
    <button id="btn-2"></button>
    <button id="btn-3"></button>
</section>
```
Esta `section` está escondida. Ao ser ativada e com foco, o foco descendente irá diretamente ao que a propriedade está pedindo, que é o elemento com `id="btn-3"`

### &bull; aria-controls

Identifica o(s) elemento(s) que são controlados pelo elemento atual. Como por exemplo uma *tablist* <link para o role>.

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
No caso, o *button* que faz o papel da *tab*, é associado diretamente ao seu painel correspondente.

### &bull; has-popup

Indica a disponibilidade de um elemento *pop-up*, como por exemplo, um *submenu* ou caixa de diálogo, sendo disparado por um elemento.
Um elemento *pop-up* aparece como um bloco de conteúdo que está na frente de outros conteúdos em destaque. O autor deve ter certeza que o contêiner do elemendo a ser exibido, seja um menu, caixa de listagem, árvore, *grid* ou caixa de diálogo e que o valor de `aria-haspopup` corresponde à função do contêiner *pop-up*.

```html
<section aria-hidden="true">
    <ul role="menu" aria-activedescendant="item-2">
        <li role="menuitem" id="item-1">Item 1</li>
        <li role="menuitem" id="item-2">Item 2</li>
        <li role="menuitem" id="item-3">Item 3</li>
    </ul>
</section>

<button aria-haspopup="true">+</button>
```
## Exemplos de *states*

### &bull; aria-expanded
É o estado que indica se o elemento está expandido ou colapsado.

Podemos utilizar o exemplo anterior, imaginando um efeito *toogle* de abrir e fechar o menu através da ação de clique no botão.

```html
<section aria-expanded="false">
    <ul role="menu" aria-activedescendant="item-2">
        <li role="menuitem" id="item-1">Item 1</li>
        <li role="menuitem" id="item-2">Item 2</li>
        <li role="menuitem" id="item-3">Item 3</li>
    </ul>
</section>

<button aria-haspopup="true">+</button>
```
Ao clicar no botão, o estado `aria-expanded` será trocado por **true**, via JavaScript e o inverso também se repete.

### &bull; aria-hidden
Indica quando o elemento está disponível na árvore de acessibilidade, aplicando **true** ou **false**.
Por exemplo, ele oculta para leitores de tela e ferramentas semelhantes. Isso é útil para componentes que são usados puramente por formatação e não contêm conteúdo relevante.

```html
<section>
    <ul role="menu">
        <li role="menuitem">Item 1</li>
        <li role="menuitem">Item 2</li>
        <li role="menuitem">Item 3</li>
    </ul>

    <div class="modal info-limit" aria-hidden="true">
      <p>Você ultrapassou o limite de acessos por dia</p>
    </div>
</section>
```

O exemplo acima, apesar de grosseiro, se aplica a sites que fornecem limite de conteúdo para não assinantes.
O conteúdo informativo deste modal é irrelevante para o leitor, principalmente se ele for assinante.

No caso de ocorrer uma mudança de estado, que nessa situação seria o nosso usuário atingir o limite de visualizações no site, o `aria-hidden` deve ser setado como `false`via JavaScript, além claro da exibição em tela ser administrado via CSS.


## Validando seu código

Para facilitar comece utilizando o HTML5 DOCTYPE em seu código. A verificação é feita por meio da ferramenta [W3C Nu Markup](http://validator.w3.org/nu/) que valida todas as marcações ARIA implementadas em seu HTML.

Mas então se eu aplicar as marcações ARIA em outro tipo de `DOCTYPE` comprometem a acessibilidade?

Além de não comprometer, os resultados serão os mesmos para as tecnologias assistivas. O que diferencia é a validação das marcações através da ferramenta do W3C, que encontrará erros de aplicação das definições de tipo de documento (DTD) por não estarem atualizadas, e não reconhecerão os atributos do ARIA.

Importante informar que a ferramenta [W3C Nu Markup](http://validator.w3.org/nu/) está ainda em constante atualização e ainda não é 100% confiável. Opte sempre em confiar nos testes com seus usuários como definição final.

O WAI-ARIA é muito bom e ao mesmo tempo soa redundante em alguns momentos. Há casos em que a semântica do HTML simples atende bem com seus significados, temos que saber dosar em qual momento é interessante aplicar esse conceito. Sempre lembrando que se o valor semântico for o mesmo e ficar redundante, sempre opte pela semântica nativa.
