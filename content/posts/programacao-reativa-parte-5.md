---
date: 2019-02-18
category: back-end
tags:
  - java
  - programacao-reativa
authors: [ljtfreitas]
layout: post
title: "Programação Reativa - Parte 5: Arquiteturas não-bloqueantes"
description: "(Mais sobre) Sistemas reativos: arquiteturas não-bloqueantes!"
---
Depois de muito falarmos sobre programação reativa, no [post anterior](/programacao-reativa-parte-4) vimos os fundamentos dos "sistemas reativos", e uma expressão em especial recebeu bastante destaque: "não bloqueante".

Mas o que significa de fato "não bloqueante"?

# Síncrono vs assíncrono vs não-bloqueante

Considere o código abaixo:

```java
String result = myObject.doSomething(); // alguma operação como acesso a um banco de dados, escrita em disco, comunicação pela rede...

// faz algo com o resultado
```

O código acima é **imperativo** e **síncrono**, e também é **bloqueante**. Mas o que efetivamente está "bloqueado"? Resposta: a **thread de execução** do programa.

Obviamente, nosso software **precisa** de uma `thread` para ser executado. Então, o que significa dizer que a `thread` está "bloqueada"?

Enquanto o programa está rodando, coisas estão acontecendo: valores estão sendo atribuídos a variáveis, cálculos estão sendo realizados, entre tantas outras coisas. Enquanto isso ocorre, nossa `thread` está utilizando a CPU; o tal "bloqueio" da `thread` ocorre quando realizamos operações que fazem a `thread`, efetivamente, **parar** sua execução.

Que operações seriam essas? Operações que envolvem algum tipo de **espera** por um recurso, e operações de I/O são os casos mais comuns (mas não os únicos): acesso à rede (como uma chamada à uma API), acesso a bancos de dados, acesso ao disco...em todos esses exemplos, enquanto o resultado dessas operações não retornarem, nossa `thread` estará, de fato, sem fazer nada!

Não obstante, temos escritos programas exatamente iguais a esse por anos, então o que está "errado"? Nada!

Mas analisemos as consequências práticas. Para começarmos de maneira simples, consideremos que, por uma necessidade do nosso software, precisemos executar esse código 100 vezes.

## Síncrono

Podemos fazer isso uma vez após a outra. É uma solução natural, afinal, nosso código precisa manter a mesma `thread` durante toda sua execução.

```java
for (int i = 1; i <= 100; i++) {
	String result = myObject.doSomething(); // operação bloqueante...

	// ...
}
```

...mas não parece uma abordagem muito interessante. Cada execução precisa **aguardar** a anterior terminar, o que limita a escalabilidade e a performance do nosso programa.

## Assíncrono

Uma solução mais inteligente parece simples: podemos executar nosso código **em paralelo**, usando diferentes `threads`.

```java
for (int i = 1; i <= 100; i++) {

	// encapsula o código em um Runnable
	Runnable block = () -> {
		String result = myObject.doSomething();

		// ...
	};

	new Thread(block).start(); // executa o bloco em outra thread
}
```

Parece melhor! E, normalmente, essa abordagem é a mais utilizada quando precisamos que nossos programas consigam fazer **mais coisas**: usamos `threads` para conseguir fazer muitas coisas ao mesmo tempo, ou executar um mesmo bloco de código muitas vezes simultaneamente, ou precisamos fazer muitas coisas diferentes em paralelo.

Esse solução certamente tem o seu valor. Mas o detalhe que os sistemas reativos trazem à tona é a questão do **uso de recursos** pelas nossas aplicações: utilizar muitas `threads` nos permite fazer muitas coisas ao mesmo tempo, mas a um **custo computacional** elevado (conforme comentamos no [post anterior](/programacao-reativa-parte-4)), em termos de uso de memória e utilização da CPU.

## Não-bloqueante

