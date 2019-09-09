---
date: 2019-09-07
category: back-end
tags:
  - scala
  - programacao-funcional
  - macwire
  - reader-monad
authors: [rodrigovedovato]
layout: post
title: Injeção de Dependência em Scala - Parte 2
description: Este artigo de duas partes irá abordar diferentes formas de resolver injeção de dependência em Scala, e como a linguagem e a programação funcional podem nos ajudar.
cover: injecao-de-dependencia-em-scala-parte-1.png
---

## _Scala no Elo7_

_Antes restrito basicamente às áreas de Data Science e Data Engineering da empresa, o uso de Scala está sendo expandido para outras áreas de backend aqui no Elo7 em 2019. Como compartilhar conhecimento faz parte do nosso DNA, iremos realizar posts contando as experiências que temos com a linguagem e um pouco sobre como resolvemos diferentes situações que aparecem no dia-a-dia._

## Recapitulando

Na [primeira parte](/injecao-de-dependencia-em-scala-parte-1), introduzimos o problema da injeção de dependência, e como podemos resolvê-lo em Scala usando o já consagrado Guice, da Google. Até o momento, nosso código está assim:

```scala
case class UserInfo(account: String, password: String)

trait UserService {
    def getUserInfo(account: String): UserInfo
}

class UserServiceComponent extends UserService {
    override def getUserInfo(account: String): UserInfo = UserInfo(account, "123")
}

trait  LoginFacadeT {
  def  login(account: String, password: String):  Boolean
}

class LoginFacade @Inject()(userService: UserService) extends LoginFacadeT {
    override def login(account: String, password: String): Boolean = {
        userService.getUserInfo(account).password == password
    }
}

class HomeController(facade: LoginFacadeT) {
  def autenticarUsuario(usuario: String, senha: String): String = {
    if (facade.login(usuario, senha)) {
      s"Olá, $usuario"
    } else {
      "Erro de login"
    }
  }
}

class DependencyInjectionWithGuiceModule extends AbstractModule {
    override def configure(): Unit = {
        bind(classOf[UserService]).to(classOf[BasicUserService])
        bind(classOf[LoginFacadeT]).to(classOf[LoginFacade])
    }
}

object DependencyInjectionWithGuice extends App {
    val injector = Guice.createInjector(new DependencyInjectionWithGuiceModule())
    lazy val loginFacade: LoginFacadeT = injector.getInstance(classOf[LoginFacadeT])

    val homeController = new HomeController(loginFacade)
    println(homeController.authenticateUser("Rodrigo", "123"))
}
```
Nosso código está correto, mas não parece muito funcional e o _setup_ do Guice é verboso. Nessa segunda parte, iremos conhecer uma biblioteca em Scala chamada MacWire, que abstrai toda essa lógica e nos fornece uma API simples para trabalhar com injeção de dependência. Além disso, iremos conhecer o Reader Monad (utilizando a biblioteca cats).

## MacWire
A programação funcional traz consigo novas formas de pensar na solução de vários problemas já resolvidos na OOP, mas a transição do pensamento orientado a objetos para o pensamento funcional não é tão simples. Bibliotecas como o MacWire ajudam nessa transição, possibilitando que o programador continue utilizando padrões já conhecidos mas de uma forma mais simples, suportada pelo ecossistema do Scala.

Para utilizar o MacWire, temos que adicionar a seguinte biblioteca às nossas dependências:

```scala
libraryDependencies += "com.softwaremill.macwire" %% "macros" % "2.3.3" % "provided"
```
Vamos começar pela classe `LoginFacade`. Como não estamos mais utilizando o Guice, o uso da annotation `@Inject` no construtor da classe não é mais necessário.

```scala
class LoginFacade (userService: UserService) extends LoginFacadeT {
  override  def  login(account: String, password: String):  Boolean  = {
    userService.getUserInfo(account).password == password
  }
}
```
Também podemos remover a classe `DependencyInjectionWithGuiceModule` e, somente para facilitar a identificação, criaremos uma nova classe, chamada `MacWireInjection`, que será o _entrypoint_ da nossa aplicação.

