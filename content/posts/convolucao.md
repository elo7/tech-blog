---
date: 2018-01-15
category: machine-learning
tags:
  - data science
  - machine learning
  - processamento de imagens
authors: [abarbosa94, igorbonadio]
layout: post
title: "Princípios de Processamento de Imagens: Uma introdução à Convolução"
description: Apresentaremos uma técnica chamada convolução, que é base de diversos algoritmos de processamento de imagens.
---

Quando trabalhamos com processamento de imagens, existem diferentes algoritmos que podemos utilizar dependendo do objetivo que queremos atingir. Alguns exemplos conhecidos podem ser vistos logo abaixo:

![Exemplos](/images/convolucao-1.png)

Dentro da área de processamento de imagem, uma das técnicas mais difundidas para solucionar esses problemas é a **Convolução**.

A convolução tem raizes na [matemática](https://en.wikipedia.org/wiki/Convolution), e pode ser contínua (que é usada em processamento de sinais, por exemplo) ou discreta (que é usada em processamento de imagens).

Antes de tudo, uma coisa que podemos perceber é que, quando o computador "enxerga" uma imagem, ele não vê nada além de números (no caso, matrizes):

![Imagem Real](/images/convolucao-2.png)

A Convolução, então, envolve a aplicação de um *kernel* sobre uma imagem, gerando uma nova imagem como resultado. O *kernel* também é uma matriz e, na prática, ele "desliza" sobre toda a imagem, modificando-a. Para um dado deslocamento, os elementos do *kernel* são multiplicados pelos pixels da imagem, que, por fim, são somados e resultam em um elemento da imagem convolucionada:

![Convolução](/images/convolucao-3.png)

Mas como calculamos os valores dos pixels das bordas da imagem? Existem basicamente duas opções:


* Criar pixels "artificiais" ao redor da imagem

Esses pixels extras podem ser escolhidos arbitrariamente ou podem ser estimados a partir dos pixels existentes nas suas vizinhanças (como média, valor máximo, valor mínimo etc.).

![Convolução](/images/convolucao-4.png)

* Ignorar as bordas

Neste caso, a imagem resultante será menor do que a imagem de entrada, como podemos ver na figura abaixo:

![Convolução](/images/convolucao-5.png)

## Exemplos

A seguir temos alguns *kernels* tradicionalmente utilizados para:

![Convolução](/images/convolucao-6.png)


Esses exemplos foram gerados com base no seguinte [jupyter notebook](https://github.com/igorbonadio/Convolution). Sinta-se à vontade para clonar e tentar outros kernels por conta própria :)

## Algumas observações

Outro nome pelo qual o *kernel* também é conhecido é *filtro* já que ele, justamente, "filtra" a imagem ao passar por ela.

## Conclusão

Vimos que o uso de convoluções tem diversas aplicações em processamento de imagens. Vimos também que esta técnica pode ser utilizada para pré processar uma imagem e facilitar tarefas futuras como a detecção de objetos.

Mas até agora só utilizamos *kernels* estáticos e pré-definidos no momento da aplicação da convolução. Será que existe um *kernel* que funciona melhor para identificar texto em documentos escaneados? Ou para diferenciar gatos de cachorros em uma fotografia? Seria interessante se pudéssemos definir um método que "aprendesse" o melhor *kernel* (ou melhores *kernels*) para uma determinada tarefa! A parte boa é que isso é possível: **Redes Neurais Convolucionais**! Mas isso fica para outro post.


