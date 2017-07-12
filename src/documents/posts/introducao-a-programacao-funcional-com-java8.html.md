---
title: 'Introdução à programação funcional com Java 8'
date: 2016-12-05
category: back-end
layout: post
description: Disponível desde 2014, o Java 8 ainda deixa muitas dúvidas, principalmente quanto às novidades em relação à sua versão anterior. Nesse post vou falar sobre as principais novidades do Java 8.
authors: [diegocesar]
tags:
  - java
  - java8
  - back-end
---

Disponível desde 2014, o Java 8 ainda deixa muitas dúvidas, principalmente quanto às novidades em relação à sua versão anterior e a incorporação de conceitos de programação funcional. Nesse post vou falar sobre as principais novidades do Java 8 relativas a esse aspecto. É importante observar que o Java 8 foi desenvolvido pensando na retrocompatibilidade, ou seja, aplicações desenvolvidas na versão 7 funcionarão perfeitamente nas versões mais atuais da linguagem. Esse é um dos pontos fortes do Java, que ajudam a garantir o seu sucesso.

Veremos a seguir um pouco sobre as principais novidades implementadas no Java 8:

## Lambda expressions
Uma das principais e mais comentadas mudanças do Java 8 são as **Lambda Expressions**, que trazem um pouco do paradigma da programação funcional para o Java. [Segundo a Oracle](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/Lambda-QuickStart/index.html), Lambda é uma forma clara e objetiva de representar um método usando apenas uma expressão.
É importante lembrar que as Lambda Expressions só funcionarão para **interfaces funcionais**, que são interfaces que possuem apenas um método.

Exemplo:

