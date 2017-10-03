---
date: 2017-09-11
category: front-end
tags:
  - javascript
  - mobile
  - web
  - webapi
authors: [tcelestino]
layout: post
title: Web Share API
description: Conheça mais uma API JavaScript que pretende melhorar a experiência do usuário quando precisar compartilhar links da Web para aplicativos nativos.
coverImage: web-share-api.png
---

Vivemos atualmente a era da informação, onde estamos conectados o tempo todo a redes sociais (Facebook, Twitter, LinkedIn), programas de conversação (WhatsApp, Telegram e Slack) e outras ferramentas que permitem o compartilhamento de informações. Através destes softwares, podemos compartilhar com nossos amigos de tudo: fotos, textos, um link para uma notícia importante ou até mesmo aquele produto que gostamos. Como desenvolvedor web, você provavelmente já precisou adicionar em seus projetos algum recurso para compartilhamento de terceiros. Muitas vezes, a quantidade de código gerado que é inserido pode influenciar no funcionamento da página, como por exemplo no tempo de carregamento. Aqui no Elo7, já usamos plugins (Facebook Share, por exemplo), mas hoje utilizamos o compartilhamento via URL, que é baseado em *query string*. Com isso, evitamos a inserção de códigos desnecessários nas páginas, o que resulta em melhor performance de carregamento.

```html
<a href="https://www.facebook.com/dialog/share?app_id=APP_ID&amp;href=https%3A%2F%2Fwww.elo7.com.br%2Fkit-decoracao-ursinho-frete-gratis&amp;display=popup" rel="noopener" target="_blank" class="btn-share" title="Clique para compartilhar no Facebook">Compartilhar</a>
```
<div style='text-align: center; font-style: italic'>Código de exemplo de como usamos o compartilhamento via query string no Facebook</div>

