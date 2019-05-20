---
date: 2019-03-11
category: front-end
tags:
  - css-scroll-snap
  - CSS
  - scroll
authors: [alinelee]
layout: post
title:
description:
cover: intersection-observer.png
---

Há algum tempo eu escrevi um post falando sobre o IntersectionObserver e como utiliza-lo para enriquecer um carrossel de fotos, você pode [ler ele aqui](https://elo7.dev/intersection-observer/). Mas ficou faltando uma funcionalidade muito utilizada em carrosséis, o scroll que ajusta as imagens na tela, mostrando ao usuário sempre a imagem posicionada centralizada certinha.

Para conseguir esse efeito existe um modulo em CSS chamado [CSS Scroll Snap](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Scroll_Snap) que facilita e muito a implementação deixando a transição de imagens bem fluída e bonita.

Nesse post eu vou mostrar um caso de uso do ScrollSnap complementando o carrossel ;)

## Funcionamento Básico

Apenas duas propriedades são necessárias para o funcionamento básico, e que neste caso já é o suficiente para o exemplo:

`scroll-snap-type` - Utilizado no container das imagens, essa propriedade é responsável por configurar o comportamento do scroll.

Possíveis valores chave:
- scroll-snap-type: none;
- scroll-snap-type: x;
- scroll-snap-type: y;
- scroll-snap-type: block;
- scroll-snap-type: inline;
- scroll-snap-type: both;

Aos valores chave, opcionalmente podemos incluir o `mandatory` ou `proximity`.

[exemplo mandatory x proximity]

No nosso caso como o scroll é no eixo `X` e o comportamento desejado é que as margens das imagens fiquem `sempre` presas às margens da tela iremos utilizar o `scroll-snap-type: x mandatory;`.

`scroll-snap-align` - Propriedade usada nos itens e determina o alinhamento relativo ao container scrollado.

O valores são parecidos com um alinhamento simples:

- scroll-snap-align: none;
- scroll-snap-align: start end;
- scroll-snap-align: center;
- scroll-snap-align: inherit;
- scroll-snap-align: initial;
- scroll-snap-align: unset;

Quando o container é menor que seus filhos e o alinhamento é o `start end` as imagens vão se alinhar dependendo da proximidade com o inicio e o fim.

Neste caso vamos utilizar a propriedade `scroll-snap-align: center` como podemos ver no `css`:

```css
.carousel {
  display: flex;
  overflow: auto;
  max-width: 400px;
  margin-left: auto;
  margin-right: auto;
  border: solid 1px #dad5d5;
  border-radius: 3px;
  padding: 0;

  scroll-snap-type: x mandatory;
}

.carousel li {
  display: flex;
  min-width: 400px;
  background-color: #e5e5e5;
  justify-content: center;

  scroll-snap-align: start end;
}
```

## Indo além do básico

scroll-padding

scroll-snap-stop

exemplo de carrossel com 2 imagens lado a lado

## Conclusão

O scroll da página é algo básico mas extremamente importante, quando mal implementado ele pode estragar totalmente a experiência do usuário.

Utilizar o `ScrollSnap` garante uma solução simples e nativa, que evita malabarismos no código e proporciona uma experiência muito fluida para o usuário.

Para se aprofundar mais no assunto você pode consultar a [documentação completa](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Scroll_Snap).

Se você ficou com alguma dúvida, ou quer compartilhar a sua experiência fique à vontade para utilizar a caixa de comentários. Obrigada e até a próxima!