**Sem lambda =/**
```java
interface Operator {
	abstract float calc(float number1, float number2);
}

public class Calculator {
	public static void main(String[] args) {
		System.out.println(
			calculate(15, 10, new Operator(){
				public float calc(float num1, float num2) {
					return num1 + num2;
				}
			})
		);
	}

	public static float calculate(float number1, float number2, Operator operator) {
		return operator.calc(number1, number2);
	}
}
```

**Com lambda =D**
```java
interface Operator {
	abstract float calc(float number1, float number2);
}

public class Calculator {
	public static void main(String[] args) {
		System.out.println(
			calculate(15, 10, (number1, number2) -> { return number1 + number2; })
		);
	}

	public static float calculate(float number1, float number2, Operator operator) {
		return operator.calc(number1, number2);
	}
}
```

Resultado: `25.0`

## Stream
Stream é uma abstração que permite processar dados de coleções de forma declarativa usando Lambda Expressions.
Muitas das operações que eram feitas utlizando loops complexos podem ser substituidas por streams, desta forma simplificamos o código e ganhamos em performance.

Os passos para fazer uso do Stream são:

1. Obter o Stream a partir de uma Collection:
```java
	List<Integer> numbers = Arrays.asList(3, 2, 1, 3);
	Stream stream = numbers.stream();
```

2. Adicionar uma ou mais operações no pipeline como ordenações, filtros etc. Por exemplo, podemos ordenar e remover os itens duplicados de uma lista:
```java
	stream = stream.sorted().distinct()
```

3. Invocar o método collect, responsável por processar o pipeline e retornar o resultado no formato solicitado.
```java
	List<Integer> result = stream.collect(Collectors.toList());
```

Veja algumas das operações que você pode executar em um Stream:

### filter

Filtra *strings* ou *streams* de acordo com a regra passada como parâmetro. No exemplo abaixo, filtra todas as '*strings* não vazias'.

```java
public void removeEmptyStrings() {
	List<String> strings = Arrays.asList("abc", "", "bc", "abcd", "", "xyz", "foo");
	strings = strings.stream().filter(var -> !var.isEmpty()).collect(Collectors.toList());
}
```

Resultado: `[abc, bc, abcd, xyz, foo]`

### sorted

Tem como função ordenar os itens de um *Stream*, como no seguinte exemplo:

```java
public void sortListAlphabetically() {
	List<String> strings = Arrays.asList("z", "x", "a", "c", "b", "y");
	strings = strings.stream().sorted().collect(Collectors.toList());
}
```

Resultado: `[a, b, c, x, y, z]`


Também é possível ordenar utilizando regras diferentes da natural:

```java
public void sortNumbersReversed() {
	List<Integer> numbers = Arrays.asList(3, 5, 1, 4, 2);
	numbers = numbers.stream().sorted((num1, num2) -> num2 - num1).collect(Collectors.toList());
}
```

Resultado: `[5, 4, 3, 2, 1]`

### map

O map aceita uma função como argumento que pode transformar cada um dos itens em um novo elemento:

```java
public void countStringCharacters() {
	List<String> strings = Arrays.asList("one", "two", "three", "four");
	List<Integer> totals = strings.stream().map(str -> str.length()).collect(Collectors.toList());
}
```

Resultado: `[3, 3, 5, 4]`

### reduce

O objetivo do reduce, como o nome sugere, é reduzir o número de itens de um *Stream* em um único valor. Para isso, ele recebe um argumento (opcional) que será utilizado como valor inicial do segundo argumento. O próximo argumento (obrigatório) é uma função que deve receber dois parâmetros, tratá-los da maneira desejada e devolver um resultado. Este resultado será o primeiro parâmetro desta mesma função na próxima iteração e o segundo parâmetro será o próximo elemento do *Stream*.

Exemplo: Retornar a soma dos números pares de uma lista:

```java
public boolean isEven(int number) {
	return number % 2 == 0;
}

public void sumEvenNumbers() {
	List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6);
	Integer result = numbers.stream().reduce(0, (total, nextNumber) -> isEven(nextNumber) ? total + nextNumber : total);
}
```

Na primeira iteração, o nosso lambda recebe no parâmetro `total` o valor inicial `0`, que foi passado como argumento para o reduce, e o `nextNumber` recebe `1`, o primeiro valor da lista. Como `1` não é um número par, devolvemos o total atual: `0` para o reduce, que inicia a próxima iteração.
No passo seguinte, o lambda recebe o total retornado pela iteração anterior: `0` e `2` como `nextNumber`. Como `2` é um número par ele será somado ao `total` e devolvido ao reduce, portanto na próxima iteração o `total` valerá `2`.

Resultado: `12`

### distinct

O distinct devolve um Stream sem nenhuma entrada duplicada.

```java
public void distinctElements() {
	List<Integer> numbers = Arrays.asList(1, 1, 2, 2, 3, 3, 4, 5);
	numbers = numbers.stream().distinct().collect(Collectors.toList());
}
```

Resultado: `[1, 2, 3, 4, 5]`

## Parallel Stream
O resultado final do Parallel Stream é o mesmo do Stream. A diferença entre eles é que, neste caso, os dados são processados de forma paralela, em várias threads, diferentemente do segundo, que é serial. O processamento paralelo por si só não garante melhora de performance, exceto em casos onde exista um grande volume de dados e múltiplos núcleos de processamento.

## Default Methods
O Java 8 permite a implementação de métodos padrões em interfaces utilizando a palavra chave **default**.
Os métodos default são úteis para incrementar interfaces sem quebrar as classes que as implementam.

```java
interface Vehicle {
	default void turnOn() {
		System.out.println("The vehicle is turned on!");
	}
}

class Car implements Vehicle { }

public class DefaultTest {
	public static void main (String[] args) {
		Car myCar = new Car();
		myCar.turnOn();
	}
}
```

Resultado: `The vehicle is turned on`


## Optionals
Optional é um *wrapper* ou *container* que pode conter ou não um valor. Esta classe contém métodos para verificar se um valor está presente ou não e recuperar o seu valor. Os métodos mais comuns são: **of**, **isPresent** e **get**.
Optionals são úteis para evitar problemas com NullPointerException, pois deixam claro que um argumento ou retorno de método podem ou não ter um valor presente. Se antigamente ficava a cargo do programador checar se o valor é `null`, com Optionals ele praticamente fica obrigado a fazer esta checagem.

```java
	// Cria um Optional a partir do número 5
	Optional<Integer> myOptional = Optional.of(5);

	// Verifica se existe um valor definido em myOptional
	if (myOptional.isPresent()) {
		// Recupera o valor de myOptional e o exibe
		System.out.println(myOptional.get());
	}
```

Resultado: 5

Essas são apenas algumas das principais novidades do Java 8. De acordo com os exemplos dados, é possível notar que ganhamos em produtividade quando utilizamos as novidades apresentadas. No caso da aplicação de streams, ainda ganhamos em performance, já que o processamento é executado através de um pipeline, seja este serial ou paralelo.

[Você encontra a lista completa de novas implementações no site da Oracle](http://www.oracle.com/technetwork/java/javase/8-whats-new-2157071.html). Consulte também a [documentação do Java 8](http://www.oracle.com/technetwork/java/javase/documentation/jdk8-doc-downloads-2133158.html) para obter a referência completa da linguagem.

O que achou das novidades? Você utiliza alguma novidade do Java 8 que não foi comentada aqui?