Diferentemente do Guice, em que precisamos registrar os tipos concretos a serem mapeados pelas nossas interfaces, no MacWire essa identificação é feita de uma forma um pouco mais automática. Só precisamos criar uma classe (ou object, neste caso) onde instanciamos os tipos concretos que queremos carregar na nossa aplicação. Chamaremos a nossa classe de `Runtime`.

```scala
object Runtime {
  val userService: UserService = new UserServiceComponent()
}
```

Tudo o que temos que fazer agora é um `import` dessa classe dentro da nossa classe principal, e colocarmos uma chamada ao método `wire`, do próprio MacWire.

```scala
object MacWireInjection extends App {
  import com.softwaremill.macwire._
  import Runtime._

  lazy val loginFacade = wire[LoginFacade]
  lazy val homeController = wire[HomeController]

  println(homeController.autenticarUsuario("Rodrigo", "123"))
}
```

Mas como isso funciona? Vamos lá!

```scala
import Runtime._

lazy val loginFacade = wire[LoginFacade]
lazy val homeController = wire[HomeController]
```

Como dito anteriormente, o MacWire detecta automaticamente os tipos que precisam ser injetados. Ao importar o object `Runtime`, definimos que a instância da trait `UserService` que devemos usar ao construir a classe `LoginFacade` é do tipo `UserServiceComponent` e, ao declararmos uma instância da classe `LoginFacade` logo acima, indicamos que ela deve ser usada na classe `HomeController`.

Se juntarmos todas as peças alteradas do nosso código, ele fica assim:

```scala
case class UserInfo(account: String, password: String)

trait UserService {
    def getUserInfo(account: String): UserInfo
}

trait LoginFacadeT {
  def login(account: String, password: String): Boolean
}

class LoginFacade (userService: UserService) extends LoginFacadeT {
  def login(account: String, password: String): Boolean = {
    userService.getUserInfo(account).password == password
  }
}

class UserServiceComponent extends UserService {
  override def getUserInfo(account: String): UserInfo = UserInfo(account, "123")
}

class HomeController(facade: LoginFacadeT) {
  def autenticarUsuario(usuario: String, senha: String): String = {
    if (facade.login(usuario, senha)) {
      s"Olá, $usuario"
    } else {
      "Erro de login"
    }
  }
}

object Runtime {
  val userService: UserService = new UserServiceComponent()
}

object MacWireInjection extends App {
  import com.softwaremill.macwire._
  import Runtime._

  lazy val loginFacade = wire[LoginFacade]
  lazy val homeController = wire[HomeController]

  println(homeController.autenticarUsuario("Rodrigo", "123"))
}
```
Utilizando o MacWire, nosso código fica bem mais simples de ser entendido! Mas e se quisermos deixá-lo mais funcional? É aí que entra o Reader Monad!

## Reader Monad

Se você está lendo este post, é bem possível que já tenha cruzado algumas vezes com a palavra _Monad_. Sentiu aquele arrepio na espinha? Pois é, todos nós já sentimos. Como o objetivo aqui não é explicar o que são monads - precisaríamos uma série de posts só para isso -, vamos pensar em um _Monad_ como sendo uma caixa que armazena valores gerados por uma determinada operação e possui alguns métodos que permitem manipulá-los - se você pensou em métodos como `map` e `flatMap`, pensou certo. Como _Monads_ são mais um conceito que uma implementação propriamente dita, podemos ter diferentes _Monads_ para resolver diferentes problemas.

No Scala, usamos _Monads_ o tempo inteiro sem perceber. Quer exemplos?

|Monad|Para que serve?|
|--|--|
|Option[T]|Operação que pode ou não retornar um valor|
|Try[T]|Armazena o retorno de uma operação que pode ou não lançar uma exceção|
|Either[A, B]|Utilizado quando uma determinada função pode retornar dois estados. Geralmente `A` representa um estado de exceção e `B`, de sucesso|

Com esse conceito em mente, vamos à definição do Reader Monad:

> O Reader Monad representa uma operação que lê valores de um ambiente compartilhado e retorna um valor qualquer

### Mas como ele resolve o problema de Injeção de Dependência?

