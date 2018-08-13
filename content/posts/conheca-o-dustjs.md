---
title: Conhecendo o Dust.js, uma biblioteca de template para javascript
date: 2018-07-31
category: front-end
layout: post
description: Nesse primeiro post, conheça sobre o Dust.js, biblioteca para trabalhar com templates no cliente e no servidor.
authors: [tcelestino]
tags:
  - front-end
  - js templates
  - isomorfismo
---

O time de front-end do Elo7 está sempre buscando novas tecnologias para compor o fluxo de trabalho, mesmo que algumas dessas tecnologias não estejam nos holofotes da comunidade. Acreditamos que independente do *hype*, temos como principal foco a resolução de nossas necessidades e é por isso que neste post vamos falar sobre o [Dust.js](http://www.dustjs.com/), uma bibloteca javascript para trabalhar com templates, desenvolvido pelo Linkedin e que usamos em nosso serviço de templates.

## Por que escolhemos o Dust.js?

Antes de começar a falar sobre o Dust.js, preciso fazer um resumo do porque escolhemos usá-lo e não outras soluções existentes no mercado. E uma palavra pode resumir isso: PERFORMANCE! Sim, a partir de vários testes em diversas bibliotecas, concluímos que a performance do Dust.js atenderia melhor a nossa necessidade. Sem contar que estavamos buscando uma solução para usarmos do lado do cliente (Client Side Render) quanto no servidor (Server Side Render), o famoso isomorfismo. Caso queria saber mais sobre Javascript isomórfico, recomendo ler o [post](https://engenharia.elo7.com.br/isomorfismo/) da [Fernanda Bernardo](https://engenharia.elo7.com.br/fernandabernardo/) sobre o assunto.

A premissa do Dust.js é não ter lógica na camada de visualização (view), mesmo você podendo fazer esse tipo de abordagem. No Dust.js a ideia é manter essa lógica na camada modelo (model), assim conseguimos manter nossas *views* sem regras de negócios. Enxergamos isso como uma boa prática, até porque, se pensarmos melhor, não é a *view* que tem que cuidar se um conteúdo vai aparecer ou não na tela, concorda?

Na prática, seria como o exemplo abaixo:

```javascript
{@eq key="elo7Login" value="true"}
  {@eq key="login" value="true"}
    {@gt key="level" value=1}
      {@eq key="isSeller" value="true"}
        Bem-vindo vendedor!
      {/eq}
    {/gt}
  {/eq}
{/eq}
```

Ao invés de escrever todo esse código (no post sobre helpers, explicarei sobre o `@eq` e `@gt`) no nosso template, escrevemos nosssa lógica no modelo. Reescrevendo o código acima, ficaria assim:

```javascript
{#elo7UserLogin}
  Bem-vindo Vendedor!
{/elo7UserLogin}
```

O `elo7UserLogin` é nosso objeto modelo, nele que podemos ter funções que irão fazer apresentação do conteúdo em nossa *view*. No próximo post, irei falar com mais detalhe sobre isso.

## Iniciando o Dust.js

Nessa primeira parte, vamos ver como funciona o "comportamento" e entender o contexto da biblioteca. Para iniciar, vamos criar uma estrutura básica.

<a class="jsbin-embed" href="http://jsbin.com/qatizuf/3/embed?html,output"></a><script src="http://static.jsbin.com/js/embed.min.js?4.1.4"></script>

Fazendo um resumo de como o código acima funciona, teríamos a seguinte estrutura:

- Carregamos os arquivos necessários para o Dust.js funcionar (dust.js e dust-helper.js);
- Implementamos uma função de *callback* para escrever nosso template na página;
- Criamos um template (usando [Template Strings](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/template_strings)) e um objeto modelo;
- Usamos o metódo `renderSource` para renderizar os dados, template e escrever no nosso HTML.

Se você já utilizou alguma *template engine* para javascript ([handlebars](https://handlebarsjs.com/), [mustache](http://mustache.github.io/), etc...) vai perceber que o uso do Dust.js é bem similar. Precisamos criar um objeto modelo e usamos as chaves desse objeto para adicionar os dados na tela. Até ai, nada diferente, correto?

## Entendendo contexto

O Dust.js trabalha com contexto global e isso pode soar bastante estranho no começo. No caso, o contexto é baseado na "árvore" do modelo. Ou seja, o framework fará uma varredura em seu objeto modelo até achar a chave correspondente que está sendo usada em um template. Para exemplicar um pouco desse conceito, observe o seguinte código:

<a class="jsbin-embed" href="http://jsbin.com/rajahus/1/embed?html,output"></a><script src="http://static.jsbin.com/js/embed.min.js?4.1.4"></script>

Analisando o código, estamos pecorrendo o objeto modelo para acessar os valores das chaves `{name}`, `{age}` e `{city}`, mas se você observou com atenção, a chave `{city}` não está associada a chave `persona` e mesmo assim conseguimos executar o código. Estranho não?

No Dust.js, os dados do nosso objeto modelo são lidos de "dentro para fora". Ou seja, ao percorrer a chave `{persona}`, conseguimos acessar as chaves daquele *nó*, mas caso não encontre uma chave que esteja sendo usado no template, o Dust.js irá buscar a chave fora desse *nó* e por isso que o nosso código é executado sem quebrar. Soa bastante perigoso esse comportamento quando não temos controle dos dados (no caso de usar uma API de terceiros, por exemplo), mas isso é uma das "coisas" estranhas que observamos durante esse tempo de uso da biblioteca e passamos a ter mais cuidado quando escrevemos nossos códigos.

# Conclusão

Vimos nessa primeira parte o conceito por trás da bibloteca e como funciona o seu contexto, que em um primeiro contato pode parecer muito estranho mas garante códigos mais "seguros".

Nos próximos posts, iremos abordar sobre iteração de dado, condicionais, filtros e *helpers*. Caso não queria perder os próximos posts e também acompanhar os novos, assine nossa [newsletter](http://eepurl.com/cVUwvH) ou acompanhe nosso feed [RSS](https://engenharia.elo7.com.br/rss.xml).
