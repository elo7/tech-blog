---
date: 2019-10-07
category: front-end
tags:
  - performance front-end
  - javascript
authors: [luiz]
layout: post
title: Melhorando a performance da nossa página de produto
description: "Essa é a história de como melhoramos a experiência do usuário e, consequentemente, a pontuação nas ferramentas de busca da nossa página de detalhes de um produto mobile."
cover: melhorando-performance-pagina-produto.jpg
---

http://metrics.elo7aws.com.br:3000/d/000000138/dorne?orgId=1&from=1562293299265&to=1564976499944&var-platform=mobile&var-page=produto&var-gtm=remove_gtm&var-test=default&var-test=shared_worker_inactive

- CSS inline
- JS inline (parece que impactou negativamente o first-contentful-paint; benefício difícil de ver pois foi deployado junto com remoção de AJAXes do i18n)
- Remover JS não usado (polyfills/fallbacks) (não deu para capturar impacto pelo Dorne pois métricas começaram a ser coletadas depois)
- Requests síncronos no carregamento (maior impacto)
  - 1o deploy: 08/07 - inline async-define + remove AJAXes do i18n (aumentou first-contentful-paint de 1,8 para 1,9 s)
  - 2o deploy: 09/07 - remove AJAXes dos templates (morte dos has-js + CSS específico para noscript)
  - 3o deploy: 11/07 - remove onboarding-tooltip no carregamento da página (nym.load)
- Preconnect 01/08: melhorou first-contentful-paint de 1,9 s para 1,8 s; aumentou um pouco page size - 489 p/ 509 kb - mas diminuiu número de conexões - 80 p/ 72

Em março desse ano, colocamos no ar uma nova versão da nossa página de produto mobile no ar. Foi um redesign tanto visual quanto na parte de código front-end!

![Versão antiga da página]()
![Versão nova da página](../images/performance-product-2.png)

Foto de capa: "<a href='https://www.flickr.com/photos/25463427@N05/2773733589' rel='nofollow noopener' target='_blank'>Bavaria City Racing 2008</a>" por Niels Broekzitter (licença <a href='https://creativecommons.org/licenses/by/2.0/deed.pt_BR' rel='nofollow noopener' target='_blank'>CC BY 2.0</a>).

