---
date: 2017-05-15
category: front-end
tags:
	- float
	- inline-block
	- flex
	- alinhamento vertical
	- css
	- posicionamento
authors: [alinelee]
layout: post
title: Posicionando elementos com CSS
description: Posicionando elementos na tela com css utilizando diferentes técnicas e ponderando pontos positivos e negativos de cada uma.
---
Posicionar elementos na tela em layout responsivo pode ser uma das partes mais chatas na construção de um site.
Muitas vezes decidir qual método utilizar, considerando suas vantagens e desvantagens, é a chave para uma economia valiosa de tempo no desenvolvimento.

Vamos considerar que queremos exibir uma simples galeria de imagens a qual deve exibir cinco imagens posicionadas em uma linha, não permitindo que as imagens fiquem esticadas. Caso a tela seja pequena demais elas devem diminuir de tamanho proporcionalmente.

![Alt "Exemplo de layout"](../images/posicionando-com-css-1.png)

Para isso, aplicaremos três diferentes técnicas no seguinte HTML:

```HTML
<h2>Titulo</h2>
<ul class="galeria">
	<li><img src="img/jigglipuff.png"></li>
	<li><img src="img/kirby.png"></li>
	<li><img src="img/madimbu.png"></li>
	<li><img src="img/patrick.png"></li>
	<li><img src="img/jujuba.png"></li>
</ul>
<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, ...</p>
```

## float: left

O float possui o poder de fazer um elemento flutuar para direita ou esquerda, ocupando o espaço livre e fazendo com que o resto do conteúdo se encaixe ao seu redor. Desta maneira conseguimos deixar as imagens posicionadas uma ao lado da outra.

O CSS ficará assim:

```CSS
.galeria {
	background-color: grey;
}
.galeria li {
	float: left;
	max-width: 20%;
}
```
Porém o resultado seria algo desse tipo:

![Alt "Exemplo de layout quebrado utilizando float"](../images/posicionando-com-css-2.png)

Um dos problemas desta abordagem é que, como a `<ul>` possui filhos flutuantes, ela deixa de conhecer o próprio tamanho e acaba, por exemplo, não pintando o *background-color*, uma vez que a `<ul>` tem tamanho 0. Uma maneira simples de se corrigir isso é utilizando a propriedade *overflow*, que irá forçar a `<ul>` a calcular o tamanho de seus filhos.

```CSS
.galeria {
	overflow: auto;
}
```

Lembrando que é possível utilizar também o valor *scroll*, que irá incluir a barra de rolagem, e o *hidden*, que irá cortar o conteúdo passado para o container.

Um ponto de atenção que pode ser observado na imagem é, que caso sobre espaço após as imagens, os elementos seguintes poderão se encaixar nele. Considerando que não precisamos do *overflow*, uma outra opção é utilizar o *clear-fix*, que é muito utilizado nesses casos, algo como `clear:left` ou `clear:both` no primeiro elemento que não deve mais flutuar para quebrar a regra.

```CSS
.proximo-elemento-nao-flutuante {
	clear: both;
}
```
![Alt "Exemplo de com clear-fix"](../images/posicionando-com-css-3.png)

Outro problema é que o float não possui meios para a distribuição do espaço entre as `<li>`s automaticamente e, por isso, é necessário incluir um valor manualmente, utilizando por exemplo um *padding-right* ou um *margin-right* para não deixar as imagens coladas. Ou seja, caso algo mude no layout, esse valor deverá ser alterado.

### Prós e Contras
Prós
- Muito bem suportado pelos navegadores.
- Muito utilizado e documentado.

Contras
- Trabalhoso!
- É necessário fazer clear-fix, quando o float começa a influenciar indesejavelmente no layout dos outros elementos.
- Não é possível centralizar verticalmente ou horizontalmente.
- Pode alterar a ordem dos elementos HTML na tela, estragando por exemplo a ordem do tabindex.
- Caso você adicione outra imagem, terá que alterar o CSS.

## display: inline-block

O inline-block consegue dispor os elementos um ao lado do outro, quebrando a linha sempre que o elemento for grande demais. É muito bem aceito pelos navegadores, não precisa de clear-fix e, diferentemente do inline, respeita largura e altura.
Porém, ao combiná-lo com porcentagens, dificilmente conseguiremos chegar aos 100%, isso porque a própria quebra de linha do HTML inclui um pixel fantasma no layout e, se você não gosta de números mágicos surgindo no CSS, não vai curtir isso.

Existem maneiras de resolver isso, infelizmente nem todas muito polidas.
Uma delas é deixar o último `<li>` menor mesmo. Assim a soma de todos os elementos será menor que 100%, e seu layout não quebrará.

O que também funciona é comentar a quebra de linha do HTML, algo assim:

```HTML
<ul class="galeria">
	<li><img src="img/jigglipuff.png"></li><!--
	--><li><img src="img/kirby.png"></li><!--
	--><li><img src="img/madimbu.png"></li><!--
	--><li><img src="img/patrick.png"></li><!--
	--><li><img src="img/jujuba.png"></li>
</ul>
```
Você também pode utilizar o font-size: 0. Com isso, todo o texto ficará tão pequeno que não irá aparecer na tela. É possível usar essa técnica quando não se tem texto no ponto aplicado, o problema é que as medidas em `em` deixarão de funcionar pois você zerou o valor no qual ele se baseia. Caso você precise utilizar, terá que definir novamente o font-size utilizando `px` ou `rem`.

