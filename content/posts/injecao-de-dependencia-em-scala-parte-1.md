---
date: 2019-06-21
category: back-end
tags:
  - scala
  - programacao-funcional
  - guice
authors: [rodrigovedovato]
layout: post
title: Injeção de Dependência em Scala - Parte 1
description: Este artigo de duas partes irá abordar diferentes formas de resolver injeção de dependência em Scala, e como a linguagem e a programação funcional podem nos ajudar.
---

## _Scala no Elo7_

_Este ano, aqui no Elo7, começamos a adotar a utilização de Scala em algumas APIs do site. Como a utilização ainda está sendo disseminada por aqui, estamos utilizando as primeiras aplicações que criamos como forma de estabelecer certos padrões de codificação e formas fáceis de resolver problemas no dia-a-dia._

_Até aí, sem problemas. Isso acontece em diversas empresas quando uma nova linguagem está sendo introduzida. Só que o Scala é uma linguagem funcional, e isso traz não só diversas opções novas para os desenvolvedores, como também dúvidas de como resolver alguns problemas._

## Injeção de dependência

Um desses problemas é a injeção de dependência (ou DI, como vou chamar daqui em diante). Apesar de ser uma linguagem funcional, o Scala ainda traz diversas características de Orientação a Objetos. Isso significa que modelos clássicos de DI, como a injeção das dependências por meio do construtor, funcionam!

```scala
case class UserInfo(account: String, password: String)

trait UserService {
    def getUserInfo(account: String): UserInfo
}

class UserServiceComponent extends UserService {
    override def getUserInfo(account: String): UserInfo = UserInfo(account, "123")
}

class LoginFacade(userService: UserService) {
    def login(account: String, password: String): Boolean = {
        userService.getUserInfo(account).password == password
    }
}

class Application extends App {
   val loginFacade = new LoginFacade(new UserServiceComponent())   
   println(loginFacade.login("Rodrigo", "123"))
}
```

Mais clássico impossível, certo? Neste padrão, deixamos explícito no construtor da classe `LoginFacade` que ela possui uma dependência com uma implementação de `UserService`, mas há alguns problemas aí: neste exemplo, toda a execução e definição do serviço está no método main, mas e se o método `login` fosse utilizado dentro de um contexto que possuísse alguma regra de negócio, exemplo:

```scala
class HomeController {
  val loginFacade = new LoginFacade(new UserServiceComponent())

  def authenticateUser(usuario: String, senha: String): String = {  
    if (loginFacade.login(usuario, senha)) {
      s"Olá, $usuario"
    } else {
      "Erro de login"
    }
  }
}
```

No mundo real, apesar de simples, este método precisaria de testes unitários. Mas como fazer para simular o comportamento da `LoginFacade`, já que a instância está presa à implementação da classe `UserServiceComponent`?. Podemos, é claro, injetar a instância da dependência via construtor, mas isso só passaria o problema para outra camada.  Felizmente, há diferentes soluções para este problema.

### Guice ou (O jeito Java de injetar dependências)
Um velho conhecido dos programadores Java é o Guice, framework de injeção de dependência criado pelo Google. Através do uso de annotations e algumas interfaces, é possível injetar suas dependências de forma dinâmica. Para usá-lo na nossa aplicação Scala, tudo o que temos que fazer é adicionar uma dependência ao pacote  `com.google.inject:guice` no nosso arquivo build.sbt

```scala
lazy  val  root  = (project in file("."))
  .settings(
    name :=  "artigo-di",
    libraryDependencies ++=  Seq( 
      "com.google.inject"  %  "guice"  %  "4.2.2",
      scalaTest %  Test
  )
)
```
Como dito anteriormente, o Guice adiciona várias algumas interfaces e _annotations_ que nos ajudam no processo. Chegou a hora de implementá-los!

A primeira classe que temos que alterar, é a `LoginFacade`, anotando o seu construtor com a _annotation_ `com.google.inject.Inject`



```scala
trait  LoginFacadeT {
  def  login(account: String, password: String):  Boolean
}

class LoginFacade @Inject()(userService: UserService) extends LoginFacadeT {
    override def login(account: String, password: String): Boolean = {
        userService.getUserInfo(account).password == password
    }
}
```
Desta forma, instruímos ao Guice que será necessário buscar em seu registro uma instância da _trait_ `UserService`. Veja, também, que criamos uma nova interface, a `LoginFacadeT`. Essa interface é necessária pois a classe `HomeController` será dependente desta interface.

```scala
class HomeController(facade: LoginFacadeT) {
  def authenticateUser(usuario: String, senha: String): String = {  
    if (facade.login(usuario, senha)) {
      s"Olá, $usuario"
    } else {
      "Erro de login"
    }
  }
}
```
Veja que, neste caso, não anotamos o construtor da nossa classe.  Neste caso específico, iremos deixar assim para fins de demonstração, mas, idealmente, também deveríamos construir nossa Controller dinamicamente.

Por fim, devemos adicionar uma classe que implemente a interface `AbstractModule`. Esta classe fica responsável por registrar todas as interfaces com suas respectivas implementações.

```scala
class DependencyInjectionWithGuiceModule extends AbstractModule {
    override def configure(): Unit = { 
        bind(classOf[UserService]).to(classOf[BasicUserService])
        bind(classOf[LoginFacadeT]).to(classOf[LoginFacade])
    }
}
```
Finalmente, chegou a hora de ligar todos os pontos na nossa aplicação. O resultado fica assim:

```scala
object DependencyInjectionWithGuice extends App {    
    val injector = Guice.createInjector(new DependencyInjectionWithGuiceModule())    
    lazy val loginFacade: LoginFacadeT = injector.getInstance(classOf[LoginFacadeT])

    val homeController = new HomeController(loginFacade)
    println(homeController.authenticateUser("Rodrigo", "123"))
}
```

Desta forma, desacoplamos completamente nosso código. Para realizar teste unitários, basta provermos _mocks_ das interfaces que criamos e registrá-los em um módulo a parte.

## Na próxima parte..

Apesar de funcionar e ser como grande parte da indústria lida com a injeção de dependência, o ecossistema Scala e conceitos de programação funcional possuem formas interessantes e bem mais elegantes de lidar com injeção de dependência. Na próxima parte, iremos conhecê-las!