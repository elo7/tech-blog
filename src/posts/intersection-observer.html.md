---
date: 2018-11-05
category: front-end
tags:
  - intersection-observer
  - API
authors: [alinelee]
layout: post
title: Intersection Observer API
description: Conheça a *Intersetion Observer API* e saiba como nós à aplicamos aqui no Elo7.
---

Nos ultimos meses nós conseguimos usufruir bastante da **Intersection Observer API** que está disponivel desde a versão 51 do Chrome.

Fizemos carregamento assincrono de imagens, paginação infinita, carrosséis entre outras ações na tela dependendo da visibilidade em que algum elemento possui.

## O que é, o que faz, pra que serve?

O **Intersection Observer** é uma **API** que atua como uma sentinela que irá te avisar sempre que certo elemento passar a ficar dentro da área visível da página.

Assim é possível executar qualquer tipo de ação sem ter que ficar observando o scroll da tela. Ganhando bastante performance sem deixar o código complexo.


## Um exemplo simples

Vamos pensar em um carrossel de imagens, que conforme seja scrolado nós deixamos colorida a bolinha relativa a sua posição.

<!-- Exemplo aqui -->

Para fazer isso nós precisamos primero criar o *observer* que irá disparar um evento quando cada uma das imagens for exibida. Ou seja:

```js
var io = new IntersectionObserver( function(images) {
		images.forEach(function(entryImage) {
			if (entryImage.isIntersecting) {
				console.log(entryImage);
			}
		});
	}
);
```

Utilizando o *entryImage* nós conseguimos recuperar o elemento, verificar se está visível, suas dimensões. Para mais detalhes sobre o *entryImage* consulte a [documentação aqui]( https://developer.mozilla.org/en-US/docs/Web/API/IntersectionObserverEntry).


Depois precisamos selecionar e fazer com que cada uma das imagens sejam observadas:

```js
var images = document.querySelectorAll('.carousel .image');

images.forEach(function(image) {
	io.observe(image);
});

```

Desta maneira assim que a **borda** de cada um dos items observados ficar visível a função será executada, porém existem momentos em que o ideal é que a função seja chamada antes da imagem ser exibida, ou apenas quando ela estiver com a sua metade visível.

Para isso temos algumas configurações disponíveis:

```js
var io = new IntersectionObserver( function(images) {
		images.forEach(function(image) {
			if (item.isIntersecting) {
				console.log(image);
			}
		});
	}, {
		root: document.querySelector('.carousel'),
		rootMargin: '0px',
		threshold: 0.5
	}
);
```

- rootMargin: Conseguimos definir uma margin no elemento para conseguir disparar com antecedencia ou após o inicio da intersecção;

- threshold: Permite determinar em qual porcentagem de visibilidade do elemento o evento será disparado. O padrão é 0, caso o ideal seja executar a função com a metada da imagem vísivel  seria 0,5.

Outra configuração interessante é o *root*, que permite definir um container para os elementos que não seja a página toda.


## Polyfill

Infelizmente por ser relativamente recente, a *API* não possui um suporte muito abrangente.

Aqui no Elo7, nós utilizamos esse [Polyfill](https://github.com/w3c/IntersectionObserver/tree/master/polyfill). Você pode checar [aqui](https://caniuse.com/#feat=intersectionobserver) se o suporte atual é suficiente para a sua aplicação.

## Conclusão

Esse post foi um apanhado geral sobre como nós utilizamos o *Intersetion Observer API* nos últimos tempos no Elo7, para se aprofundar mais no assunto você pode consultar a [documentação completa](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API), ou esse [artigo](https://developers.google.com/web/updates/2016/04/intersectionobserver) bem interessante do Google.

Se você ficou com alguma dúvida, ou quer compartilhar a sua experiencia com a *API* fique à vontade para utilizar a caixa de comentários. Obrigada e até a próxima!