Então, implementar nosso código assumindo que usaremos apenas uma `thread` para execução e que essa `thread` irá fazer coisas que vão bloquear sua execução, pode tornar as coisas complicadas caso precisemos escalar nosso programa e executá-lo muitas vezes paralelamente. A solução assíncrona parece boa, mas utilizar muitas `threads` traz uma pegadinha embutida, que é o maior consumo de recursos de *hardware*. E agora? :(

Os sistemas reativos propõe que o software deve ser projetado para ser executado de maneira assíncrona, de modo a poder fazer muitas coisas simultaneamente; ao mesmo tempo, propôe que utilizemos um pequeno conjunto de `threads` (ou até mesmo uma única `thread`!). Para obter esse resultado, precisamos que essas `threads` **nunca fiquem bloqueadas** por nenhuma operação. Precisamos de **arquiteturas não-bloqueantes**.

Parece legal...mas como fazemos isso?

# Concorrência em aplicações web

Para exemplificar melhor as idéias comentadas acima e chegarmos à tal "arquitetura não-bloqueante", a partir desse ponto vamos explorar o desenvolvimento de uma aplicação web absolutamente comum: uma aplicação que recebe uma requisição, faz "algo" e devolve uma resposta.

Quando desenvolvemos software, especialmente para o contexto web (um site ou uma API, por exemplo), muitas vezes não consideramos detalhes de concorrência durante a implementação; simplesmente incluímos um código como o do nosso exemplo em algum ponto da aplicação (digamos, em um `controller`, um `handler` ou equivalente) e a coisa toda "apenas funciona". E isso é uma coisa positiva, pois os servidores/frameworks costumam fazer um ótimo trabalho abstraindo esse tipo de detalhe. Mas, bom, **como** funciona?

Imaginemos uma aplicação web Java típica (servlet), que utiliza um código equivalente ao exemplo anterior durante a manipulação de uma requisição HTTP.

```java
// em algum lugar que manipula requisições http...

@WebServlet(value = "/my-servlet")
public class MyServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String result = myObject.doSomething(); // alguma operação bloqueante...

		// gera uma resposta com o resultado...
		response.setStatus(200); //200 OK
		response.getWriter().append(result);
		response.getWriter().flush();

	}
}
```

Essa implementação traz algumas consequências equivalentes às discutidas acima: 1) estamos assumindo que a `thread` estará atrelada à requisição **até o fim** (o que é verdadeiro, e será garantido pelo `servlet container`); 2) essa `thread`, então, só estará disponível para outras requisições apenas após concluir a anterior; 3) essa mesma `thread`, então, só pode atender requisições **uma de cada vez**!

Mas queremos que nossa aplicação possa servir múltiplas requisições simultaneamente! A solução novamente parece simples: utilizar **mais threads!** Novamente voltamos à essa solução: precisamos de múltiplas `threads` para adicionar paralelismo à nossa aplicação, e é exatamente isso que servidores web fazem. É esse mecanismo que permite que nossas aplicações web recebam milhares de requisições ao mesmo tempo.

No caso dos servidores Java que implementam a especificação de *Servlets* (como o Tomcat, o Jetty e outros), esse comportamento pode se apresentar de duas maneiras:

## Thread-per-connection

