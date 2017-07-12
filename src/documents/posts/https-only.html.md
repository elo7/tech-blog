---
title: Migrando para HTTPS
date: 2017-05-02
category: devops
layout: post
description: Recentemente, o Elo7 passou a ser servido unicamente em HTTPS. Essa mudança, que pode parecer simples à primeira vista, tem uma série de motivos e também implicações, que serão discutidas neste artigo.
authors: [edsonmarquezani]
tags:
  - https
  - http2
---

Como vocês já devem ter notado, recentemente o [**Elo7**](https://www.elo7.com.br) passou a ser servido **unicamente em _HTTPS_**. Nenhuma parte de nosso conteúdo ou navegação está mais disponível em _HTTP_ plano. Isso segue uma tendência de toda a Internet e cada vez mais sites devem adotar esse "formato". O gráfico abaixo ([extraído daqui](https://www.troyhunt.com/https-adoption-has-reached-the-tipping-point/)) mostra o crescimento do uso de _HTTPS_ entre o 1 milhão de sites mais acessados listados pela [_Alexa_](http://www.alexa.com/).

![Crescimento de sites HTTPS no último ano](../images/https-4.png)

Essa mudança, que pode parecer simples à primeira vista, tem uma série de motivos e também implicações, que serão discutidas a seguir.

## _HTTP_ versus _HTTPS_

O protocolo _HTTPS_ é a versão segura do protocolo _HTTP_. Com ele, todos os dados trafegados são criptografados por outro protocolo chamado [_SSL/TLS_](https://en.wikipedia.org/wiki/Transport_Layer_Security). O _SSL_ é baseado em técnicas de criptografia simétrica (onde uma única chave é usada) e assimétrica (onde existem chaves separadas para criptografar e descriptografar). Por "debaixo" do _SSL_, permanece o mesmo _HTTP_ de sempre, como conhecemos.

O objetivo primário do _HTTPS_ é, como pode ser facilmente deduzido, prover privacidade na comunicação, impedindo que o teor dos dados seja revelado em caso de interceptação por terceiros. Isso é não apenas desejável, mas indispensável para operações que transmitem dados sensíveis, como senhas, dados bancários, mensagens, etc. É por isso que operações de _login_, pagamentos _online_ e até mesmo troca de mensagens (por aplicativos ou e-mails) sempre são realizadas dessa forma.

Outra vantagem do _HTTPS_ é a comprovação de identidade, ou seja, poder ter certeza de que um site não é falso e que realmente pertence à entidade que diz pertencer. Isso é possível pois, na _web_, todo certificado _SSL_ utilizado é assinado por uma [Autoridade Certificadora](https://en.wikipedia.org/wiki/Certificate_authority) (_CA_), garantindo sua autenticidade. O certificado nada mais é do que a chave pública usada na porção do protocolo onde se utiliza criptografia assimétrica. (A compreensão plena de todo o mecanismo de funcionamento do protocolo _SSL_ e, em especial, das técnicas de criptografia foge ao escopo desse artigo, por tratar-se de um tópico bastante extenso e complexo.) Essa chave (ou certificado) contém o próprio endereço do site, entre outras informações da entidade à qual pertence. Quando o navegador obtém esse certificado do site, pode validar se ele foi realmente emitido por uma _CA_ confiável, confirmando se o site é autêntico. (O mecanismo de validação envolve um outro conjunto de certificados das _CAs_ que vêm junto dos navegadores.) Em um cenário onde alguém tentasse usar um certificado falso, essa validação falharia, expondo a fraude, e a barra de endereço não seria exibida com o cadeado verde abaixo.

![Navegador indicando que a identidade do site é verdadeira e o site é seguro](../images/https-6.png)

Essa garantia de autenticidade é fundamental para sites que contém informações hiper sensíveis dos usuários, como entidades finaceiras, serviços de email, entre outros, evitando que se caia em golpes (_phishing_).

Uma das desvantagens do _HTTPS_ em relação ao _HTTP_ é o custo computacional maior para cliente e servidor, devido à série de cálculos que é necessário realizar para criptografar e descriptografar os dados. Entretanto, para o _hardware_ que temos nos dias de hoje, esse _overhead_ costuma ser desprezível perto da complexidade das aplicações em si, impactando muito pouco na carga do servidores ou tempo de resposta. Assim como para os _desktops_, cujos CPUs ficam ociosos boa parte do tempo.

Outra desvantagem é o custo: em geral, as autoridades certificadoras cobram pela emissão dos certificados. Entretanto, atualmente já existem serviços gratuitos como o [_Let's Encrypt_](https://letsencrypt.org/), e até mesmo o [_AWS Certificate Manager_](https://aws.amazon.com/pt/certificate-manager/), que oferece gratuitamente certificados, desde que usados em conjunto de outros recursos _AWS_ (como _Elastic Load Balancer_ e _CloudFront_).

## _Snowden_, _HTTP2_, _Google_ e navegadores

É bem verdade que o _HTTPS_ é fundamental para operações que envolvem dados mais sensíveis, mas e quanto à navegação mais corriqueira, como leitura de conteúdo, visualização de produtos, pesquisas, etc? Por que utilizá-lo nesses casos?

Bem, o mundo pós-[_Snowden_](https://en.wikipedia.org/wiki/Edward_Snowden) encara essa questão de forma diferente. Hoje, é de conhecimento público que diversos governos de nações espionam a comunicação de cidadãos, empresas e até mesmo de outros governos. Em decorrência disso, a preocupação com a privacidade levou a comunidade técnica a um consenso de que a criptografia deixou de ser uma opção, para se tornar uma necessidade, razão pela qual a adoção do _HTTPS_ tem sido não apenas incentivada, mas também de certa forma forçada pelas grandes empresas do setor e grupos que atuam na definição de padrões e regulação da Internet. Desde 2014 o Google vem [favorecendo páginas em _HTTPS_ com um pequeno ganho de ranking (SEO)](https://webmasters.googleblog.com/2014/08/https-as-ranking-signal.html), como forma de incentivo à sua adoção.

Portanto, a pergunta que se fazia antes - "por que usar _HTTPS_?" - foi invertida para: **"por que não usar _HTTPS_?"**

De fato, para a nova versão do protocolo _HTTP_, o [***HTTP/2***](https://http2.github.io/), os navegadores nem sequer dão mais suporte à versão não _SSL_. Ou seja, na prática, pra poder usar os recursos da versão mais nova do _HTTP_, é obrigatório o uso de _HTTPS_. E não para por aí. Navegadores como o _Chrome_, por exemplo, já tem há um bom tempo em seus planos [classificar explicitamente páginas _HTTP_ como não seguras](https://www.chromium.org/Home/chromium-security/marking-http-as-non-secure). Futuramente, toda página _HTTP_ deve ser exibida como abaixo (atualmente isso é só exibido quando habilitada uma _flag_ específica na configuração):

![Esse pudim não é seguro!](../images/https-1.png)

A partir da versão 56, o [_Chrome Canary_](https://www.google.com.br/chrome/browser/canary.html) (uma versão com os recursos mais recentes do navegador) já exibe **por padrão** avisos para formulários de senhas ou cartões de crédito em páginas não _HTTPS_.

![Aviso de segurança em formulário no Chrome](../images/https-2.png)

Analogamente, a versão de desenvolvimento do _Firefox_ também alerta o usuário de forma bastante explícita.

![Aviso de segurança em formulário no Firefox](../images/https-3.png)

Todos os outros navegadores também apontam na mesma direção - a migração total para _HTTPS_ parece ser uma realidade inevitável.

## Assets e outros elementos da página

Para que uma página seja considerada segura, não apenas a página em si precisa ser servida em _HTTPS_, mas também todos os seus recursos (imagens, arquivos _CSS_ e _Javascript_, etc). Assim como não pode haver chamadas de métodos _Ajax_ para serviços não _HTTPS_. Isso vale, inclusive, para _websockets_ e _pixels_ ocultos. Portanto, um dos desafios da migração para _HTTPS_ é garantir que todo esse conteúdo também esteja disponível em _HTTPS_. Do contrário, os navegadores exibirão um ícone de _info_ no lugar do cadeado verde.


## 301 ou 302?

Toda migração precisa ser amigável para os usuários, portanto, um requisito fundamental desse tipo de mudança é que todos os links _HTTP_ sejam redirecionados para sua versão em _HTTPS_, o que, na maior parte das vezes, demanda apenas a troca do protocolo na _URL_. Isso pode ser realizado a partir de uma configuração muito simples em qualquer _webserver_ de mercado (_Nginx_, _Apache_), como no exemplo abaixo para _Nginx_.

```
# Trecho de configuração que deve ir no server HTTP (porta 80)
location / {
  return 302 https://${http_host}${request_uri};
}
```

Um ponto de atenção importante é com relação ao tipo de _redirect_ retornado. O protocolo _HTTP_ suporta, entre outros, dois tipos principais e mais usados de _redirect_:

- ***Redirect Permanente*** - código **301**: como diz o próprio nome, é permanente, portanto, uma vez recebido para aquela _URL_, o servidor só volta a ser consultado após limpeza do cache do navegador;
- ***Redirect Temporário*** - código **302**: basicamente o oposto do caso anterior, não deve ser cacheado pelo navegador, exceto se indicado pelo servidor, e garante que requisições subsequentes sejam feitas no endereço original.

Como pode ser facilmente concluído, o mais seguro para esse tipo de migração é o _redirect_ temporário (**302**, como no exemplo acima), uma vez que sempre há a possibilidade de ter que reverter as mudanças realizadas.

Entretanto, após a constatação de que tudo correu bem e de que não há mais grandes chances de precisar reverter as mudanças, o ideal é alterar o retorno para **301**, pois esse é o código de retorno mais adequado e bem interpretado de forma geral, além do fato de poupar requisições e não perder _throughput_ de _bots_.

## Page ranking e Bots

_Bots_ (ou robôs) são agentes automatizados dos mecanismos de busca (_Google_, _Bing_, _Baidu_) que navegam pelos sites e indexam seu conteúdo. Os usuários que vêm por meio desses mecanismos de busca são parte fundamental da audiência da maioria dos sites, incluindo _e-commerces_ como o [**Elo7**](https://www.elo7.com.br). Portanto, os _bots_ devem ser tratados com muito cuidado. Aqui no **Elo7**, nós acompanhamos de perto a atividade deles em nosso site por meio de diversas métricas, como abaixo.

![Métricas de Bots](../images/https-5.png)

Até o presente momento, o Google [garante que não há perda de pontuação de ranking](https://plus.google.com/+JohnMueller/posts/PY1xCWbeDVC) para as páginas redirecionadas de _HTTP_ para _HTTPS_. Entretanto, não são todos os _bots_ que seguem _redirects_, como ficou evidente mais tarde para nós. Assim que migramos nosso site, vimos uma queda brusca nesse gráfico da esquerda, indicando uma redução grande na quantidade de acesso de _bots_. Mais tarde, ficou claro que o problema era o bot do _Bing_, que não seguia _redirects_ e, portanto, parou de navegar pelo nosso conteúdo.

## Sitemaps e Webmaster Tools

Consequências inesperadas como essa - o sumiço dos _bots_ - podem ocorrer, mas há como contorná-las e, de preferência, evitá-las.

Algo muito importante para a indexação de qualquer site são os índices conhecidos como [_Sitemaps_](https://support.google.com/webmasters/answer/156184?hl=pt-BR), que orientam a navegação inicial dos _bots_ e permitem configurar alguns de seus comportamentos (por exemplo, desligar a indexação de parte das _URLs_, listar endereços que não estão _linkados_ em outras páginas, entre outras coisas), além de identificar de forma mais exata o tipo de conteúdo. Uma vez que o site seja migrado totalmente para _HTTPS_, **é muito importante que as _URLs_ listadas nos arquivos de sitemaps também sejam alteradas**.

Outra ferramenta muito útil são as chamadas _Webmaster Tools_, painéis de controle oferecidos pelos indexadores, como [_Google_](https://www.google.com/webmasters/tools/home?hl=pt-BR) e [_Bing_](http://www.bing.com/toolbox/webmaster), onde é possível visualizar e administrar a indexação das páginas. Através dele é possível adicionar, por exemplo, o endereço inicial do site em _HTTPS_ para que seja indexado paralelamente, mesmo antes da migração definitiva, o que pode ser bastante útil para evitar maiores consequências no _ranking_.

E, por final, não se desespere. É natural uma mudança de comportamento dos _bots_ após esse tipo de migração, e tomadas todas as precauções necessárias, muitas já mencionadas, é necessário aguardar até alguns dias para que eles voltem ao normal. Além disso, é importante ficar atento, pois é possível que o site todo seja reindexado após essa mudança, aumentando significativamente a carga.

## Conclusão
A migração para _HTTPS_ é inevitável e terá que ser feita por todos, mais cedo ou mais tarde. Quanto antes possa ser feita, melhor. Não se trata de algo complexo, mas, especialmente para sistemas grandes, pode haver um certo nível de esforço, sendo importante levar em consideração os pontos mencionados. Entretanto, tomados os devidos cuidados e sendo bem planejado, é plenamente possível de ser realizado sem qualquer indisponibilidade.

Dúvidas? Contribuições? Deixe um comentário!
