---
date: 2020-12-14
category: front-end
tags:
  - front-end
  - acessibilidade
  - html
  - css
authors: [ricardokojo]
layout: post
title: Complementando elementos textuais para leitores de tela
description: Entenda como complementar o texto de seu site para melhorar a experiência de usuários de leitores de tela.
---
Ao digitar o conteúdo de nossas páginas web, muitas vezes utilizamos siglas, abreviações e outros elementos visuais que são triviais para usuários videntes, mas que não conseguem ser interpretadas corretamente por leitores de tela (_screen readers_). Assim, a acessibildade do site fica prejudicada.

Recentemente, aqui no Elo7, enfrentamos o seguinte problema: **como fazer com que nossos _cards_ de produtos sejam lidos da forma esperada por leitores de tela?** Por exemplo, tendo um preço com fonte menor e tachada, e outro com fonte maior, é possível entender que o primeiro é o preço original, enquanto o segundo é o promocional. No entanto, um leitor de tela lê os dois preços da mesma forma, sem distinção. No caso de parcelamento, interpretamos o texto `"12x sem juros"` como `"doze vezes sem juros"`, enquanto um leitor de tela lê `"12 xis sem juros"`.

Neste _post_, veremos exemplos (visuais e com áudios de leituras de tela) dos problemas citados e como resolvê-los usando apenas atributos [ARIA (link externo)](https://developer.mozilla.org/pt-BR/docs/Web/Accessibility/ARIA) do HTML e um pouquinho de CSS!

## Entendendo melhor o problema

Vale notar que este problema ocorre pelo fato de usarmos **elementos puramente textuais**. No caso de **elementos não-textuais**, como imagens e ícones, conseguimos usar atributos HTML como `alt` e `aria-label` para descrever seus conteúdos. Para _tags_ textuais como `<p>` e `<h1>`, o leitor de telas dá preferência para o texto visível. Logo, caso uma _tag_ textual possua `aria-label`, o leitor ignora e lê apenas o conteúdo da _tag_.

Também é importante saber que **não há um padrão de implementação dos _screen readers_**. Nos exemplos a seguir, usamos o [NVDA (link externo, em inglês)](https://www.nvaccess.org/) versão 2020.3 no Windows 10. Assim, caso você use outro leitor ou sistema operacional, há possibilidade de se obter outros resultados.

## Exemplificando

No CodePen a seguir, está um exemplo de _card_ de produto - parecido com o de nosso site, com algumas adaptações - que contém os problemas descritos na introdução deste artigo:

<p class="codepen" data-height="500" data-theme-id="dark" data-default-tab="css,result" data-user="ricardokojo" data-slug-hash="qBNvpzz" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;" data-pen-title="Exemplo: card com aria-labels para tags &amp;lt;p&amp;gt;">
  <span>See the Pen <a href="https://codepen.io/ricardokojo/pen/qBNvpzz">
  Exemplo: card com aria-labels para tags &lt;p&gt;</a> by Ricardo Hideki Hangai Kojo (<a href="https://codepen.io/ricardokojo">@ricardokojo</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>

O exemplo acima é fictício, então não se assuste com o preço! Preste atenção no HTML. Note que temos `aria-labels` mais descritivos nos elementos do _card_.

Agora, no áudio a seguir temos a leitura deste componente feita via NVDA:

<audio controls src="../audios/a11y-complementando-elementos-textuais-para-leitores-de-tela-1.mp3"></audio>

> _Transcrição do áudio_: "Frame. Figura. Origami Tsuru Colorido (Um unid). Sessenta reais, quarenta e oito reais, doze xis sem juros de quatro reais, quê tê dê min dez, frete grátis, legenda."

**Confuso, não?** Como foi dito anteriormente, o preço original e o promocional são lidos sequencialmente, sem diferenciação. Além disso, tanto a leitura do parcelamento quanto da quantidade mínima não ficaram claras. Isso se agrava se levarmos em conta que aqueles que utilizam _screen readers_ configuram a leitura para algo **muito** mais rápido do que o exemplo acima.

E agora, o que fazer?

## Resolvendo o problema

O [Wordpress criou uma solução para este problema usando CSS (link externo, em inglês)](https://make.wordpress.org/accessibility/handbook/markup/the-css-class-screen-reader-text/) - e não se preocupe pois ela não funciona exclusivamente com Wordpress!

Basta usarmos esta classe:

```css
.screen-reader-text {
  border: 0;
  clip: rect(1px, 1px, 1px, 1px);
  clip-path: inset(50%);
  height: 1px;
  margin: -1px;
  overflow: hidden;
  padding: 0;
  position: absolute;
  width: 1px;
  word-wrap: normal !important;
}
```

Vamos adaptar o conteúdo do primeiro CodePen e adicionar esta classe para nos ajudar com a leitura de nosso _card_:

<p class="codepen" data-height="500" data-theme-id="dark" data-default-tab="css,result" data-user="ricardokojo" data-slug-hash="pobYVwP" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;" data-pen-title="Exemplo: card com classe .screen-reader-text">
  <span>See the Pen <a href="https://codepen.io/ricardokojo/pen/pobYVwP">
  Exemplo: card com classe .screen-reader-text</a> by Ricardo Hideki Hangai Kojo (<a href="https://codepen.io/ricardokojo">@ricardokojo</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>

Podemos ver que visualmente o _card_ continua o mesmo, mas notamos que há o uso da classe CSS `.screen-reader-text` juntamente com _tags_ `<span>`. Há duas abordagens diferentes nesta solução:

- no caso de descrições que complementam o que está na tela, como `De R$ 60,00` e `Por R$ 48,00`, adicionamos um `<span>` no meio do parágrafo.
- por outro lado, quando a descrição é muito diferente do texto visível, usamos o atributo `aria-hidden='true'` nas tags `<p>` (que "esconde" o elemento do leitor de tela, fazendo com que ele o ignore) e adicionamos o texto mais descritivo diretamente num `<span>`, como em `<span class='screen-reader-text'>em até 12 vezes de R$ 4,00 sem juros. </span>`.

Assim, segue a nova leitura feita pelo NVDA:

<audio controls src="../audios/a11y-complementando-elementos-textuais-para-leitores-de-tela-2.mp3"></audio>

> _Transcrição do áudio_: "Frame. Figura. Origami Tsuru Colorido (Um unid). De sessenta reais por quarenta e oito reais, em até doze vezes de quatro reais sem juros. Quantidade mínima: dez. Frete grátis. Legenda."

**Bem melhor agora!** A descrição feita é mais inteligível e possui breves pausas entre os diferentes conteúdos do _card_ (note a pontuação utilizada nas descrições, elas fazem diferença na leitura!).

## Entendendo a solução

A solução foi bem simples, mas por quê `margin` negativa? Qual a necessidade do `clip` e do `clip-path`? O artigo do WordPress mencionado no início da seção anterior explica melhor tudo isso, mas se você tem dificuldades com inglês, segue aqui uma tradução:

> - O valor `width` e `height` é `1px` pois alguns leitores de tela não leem elementos de tamanho `0px`;
> - `margin: -1px;` esconde o elemento completamente;
> - `word-wrap: normal;` evita que o leitor de tela leia um texto letra por letra, dado que o texto está contido num espaço de apenas 1 pixel. Muitas combinações de leitores de tela e browsers leem palavras quebradas da forma como elas são dispostas visualmente;
> - `clip` está depreciado, mas foi adicionado para manter suporte a browsers mais antigos que ainda não suportam `clip-path`.
>
> Nota: `display: none;` e `visibility: hidden;` escondem o texto da tela, mas também o escondem dos leitores de tela. Assim, estes atributos não podem ser utilizados para dar descrições adicionais a usuários de _screen readers_.

Ressalto que a classe disponibilizada pelo WordPress tem como objetivo funcionar no máximo de combinações browser-leitor de tela. Caso esta não seja sua situação, algo do como:

```css
.visually-hidden {
  clip: rect(0.1rem, 0.1rem, 0.1rem, 0.1rem);
  height: 0.1rem;
  overflow: hidden;
  position: absolute !important;
  width: 0.1rem;
}
```

Também funciona. E vale lembrar que você pode alterar o nome da classe para o que achar que faz mais sentido!

Eai, o que achou? Já tinha ouvido um leitor de tela antes? Este post te ajudou a resolver seu problema? Conhece outra solução? Deixe nos comentários!

Obrigado por ler meu primeiro post no blog :) Espero escrever mais em breve!