```HTML
<ul class="galeria">
	<li><img src="img/jigglipuff.png"></li>
	<li><img src="img/kirby.png"></li>
	<li><img src="img/madimbu.png"></li>
	<li><img src="img/patrick.png"></li>
	<li><img src="img/jujuba.png"></li>
</ul>
```

```CSS
.galeria {
	padding-right: 1em;
	text-align: center;
	font-size: 0;
}
.galeria li {
	font-size: 16px;
}
```

Acredito que a opção mais polida delas (mas nem tanto) é deixar de fechar as tags `<li>`. Se você utiliza `Doctype HTML5`, na teoria não é necessário fechá-las e isso irá remover o bug.

O código ficará assim:

```HTML
<ul class="galeria">
	<li><img src="img/jigglipuff.png">
	<li><img src="img/kirby.png">
	<li><img src="img/madimbu.png">
	<li><img src="img/patrick.png">
	<li><img src="img/jujuba.png">
</ul>
```

Infelizmente, semelhante ao *float*, o *display-inline* não distribui o espaço automaticamente entre os elementos. Mas é possível centralizar horizontalmente utilizando a propriedade `text-align: center`,  contornando melhor o problema.
Assim como o *float*, definimos paddings na `<li>` para delimitar o espaço mínimo entre as imagens.

```CSS
.galeria {
	padding-right: 1em;
	text-align: center;
}

.galeria li {
	padding-left: 0.1em;
	padding-right: 0.1em;
	box-sizing: border-box;
	display: inline-block;
	width: 20%;
}
```

### Prós e Contras
Prós
- Bem suportado pelos navegadores. Não tanto quanto float, funcionando bem a partir do IE 8.
- Muito utilizado e documentado.
- Fácil de utilizar.
- É possível centralizar verticalmente.

Contras
- Exige números mágicos ou hacks para encaixar os elementos na quantidade desejada.
- Caso você adicione outra imagem, terá que alterar o CSS.

## display: flex

O flex é uma abordagem mais recente, por isso, nem pense em Internet Explorer (IE) do 9 para trás. Mas, se esse não é o seu caso, você está com sorte.
Combinando o `display: flex` com a declaração `justify-content: space-between`, teremos todas as imagens alinhadas e com o espaço que sobrar alinhado entre elas.

```CSS
.galeria {
	display: flex;
	justify-content: space-between;
}
```
O alinhamento vertical e horizontal, que é bem difícil nas outras técnicas, acaba sendo mais viável com o flex, além de oferecer mais opções. Por exemplo, considerando que a galeria é mais alta, poderíamos alinhar todos os itens no centro utilizando:

```CSS
.galeria {
	align-items: center; //Poderia ser flex-start | flex-end | center | baseline | stretch
}
```
![Alt "Exemplo de align-items center com flex"](../images/posicionando-com-css-4.png)

Ou então poderíamos criar regras mais específicas e alinhar os itens pares embaixo:
```CSS
.galeria li:nth-child(2n) {
	align-self: flex-end; //Poderia ser flex-start | flex-end | center | baseline | stretch
}
```
E os itens ímpares no meio:

```CSS
.galeria li:nth-child(2n+1) {
	align-self: center; //Poderia ser flex-start | flex-end | center | baseline | stretch
}
```
![Alt "Exemplo de align-self center e flex-end"](../images/posicionando-com-css-5.png)

O interessante do flex é que, com ele, além de conseguir resolver os problemas que temos com as outras técnicas, ainda temos muitas possibilidades disponíveis.

### Prós e Contras
Prós
- Alinhamento vertical.
- Alinhamento horizontal.
- É possível facilmente alterar a ordem dos elementos, dizendo qual a posição que cada elemento deve aparecer.
- Com o flex você consegue até determinar se os itens devem estar dispostos em linha ou coluna e até mesmo inverter eles.
- As propriedades flex-grow e flex-shrink abrem várias possibilidades pois, com elas, você pode escolher itens que ficarão proporcionalmente maiores que os outros e determinar o quanto eles podem encolher.
- Você consegue chegar no mesmo resultado de várias formas utilizando o flexbox.

Contras
- Não é bem suportado, o que traz a necessidade de se utilizar fallbacks, prefixos ...
- Existem versões diferentes, que trocam não só os prefixos das propriedades, mas a propriedade em si e a maneira como é aplicada.
- Por possuir versões que irão funcionar de maneiras diferentes em cenários distintos, acaba ficando difícil de aplicar e dar manutenção a códigos mais antigos.
- Como possui muitas propriedades, que nem sempre são tão intuitivas, você precisa estudar e por vezes *relembrar* o que elas fazem.

### Resumindo

`Float`, `inline-block` e `flex` são técnicas comuns e bastante utilizadas para resolver layouts como o proposto nesse post. [Você pode conferir um exemplo destas abordagens aqui](https://alinelee.github.io/galeria-exemplo/). Lembrando que existem outras técnicas de posicionamento com CSS que não foram abordados nesse post, como o `position`, que se ajusta muito bem a outros cenários.

Por enquanto é só! Em breve, teremos uma série de posts comentando mais especificamente sobre as propriedades do CSS, então aproveite para deixar suas dúvidas e sugestões. Até a próxima!
