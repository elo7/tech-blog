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

_Antes restrito basicamente às áreas de Data Science e Data Engineering da empresa, o uso de Scala está sendo expandido para outras áreas de backend aqui no Elo7 em 2019. Como compartilhar conhecimento faz parte do nosso DNA, iremos realizar posts contando as experiências que temos com a linguagem e um pouco sobre como resolvemos diferentes situações que aparecem no dia-a-dia._

## Injeção de dependência

 Injeção de dependência (ou DI) é um dos padrões mais básicos utilizados por desenvolvedores em diferentes linguagens, e no Scala não poderia ser diferente. Apesar de ser uma linguagem funcional, a linguagem ainda traz diversas características de Orientação a Objetos. E isso significa que modelos clássicos de DI, como a injeção das dependências por meio do construtor, funcionam!

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

Mais clássico impossível, certo? Neste padrão, deixamos explícito no construtor da classe `LoginFacade` que ela possui uma dependência com uma implementação de `UserService`, mas há alguns problemas aí: toda a execução e definição do serviço está no método main, mas e se o método `login` fosse utilizado dentro de um contexto mais complexo?

```scala
class HomeController {
  val loginFacade = new LoginFacade(new UserServiceComponent())

  def autenticarUsuario(usuario: String, senha: String): String = {
    if (loginFacade.login(usuario, senha)) {
      s"Olá, $usuario"
    } else {
      "Erro de login"
    }
  }
}
```

Com certeza precisaríamos escrever testes unitários para o método `autenticarUsuario`. Mas como fazer para simular o comportamento da `LoginFacade`, já que a instância está presa à implementação da classe `UserServiceComponent`?. Podemos, é claro, injetar a instância da dependência via construtor, mas isso só passaria o problema para outra camada.  Felizmente, há diferentes soluções para este problema.

### Guice ou (O jeito Java de injetar dependências)
Um velho conhecido dos programadores Java é o Guice, framework de injeção de dependência criado pelo Google. Através do uso de annotations e algumas interfaces, é possível injetar suas dependências de forma dinâmica.

Para usá-lo na nossa aplicação Scala, tudo o que temos que fazer é adicionar uma dependência ao pacote  `com.google.inject:guice` no nosso arquivo build.sbt

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
  def autenticarUsuario(usuario: String, senha: String): String = {
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

Desta forma, desacoplamos completamente nosso código. Para realizar teste unitários, basta implementarmos _mocks_ das interfaces que criamos e registrá-los em um módulo a parte.

## Na próxima parte..

Apesar de funcionar e ser como grande parte da indústria lida com a injeção de dependência, o ecossistema Scala e conceitos de programação funcional possuem formas interessantes e bem mais elegantes de lidar com injeção de dependência. Na próxima parte, iremos conhecê-las!
