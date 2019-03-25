---
title:
date: 2018-03-14
category: front-end
layout: post
description:
authors: [williammizuta]
tags:
  - travis ci
  - integracao continua
  - npm
---

![Alt "Travis CI"](/images/travis-npm-ci-1.png)

A equipe do _npm_ acaba de anunciar um novo comando para baixar as dependências de um projeto: o <a href="http://blog.npmjs.org/post/171556855892/introducing-npm-ci-for-faster-more-reliable" target="_blank" rel="noopener">npm ci</a>. Segundo eles, este novo comando traz um ganho significativo tanto em performance quanto em confiabilidade para os builds em processos de integração continua/deploy continuo.

Essa melhora foi possível com a utilização do arquivo _package-lock.json_ para definir as dependências que serão baixadas. Se alguma dependência nesse arquivo não for compatível com o escrito no _package.json_, o comando retornará um erro ao invés de atualizar o comando _package-lock.json_.

E para ver o resultado desse novo comando, vou usar no processo de integração contínua deste blog.

## Utilizando npm ci no travis-ci


## Npm ci x npm install


## Conclusão
