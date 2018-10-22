---
date: 2018-10-22
category: front-end
tags:
  - intersection-observer
  - API
authors: [alinelee]
layout: post
title: Intersection Observer API
description: Neste post, você aprenderá a utilizar ...
---

Nos ultimos meses nós conseguimos usufruir bastante da **Intersection Observer API** que está disponivel desde a versão 51.

Fizemos carregamento assincrono de imagens, paginação infinita, carrosséis entre outras ações na tela dependendo da visibilidade em que algum elemento possui. Conseguir fazer essas ações sem ter que ficar observando o scroll da tela é muito mais performático sem deixar o código complexo.

O que é, o que faz, pra que serve?

Através do **Intersection Observer API** nós podemos literalmente observar um certo elemento e disparar uma função quando ele cruzar a área visível da página. Assim podemos executar qualquer tipo de ação neste momento.

Vamos pensar em um carrossel de imagens, que conforme seja scrolado nós deixamos colorida a bolinha relativa a sua posição.

Exemplo aqui

Para fazer isso nós precisamos primero criar o *observer* que irá disparar o evento quando cada uma das imagens for exibida. Ou seja:

```js
var io = new IntersectionObserver( function(images) {
		images.forEach(function(image) {
			if (image.isIntersecting) {
				console.log(image);
			}
		});
	}
);
```

Aqui na variável *image* é possivel utilizar algumas informações interessantes, como:

- boundingClientRect: Retorna o mesmo que o getBoundingClientRect() do elemento;
- intersectionRatio: 1
- intersectionRect: ?? o msm do getBoundingClientRect ...;
- isIntersecting: true quando o item está visível;
- rootBounds:
- target: o elemento responsável pelo disparo do evento;
- time: ?? o tempo de cada uma das chamadas


Depois precisamos selecionar e fazer com que cada uma das imagens sejam observadas:

```js
var images = document.querySelectorAll('.carousel .image');

images.forEach(function(image) {
	io.observe(image);
});

```

Desta maneira assim que a **borda** de cada um dos items observados ficar visível a função será executada, porém existem momentos em que o ideal é que a função seja chamada antes da imagem ser exibida, ou apenas quando ela estiver com a sua metade visível. Para isso temos algumas configurações disponíveis:

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

- root: Conseguimos definir o container dos elementos para o observer utilizar como referência;

- rootMargin: Conseguimos definir uma margin no elemento para conseguir disparar com antecedencia ou após o inicio da intersecção;

- threshold: Permite determinar em qual porcentagem de visibilidade do elemento o evento será disparado. O padrão é 0, caso o ideal seja executar a função com a metada da imagem vísivel  seria 0,5.

Assim com essa

//TODO Polyfill