E se existisse a possibilidade de compartilhar conteúdo diretamente da web para aplicativos nativos? Sim, isso é possível usando uma nova API Javascript chamada [Web Share API](https://wicg.github.io/web-share/), que já está [disponível na última versão do Chrome para Android](https://developers.google.com/web/updates/2017/09/nic61). Firefox e Safari pretendem implementá-la em breve, enquanto a Microsoft ainda não se pronunciou sobre a adoção no Edge. Isso não quer dizer que você não possa implementar para o futuro próximo.

<div style='text-align: center; font-style: italic'><iframe src="https://giphy.com/embed/26zz3WzwwLTbnYXUk" width="270" height="480" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><br><br>Compartilhando um link usando URL Intent</div>

## Um pouco de história

No Android, utilizávamos o [Web Intents](https://www.chromium.org/developers/web-intents-in-chrome) desde a versão 18 do Chrome. Já no iOS, a implementação utilizava [Custom URL Schemes](https://css-tricks.com/create-url-scheme/). E no Firefox OS, a tecnologia era a dos [Web Activies](https://developer.mozilla.org/en-US/docs/Archive/Firefox_OS/API/Web_Activities). Como se pode notar, existiam diversas formas de implementação que demandavam muito tempo e paciência do desenvolvedor. Pensando em facilitar a implementação desse recurso, o time do Google Chrome resolveu criar uma nova abordagem, assim surgindo a ideia da Web Share API.

A Web Share API é baseada no uso de [Promise](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Global_Objects/Promise), e sua implementação é realmente bem simples!

## Implementando Web Share API

Como falei anteriormente, aqui no Elo7 implementamos em nossas páginas o compartilhamento utilizando *query strings*. Na discussão do time de front-end sobre a adoção da Web Share API, concluímos que seria melhor mantermos a implementação atual (utilizando *query strings*) como *fallback* para os casos onde os navegadores não tenham suporte nativo a Web Share API. Quando implementamos a funcionalidade da primeira vez, era possível utilizá-la participando do programa [Origin Trials](https://github.com/GoogleChrome/OriginTrials) do Google Chrome. No momento, a Web Share API não está mais disponível por lá, mas caso você esteja curioso, saiba que existem outras API's interessantes que podem ser lançadas em breve, como: WebUSB, WebVR, getInstalledRelatedApps, entre outras. Vale a pena conferir!

Utilizar a Web Share API é bem simples! Vamos criar um arquivo, chamá-lo de index.html contendo o seguinte código:

```html
<html>
  <head>
    <title>Usando a Web Share API</title>
  </head>
  <body>
    <button type='button' title='Clique e compartilhe' class='share'>Compartilhar</button>
    <script>
      (function() {
        document.querySelector('.share').addEventListener('click', function(evt) {
          if(navigator && navigator.share) {
            navigator.share({
              title: document.title,
              text: 'Usando Web Share API',
              url: window.location.href
            }).then(function() {
              console.log('Funcionou!!');
            }).catch(function(err) {
              console.error(err);
            });
          }
          evt.preventDefault();
        });
      })();
    </script>
  </body>
</html>
```

Ao clicar no link compartilhar, teremos a seguinte tela:

<div style='text-align: center; font-style: italic;'><iframe src="https://giphy.com/embed/26zza3FAMBhksoHFC" width="270" height="480" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><br><br>Compartilhamento usando Web Share API</div>

## Entendendo o código

Vamos entender um pouco mais sobre como que funciona nosso código de exemplo.

A Web Share API está disponível através do método `share` do objeto `navigator`. Precisamos verificar se ela está disponível no navegador, por isso usamos o `if`. Caso não esteja disponível, chamamos nosso *fallback*.

```javascript
if(navigator && navigator.share) {
  navigator.share({
    title: document.title,
    text: 'Usando a Web Share API',
    url: window.location.href
  }).then(function() {
    console.log('Funcionou!!');
  }).catch(function(error) {
    console.error(error);
  })
} else {
  // fallback
}
```

Como falei anteriormente, a Web Share API é baseada em [Promise](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Global_Objects/Promise), então ao compartilhar uma informação temos dois comportamentos mapeados. Caso o compartilhamento seja realizado com sucesso, é executado o trecho de código implementado no método `then`. A título de exemplo, quando isso ocorre no Elo7, enviamos essa informação para o nosso Google Analytics. Caso aconteça um erro durante o processo, o que está implementado dentro do método `catch` será executado e assim podemos adicionar uma estratégia de fallback para o usuário. Vale ressaltar aqui que o `catch` não tem nenhuma relação com a disponibilidade da Web Share API no navegador do usuário.

Hoje em dia, grande parte das novas APIs JavaScript são baseadas no uso de Promises, portanto recomendo que você comece a estudá-la para enriquecer ainda mais os seus projetos.

Passando pela verificação, caso o navegador tenha suporte, passamos para a API um objeto com os seguintes valores:

```javascript
navigator.share({
  title: document.title,
  text: 'Usando a Web Share API',
  url: window.location.href
})
```

* title: título que será usado no compartilhamento do link;
* text: texto que será adicionando no campo de texto (opcional);
* url: link para onde o usuário será redirecionado ao clicar.

## Usando canonical URL

Muitos sites utilizam um domínio específico (http://m.site.com.br) para ser acessado em dispositivos móveis ou até mesmo URL's baseadas no contexto do usuário. Com isso, é preciso pensar bastante na URL que será compartilhada para entregar uma boa experiência para o usuário. Existe a possibilidade de compartilhar o link correto usando [canonical URL](https://en.wikipedia.org/wiki/Canonical_link_element). Atualizando nosso `index.html`, ficaria assim:

```html
<html>
  <head>
    <title>Usando a Web Share API</title>
    <link rel="canonical" href="https://engenharia.elo7.com.br/web-share-api">
  </head>
  <body>
    <button type='button' title='Clique e compartilhe' class='share'>Compartilhar</button>
    <script>

      (function() {
        var $canonical = document.querySelector('link[rel=canonical]');

        document.querySelector('.share').addEventListener('click', function(evt) {
          if(navigator && navigator.share) {
            navigator.share({
              title: document.title,
              text: 'Usando Web Share API',
              url: $canonical ? $canonical.getAttribute('href') : window.location.href
            }).then(function() {
              console.log('Funcionou!!');
            }).catch(function(err) {
              console.error(error);
            });
          }

          evt.preventDefault();
        });

      })();
    </script>
  </body>
</html>
```

Com isso, garantimos que estamos compartilhando o link real da página.

## Notas

Apesar da implementação ser simples, para usar a API é preciso ter algumas atenções:

* Seu servidor precisa ter HTTPS habilitado;
* Os valores passados para API precisam ser no formato de texto;
* Você só pode executar a API a partir de uma ação do usuário. E não pode chama-la no `onload` da página.


## Conclusão

A Web Share API tem um enorme potencial e certamente será utilizada pelos desenvolvedores para entregar uma experiência aprimorada a seus usuários. Essa tendência deve ser puxada pelo desenvolvimento de Web Apps que utilizam o [conceito Progressive Web Apps (PWA)](/a-tecnologia-por-tras-de-progressive-web-apps/), para entregar em mobile browsers a mesma fluidez que os Apps Nativos possuem. Outra vantagem é que através de sua utilização, não haverá mais a necessidade de utilizar códigos de terceiros (a não ser que você precise implementar uma estratégia de *fallback*) para compartilhar de conteúdo na web.

## Referências

* [Web Share API Draft - W3C](https://wicg.github.io/web-share/)
* [Introducing the Web Share API](https://developers.google.com/web/updates/2016/10/navigator-share)
* [Web Share API brings the native sharing capabilities to the browser](https://blog.hospodarets.com/web-share-api)
