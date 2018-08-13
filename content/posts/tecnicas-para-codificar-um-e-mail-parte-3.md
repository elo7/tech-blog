---
date: 2018-04-09
category: front-end
tags:
  - e-mail
  - html
  - css
  - responsivo
  - mobile
authors: [erikatakahara]
layout: post
title: Técnicas para codificar um e-mail - parte 3
description: Já teve problemas ao visualizar um e-mail no celular? Aquelas letras pequenas, scroll lateral e colunas quebradas? Neste post iremos abordar como criar colunas nos e-mails e como deixá-las responsivas para melhor visualização em dispositivos móveis.
---

No [segundo post da série](/tecnicas-para-codificar-um-e-mail-parte-2/), aprendemos a lidar com espaçamento nos e-mails. Neste, iremos abordar como criar conteúdo em colunas e como deixá-las <a href='https://tableless.com.br/introducao-ao-responsive-web-design/' rel='nofollow' target='_blank'>responsivas</a>.

Finalmente chegamos ao conteúdo! Para começar, vamos criar uma nova tabela. É possível usar a mesma tabela do container e alterar o `bgcolor` para mudar a cor da célula em vez da tabela. Mas aconselho a criar uma nova para evitar problemas com o `colspan` e `rowspan`, porque essas propriedades causam problemas para manter a estrutura correta à medida que são criadas novas células.

Para montar o conteúdo, vamos usar as mesmas técnicas citadas nos posts anteriores:

![E-mail com o conteúdo](../images/tecnicas-para-codificar-um-e-mail-parte-3-1.png)

```HTML
<table bgcolor="#ffffff" width="100%" cellpadding="0" cellspacing="0" style="padding-left: 15px; padding-right: 15px">
    <tr>
        <td>
            <h2 style="padding: 0; margin: 0.5em 0; font-size: 1.5em; font-family: arial, sans-serif; color: #788895">Novidades do tech blog!</h2>
            <img src="http://placehold.it/570x150" alt="Imagem" width="570" height="150">
            <p>Lorem ipsum  [...]</p>
            <p>Phasellus vulputate [...]</p>
        </td>
    </tr>
</table>
```

Mas temos um problema: com essa modificação, o e-mail deixou de ser responsivo por causa da imagem com largura fixa que expande o tamanho de seu container, fazendo com que os outros elementos ocupem uma área maior:

![Problema da largura fixa nos dispositivos móveis](../images/tecnicas-para-codificar-um-e-mail-parte-3-2.png)

Para torná-lo responsivo, basta adicionar uma largura na imagem para que ocupe o maior espaço possível do container sem expandi-lo, ou seja, `width: 100%`. O problema dessa técnica é que a altura definida acaba deixando a imagem desproporcional em telas menores.

![Adicionando largura 100% para os dispositivos móveis](../images/tecnicas-para-codificar-um-e-mail-parte-3-3.png)

Uma solução é remover a altura fixa, mas caso a imagem esteja carregando ou não possa ser carregada (por URL inválida ou inacessível ou até mesmo o cliente de e-mail impedir a sua exibição, por exemplo), o nosso navegador não consegue definir a altura e usará um valor proporcional à largura:

![Template do e-mail quebra quando a imagem demora para carregar](../images/tecnicas-para-codificar-um-e-mail-parte-3-4.png)

A solução que acredito ser a melhor é fazer uma mescla de `width="100%"` e limitar o tamanho da imagem com o `max-width` e o `max-height`.

![Imagem com altura máxima definida](../images/tecnicas-para-codificar-um-e-mail-parte-3-5.png)

```HTML
<table bgcolor="#ffffff" width="100%" cellpadding="0" cellspacing="0" style="padding-left: 15px; padding-right: 15px">
    <tr>
        <td>
            <h2 style="padding: 0; margin: 0.5em 0; font-size: 1.5em; font-family: arial, sans-serif; color: #788895">Novidades do tech blog!</h2>
            <img src="http://placehold.it/570x150" alt="Imagem" width="100%" style="max-width: 570px; max-height: 150px;">
            <p>Lorem ipsum  [...]</p>
            <p>Phasellus vulputate [...]</p>
        </td>
    </tr>
</table>
```

## Colunas responsivas

Para as colunas, vamos criar duas tabelas com uma largura de 270px: uma com a imagem e a outra com o título do texto e a descrição:

