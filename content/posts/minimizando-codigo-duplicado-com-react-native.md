---
date: 2017-10-16
category: mobile
tags:
  - react-native
  - ios
  - android
authors: [aterribili]
layout: post
title: Minimizando código duplicado com React Native no Elo7
description: Neste post explico como aplicamos o uso de React Native no Elo7.
---

# Minimizando código duplicado com React Native no Elo7
## Início
Quando entrei no Elo7, estávamos engatinhando no mundo dos aplicativos, tínhamos uma versão apenas para o Android, que era basicamente um *wrapper* de um conjunto de *webviews*, com um *drawer menu* nativo. Olhando o *roadmap*, percebemos que logo atacaríamos uma versão *mais* nativa (sem tantos *webviews*) para o iOS e Android. O tempo foi passando e logo as versões mais nativas foram amadurecendo. Então, percebemos que havia uma quantidade de código semelhante* em ambas plataformas: consumo de um endpoint/API, mapeamento de um JSON para um modelo e exibição na tela, etc.

*Semelhante = códigos que fazem exatamente a mesma coisa, porém em linguagens diferentes (Android = Java, iOS = Objective-C)

Com essas informações, definimos que iríamos minimizar esse código dúplicado, com a premissa de criar aplicativos nativos. Fomos atrás de material na internet e encontramos o [Djinni](https://github.com/dropbox/djinni), do Dropbox, que tinha uma proposta alinhada com algo que procurávamos, porém apenas a camada de UI (*User Interface*), teria que ser escrita em cada plataforma. Fizemos algumas provas de conceito e o resultado não foi o que esperávamos, o código escrito usando o Djinni era em C++, não abstraía a camada de UI e ainda assim era complexo de integrar com *apps* já existentes. Então assumimos que a melhor maneira de construir aplicativos na época, era manter a abordagem que já estava dando certo, cada plataforma com o seu código.

## Meio
Novamente, olhando o *roadmap*, vimos que desenvolveríamos mais dois aplicativos destinados aos vendedores que, por sua vez, teriam algumas *features* já presentes nos aplicativos dos compradores (já mencionados). Nessa época, decidimos modularizar o que seria semelhante em mais de um aplicativo. Lembrando que ainda nesse ponto, **não** compartilhávamos código entre plataformas (Android e iOS).
Dividimos as aplicações em *libraries* do iOS e Android:
módulo de mensagens - responsável por abstrair **quase** tudo que tem relação com o nosso fluxo de troca de mensagens;
módulo *commons* - responsável por abstrair fluxo de *login*, tela de perfil e tudo que considerávamos comum entre os aplicativos;
módulo *networking* - responsável por abstrair nossa camada HTTP;

Segue uma descrição resumida do cenário do Android, visto que do iOS é **muito** semelhante, ele será omitido:

Talk7 consome as *libraries*:
  - módulo de mensagens
  - módulo *commons*
  - módulo *networking*

Elo7 consome as *libraries*:
  - módulo de mensagens
  - módulo *commons*
  - módulo *networking*

Com essa estrutura e a famosa [Clean Architecture](https://fernandocejas.com/2014/09/03/architecting-android-the-clean-way/), alcançamos um reaproveitamento de código legal, com todas aquelas vantagens de evitar código duplicado que todo mundo já conhece, tem até uma [palestra minha com o Thiago Pilon](https://www.youtube.com/watch?v=HK0fZRCJfYw) que falamos bastante a respeito da arquitetura que adotamos na época. ([Thiago Pilon](https://github.com/Pilon))

## Fim (pelo menos até agora)
Eis que algumas [pessoas/empresas](https://facebook.github.io/react-native/showcase.html) não paravam de falar que o React-Native (RN) era uma solução **elegante** para compartilhamento de código entre plataformas, que é uma ferramenta que permite escrever aplicativos nativos usando [React](https://facebook.github.io/react/) e Javascript e tem como diretiva: aprenda uma vez e escreva aplicativos para as duas plataformas (Android e iOS, eventualmente até aplicações [WPF/Phone para Windows](https://github.com/Microsoft/react-native-windows)). 

A proposta do RN é ambiciosa, gerar código nativo, componentes de UI nativos, integração com código já existente, [toolset](https://facebook.github.io/react-native/docs/debugging.html) bem completo e até possibilidade de [atualização de aplicativos já instalados](https://microsoft.github.io/code-push/). 

Esses dois últimos pontos chamaram bastante nossa atenção, poderiamos colocar o RN na nossa base de código sem reescrever todo o projeto, uma vez que a integração com a parte nativa era possível e também poderíamos subir uma correção de *bug* sem a necessidade de passar por todo o processo de *review*/aprovação da Apple, isso sem falar que teríamos nossa base inteira atualizada em pouco tempo. <3

### Prova de conceito
Concluímos que a proposta do RN casava muito bem com aquela premissa lá do começo do post, de evitar código duplicado entre as plataformas (Android e iOS), então decidimos avaliar. Fizemos nossa prova de conceito e obtivemos sucesso, porém a integração deu bastante trabalho, e até que chegássemos à uma solução *production-ready*, investimos muito esforço. O problema era que os mantenedores do RN estão acostumados com uma estrutura de diretórios diferente da que temos aqui e não queríamos mudar nossa estrutura atual, afetando a produtividade do time modificando a maneira de trabalhar.. Então, tomamos a ousada decisão de fazer a integração de uma forma bem diferente da [sugerida](https://facebook.github.io/react-native/docs/integration-with-existing-apps.html).

Estrutura de diretórios sugerida:
```
ios/
android/
package.json
src/
node_modules/
...
```

Ou seja, nosso projeto estaria acoplado ao RN :/, e não queríamos isso, pois se um dia abandonarmos a ideia de utilizar RN, poderíamos simplesmente removê-lo. :)
Por essa motivação, gostaríamos que a *lib* que abstraísse o RN também fosse uma dependência dos aplicativos atuais, algo como:

Talk7 consome as libraries:
  - lib de mensagens
  - lib *commons*
  - lib *networking*
  - **lib react native**

Após um tempo investido, aproximadamente 1 mês, alcançamos esse objetivo. O único incômodo causado para a parte do time que não estava totalmente envolvida com essa integração, era a instalação do [NPM](https://www.npmjs.com) para podermos gerar o *bundle* com os componentes escritos em RN. Acredito que a explicação de como integramos o RN nos aplicativos daqui vale um outro *post*, pois é um tema bem extenso e não está no escopo do tema deste *post*.

## Hoje
No Elo7, o RN vem cumprindo seu objetivo, por isso já temos diversas *features* feitas inteiramente em RN, que se comunicam com o nosso *backend* e são exibidas nas plataformas Android e iOS, compartilhando código Javascript de fácil manutenção.

Bom, mas e a experiência do usuário, como fica? 
Não precisa ser igual, se você precisar de customizações específicas para cada plataforma, o RN resolve [muito bem](https://facebook.github.io/react-native/docs/platform-specific-code.html), vale a pena conferir.

Aqui vai um exemplo de código em React Native, bem simples, com o objetivo de exibir um pouco a forma que utilizamos o RN aqui no Elo7:
<div data-snack-id="ryfaGFmUW" data-snack-platform="ios" data-snack-preview="true" data-snack-theme="light" style="overflow:hidden;background:#fafafa;border:1px solid rgba(0,0,0,.16);border-radius:4px;height:505px;width:100%"></div>
<script async src="https://snack.expo.io/embed.js"></script>

Caso tenha dúvidas ou sugestões, pode comentar abaixo. (:

Obrigado [Thiago Pilon](https://github.com/Pilon) pela revisão e sugestões!

