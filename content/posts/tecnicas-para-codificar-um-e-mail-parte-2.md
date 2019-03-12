---
date: 2018-01-29
category: front-end
tags:
  - e-mail
  - html
  - css
authors: [erikatakahara]
layout: post
title: Técnicas para codificar um e-mail - parte 2
description: Continuando com a série de posts sobre codificar e-mails, você já teve problemas para adicionar espaçamentos? Ou com cliente de e-mail que não lê corretamente o que foi codificado? Nesse segundo post, vamos abordar diversas técnicas.
---

No [primeiro post da série](/tecnicas-para-codificar-um-e-mail/), aprendemos a criar uma base para codificação de e-mail. Neste, iremos abordar as diversas formas de trabalhar com os espaçamentos.

Para começar, vamos adicionar um cabeçalho ao nosso e-mail. Criaremos uma tabela e, dentro dela, adicionaremos um título para o nosso e-mail. Para ficar igual ao <a href='../images/tecnicas-para-codificar-um-e-mail-1.png' target='_blank'>layout proposto no primeiro post da série</a>, vamos adicionar o atributo `bgcolor` para alterar a cor do fundo para marrom claro:

![Adicionando uma cor de fundo ao nosso cabeçalho](../images/tecnicas-para-codificar-um-e-mail-parte-2-1.png)

```HTML
<table bgcolor="#E2D6C7" width="100%" cellpadding="0" cellspacing="0">
    <tr>
        <td>
            <h1>Meu primeiro e-mail</h1>
        </td>
    </tr>
</table>
```

Agora vamos para a parte que nos interessa: adicionar um pequeno espaçamento entre o texto e as bordas. Podemos fazer isso com as técnicas explicadas a seguir.

## Colunas

Nesta abordagem, adicionamos uma célula antes e outra após a célula que contém o texto, definimos uma largura e adicionamos algum conteúdo para que seja sempre considerada nos clientes de e-mail. Como neste caso não precisamos de algo escrito de fato, iremos inserir no conteúdo a entidade `&nbsp;`, que é equivalente a um espaço na <a href='http://agentewebmaster.ucoz.com.br/publ/tutorial_html/entidades_html/1-1-0-24' rel='nofollow' target='_blank'>tabela de entidades html</a>.

```HTML
<table bgcolor="#E2D6C7" width="100%" cellpadding="0" cellspacing="0">
    <tr>
        <td width="15">&nbsp;</td>
        <td>
            <h1>Meu primeiro e-mail</h1>
        </td>
        <td width="15">&nbsp;</td>
    </tr>
</table>
```

![Espaçamento com colunas](../images/tecnicas-para-codificar-um-e-mail-parte-2-2.png)

## Cellpadding

Nesta técnica, utilizamos o atributo `cellpadding`, responsável pelo espaçamento interno da célula, para criar o espaço desejado:

```HTML
<table bgcolor="#E2D6C7" width="100%" cellpadding="15" cellspacing="0">
    <tr>
        <td>
            <h1>Meu primeiro e-mail</h1>
        </td>
    </tr>
</table>
```

O problema dessa abordagem é que ela não permite definir diferentes espaçamentos, o valor será sempre igual para todas as direções (`top`, `left`, `bottom` e `right`).

![Espaçamento com cellpadding](../images/tecnicas-para-codificar-um-e-mail-parte-2-3.png)


## Padding

Com a propriedade `padding`, podemos definir o espaçamento da mesma forma que faríamos no desenvolvimento de um site. Basta adicionar o `padding-left` e o `padding-right` com o valor de **15px** e temos o mesmo efeito:

```HTML
<table bgcolor="#E2D6C7" width="100%" cellpadding="0" cellspacing="0" style="padding-left: 15px; padding-right: 15px">
    <tr>
        <td>
            <h1>Meu primeiro e-mail</h1>
        </td>
    </tr>
</table>
```

## Margin

Uma outra forma é adicionar uma margem para os lados no nosso texto:

```HTML
<table bgcolor="#E2D6C7" width="100%" cellpadding="0" cellspacing="0">
    <tr>
        <td>
            <h1 style="margin-left: 15px; margin-right: 15px">Meu primeiro e-mail</h1>
        </td>
    </tr>
</table>
```

É importante lembrar que não precisamos seguir apenas uma dessas técnicas. Em determinadas partes do código uma abordagem é melhor que a outra, por isso não se limite!

## Fonte

Com os espaçamentos feitos, precisamos alterar a fonte para que o resultado fique mais próximo ao layout. A cor pode ser alterada utilizando a propriedade `color`, a tipografia com `font-family` e o tamanho com `font-size`. E vale lembrar que precisamos redefinir as margens e os espaçamentos internos para garantir que a renderização se mantenha igual entre os clientes:

![Espaçamento no e-mail](../images/tecnicas-para-codificar-um-e-mail-parte-2-4.png)

```HTML
<table bgcolor="#E2D6C7" width="100%" cellpadding="0" cellspacing="0" style="padding-left: 15px; padding-right: 15px">
    <tr>
        <td>
            <h1 style="margin: 0.5em 0; padding: 0; font-family: arial; color: #7F674D; font-size: 2em">Meu primeiro e-mail</h1>
        </td>
    </tr>
</table>
```

Para a tipografia, é sempre legal colocar uma alternativa para o navegador renderizar, porque nem sempre a fonte escolhida existe no sistema que o usuário utiliza. Uma alternativa genérica são as `sans-serif`, `serif` e `cursive` para as fontes <a href='http://knabbenn.com/classificacao-tipografica/' rel='nofollow' target='_blank'>sem serifa, serifadas e cursivas</a> respectivamente.

Nesse caso só adicionamos uma fonte alternativa após a escolhida:

```CSS
    font-family: arial, sans-serif;
```

## Compatibilidade

As técnicas apresentadas funcionam nos seguintes clientes de email:

### Web

|                | Gmail | Inbox | Outlook | Yahoo |
|----------------|:-----:|:-----:|:-------:|:-----:|
| Chrome         |   ✓   |   ✓   |    ✓    |   ✓   |
| Safari         |   ✓   |   ✓   |    ✓    |   ✓   |
| Firefox        |   ✓   |   ✓   |    ✓    |   ✓   |
| IE11           |   ✓   |   -   |    ✓    |   ✓   |
| Edge           |   ✓   |   ✓   |    ✓    |   ✓   |
| Chrome Mobile  |   ✓   |   -   |    ✓    |   ✓   |
| Firefox Mobile |   ✓   |   -   |    ✓    |   ✓   |
| Safari Mobile  |   ✓   |   -   |    ✓    |   ✓   |
| Edge Mobile    |   ✓   |   -   |    ✓    |   ✓   |

### Mobile

|                   | Gmail App | Inbox App | Outlook App | Yahoo App |
|-------------------|:---------:|:---------:|:-----------:|:---------:|
| Android           |     ✓     |     ✓     |      ✓      |     ✓     |
| iOS               |     ✓     |     ✓     |      ✓      |     ✓     |
| Windows Phone     |     -     |     -     |      ✓      |     -     |

### Aplicativo Outlook

|        | 2007 | 2010 | 2011 | 2013 | 2015 |
|--------|:----:|:----:|:----:|:----:|:----:|
| Outlook |   ✓  |   ✓  |   ✓  |   ✓  |   ✓  |

## Conclusão

Essa foi a segunda parte da série de posts de como codificar um e-mail, na qual aprendemos a lidar com espaçamentos. [No próximo iremos abordar técnicas para torná-lo responsivo.](/tecnicas-para-codificar-um-e-mail-parte-3/)

E você? Já teve problemas com espaçamentos? =]