Vamos olhar uma parte do código que fizemos acima, com o MacWire:

```scala
object Runtime {
  val userService: UserService = new UserServiceComponent()
}

object MacWireInjection extends App {
  import com.softwaremill.macwire._
  import Runtime._

  lazy val loginFacade = wire[LoginFacade]
  lazy val homeController = wire[HomeController]

  println(homeController.autenticarUsuario("Rodrigo", "123"))
}
```

Se refletirmos um pouco sobre o que é a classe `Runtime`, veremos que ela é nada mais do que um ambiente compartilhado onde colocamos a implementação do nosso `UserService`. Temos, então, as duas coisas necessárias para utilizar o  _Reader Monad_: um ambiente compartilhado e uma operação que lê este ambiente (login, nesse caso). _It's a match!_

Poderíamos fazer uma implementação do nosso próprio Reader Monad, mas isso deixaria este post ainda mais extenso. Para facilitar nossa vida, vamos usar a biblioteca [cats](https://typelevel.org/cats/), que já tem uma implementação do Reader Monad amplamente usada. Basta adicionar a seguinte dependência:

```scala
libraryDependencies += "org.typelevel" %% "cats-core" % "2.0.0-M1"
```

Pra começar, vamos criar a classe que vai representar este estado compartilhado:

```scala
case class LoginEnv(service: UserService)
```

Como estamos nos aproximando cada vez mais de conceitos de programação funcional, a partir deste momento vamos excluir as classes `LoginFacadeT` e `LoginFacade` pois, conceitualmente, já não faz mais sentido ter um Facade, já que não é mais a classe quem define as dependências necessárias para executar as operações e, sim, a nossa função. Como iremos criar uma classe que irá conter as operações relacionadas a autenticação, iremos chamá-la de `AuthenticationOps`

```scala
object AuthenticationOps {
  def login(userName: String, password: String): Reader[LoginEnv, Boolean] = {
    Reader[LoginEnv, Boolean] { loginEnv =>
      loginEnv.service.getUserInfo(userName).password == password
    }
  }
}
```
Nossa operação `login`, portanto, é uma operação que lê o ambiente compartilhado `LoginEnv` e retorna um valor booleano, indicando se a operação foi ou não executada com sucesso.

Lembra que falamos que _Monads_ possuem métodos auxiliares, como `map` e `flatMap`, que permitem manipular seu valor de saída? Isso também acontece com o Reader Monad, e iremos tirar vantagem dessa característica para executar o que a classe `HomeController` (por enquanto, vamos manter este nome) faz no método `autenticarUsuario`.

```scala
object HomeController {
  def autenticarUsuario(userName: String, password: String): Reader[LoginEnv, String] = {
    AuthenticationOps.login(userName, password).map { isAuthorized =>
      if (isAuthorized) {
        s"Olá, ${userName}"
      } else {
        "Erro de login"
      }
    }
  }
}
```
Neste cenário, em vez de executarmos a operação para então gerarmos um resultado de saída, realizamos um `map` no retorno do método `AuthenticationOps.login`. Isso retorna, no final, uma operação que recebe dois parâmetros (`userName` e `password`) e retorna um `ReaderMonad[LoginEnv, String]`, que ainda precisa de um ambiente `LoginEnv` para ser executado.

Finalmente, na classe principal da nossa aplicação, criamos o contexto com as instâncias que serão utilizadas e chamamos o método `run` do nosso Reader Monad.

```scala
object ReaderMonadInjection extends App {
  val loginEnvironment = new LoginEnv(service = new UserServiceComponent())
  val loginMessage = HomeController.autenticarUsuario("Rodrigo", "123").run(loginEnvironment)

  println(loginMessage)
}
```
Olhe o código final após essa última alteração. Apesar de ainda termos alguns conceitos de Orientação a Objetos (como as traits servindo de interface, por exemplo), já estamos bem mais próximos de como códigos funcionais são escritos no dia-a-dia. Gostou? No próximo post, iremos ver como implementar todo este comportamento utilizando apenas funções! Isso mesmo, sem bibliotecas dessa vez.
