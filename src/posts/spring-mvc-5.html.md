---
date: ????-??-??
category: back-end
tags:
  - java
  - spring
  - mvc
  - functional programming
author: gabriel.gomes
layout: post
title: MVC com programação funcional, Por que não?
description:
---

## Introdução

Uma coisa muito falada nos últimos tempos é Programação Funcional Reativa. Não sei se é certo falar que é um conceito novo já que algumas linguagens funcionais já usam isso há um bom tempo, mas mesmo assim é um assunto bem novo quando se trata do mundo Java por exemplo, já que é uma linguagem fortemente tipada e tem algumas regrinhas chatas pra escrevê-la, então isso acaba sendo uma novidade para os que estão acostumados com uma programação mais imperativa do mundo Java. Ah, e se você ficou curioso pra saber o porque do termo **programação imperativa**, fique tranquilo que aqui nesse post isso vai ficar bem explicadinho pra você.

## Spring 5 MVC

![Alt "Spring e Reactor"](../images/spring_reactor.png)

O Spring lançou a sua versão [5.0](https://spring.io/blog/2016/07/28/reactive-programming-with-spring-5-0-m1) com uma grande diferença de paradigma, já saiu na frente (como sempre) e criou um framework web reativo que basicamente usa todas os recursos disponíveis na nova versão do [Reactor 3.0 G.A](https://projectreactor.io/), que por si só já é um projeto bem interessante e dá um leque de opções para desenvolver usando de uma maneira funcional e reativa, mas vamos focar na nova versão do Spring.

### O que mudou?

Bom, primeiro, vamos tentar lembrar como a gente pode declarar uma rota com Spring MVC:

```java
@RequestMapping(value = "/users", method = RequestMethod.GET)
public ResponseEntity<List<User>> users() {
	List<User> users = userRepository.findAll();
	return new ResponseEntity<>(users, HttpStatus.OK);
}
```

Até aí beleza, certo? Um exemplo de uma rota `GET` que devolve uma lista de usuários e envelopa isso em um objeto que representa um `response` para o Spring, mas se fosse pensar de um jeito funcional, o código ficaria um pouco diferente:

```java
RouterFunction<?> route = route(GET("/users"),
  request -> {
    Flux<User> users = userRepository.findAll();
    return Response.ok().body(fromPublisher(users, User.class));
  });
```

Você pode reparar que nesse tipo de rota tudo é uma função. A declaração da rota é uma função que recebe basicamente dois parâmetros: O primeiro é do tipo `RequestPredicate`, que simplesmente é um objeto que compões as **condições** para uma requisição cair naquela rota, o segundo parâmetro é a **função** que vai ser executada, caso essas condições sejam atendidas.
Provavelmente você vai perceber a presença de alguns carinhas novos (Não se você já mexeu com Reactor antes), mas talvez os que você vai acabar usando mais são as classes `Flux` e `Mono`. Os dois são objetos que lidam com algum recurso de forma não blocante baseados em eventos, e a diferença entre os dois é que o `Flux` vai lidar com _N_ eventos desse recurso e o `Mono` é apenas um evento desse recurso. O `Routerfunction` representa um objeto que possui todas as informações sobre as rotas, e pra rodar uma aplicação assim, basicamente só é preciso pegar esse objeto e passar ele para um cara que vai rodar isso na camada Web Reativa:

```java
HttpHandler httpHandler = RouterFunctions.toHttpHandler(route);
ReactorHttpHandlerAdapter adapter = new ReactorHttpHandlerAdapter(httpHandler);
HttpServer server = HttpServer.create("localhost", 8080);
server.startAndAwait(adapter);
```

### Imperativo vs Declarativo

Vamos dar uma olhada mais uma vez em uma rota do Spring MVC, dessa vez com algumas tarefas a mais:

```java
@RequestMapping(value = "/users/{id}/pictures", method = RequestMethod.POST)
public ResponseEntity<Void> createPicture(@PathVariable Long id) {
	User user = userRepository.getUser(id);
	if (user != null){
		try {
			String imageName = user.getName() + user.getId();
			imageHelper.createPicture(imageName);
			imageHelper.uploadToS3();
		} catch (Exception e) {
			logger.error("Não foi possível criar a imagem");
		}
	}
}
```

Perceba que nesse caso, precisamos pegar um usuário do banco, montar o nome da imagem e logo em seguida criar uma imagem com aquele nome, depois disso fazemos upload contando que o imageHelper vai ter um atributo da classe com a imagem que precisa ser enviada para o nosso serviço de armazenamento da internet, e se isso der errado, a gente loga um erro mesmo. Tudo bem que existem alguns problemas nesse código aí, mas o problema que vamos destacar agora é que ele está muito imperativo...

![Alt "Imperador"](../images/imperador_kuzco.png)

Ele pega um usuário, ele mesmo verifica se o usuário existe, se existe, ele cria um nome pra imagem a partir dos dados do usuário, tenta fazer o upload e se não conseguir loga um erro. Mas e se a gente escrevesse esse código de um jeito mais declarativo, de uma forma em que eu não falasse **como** fazer, e sim somente **o que** fazer, passando somente que tarefa queremos fazer, mas o responsável por executar aquela tarefa que vai decidir como fazer e que recursos vai usar pra isso, talvez ficaria assim:

```java
RouterFunction<?> route = route(POST("/users/{id}/pictures"),
  request -> {
  	Mono<User> User = Mono.justOrEmpty(request.pathVariable("id"))
		.map(Integer::valueOf)
		.then(userRepository::getUser)
		.then(user -> {
			createPicture(buildPictureName(user))
				.then(s3Client::upload)
				.onError(() -> logger.error("Não foi possível criar a imagem"))
		});
  });
```

Aqui dá pra perceber que quem está recebendo a função de fazer upload, poderia rodar ela em **paralelo** e continuar rodando sua stack principal tranquilamente. Uma das grandes sacadas da programação reativa é que ela pode acabar com os insuportáveis **efeitos colaterais**, uma vez que não existem váriaveis de estado ou algum recurso externo que influencie na função (que não sejam recebidas por parâmetro).

Uma das boas características da programação funcional é a **facilidade para testar**. Se nós garantimos que com a mesma entrada, teremos uma mesma saída, fica bem fácil criar testes para essas funções e também quase impossível que, de um dia pro outro, alguma funcionalidade da sua aplicação quebra porque alguma váriavel externa modificou seu comportamento e seu teste não conseguiu prever isso.


## Voltando ao Spring

A grande pergunta é: Como o Spring consegue tirar proveito disso tudo? Bom, primeiro precisamos pensar que toda a stack precisa tirar proveito disso, e usar um servlet container comum não ajuda a ter completamente as vantagens que o paradigma funcional traz, por isso o Spring usa uma camada específica de Stream Reativo HTTP que, ao contrário de um servlet container, lida com as requisições de forma não blocante. Pra isso fazer sentido, nós precisamos ter alguma forma de processar a requisição e não ficar preso a resposta dela de nenhuma forma, e talvez poderia existir uma maneira de transformar o processo que uma requisição executa em uma função que eu posso carregar para um lado e para o outro e executar a hora que eu quero e da maneira que eu quero...

Mas espera aí! Isso já está funcionando com essa nova versão MVC do Spring (such awesome!). As rotas que temos no Handler são puras funções que não usam nada a mais do que seus parâmetros e suas váriaveis internas para responder uma requisição, e por isso o Spring pode pegar uma requisição, pegar a função que vai responder a ela e executar essa função da forma que o Framework achar melhor, e talvez até oferecer mais recursos a alguma rota que potencialmente pode receber mais requisições, mas com certeza o mais interessante é que isso nem é mais problema da sua aplicação, o que nos faz dedicar mais tempo a um dominío de negócios bem definido.

## Conclusão

Talvez o paradigma funcional traga um pouco de dificuldades para quem não está acostumado com isso, mas as vantagens de desenvolver dessa forma com certeza valem a pena para alguns cenários e hoje em dia já existem várias faculdades que começam a ensinar programação usando o paradigma funcional e isso, com certeza, desbloqueia a mente para várias coisas logo de ínicio. Enfim, atualmente o Spring está prester a lançar sua versão estável do framework web reativo e com certeza essa forma de atender as requisições HTTP podem melhorar muito a maneira de lidar com as nossas aplicações Web.