```HTML
<table cellpadding="0" cellspacing="0" width="270">
    <tr>
        <td>
            <img src="http://placehold.it/270x150" width="100%" style="max-width: 270px; height: 150px;" alt="Imagem veja mais">
        </td>
    </tr>
</table>

<table cellpadding="0" cellspacing="0" width="270">
    <tr>
        <td>
            <h2 style="margin: 0; font-size: 1.5em; font-family: 'Lobster', sans-serif; color: #788895">Veja mais!</h2>
            <p>Sed congue purus lorem, nec luctus nibh fermentum non. Ut fermentum aliquet nunc, tempus placerat turpis tristique sed.</p>
        </td>
    </tr>
</table>
```

Para alinhar os elementos na mesma linha, vamos usar a propriedade `display: inline-block`:

![Colunas em e-mail](../images/tecnicas-para-codificar-um-e-mail-parte-3-6.png)

```HTML
<table cellpadding="0" cellspacing="0" width="270" style="display: inline-block">
    [...]
</table>

<table cellpadding="0" cellspacing="0" width="270" style="display: inline-block">
    [...]
</table>
```

Para alinhar no topo é só adicionar o atributo `valign="top"` (o `valign` tem a mesma função da propriedade `vertical-align`).

```HTML
<table cellpadding="0" cellspacing="0" width="270" style="display: inline-block" valign="top">
    [...]
</table>

<table cellpadding="0" cellspacing="0" width="270" style="display: inline-block" valign="top">
    [...]
</table>
```

Por fim, vamos adicionar margem nas duas tabelas para separar o conteúdo verticalmente e uma margem à direita na primeira.

![Colunas alinhadas verticalmente](../images/tecnicas-para-codificar-um-e-mail-parte-3-7.png)

```HTML
<table cellpadding="0" cellspacing="0" width="270" style="display: inline-block; margin-right: 15px;" valign="top">
    [...]
</table>
```

E como usamos o `display: inline-block`, essas colunas já são responsivas:

![Colunas em um dispositivo móvel](../images/tecnicas-para-codificar-um-e-mail-parte-3-8.png)

O problema agora é que a primeira tabela está causando um scroll horizontal. Isso porque a margem da direita (15px), somada à largura da imagem (270px) e a margem interna (30px), ultrapassa o limite de 300px (largura mínima de um celular).

Uma forma de resolver é remover o `margin-right` da primeira tabela e adicionar um `span` em volta da tabela com um `border-right: 15px solid white`. Essa borda se encarrega de criar o espaçamento entre as duas tabelas na horizontal e não contabiliza na soma por ser um elemento `inline`. Dessa forma conseguimos atingir o efeito desejado:

```HTML
<span style="border-right: 15px solid white">
    <table cellpadding="0" cellspacing="0" width="270" style="display: inline-block" valign="top">
        [...]
    </table>
</span>
<span>
    <table cellpadding="0" cellspacing="0" width="270" style="display: inline-block" valign="top">
        [...]
    </table>
</span>
```


![Colunas usando borda para criar a margem](../images/tecnicas-para-codificar-um-e-mail-parte-3-9.png)

A outra forma é adicionar uma <a href='https://developer.mozilla.org/pt-BR/docs/Web/Guide/CSS/CSS_Media_queries' target='_blank' rel='nofollow'>media query</a> específica para mobile e remover essa margem. Sim! Alguns clientes de e-mail agora aceitam a tag `style` no cabeçalho e media queries! Essa mudança está revolucionando o desenvolvimento de e-mails responsivos, criando experiência mais rica para os nossos usuários e melhorando a legibilidade do código.

Voltando ao nosso exemplo, vamos adicionar a tag `style` com uma media query dentro do header:

```HTML
<head>
    <style>
        @media only screen and (max-width: 480px) {

        }
    </style>
</head>
```

As regras declaradas nessa media query serão aplicadas para todas as telas com uma largura de no máximo 480px, ou seja, apenas para a versão mobile. Para aplicar a regra de remoção da margem, vamos adicionar uma classe para a primeira tabela:

```HTML
<table class="tabela-responsiva" bgcolor="#ffffff" width="100%" cellpadding="0" cellspacing="0" style="padding-left: 15px; padding-right: 15px; margin-right: 15px;">
```

E dentro da media query:

