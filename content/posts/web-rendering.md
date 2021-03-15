---
date: 2021-03-15
category: front-end
tags:
  - javascript
  - html
  - css
authors: [jeeanribeiro]
title: Renderização na Web
description: Existem diferentes técnicas de renderização na web, saber escolher a que melhor se aplica à sua aplicação pode fazer você aumentar performance, economizar recursos e melhorar o ranking em mecanismos de busca. Desde renderização no servidor até reidratação completa, vamos abordar cada conceito com comparações e exemplos.
---
Compreender a forma que sua aplicação é renderizada no navegador é fundamental para otimizar a experiência do usuário e potencializar o alcance da mesma.

## Terminologias de performance
Quando usamos ferramentas de diagnóstico de performance do nosso site, vemos que há quatro métricas principais e uma técnica otimizada:
- **TTFB**: Time to First Byte - tempo de acessar uma URL e receber o primeiro pedacinho de conteúdo.
- **FP**: First Paint - o tempo que leva para aparecer o primeiro pixel na tela para o usuário.
- **FCP**: First Contentful Paint - tempo quando o conteúdo requisitado se torna visível.
- **TTI**: Time To Interactive - tempo que leva para a página ficar interativa.
- **Streaming**: enviar resposta fragmentada, conforme vai sendo gerada, em vez de enviá-la somente quando o processamento estiver completo.

A performance do seu site pode ser metrificada de forma fácil com o [PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/?hl=pt-br)

## Terminologias de renderização
- **SSR**: Server-Side Rendering - renderização da aplicação cliente ou universal para HTML no servidor.
- **CSR**: Client-Side Rendering - renderização de um aplicativo no navegador, geralmente usando o DOM.
- **Rehydration**: "inicialização" da view JavaScript no cliente de tal forma que sejam reutilizados os dados e a árvore DOM do HTML renderizada pelo servidor.
- **Prerendering**: rodar uma aplicação cliente no tempo de *build* para capturar seu estado inicial como HTML estático.

## Server Rendering
![Server rendering](https://developers.google.com/web/updates/images/2019/02/rendering-on-the-web/server-rendering-tti.png) \
Na renderização pelo servidor o cliente faz a requisição, o servidor delega para a aplicação, a mesma gera o HTML completo que é enviado para o cliente através do servidor.

|Prós|Contras|
|----|-------|
|Não precisa de requisições adicionais para pegar dados|TTFB tende a ser mais alto|
|Consegue fazer streaming|Custo do servidor tende a ser mais alto|
|TTI = FCP|Não tem aproveitamento de código do servidor no Javascript|

## Static Rendering
![Static rendering](https://developers.google.com/web/updates/images/2019/02/rendering-on-the-web/static-rendering-tti.png)
A aplicação faz o build dos HTMLs estáticos em tempo de execução e os arquivos estáticos são servidos.

|Prós|Contras|
|----|-------|
|TTFB tende a ser mais baixo|Não tem aproveitamento de código do servidor no Javascript|
|Consegue fazer streaming|Quantidade limitada de páginas|
|FP tende a ser mais rápido||
|TTI=FCP||
|Custo do servidor tende a ser mais baixo||

## SSR com Reidratação
O cliente faz a requisição, o servidor delega para a aplicação que gera um HTML pré-renderizado, o cliente recebe como resposta e faz a reidratação.

|Prós|Contras|
|----|-------|
|Reaproveitamento de código de front no servidor e no cliente|TTFB tende a ser mais alto|
||TTI >>> FCP|
||Mais difícil fazer streaming|

### Reidratação Parcial
A reidratação comumente gera uma cópia da árvore DOM inteira e na maioria dos casos precisamos de apenas algumas partes e dessa forma também conseguimos otimizar a performance da nossa aplicação.

## CSR com Pré-renderização
A aplicação faz o build de HTMLs estáticos parciais, que são servidos para o cliente e o mesmo executa os scripts que completam a renderização.

|Prós|Contras|
|----|-------|
|TTFB baixo|TTI > FCP|
||Quantidade limitada de páginas|

## Full CSR
![Full CSR](https://developers.google.com/web/updates/images/2019/02/rendering-on-the-web/client-rendering-tti.png)
Servidor devolve HTML base e o cliente carrega os scripts, baixa os dados e renderiza o HTML completo.

|Prós|Contras|
|----|-------|
|TTFB baixo|TTI >>> FCP|
|Modelo mental mais simples|Sem streaming|
||Pesado renderizar tudo client-side|
||Totalmente dependente de JS|
||SEO mais difícil|

## Conclusão
### Não existe bala de prata
Na escolha por um método de renderização é valido pensar na interatividade desejada, recursos disponíveis e SEO antes de chegar numa solução apropriada.