Um modelo é o **thread-per-connection**, que utiliza uma `thread` por conexão HTTP; se a conexão for [persistente](https://en.wikipedia.org/wiki/HTTP_persistent_connection), múltiplas requisições poderão ser feitas sobre a mesma conexão, e serão atendidas pela mesma `thread`; quando a conexão é enfim fechada, a `thread` está novamente disponível. O tempo demonstrou que essa abordagem não é escalável, pois `threads` são relativamente caras em relação ao uso de memória (que crescerá em proporção direta ao número de conexões no servidor). Servidores com um número fixo de `threads` podem chegar ao ponto de rejeitar requisições enquanto todas as `threads` estiverem ocupadas (problema conhecido como *thread starvation*).

## Thread-per-request

Uma evolução dessa abordagem é o modelo chamado como **thread-per-request**, onde uma `thread` é utilizada (associada à conexão) apenas durante o processamento da requisição; após o envio da resposta HTTP, a `thread` volta a estar disponível para atender outras requisições. Os servidores web Java populares (Tomcat, Jetty, Grizzly, etc) funcionam dessa maneira por padrão: uma `thread` estará vinculada à requisição do início ao fim, e então será liberada.

O modelo de *thread-per-request*, com efeito, é potencialmente mais eficiente do que o *thread-per-connection*. Mesmo com um número fixo de `threads` e com o mesmo hardware, o servidor será capaz de lidar com um número muito maior de requisições.

Parece interessante, não? Então, consideremos a seguinte situação:

```java
// em algum lugar que manipula requisições http...

@WebServlet(value = "/my-servlet")
public class MyServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String result = myObject.doSomething(); // alguma operação bloqueante e lenta...

		// gera uma resposta http com o resultado...
		response.setStatus(200);
		response.getWriter().append(result);
		response.getWriter().flush();
	}
}
```

Considere que nossa aplicação está recebendo muitas requisições: o que acontecerá se **todas** as `threads` do servidor estiverem bloqueadas aguardando a resposta do método `myObject.doSomething()`, enquanto novas requisições continuam chegando?...nossa aplicação ficará indisponível!

Isso não ocorrerá imediatamente, pois quando todas as `threads` do servidor estiverem ocupadas, novas requisições são empilhadas aguardando o momento de serem atendidas, mas essa pilha tem um tamanho limitado. Após esse limite ser atingido, novas requisições serão simplesmente recusadas.

## Do síncrono para o assíncrono

Então, o design acima apresenta um problema: durante a manipulação da requisição, realizamos uma operação que demanda um certo intervalo de tempo, e a `thread` está bloqueada durante esse período e impedida de ser liberada para outras requisições. Temos um primeiro sinal, aqui, que bloquear a `thread` não parece algo muito legal. Talvez possamos pensar: "precisamos tornar esse código assíncrono e liberar a thread! o método precisa executar em uma thread separada!"; Essa é uma abordagem muito comum para esse problema. Mas será que daria certo?

Digamos que refatoramos o código; o método "doSomething" agora é **assíncrono** e é executado em uma `thread` separada. Ao invés do resultado ser devolvido no retorno do método, refatoramos a assinatura para recebermos um `callback` como argumento:

```java
interface MyObject {

    // nova assinatura do método; a implementação será assíncrona
	void doSomething(Consumer<String> calback);
}

@WebServlet(value = "/my-servlet")
public class MyServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// doSomething agora executa em outra thread :)
		myObject.doSomething(result -> {
			// em outra thread, com o resultado

			// gera uma resposta http...
			response.setStatus(200);
			response.getWriter().append(result);
			response.getWriter().flush();
		});

		/*
			a thread associada à requisição não está mais bloqueada e pode prosseguir a execução,
			retornando ao servidor para atender outras requisições :)
		*/
	}
}
```

Seria uma idéia interessante...mas esse código não funciona! O motivo é que a `thread` principal (associada à requisição) irá continuar em frente e retornar ao servidor, e a resposta será enviada nesse momento; quando a `thread` do método "doSomething" executar o `callback`, já não seremos capazes de escrever a resposta porque ela já foi enviada.

Talvez possamos fazer nosso "doSomething" devolver um [Future](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/concurrent/Future.html), para encapsular o processamento assíncrono?

```java
interface MyObject {

    // a implementação irá devolver um Future e executar o código que gera o resultado em outra thread
	Future<String> doSomething();
}

@WebServlet(value = "/my-servlet")
public class MyServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// em algum lugar que manipula requisições http...
		Future<String> promise = myObject.doSomething();

		//e agora? a computação está sendo executada em outra thread...precisamos obter o resultado do Future!

		// o método get() bloqueia a thread corrente! (pois deve aguardar a outra thread para obter o resultado)
		// voltamos ao problema anterior :(
		String result = promise.get();

		// gera uma resposta http com o resultado...
		response.setStatus(200);
		response.getWriter().append(result);
		response.getWriter().flush();
	}
}
```

Talvez possamos utilizar o [CompletableFuture](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/concurrent/CompletableFuture.html), uma variação interessante do `Future` introduzida no Java 8, que funciona baseado em `callbacks`? Infelizmente, ele também não resolveria nosso problema, pois teríamos em mãos a mesma situação relacionada à `thread` que executa o `callback`.

E agora??? :(

### Servlets assíncronos

Esse não é um post necessariamente sobre Java (bom, é sim hehe) mas vejamos uma maneira elegante de resolver esse problema utilizando um recurso fornecido pela própria linguagem: [servlets assíncronos](https://docs.oracle.com/javaee/7/tutorial/servlets012.htm):

```java
interface MyObject {

	// retornamos à versão bloqueante
	String doSomething();
}

@WebServlet(value = "/my-servlet")
public class MyServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// a partir do objeto de requisição (HttpServletRequest), obtemos um AsyncContext
		final AsyncContext asyncContext = request.startAsync();

		// o bloco será executado em outra thread! (o parâmetro é do tipo Runnable)
		asyncContext.start(() -> {
			String result = myObject.doSomething(); // bloqueio de thread...mas não é a thread do servidor

			// obtem a resposta associada ao contexto
			HttpServletResponse response = asyncContext.getResponse();

			// agora podemos gera uma resposta http com o resultado
			response.setStatus(200);
			response.getWriter().append(result);
			response.getWriter().flush();
		})

		//a thread pode prosseguir a execução; será devolvida ao pool do servidor e estará disponível para novas requisições
	}
}
```

O código acima funciona sem problemas! Servlets assíncronos são um recurso bastante poderoso e útil; conseguimos executar um processamento demorado sem bloquear a `thread` do servidor web. Mas será essa a melhor solução?

Novamente, temos a questão do uso de recursos. Criar muitas `threads` é útil para fazermos muitas coisas em paralelo, mas o outro lado da moeda é o custo computacional que isso acarreta.

Precisamos de algo um pouco complicado: um design que permita a execução concorrente do nosso código, e que permita um alto nível de paralelismo usando um pequeno número de `threads`.

## Do assíncrono para não-bloqueante

Nas abordagens acima, o bloqueio da `thread` é o nosso principal limitador de escalabilidade. Esse é um fato introduzido no código de maneira implícita e quase imperceptível, porque projetamos um design **imperativo**: nós **dizemos** explicitamente ao programa o que ele deve fazer, um passo de cada vez: chame um método, obtenha uma resposta, atribua à uma variável, chame outro método usando essa resposta...e assim vai. E um design imperativo implica que as instruções do nosso programa **aguardam** as coisas acontecerem e retornarem.

De que outra maneira poderíamos implementar isso? Talvez com um design que assuma explicitamente que os dados estarão disponíveis em **algum ponto do futuro**.

Esse é o detalhe mais importante que precisamos introduzir, pois "assíncrono" não significa necessariamente "está rodando em outra thread", como normalmente associamos, e sim que o resultado de uma computação estará disponível no **futuro**. Desse modo, podemos implementar nosso programa orientados à disponibilidade dos dados (baseados em **eventos**), e aplicar as operações que desejamos conforme as coisas acontecerem. Precisaríamos utilizar alguma abstração que nos permita **declarar** o que nosso programa deve fazer, ao invés de dizer ao programa o que fazer.

Dito isso, olhando em retrospectiva essa série de posts, podemos perguntar: não é exatamente isso que a programação reativa nos permite fazer?

No [post inicial](/programacao-reativa), aprendemos que o fundamento-chave desse paradigma é representar as entradas de um programa (digamos, uma requisição HTTP) como um **fluxo de dados**, baseado em uma sequência de eventos ordenados no tempo. No [segundo post](/programacao-reativa-parte-2), vimos que os operadores reativos nos permitem declarar (através de funções) o que deve ser feito quando os eventos reativos ocorrerem (recapitulando, eventos *onNext*, *onCompleted* e *onError*). E no [terceiro post](/programacao-reativa-parte-3), aprendemos sobre *pipelines* assíncronos.

Dito isso, correndo o risco de soar tendencioso :), a programação reativa é um modelo que parece se adequar perfeitamente aos nossos propósitos. Mas será a programação reativa "não-bloqueante"?

### O que é "não-bloqueante"?

Em relação a operações de I/O, há uma diferença mais ou menos sutil entre "assíncrono" e "não-bloqueante", de modo que esses dois termos costumam se confundir (e gerar alguma confusão). Se definirmos "assíncrono" como "uma computação cujo resultado será retornada em algum momento do futuro", poderemos dizer que, com efeito, toda operação não-bloqueante é assíncrona, mas nem toda operação assíncrona é não-bloqueante. Por que?

Operação assíncronas são equivalentes às que vimos nos exemplos anteriores: o programa utiliza `threads` para executar simultaneamente operações de natureza síncrona, de modo que a `thread` principal do programa possa continuar sua execução enquanto uma segunda `thread` é executada em paralelo. As linguagens de programação modernas oferecem estruturas de alto nível para realizar esse tipo de trabalho, embora eventualmente alguma complexidade se torne mais ou menos necessária (como métodos sincronizados, gerenciamento de `pools` de `threads`, etc).

Uma operação de I/O não-bloqueante é um pouquinho mais complexa. O programa delega o controle ao **sistema operacional**, através de um [channel](https://en.wikipedia.org/wiki/Channel_I/O), que avisará o programa **quando os dados estiverem disponíveis**. O mesmo ocorre para operações de escrita: o programa pode ser avisado quando **os dados puderem ser escritos**, fazendo isso aos poucos, ao invés de escrever todos os dados de uma vez.

A `thread` do programa não fica bloqueada em nenhum momento, pois não é necessário que aguarde o resultado da operação de I/O (que é executada em segundo plano pelo SO), mas é responsável por verificar o estado do **chanell**. Mas, como a `thread` já não precisar perder tempo em operações de bloqueio, ela é capaz de processar leituras e escritas em múltiplos **channels**. Ou seja, com uma única `thread`, é possível realizar várias operações de I/O simultaneamente!

Isso é possível por um mecanismo chamado **multiplexação**. Para ilustrar, imaginemos uma situação como um garçom em um restaurante; seria complicado manter um garçom para cada mesa, certo? Ao invés disso, um único garçom é capaz de atender vários pedidos, pelo simples fato de não permanecer "parado" em uma única mesa! Trazendo esse exemplo para o nosso contexto, a multiplexação é uma técnica que permite que uma única `thread` observe muitas operações de I/O ocorrendo simultaneamente no sistema operacional, através de [selectors](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/nio/channels/Selector.html). Essa abordagem é **muito** mais escalável do que a execução assíncrona orientada a `threads`.

Naturalmente, tudo isso envolve uma razoável complexidade de código. No caso do Java, a linguagem fornece várias abstrações no pacote [java.nio.channels](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/nio/channels/package-summary.html) para lidar com I/O não-bloqueante. Esses recursos merecem um post em particular no futuro :).

### A programação reativa é "não-bloqueante"?

Agora que diferenciamos "assíncrono" de "não-bloqueante", podemos responder à pergunta acima: um framework reativo, como o RxJava, é "não-bloqueante"? Não necessariamente, e certamente não é o caso do RxJava, pelo simples fato de que o RxJava não é um framework de I/O.

A principal abstração para processamento assíncrono dos frameworks Rx, o `Scheduler`, é implementado no RxJava usando um `pool` de `threads`. Podemos encapsular código bloqueante simplesmente movendo-o para outra `thread` (como vimos no [terceiro post da série](/programacao-reativa-parte-3)), mas isso é "não-bloqueante"? Como vimos, a resposta é "não".

Não obstante, I/O não-bloqueante envolve a observação de diversos `channels`, consumindo dados conforme estão disponíveis ou realizando operações de escrita conforme possível. Se isso lhe traz uma sensação de *deja vu*, acertou: a programação reativa se encaixa aqui de maneira muito natural, porque o I/O não-bloqueante é **orientado à disponibilidade dos dados**, e esse é exatamente o caso de uso onde a programação reativa pode ser útil: nosso programa pode simplesmente **declarar** o comportamento que será executado no momento adequado.

# Conclusão

Nesse post, entendemos o que diferencia um código assíncrono de uma operação não-bloqueante (também vimos código síncrono, mas esse nós já conhecíamos :)), com alguns exemplos baseados em uma aplicação Java comum. Também vimos que usar muitas `threads` é um recurso poderoso, mas que pode se tornar um limitador de escalabilidade.

Talvez algumas coisas tenham ficado abstratas demais, então no próximo post veremos CÓDIGO! Como funciona um servidor HTTP com poucas `threads`? Por que em uma aplicação reativa devemos usar apenas operações não-bloqueantes (ou no mínimo, assíncronas)? Vamos descobrir.

Obrigado pela leitura e qualquer dúvida ou comentário, esteja a vontade para usar a caixa de comentários! Obrigado :)