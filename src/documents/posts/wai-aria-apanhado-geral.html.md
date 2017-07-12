---
date: 2017-04-03
category: front-end
tags:
  - HTML
  - semântica
  - Acessibilidade
authors: [rapahaeru]
layout: post
title: Um apanhado geral sobre o WAI-ARIA
description: O que o desenvolvedor atual está fazendo para tornar seu conteúdo mais acessível para pessoas com algum tipo de deficiência? Com a evolução da web, a usabilidade melhorou muito, porém usuários de tecnologias assistivas correm risco de serem excluídos por conta das lacunas de acessibilidade que surgem com as páginas mais dinâmicas. Como leitores de tela normalmente sofrem com JavaScript, surge uma nova maneira de criar interfaces dinâmicas que são acessíveis a mais usuários.
---

Com a evolução da web, os sites estão ficando cada vez mais dinâmicos, utilizando muitos recursos de AJAX, JavaScript e CSS. Essas mudanças melhoram muito a usabilidade na web, porém usuários de tecnologias assistivas correm risco de serem excluídos por conta das lacunas de acessibilidade. Como leitores de tela normalmente sofrem com JavaScript, surge uma nova maneira de criar interfaces dinâmicas que são acessíveis a mais usuários.

A maioria dos frameworks de JavaScript oferece ferramentas do lado do cliente que simulam o comportamento de interfaces desktop e mobile para se tornarem mais familiares, como *drag and drop*, menu hamburguer deslizante... Todos eles são criados nessa combinação de JavaScript, CSS e HTML. Só que, para criar tais elementos, às vezes é necessário recorrer a marcações mais genéricas do HTML, como `span`, `div`, que não representam corretamente seu significado (em determinados casos), e é nesses momentos em que é utilizado o ARIA.

Falamos anteriormente sobre o [significado da semântica no html](/html-semantico-1/), aqui no blog, caso queira se aprofundar mais no tema.

## Ampliando os significados

Com o surgimento do HTML5 as marcações de layout já ficaram mais ricas, marcando os artigos, navegações, dentre outros. O ARIA serve para estender ainda mais o significado dessas tags, não como os [microdados](/html-semantico-2/) que são bem úteis nessa função, mas com foco nas interações.

## WAI-ARIA, o que é ?

