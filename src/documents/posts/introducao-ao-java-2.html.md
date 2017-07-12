---
title: Introdução ao Java - parte 2
date: 2017-03-20
category: back-end
layout: post
description: Entenda como controlar o fluxo de funcionamento do seu código usando expressão booleana e do funcionamento do "if", "else", "for", "while" e de alguns operadores.
authors: [tcelestino]
tags:
  - java básico
  - controle de fluxo
  - expressões booleanas
---

No [primeiro post da série de introdução ao Java](/introducao-ao-java/), mostrei como configurar e executar nosso código Java. Continuando, nesse post vou apresentar alguns conceitos que serão necessários para lidarmos com o controle de fluxo na lógica de funcionamento dos nossos códigos. Sim, vamos continuar no básico, porém essencial para os próximos posts. Mas vamos deixar de conversa e partir para o que mais interessa: código!

## Lidando com o controle de fluxo

Se você já iniciou algum estudo em qualquer linguagem de programação, acredito que já tenha ouvido falar de "if", "else", "while" e "for". Essas palavras são usadas quando queremos criar alguma condicional, ou seja, controlar o fluxo de funcionamento dos nossos códigos.

Para trabalharmos com condicionais, vamos precisar criar uma expressão booleana, que é uma expressão a qual retorna "true" (verdadeiro) ou "false" (falso). Para obter o resultado esperado, podemos usar os seguintes operadores: `<` (menor que), `>` (maior que), `<=` (menor ou igual a que), `>=` (maior ou igual a que), `==` (igual a), `!=` (diferente de), entre outros. Basicamente, podemos encontrar esses operadores em diversas outras linguagens como PHP, Ruby, Javascript entre outras.

### - if, else, else if

Vamos imaginar o seguinte caso: apenas maiores de idades podem visualizar a mensagem de texto.

```Java
public static void main(String[] args) {
  int menorIdade = 15;

  if(menorIdade < 18) {
    System.out.println("Você ainda é menor de idade!");
  } else {
    System.out.println("Agora você é maior de idade.");
  }
}
```

Analisando o código acima, podemos notar que existe uma expressão booleana, na qual verificamos se o valor da nossa variável `menorIdade` tem o valor menor que o número 18. Para executar o código acima, [tem a cola aqui](/introducao-ao-java/). Agora, se alterarmos o valor da variável para um valor acima de 18, o que acontece? Execute o código e veja.

Para deixarmos mais interessante nosso código, vamos adicionar mais uma expressão booleana. Com isso, vamos verificar duas situações:

1. se o valor da variável `menorIdade` é menor que 18;
2. se o valor da variável `menorIdade` é exatamente igual a 18.

```Java
public static void main(String[] args) {
  int menorIdade = 15;

  if(menorIdade < 18) {
    System.out.println("Você ainda é menor de idade!");
  } else if (menorIdade == 18) {
    System.out.println("Agora você é maior de idade.");
  } else {
    System.out.println("Reveja sua idade, parça!");
  }
}
```

Se alterarmos o valor da variável `menorIdade` para 18, a condicional entrará no `else if`, mas e se trocarmos o valor para um número maior que "18", o que aconteceria?

### - while

A palavra "***while***", no português, pode ser traduzida pela palavra "enquanto". Na expressão booleana, podemos usar o `while` quando precisamos executar uma operação enquanto a nossa expressão booleana for verdadeira. Para ficar mais claro, vamos ao exemplo básico de como utilizá-lo.

```Java
public static void main(String[] args) {
  int numero = 0;

  while(numero < 20) {
    System.out.println(numero);
    numero = numero + 1;
  }
}
```

A variável `numero` receberá novos valores até chegar ao valor ao qual está sendo comparada. Ou seja, enquanto a condição booleana for verdadeira (`true`), o código será executado, sobrescrevendo o valor anterior da variável numero com a soma do valor atual mais 1. A execução do trecho do código entre as chaves do `while` só é finalizada quando o valor da variável chegar a exatamente 20. Vamos melhorar o nosso código, deixando-o um pouco mais interessante.

```Java
public static void main(String[] args) {
  int i = 0;
  while(i < 20) {
    if(i < 18) {
      System.out.println("Você ainda é menor de idade!");
    } else if(i == 18) {
      System.out.println("Agora você é maior de idade.");
    }
    i++;
  }
}
```

Isso é apenas um exemplo de como podemos fazer uma combinação de várias expressões booleanas para criar lógicas em nossos códigos.

### - for

O `for` tem o mesmo comportamento do `while`, porém podemos executar nossos códigos de maneira mais prática. Veja o exemplo:

```Java
public static void main(String[] args) {
  for (int i = 0; i < 20; i++) {

		if(i < 18) {
			System.out.println("Você ainda é menor de idade!");
		} else if(i == 18) {
			System.out.println("Agora você é maior de idade.");
		}
  }
}
```
Já que o `for` e o `while` são bem "parecidos", você deve estar se perguntando: quando usar o `for` e o `while`? Tudo vai depender de como você está implementando seu código e também do seu gosto. Eu prefiro o `for` porque consigo entender mais facilmente o que está acontecendo. Fica ao seu gosto!

## Controlando loops

Agora que sabemos usar os loops, por que não aprender a controlá-los? Para ficar mais fácil de entender, vejamos o exemplo:

```Java
public static void main(String[] args) {
  String times[] = {
		"São Paulo",
		"Palmeiras",
		"Vitória",
		"Ferroviária",
		"Santos",
		"XV de Piracicaba"
	};

  for (int i = 0; i < times.length; i++) {
    if(times[i].equals("Vitória")) {
      System.out.println("Esse é o time do " + times[i]);
      break;
    }
  }
}
```
Para usarmos o `for`, precisamos passar alguns paramêtros que fará o controle do nosso "loop". Na variável `i`, guardamos um valor padrão (no nosso caso, 0) e precisamos fazer uma comparação (expressão booleana) entre o valor de `i` e o total de itens do nosso "array". Feito isso, o "loop" será executado até encontrar a palavra que estamos buscando (Vitória). Ao encontrar a palavra, o "loop" é finalizado, deixando de percorrer nosso "array" (o `break` é o responsável por essa finalização). Isso é bom para performance, já que não é preciso pecorrer todo o "array" para fazer a busca do valor.

Além do `break`, temos a palavra chave `continue`. Diferente do `break`, ao usar o `continue` fazemos nosso código parar de executar uma iteração e passar para a próxima iteração do nosso código.

```Java
public static void main(String[] args) {
  for (int i = 0; i < 100; i++) {
    if (i > 10 && i < 20) {
      continue;
    }
    System.out.println(i);
  }
}
```

Se notar bem os números impressos no seu terminal, vai notar que nem todos foram exibidos.

Existem outras formas de recuperar valores de um "array". Se tiver interesse, o Diego César escreveu um post bem explicativo sobre [programação funcional com o Java 8](/introducao-a-programacao-funcional-com-java8/).

## Resumo

Nesses dois primeiros posts sobre Introdução ao Java ([leia o primeiro post](/introducao-ao-java/)), aprendemos como configurar o Java e como executar nosso código sem necessidade de uma IDE. Também descobrimos como que podemos utilizar expressões booleanas para criar fluxos em nosso código, controlando loops e criando condicionais. Agora, acredito que podemos evoluir nossos estudos, começando a estudar algo mais real, principalmente o grande princípio do Java: Orientação a Objetos. Preparados!?
