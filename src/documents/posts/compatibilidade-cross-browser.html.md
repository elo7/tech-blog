---
title: O universo soturno da compatibilidade cross-browser
date: 2015-09-28
category: front-end
layout: post
description: Em um mundo ideal, todos os browsers apresentariam o mesmo comportamento no carregamento e renderização das páginas da web. Para o terror de muitos desenvolvedores, existem determinadas situações em que uma implementação funciona perfeitamente no navegador utilizado na hora de testar o código, contudo ao abrir a mesma página com o mesmo código em outro, o site está quebrado...
authors: [mottam]
tags:
  - browsers
---

![Alt "Browsers"](../images/compatibilidade-cross-browser-1.png)

Em um mundo ideal, todos os browsers apresentariam o mesmo comportamento no carregamento e renderização das páginas da web. Para o terror de muitos desenvolvedores, existem determinadas situações em que uma implementação funciona perfeitamente no navegador utilizado na hora de testar o código, contudo ao abrir a mesma página com o mesmo código em outro, o site está quebrado.

Ao afirmar que um site é cross-browser, o desenvolvedor está se comprometendo a dar suporte às funcionalidades em todos os navegadores. O usuário deve conseguir alcançar seus objetivos, esteja ele usando um Internet Explorer 8 ou uma versão nightly do Firefox. Isto não necessariamente significa que a aparência de todos os browsers deve ser igual. Entretanto, é almejado que o desenvolvedor lide com as limitações de cada navegador da melhor forma possível.

## Checkbox-hack

Um truque bem conhecido para exibir e esconder elementos sem javascript é o checkbox hack. A tag label contém a propriedade "for", a qual faz referência a outro elemento. O comportamento esperado disso é: ao se clicar na label, o mesmo evento de click é disparado na referência. Complementando isso, os seletores de css permitem escolher elementos irmãos. Como resultado, é possível permitir ao usuário clicar em uma label, a qual selecionará um checkbox que, ao clicado, exibe um outro elemento.

```html
<form>
    <label for='toggle'>Label text</label>
    <input id='toggle' type='checkbox' />
    <div>olá</div>
<form>
```

```css
#toggle {
    display: none; /* Não queremos uma checkbox aparecendo à toa */
}

#toggle:checked ~ div { /* Este é o nosso truque. Quando a checkbox estiver clicada, a div aparece */
    display: block;
}

div {
    display: none; /* Inicialmente a div está invisível */
}
```

Tudo parece perfeito, certo? O Chrome ou o Firefox rodariam isso sem nenhum problema. O problema aparece na hora de testar no IE. O primeiro pensamento que vem à cabeça do desenvolvedor é "Ué, será que o seletor '~' não funciona no IE8?". Uma rápida procurada na internet e ele já descobre que o seletor em questão funciona desde o IE7! Então por que não funciona?

Bom, o comportamento de clique em um elemento invisível no IE8 não é o mesmo dos navegadores mais recentes. O problema não está no css, mas no fato da label estar apontando para um checkbox invisível (o que particularmente acredito que faça sentido. Se não está visível, não tem como este elemento ter sido clicado). Portanto, para que este truque funcione no IE, basta que o elemento esteja aparecendo (por mais que não esteja aparente ao usuário final).

```css
#toggle {
    position: absolute;
    top: -9999px;
    left: -9999px;
}
```

Resolvido o problema do IE, aparenta-se que tudo irá funcionar perfeitamente em outros navegadores principais. Entretanto, com a chegada dos smartphones e a popularização dos planos de dados, grande porção dos acessos agora são realizados pelo universo mobile, o que inicialmente não parece um problema. Pela suprema maioria dos smartphones rodarem Android (82.8%) ou iOS (13.9%), é esperado que os navegadores tenham comportamentos iguais à suas respectivas versões desktop.

Infelizmente, este cenário é bom demais para ser verdade. Ainda é preciso lidar com o Android Browser.