*Accessible Rich Internet Applications* ([ARIA](https://www.w3.org/WAI/intro/aria)) é uma iniciativa de acessibilidade (WAI - *Web Accessibility Initiative*) da [W3C](https://www.w3.org/) que fornece uma maneira de adicionar a semântica em falta em determinado elemento para tecnologias assistivas, como leitores de tela. Define formas de tornar o conteúdo da web (especialmente aqueles desenvolvidos com AJAX e JavaScript) mais acessível para pessoas que possuem algum tipo de deficiência. É um conjunto de atributos de acessibilidade especiais que podem ser adicionados a qualquer marcação, mas é especialmente adequado para HTML. O atributo `role` define qual o tipo geral de objeto (como um artigo, alerta ou controle deslizante). Outros atributos ARIA fornecem outras propriedades úteis, como uma descrição para um formulário ou o valor atual de uma barra de progresso.

## Regras importantes de acessibilidade

Existem cinco regras (por enquanto) para que seu código seja implementado de forma conceitualmente correta.
Dessa forma respeitaria todos os princípios de acessibilidade para atingir os mais diferentes usuários e suas tecnologias.

### Primeira: Priorize a semântica nativa
Se você puder inserir um elemento HTML que já possui o valor semântico correto nativamente, opte sempre por ele, evitando adicionar uma *role*, *state* ou *property* ARIA em um elemento mais genérico.

Exemplo ruim:
```html
<ul role="list">
    <li role="listitem">Item da lista</li>
    <li role="listitem">Item da lista</li>
    <li role="listitem">Item da lista</li>
</ul>
```

As tags nativas do HTML já nos dizem semanticamente que é uma lista, esses atributos (roles) estão fazendo um papel redundante.

### Segunda: substituir a semântica nativa somente quando for realmente necessário
Não mude a semântica nativa, a menos que você realmente precise. Essa segunda regra complementa a anterior.

Exemplo ruim:
```html
<span role="button">ok</span>
```
Não precisa mudar semanticamente o `span`, já que possuímos uma tag nativa que já faz esse papel

Exemplo bom:

```html
<label for="chk_btn">Botão</label>
<input type="checkbox" id="chk_btn">
```

Em um caso de [checkbox hack](https://css-tricks.com/the-checkbox-hack/), utilizamos a `label` como trigger de um `checkbox`, certo?

**Nota:** O checkbox hack é um dos casos que precisamos modificar a semântica nativa, pois ainda não encontramos uma forma similar de aplicar sua funcionalidade em algum elemento nativo do HTML. Fazemos uso dele pois precisamos de funcionalidades similares sem JavaScript.

Neste caso, o papel do `label` seria de um botão, para disparar a ação, então podemos modificar semanticamente este elemento para um botão.
```html
<label for="chk_btn" role="button">Botão</label>
<input type="checkbox" id="chk_btn">
```

### Terceira: Interação via teclado
Todos os controles interativos do ARIA devem ser utilizáveis via teclado.

Se você criar um *widget* que um usuário pode clicar, tocar, arrastar, soltar, deslizar ou deslocar, um usuário também deve ser capaz de navegar até o widget e executar uma ação equivalente usando o teclado.

Todos os widgets interativos devem ser preparados via script para responder as ações via teclado, quando possível.

Por exemplo, se estiver usando o `role="button"`, o elemento deve ser capaz de receber o foco e o usuário deve ser capaz de ativar a ação associada ao elemento usando a tecla **enter** (no Windows) ou o **retorno** (MAC OS) e a tecla de espaço.

### Quarta: Só omita os elementos que realmente não estejam disponíveis para o usuário  
Não use `aria-hidden="true"` se o elemento estiver visível. 

Isso é muito comum de ocorrer quando os estados são modificados via JavaScript.
Se o elemento estiver escondido, estando com `aria-hidden="true"`, e for ordenada a sua exibição, o atributo `aria-hidden` deverá ser setado para *false* imediatamente.

Exemplo:
```html
<!-- elemento visível -->
<button aria-hidden="true">Ok</button>
```

Fazendo isso, o elemento não terá seu valor semântico correto.

Ao invés disso, utilize `aria-hidden="false"` se estiver visível ou `aria-hidden="true"` quando não estiver visível.

**Nota:** Prefira utilizar nesse caso a propriedade `visibility: hidden` no CSS, pois, se utilizar o `display: none`, o elemento some da árvore de acessibilidade (Estrutura do navegador que roda em paralelo ao DOM com o objetivo de expor as informações de acessibilidade às tecnologias assistivas, como os leitores de tela) o que torna o `aria-hidden` desnecessário.


### Quinta: Nomes acessíveis entre os elementos
Todos os elementos que possuem interação, devem saber que interagem.

Em um formulário de contato, por exemplo, é necessário preencher o e-mail do usuário. Veja o código abaixo:
```html
E-mail <input type="text">
```
Ele possui uma informação visível "E-mail", porém não acessível.
Há também outra forma errônea de se aplicar:
```html
<label>E-mail</label>
<input type="text">
```
A informação ainda não está acessível, já que a `label` precisa "abraçar" o elemento input para que a informação "E-mail" seja correspondente ao `input`.
```html
<label>
    E-mail <input type="text">
</label>
```
Podemos também adicionar um atributo que vincule o `input` à informação que queremos.
```html
<label for="email">E-mail</label>
<input id="email" type="text">
```
Obedecendo esses conceitos, já é uma boa porta de entrada para preparar o seu código de forma mais acessível.

Acessando esse [diagrama](https://www.w3.org/TR/wai-aria/rdf_model.png), você consegue ter uma ideia das roles e suas propriedades e estados, de que falaremos mais pra frente.

É muito importante compreendermos as regras do WAI-ARIA para não nos perdermos no seu real conceito. O próximo post será focado nas roles do WAI-ARIA e suas categorias, exemplificando cada atributo.
Esta foi uma introdução de uma série de três posts sobre o tema, espero que tenham gostado.