```CSS
@media only screen and (max-width: 480px) {
    .tabela-responsiva {
        margin-right: 0 !important;
    }
}
```

O `!important` é necessário para conseguirmos sobrescrever o estilo que está declarado `inline`. Com essa mudança conseguimos atingir o mesmo resultado, entretanto a tag `style` no cabeçalho não funciona em alguns clientes de e-mail.

Voltando ao nosso e-mail, agora o único problema ainda não resolvido é o fato do template não ser exibido corretamente em telas um pouco menores que 600px, mas maiores que 480px:

![Colunas quebram em duas linhas em devices com uma largura um pouco menor que 600px](../images/tecnicas-para-codificar-um-e-mail-parte-3-10.png)

Para esse problema, podemos alterar a largura das tabelas para serem baseadas em uma porcentagem. Por exemplo, se alterarmos as larguras dessas tabelas para 47% (um valor próximo da largura de 270px) teríamos o seguinte resultado:

![Usando porcentagem nas colunas](../images/tecnicas-para-codificar-um-e-mail-parte-3-11.png)

Mas, como podemos ver, essa alteração piora a usabilidade na versão mobile. Nesse caso, podemos aproveitar a nossa media query no header e fazer essas tabelas ocuparem 100% do espaço em telas menores. Vamos adicionar a mesma classe `.tabela-responsiva` para a segunda tabela e adicionar a seguinte regra na media query:

```CSS
@media only screen and (max-width: 480px) {
    .tabela-responsiva {
        margin-right: 0 !important;
        width: 100% !important;
    }
}
```

![Template final](../images/tecnicas-para-codificar-um-e-mail-parte-3-12.png)

E voilá! Chegamos ao efeito desejado!

Também poderíamos optar por não utilizar a tag `style` para corrigir esse problema. Não resolveria muito, mas poderíamos voltar para as medidas fixas e adicionar uma tabela envolta para alinhar os elementos no centro e melhorar um pouco o design.

Por fim, podemos só adicionar uma tipografia padrão na tabela de conteúdo:

```HTML
<table bgcolor="#ffffff" width="100%" cellpadding="0" cellspacing="0" style="padding-left: 15px; padding-right: 15px; font-family: arial, sans-serif">
```

Assim, todo o texto que está no conteúdo já herda por padrão essa tipografia.

## Compatibilidade

As técnicas apresentadas funcionam nos seguintes clientes de email:


### Web

|                | Gmail | Inbox | Outlook | Yahoo |
|----------------|:-----:|:-----:|:-------:|:-----:|
| Chrome         |   ✓   |   ✓   |    ✗¹   |   ✓   |
| Safari         |   ✓   |   ✓   |    ✗¹   |   ✓   |
| Firefox        |   ✓   |   ✓   |    ✗¹   |   ✓   |
| IE11           |   ✓   |   -   |    ✗¹   |   ✓   |
| Edge           |   ✓   |   ✓   |    ✗¹   |   ✓   |
| Chrome Mobile  |   ✗¹  |   -   |    ✗¹   |   ✓   |
| Firefox Mobile |   ✗¹  |   -   |    ✗¹   |   ✓   |
| Safari Mobile  |   ✗¹  |   -   |    ✗¹   |   ✓   |

### Mobile

|                   |  Gmail App |  Inbox App | Outlook App  | Yahoo App  | Apple Mail  |
|-------------------|:----------:|:----------:|:------------:|:----------:|:-----------:|
| Android           |     ✓      |     ✓      |      ✓      |     ✓      |      -      |
| iOS               |     ✗¹     |     ✗¹     |      ✗¹      |     ✗¹     |      ✓      |
| Windows Phone     |     -      |     -      |      ✓       |     -      |      -      |

### Aplicativo Outlook

|        | 2007 | 2010 | 2011 | 2013 | 2015 |
|--------|:----:|:----:|:----:|:----:|:----:|
| Outlook |  ✗¹ |  ✗¹  |   ✓  |  ✗¹  |   ✓  |

¹ A propriedade `style` no `head` não funciona

## Conclusão

Enfim, conseguimos finalizar o e-mail com o layout apresentado no [primeiro post](/tecnicas-para-codificar-um-e-mail/)! No próximo e último post da série, vamos comentar sobre algumas dicas e web fonts nos e-mails.

E você? Já teve problemas com e-mails responsivos?