Em relação ao checkbox hack, pseudo-seletores (:checked, no caso) juntamente a seletores de elementos adjacentes (+ ou ~) não funcionam. Este seria o momento de desistir de tentar implementar essa funcionalidade sem javascript, o que seria péssimo. O poder computacional destes dispositivos é limitado e a experiência de utilização desses navegadores já é péssima. Ademais, resolver este problema com javascript implicaria na velocidade de carregamento da página, algo não desejável quando se trata de conexões por rede móvel.

É aí que entram as resoluções sem sentido. Existe um hack para que este comportamento seja alcançado: colocar uma animação infinita no corpo do html.

…?

Estes são os momentos que intrigam o desenvolvedor, pois este exerce lógica em suas decisões de implementação. Eis que de súbito, existem formas de se resolver o problema tão lógicas quanto a de se colocar dentes caídos debaixo de um travesseiro a fim de resolver problemas financeiros.

```css
body { -webkit-animation: bugfix infinite 1s; }
@-webkit-keyframes bugfix { from {padding:0;} to {padding:0;} }
```

E com isso já é possível remover um item da lista de 'não funciona e não sei por quê' e movê-lo para a 'funciona, mas não me pergunte como'. Para finalizar, ainda existe o bug no iOS < 6, o qual não permite que checkboxes sejam ativas com toques em labels. Mas tudo é solucionado com uma propriedade onclick vazia colocada diretamente no elemento.

```html
<input id='toggle' type='checkbox' onclick />
```

O resultado disso é que algo relativamente trivial acaba se tornando um monstro que só funciona com rituais pagãos.

## text-align-last

Outro problema comum é o de alinhar em uma só linha o conteúdo de um elemento de forma que este tenha o mesmo comportamento de um texto justificado. Este tipo de layout é bem comum quando se quer deixar dois ou mais botões em uma linha, com espaços iguais entre si e ocupando todo o elemento pai. Uma propriedade de css que existe há uma grande porção de tempo resolvia isso sem grandes problemas: a text-align-last. Contando que quando se tem uma linha, a primeira também é a última. No IE 5.5 bastava colocar esta propriedade como text-align-last: justify; e pronto. O efeito obtido já era o desejado.

Nos navegadores atuais, o único que suporta tal propriedade é o Firefox. Pasmem, nem o Chrome dá suporte a isso. Não obstante, o suporte ao simples text-align é vasto. Este funciona normalmente, exceto na última linha. Uma forma inteligente de resolver esse problema é dada pelo uso do pseudo-seletor :after, criando uma linha vazia após a desejada. Isso torna possível justificar o conteúdo da linha que outrora não era capaz.

```html
<div class='parent'>
    <div class='son'></div>
    <div class='son'></div>
    <div class='son'></div>
</div>
```

```scss
/* scss */
.parent {
    height: 100px;
    text-align: justify;

    .son {
        display: inline-block;
        background: black;
        height: 100px;
        width: 20px;
    }

    &:after {
        content: ''; /* conteúdo vazio */
        display: inline-block; /* com o inline-block este conteúdo tenta permanecer na mesma linha dos elementos irmãos */
        width: 100%; /* porém, como a linha ocupa 100% do pai, isto força o início de outra linha */
    }
}
```

Os problemas apresentados neste artigo são um ínfimo pedaço que o grande problema de cross-browsing representa. Além desses, existem problemas de manutenibilidade de código relacionados a arquivos separados de fallback, por exemplo. Em alguns casos, é possível que determinada fonte de código só seja carregada em determinados ambientes, como é o caso do IE. Neste caso, é comum criar um arquivo chamado ie.css e criar fallbacks específicos. O problema emerge quando o arquivo fica tão grande que passa a conflitar com outras regras.

Em suma, não há um cenário belo no suporte a múltiplas plataformas. Os simples exemplos aqui apresentados demonstram que para alcançar determinados objetivos deixa-se de lado a intuitividade do código. Isto é decorrente da plataforma web estar presa a navegadores, o que deixa o desenvolvedor à mercê de suas implementações. Com isso, a fim de satisfazer os casos distintos de cada navegador, o desenvolvedor escreve códigos semelhantes a canivetes suíços.

Espero que tenham apreciado este post. Caso tenham gostado, deixem abaixo suas experiências surreais relativas a este assunto!
