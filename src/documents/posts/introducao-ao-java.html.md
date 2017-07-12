---
title: 'Introdução ao Java'
date: 2016-09-26
category: back-end
layout: post
description: O primeiro post de uma série sobre como começar a codificar algo em Java. Nesse primeiro post você vai entender como que funciona a execução do Java no computador, além de entender sobre tipos primitivos.
authors: [tcelestino]
tags:
  - java
---

Entrei para o time de front-end do [Elo7](http://elo7.com.br) tem alguns meses e digo que fiquei "assustado" quando vi que o time mexia muito com código Java. Meu susto maior é que minha única experiência com a linguagem foi na época da faculdade, chegando apenas a desenvolver o [iSnake](https://github.com/tcelestino/iSnake). Tirando isso, posso dizer que minha experiência é `null`.

Mas chega de história e vamos ao que interessa!

## Instalando o Java

Antes de começar a escrever algum código, vamos precisar verificar se já temos o Java instalado. Para descobrir se já tem o compilador Java instalado em seu computador, execute o seguinte comando no terminal:

```bash
$ javac -version
```

Você precisa ver uma mensagem como a que aparece na imagem abaixo:

![Verificando se já temos o Java instalado](../images/introducao-ao-java-1.png)

Estou usando a versão 8 do Java, provalvemente você estará usando uma outra versão, que não vai impactar por enquanto nossos primeiros passos. Agora, caso a mensagem não seja parecida com a que tem na imagem acima, recomendo esse [artigo](https://goo.gl/XfZCiB) do pessoal da Caelum que explica como fazer a instalação do Java em diversos sistemas operacionais.

## Nossa primeira classe

Para começarmos a fazer algum código, vamos apenas precisar do terminal e seu editor de texto preferido (Sublime, Atom, Bloco de Notas etc...). Sim, por enquanto não vamos usar nenhuma IDE, assunto que ficará para os futuros posts. Com seu editor de texto aberto, escreva (ou copie) o código abaixo:

```Java
public class HelloWorld {
  public static void main(String[] args) {
    System.out.println("Hello World!");
  }
}
```

Salve o arquivo como *HelloWorld.java*. No terminal digite o seguinte comando:

```bash
$ javac HelloWorld.java
```

**Explicando:** o comando *javac* irá compilar seu *nomeClasse.java* e criar um arquivo chamado *nomeClasse.class*, no nosso caso *HelloWorld.class*.

Depois de compilar nosso arquivo, vamos precisar executar o nosso código compilado. Rode o comando:

```bash
$ java HelloWorld
```

**Explicando:** o comando *java* irá executar o nosso arquivo compilado.

![Nossa primeira classe: Hello World!](../images/introducao-ao-java-2.png)

**Nota:** Todos os exemplos de código que serão usados nos posts, estarão disponíveis [nesse repositório](http://github.com/tcelestino/intro-java)

## Entendendo tipos primitivos

No Java, precisamos sempre definir o tipo das variáveis que não poderá ser modificada em qualquer momento da execução do código. Existem 8 tipos de dados primitivos (char, boolean, byte, int, short, long, float e double). Vou explicar algumas delas.

### #int

Variáveis do tipo *int* armazenam valores inteiros. Além disso, podemos realizar operações matemáticas (somar, subtrair, dividir, multiplicar, etc..) com os valores armazenados. Segue um exemplo:

```java
public class ExampleInt {
  public static void main(String[] args) {
    int bornYear = 1987;
    int actualYear = 2016;
    int myAge = bornYear - actualYear;
    int myNewAge = myAge + 1;

    System.out.println(myAge);
    System.out.println(myNewAge);
  }
}
```

### #double

Em variavéis do tipo *double*, podemos armazenar valores com pontos flutuantes (Ex.: 1.89) e além desses valores fracionados, o *double* também aceita números inteiros. E assim como nas variáveis do tipo *int* é possível fazer operações matemáticas.

```java
public class ExampleDouble {
  public static void main(String[] args) {
    double dollar = 3.20;
    double weight = 75;
    double count = weight / 3;

    System.out.println(dollar);
    System.out.println(weight);
    System.out.println(count);
  }
}
```

**Nota:** assim como o *double*, existe o tipo *float* que também aceita valores fracionados, sendo que a diferença entre eles fica pela quantidade de bytes que cada um pode suportar. No **float** são 4 bytes e no *double* 8 bytes.

### #char

Variáveis do tipo *char* apenas podem receber um caractere. Ou seja, você não pode escrever um texto, ou definir um número para ela.

```java
public class ExampleChar {
  public static void main(String[] args) {
    char e = 'e';

    System.out.println(e);
  }
}
```

Vale anotar que variáveis desse tipo não podem receber um valor vazio, isso porque um valor vazio não é um caractere. Veja o exemplo:

```java
public class ExampleChar2 {
  public static void main(String[] args) {
    char charEmpty = '';

    System.out.println(charEmpty);
  }
}
```

Se tentar compilar, terá o seguinte erro no terminal:

![Erro ao tentar compilar um char vazio](../images/introducao-ao-java-4.png)

### #boolean

Variáveis do tipo *boolean* apenas possuem dois valores: *true* ou *false*. As palavras *true* e *false*, no Java são palavras reservadas, ou seja, só podem ser usadas em variáveis que são do tipo *boolean*.

```java
public class ExampleBoolean {
  public static void main(String[] args) {
    boolean isBrazilian = true;
    boolean isFitness = false;

    System.out.println(isBrazilian);
    System.out.println(isFitness);
  }
}
```

Agora, se tentarmos adicionar valores que não sejam do tipo definido, o que pode acontecer? Vamos criar um arquivo que vamos chamar de *MyPersonalInfo.java* e vamos escrever (pode copiar) o código abaixo:

```Java
public class MyPersonalInfo {
  public static void main(String[] args) {
    char t = 29;
    int age = 78.9;
    double weight = true;
    boolean isBrazilian = "a";

    System.out.Println(age);
    System.out.Println(weight);
    System.out.Println(isBrazilian);
  }
}
```

Ao tentar compilar o arquivo, provavelmente você verá uma mensagem como a da imagem abaixo:

![Exibe erros ao tentar compilar o código Java](../images/introducao-ao-java-3.png)

Isso acontece porque o Java é uma linguagem fortemente tipada, ou seja, toda variável precisa ter um tipo especifico, sendo que após seu tipo ser declarado a variável será até o seu fim do mesmo tipo. Vale lembrar que a tipagem não está restrita apenas a variáveis, mas também aos metódos, mas isso fica para os futuros posts.

Se tiver algo para acrescentar/sugerir, deixe nos comentários e aguardem os próximos posts.

**Fonte:** [Variáveis primitivas e Controle de fluxo](https://www.caelum.com.br/apostila-java-orientacao-objetos/variaveis-primitivas-e-controle-de-fluxo/)
