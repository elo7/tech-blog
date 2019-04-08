---
title: Front-End - Coisas de que nós nos orgulhamos em 2018!
date: 2019-04-08
category: front-end
layout: post
description: "Nunca é tarde para falar de coisa boa! Nesse post, vamos mostrar tudo que marcou o nosso ano de 2018 quanto a tecnologias de front :)"
authors: [fernandabernardo]
tags:
  - javascript
  - css
  - grid
  - intersection observer
  - schema
  - non-interaction
  - linters
  - etag
cover: retrospectiva-2018.jpg
---

Antes tarde do que nunca! Já acabamos o primeiro trimestre de 2019, mas ainda dá tempo de falar sobre o que fizemos aqui no Elo7 no time de front end. E nesse post vou falar melhor sobre quais foram cada um deles.

## Intersection Observer
Começamos a usar bastante a API do *Intersection Observer*, principalmente nos nossos carrosséis de imagens ao longo do site.

![""](../images/front-end-coisas-que-nos-nos-orgulhamos-em-2018-1.gif)

A [@alinelee](/autor/alinelee) fez um post só sobre ele [aqui](/intersection-observer), mas para resumir, com ele, você consegue observar um determinado elemento, que te avisa sempre que este aparece na área visível da página. Uma das grandes vantagens dele, é não precisar observar sempre o scroll da página, trazendo um ganho de performance. Quanto a compatibilidade, alguns browsers e versões ainda não estão compatíveis. Para resolver esse problema, aqui usamos esse [polyfill](https://github.com/w3c/IntersectionObserver/tree/master/polyfill).

![""](../images/front-end-coisas-que-nos-nos-orgulhamos-em-2018-2.png)

## CSS Grid Layout
Uma "novidade" do CSS, o *Grid Layout* veio fazendo sucesso desde quando as primeiras specs surgiram. Mas tivemos que esperar um pouco para usá-lo, por conta da sua compatibilidade com diferentes browsers.

![""](../images/front-end-coisas-que-nos-nos-orgulhamos-em-2018-3.png)

Depois de alguns testes e tentativas, e também na melhora das compatibilidades, conseguimos finalmente colocar o *Grid Layout* no site, e em uma situação não tão convencional. Por convencional, digo a estrutura clássica de cards, que inclusive usamos em uma outra situação que falarei já já. Mas nessa primeira situação, queríamos separar esses componentes em 3 colunas, e queríamos deixar o layout bem flexível.

![""](../images/front-end-coisas-que-nos-nos-orgulhamos-em-2018-4.png)

O `display: flex` até resolveria, mas seria bem mais complexo de resolver. Nesse caso, o código ficou assim:

```css
footer {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
}
```

E no elemento de "Enviar", nós só posicionamos ele no lugar correto, com:

```css
.share {
    grid-column-start: 3;
}
```

Se quiser saber mais sobre o *Grid Layout*, tem tudo na [documentação da MDN](https://developer.mozilla.org/pt-BR/docs/Web/CSS/CSS_Grid_Layout/Basic_Concepts_of_Grid_Layout)

Um outro caso que usamos, o mais convencional, foi para separar cada um dos cards de produto. E nesse caso, além da facilidade, também decidimos por usá-lo para alinhar melhor a nossa comunicação com o time de design, que já está bem acostumado a falar na "linguagem dos grids".

![""](../images/front-end-coisas-que-nos-nos-orgulhamos-em-2018-5.png)

## Schema Json
É bem importante o uso dos dados estruturados para melhorar o SEO da sua página, e a indexação do Google. Mas existem algumas formas de fazer isso, mas aqui vou falar apenas de duas: **microdados** e **JSON-LD**. Usávamos a estrutura de microdados por aqui, mas por recomendação do próprio Google, migramos para o *JSON-LD*.

Os *microdados*, são uma especificação do *HTML*, e as informações do *schema* são colocadas no meio do *HTML* visível para o usuário. Já no *JSON-LD*, as informações ficam em uma tag `<script>`.

Você pode conhecer mais sobre essas estruturas no [site do Google](https://developers.google.com/search/docs/guides/intro-structured-data?hl=pt-br) e testar qualquer página ou código [online](https://search.google.com/structured-data/testing-tool?hl=pt-br).

## Linters
Sempre queremos padronizar nossos códigos de forma automatizada, e nada melhor para isso do que usar *linters*.

Hoje usamos dois tipos de linters, o [stylelint](https://www.npmjs.com/package/stylelint) e o [eslint](https://eslint.org/), e sempre rodamos eles junto com os testes antes de cada commit. Mas o uso de lints sempre é recomendado?

Bom... descobrimos que em algumas situações eles mais atrapalham do que ajudam. Foi o caso do [htmllint](https://www.npmjs.com/package/htmllint-cli), que removemos depois de um tempo. Isso aconteceu porque usamos o [Dust.js](http://www.dustjs.com/) e isso acabava confundindo o *lint* que estava preparado para funcionar com HTML puro. E o que acontecia, é que tínhamos que ficar sempre adaptando, criando hacks, e "burlando" o lint para funcionar corretamente. Até que percebemos que ele não estava verificando o que queríamos de fato e estava atrapalhando o nosso desenvolvimento. Por esse motivo, decidimos removê-lo.

Mas isso significa que todo lint não funciona? Claro que não! Para nós, o que funcionou melhor e bem foram os *linters* de CSS e JS, e continuam funcionando bem até hoje. Vale a pena testar e ver se adequa ao seu ambiente de desenvolvimento.

## Etag
Cache é algo sempre complicado de desenvolver e que se não feito da forma correta, pode não atualizar modificações mais recentes ou sempre atualizar tudo. Um dos mecanismos do *HTTP* para lidar com o cache, é o uso do **Etag**. Esse tipo de *header* faz uma validação condicional do cache. Enquanto não houver alteração no conteúdo do arquivo, o valor do *Etag* continua o mesmo e fica cacheado.

Nós começamos a utilizar esse tipo de *header* para mlehorar o cache dos nossos arquivos e conseguir otimizar a performance. Nesse método, o próprio navegador faz as verificações dos valores do *Etag* e decide o que fazer.


## Non-interaction
No *Google Analytics*, uma forma de aperfeiçoar ainda mais os eventos e ter métricas mais precisas é com o uso do **non-interaction**. Quando temos casos de eventos que são enviados para o *Analytics* não tem nenhum tipo de interação, são apenas enviados quando o usuário vê alguma parte do site, normalmente essa métrica é contabilizada para as métricas de rejeição. Quando adicionamos o atributo `non-interaction`, essas métricas deixam de ser contabilizadas, porque o usuário não teve uma interação com a página de fato.

Para conhecer mais, veja a [documentação do Google Analytics :)](https://developers.google.com/analytics/devguides/collection/analyticsjs/events?hl=pt).

## Conclusão
Essas foram as principais tecnologias que marcaram o nosso 2018, todas elas ainda estamos incrementando cada vez mais, e estamos trazendo cada vez mais tecnologias para fazer parte do nosso trabalho! O que você tem usado no seu front de interessante ou estão estudando? Compartilhe conosco ;D
