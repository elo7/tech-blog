---
title: Javascript Isomórfico - parte 2
date: 2017-07-10
category: front-end
layout: post
description: Continuando com a série de posts sobre javascript isomórfico, agora falando um pouco mais sobre frameworks e onde usá-los.
authors: [fernandabernardo]
tags:
  - javascript
  - isomorfico
---

Continuando o post sobre [Javascript isomórfico](/isomorfismo), depois de explicar toda a história e o conceito de isomorfismo, vamos entrar em uma parte mais prática. Quais empresas usam, o resultado da implementação e alguns frameworks existentes no mercado serão alguns dos tópicos deste post.

# Quem usa?
Algumas empresas como [Airbnb](https://www.airbnb.com.br/), [Facebook](https://www.facebook.com/), [PayPal](https://www.paypal.com/br/), [Walmart](https://www.walmart.com.br/), [Netflix](https://www.netflix.com/br/), [Autodesk](https://www.autodesk.com.br/), além do próprio [Elo7](https://www.elo7.com.br/).

# Como tudo começou?
Em 2011, Charlie Robbins, da Nodejitsu, escreveu [um post apresentando a arquitetura isomórfica](https://blog.nodejitsu.com/scaling-isomorphic-javascript-code/). Porém, teve uma adoção bem lenta, além de ter várias discussões a respeito do nome *isomórfico*.

Recomendo a leitura desses outros dois posts contando [sobre a implementação da arquitetura isomórfica no Airbnb](http://nerds.airbnb.com/isomorphic-javascript-future-web-apps/) e [na Netflix](http://techblog.netflix.com/2015/08/making-netflixcom-faster.html). O Airbnb reconstruiu todo seu site mobile para melhorar o tempo de carregamento da página e melhorar a usabilidade para o usuário. Com isso, lançaram sua própria biblioteca isomórfica, o [Rendr](http://rendrjs.github.io/) (falarei dele mais para frente). Já o Netflix trocou sua estrutura feita em Java, Struts e Tiles, no back-end, e Javascript (com jQuery), no front-end, por uma estrutura só com React. Isso rendeu uma melhora de 70% no TTI (*Time to Interact*).

No Elo7 temos um servidor de componentes que funciona da seguinte forma: quando um usuário entra em uma página, é feita uma requisição ao marketplace; o marketplace faz um `POST` com um JSON para o servidor de componentes; o servidor de componentes junta o JSON dos dados com o template e retorna o HTML compilado para o marketplace, que retorna a página em HTML ao cliente.

![Fluxo da primeira requisição](/images/isomorfismo-parte-2-1.png)

Após o carregamento da página, são feitas novas requisições para carregar os componentes. Esses, por sua vez, se dividem, fazendo uma requisição ao marketplace para pegar o JSON e outra para o servidor de componentes para conseguir um template do componente. Com isso, o cliente tem o JSON e o template e consegue assim fazer a renderização da página. Essa é a nossa arquitetura isomórfica, na qual utilizamos o [Dust.js](http://www.dustjs.com/) como engine de templates.

![Fluxo após o carregamento da página](/images/isomorfismo-parte-2-2.png)


# Fatos sobre isomorfismo
Falar sobre prós e contras é um pouco complicado, já que depende muito do objetivo da aplicação. Logo, vou falar sobre fatos do uso do isomorfismo que percebi ao longo do meu estudo e o que vários posts sobre o assunto comentavam:
* Menos duplicação de código, mais fácil de dar manutenção;
* Menos tempo gasto para escrever código no servidor e no cliente;
* Cuidado para levar em conta onde o código será executado;
* Primeiro request é rápido e os outros ainda mais;
* Mais simples de funcionar sem JS, servidor consegue retornar o HTML;
* Debug é mais complicado, já que temos um código que funciona no cliente e no servidor;
* Cautela para não expor dados sensíveis. Não podemos expor dados que colocaríamos apenas no back-end, como chaves de acesso por exemplo;
* Os frameworks mudam muito rápido e quebram rápido também;
* Se sua página não tiver muita atualização dinâmica, você irá implementar muito código para pouco benefício.

# Frameworks e Bibliotecas
Vou colocar aqui os links dos frameworks e bibliotecas mais conhecidas e vou entrar em detalhes de apenas algumas. Segue a lista:
* [Meteor](https://www.meteor.com/)
* [Rendr](http://rendrjs.github.io/)
* [Catberry](http://catberry.org/)
* [Ezel](http://ezeljs.com/)
* [React](https://facebook.github.io/react/)
* [Dust.js](http://www.dustjs.com/)
* [Derby](http://derbyjs.com/)
* [Taunus](https://github.com/taunus/taunus)
* [Lazojs](https://github.com/lazojs/lazo)
* [Mithril](http://mithril.js.org/)
* entre muitos outros ...

# Mojito
Não coloquei o [Mojito](https://github.com/yahoo/mojito) na lista acima pelo fato da última versão estar com o *build* quebrado e o último *commit* ser de 2014. Mas acredito que vale a pena comentar sobre ele, já que foi a primeira biblioteca isomórfica *open source*, desenvolvida em abril de 2012, pelo Yahoo.

# Meteor
O Meteor já tem um conceito um pouco diferente dos outros que falarei aqui. É uma plataforma *open source* usada para desenvolver aplicações web e mobile e também é *fullstack*, ou seja, apresenta soluções desde o back-end (como banco de dados, por exemplo) até o front-end. Listarei algumas características que percebi ao usá-lo para desenvolver uma aplicação básica, que pode ser encontrada nesse [repositório com um projeto simples de `To Do` usando o Meteor](https://github.com/FernandaBernardo/meteor-simple-todos).
* O desenvolvimento é em tempo real. Ou seja, em qualquer mudança no banco de dados ou em qualquer arquivo, os componentes são atualizados em tempo real;
* A parte de configurações é bem simples. Não é necessário configurar dependências (como o Gulp). Além disso, já vem com [EcmaScript6](http://es6-features.org/) e [MongoDB](https://www.mongodb.com/) funcionando;
* Um projeto bem básico, como um *Hello World*, por exemplo, é muito pesado. Possui mais de 50 scripts importados, sem que esteja usando nenhum no projeto;
* A página da aplicação não funciona com o Javascript desabilitado;
* A documentação é bem explicada e torna fácil o aprendizado;
* Possui muitos componentes prontos e é fácil criar novos componentes.

# React
O [React](https://facebook.github.io/react/), biblioteca desenvolvida pelo Facebook, é uma linguagem de templates que é utilizada para renderizar HTML, ou seja, só está presente na parte da *view*. Pelo fato de estar presente apenas na *view*, não pode ser comparado diretamente com outros frameworks como Meteor, Angular, Backbone, Ember, que são utilizados na aplicação como um todo.
No React, é usado [a linguagem JSX](https://jsx.github.io/), em que todo o código HTML é escrito no meio do código Javascript. Logo, no caso, não existem arquivos `.html`, existem somente `.js`. E um problema (ou não) do React é que ele não dá suporte, e nem pretende, ao Internet Explorer 8 e mais antigos.

# Marko
Passando rapidamente pelo [Marko](https://github.com/marko-js/marko), ele é uma linguagem de template desenvolvida pelo Ebay. Ela é conhecida por ser uma das mais rápidas linguagens de template. Diferente do React, ela tenta fazer o HTML ser mais parecido com o Javascript. Existem alguns *benchmarks* [comparando o Marko com outras linguagens](https://github.com/marko-js/templating-benchmarks) e um específico [comparando ele com React](https://github.com/patrick-steele-idem/marko-vs-react).

# Support Libs
Para finalizar, acredito que não poderia falar de isomorfismo sem falar das bibliotecas que permitem ele ser possível. Uma delas é o [browserify](http://browserify.org/), que permite ao *browser* suportar o *require*. Outra bem famosa é o [webpack](https://webpack.github.io/), que transforma módulos com dependências em *assets* estáticos. Quando se trata de Javascript isomórfico, essas duas bibliotecas geralmente aparecem, então é bom saber que elas existem e onde são utilizadas, como por exemplo no projeto [CommonJs](http://www.commonjs.org/). Outro exemplo, é o React, que está preparado para ser usado com essas duas bibliotecas.

Aqui finalizamos nossos posts sobre isomorfismo, sabendo um pouco mais das bibliotecas que existem e como as empresas usam em seus projetos. Qualquer dúvida, só perguntar ;D
