---
date: 2018-05-21
category: back-end
tags:
  - java
  - programacao-reativa
authors: [ljtfreitas]
layout: post
title: Programação Reativa - Parte 2
description: Continuando a série sobre Programação Reativa, agora com um pouco de código!
cover: programacao-reativa-parte-2.png
---
No [post anterior](/programacao-reativa), vimos os fundamentos da programação reativa, incluindo o funcionamento básico sobre os quais os frameworks da família [ReactiveX](http://reactivex.io/) são implementados. Nessa segunda fase da nossa "jornada reativa", começaremos a estudar os principais recursos e funcionalidades do [RxJava](https://github.com/ReactiveX/RxJava), e então estaremos mais preparados para aplicar esses conceitos - não apenas em "programas" mas em "sistemas", os chamados **sistemas reativos**.

Os exemplos deste post estão implementados com o RxJava (a versão 2, compatível com o [Reactive Streams](http://www.reactive-streams.org/), que tem [algumas diferenças](https://github.com/ReactiveX/RxJava/wiki/What's-different-in-2.0) para a versão anterior). Porém, os mesmos fundamentos são aplicáveis em qualquer outro framework da família Rx, ou mesmo outros frameworks reativos como o [Reactor](https://projectreactor.io/).

> *“É fazendo que se aprende o que se deve aprender a fazer. (Aristóteles)”*

## Observables

Conforme dito (superficialmente) no [post anterior](/programacao-reativa), a principal classe do RxJava é o [Observable](http://reactivex.io/documentation/observable.html), que representa um fluxo de dados (contínuos ou discretos, finitos ou infinitos). Essa classe contêm todos os operadores reativos disponíveis no RxJava. Para nossos propósitos, podemos criar uma instância a partir de uma lista de valores fixos, e nos *subscrevermos* ao `Observable` criado:

```java
Observable<String> observable = Observable.just("one", "two", "three");

observable.subscribe(System.out::println);

/*
output:

one
two
three
*/
```

Nesse código, nós estamos executando uma ação no evento *onNext*. Recapitulação rápida: *onNext* é o evento que representa a emissão de um valor pelo Observable. Os outros dois eventos possíveis em um fluxo reativo são o *onError* e o *onCompleted*. Se quiséssemos executar algum código quando esses dois eventos ocorressem, poderíamos usar as sobrecargas do método *subscribe*:

```java
//onError

Observable<String> observable = Observable.error(new RuntimeException("ooops...")); // esse Observable irá emitir apenas um erro

observable.subscribe(System.out::println, Throwable::printStackTrace); //o segundo parâmetro é a ação que deverá ser realizada em caso de erro (um Consumer que recebe um Throwable)

/*
output:

java.lang.RuntimeException: ooops...
*/
```

```java
//onCompleted

Observable<String> observable = Observable.just("one", "two", "three");

observable.subscribe(System.out::println, Throwable::printStackTrace, () -> System.out.println("Completed...")); //o terceiro parâmetro é a ação que deverá ser realizada quando o Observable for completado (um objeto do tipo Action que não recebe parâmetros)

/*
output:

one
two
three
Completed...
*/
```

```java
//outra maneira é se subscrever usando um objeto do tipo Observer; desse modo você pode implementar as acões de cada evento em um único objeto

Observable<String> observable = Observable.just("one", "two", "three");

observable.subscribe(new Observer<String>() {

	@Override
	public void onSubscribe(Disposable d) {
		System.out.println("Alguém se subscreveu...");
	}

	@Override
	public void onNext(String t) {
		System.out.println(t);
	}

	@Override
	public void onError(Throwable e) {
		e.printStackTrace();
	}

	@Override
	public void onComplete() {
		System.out.println("Completed...");
	}
});

/*
output:

Alguém se subscreveu...
one
two
three
Completed...
*/
```

O `Observable` possui muitos métodos de fábrica que podem ser utilizados para criação. O método [just](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#just-T-) utilizado nos exemplos acima cria um Observable a partir de uma sequência fixa de valores; podemos utilizar também um [intervalo de valores](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#range-int-int-), um [intervalo de tempo](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#timer-long-java.util.concurrent.TimeUnit-), um [Callable](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromCallable-java.util.concurrent.Callable-), um [Future](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromFuture-java.util.concurrent.Future-), [outro Observable](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromPublisher-org.reactivestreams.Publisher-)...veremos todos esses métodos em detalhes no decorrer do post.

## Completable, Single, Maybe

Na versão 2 do RxJava, existem algumas especializações interessantes sobre o comportamento de um fluxo reativo. Eventualmente, queremos nos sobrescrever a um objeto observável com uma semântica diferente de um `Observable` convencional; às vezes esse objeto não irá emitir valores (ou emitirá um erro ou apenas completará), ou emitirá apenas um valor, ou *talvez* emita apenas um valor (ou nenhum). Existem alguns objetos específicos para essas situações.

### Completable

[Completable](http://reactivex.io/RxJava/javadoc/) representa um computação que **não devolve valores**, podendo gerar um erro ou ser concluída sem erros. Um `Completable`, então, nunca irá emitir o evento *onNext*; apenas *onCompleted* ou *onError*.

```java
Completable completable = Completable.complete();

completable.subscribe(() -> System.out.println("Completed..."));

/*
output:

Completed...
*/
```

```java
Completable completable = Completable.error(new RuntimeException("oops..."));

completable.subscribe(() -> System.out.println("Completed..."), Throwable::printStackTrace); //o segundo parâmetro é a ação que deverá ser realizada em caso de erro (um Consumer que recebe um Throwable)

/*
output:

java.lang.RuntimeException: oops...
*/
```

E para o que poderia servir isso? Talvez para algo assim:

```java
Completable completable = Completable.fromAction(() -> {
	/* aqui você poderia executar alguma ação como invocar uma API externa, persistir alguma informação, etc.
	   ou qualquer outra tarefa onde você não precisa de algum valor de retorno,
	   mas precisa reagir caso ocorra algum erro ou quando essa ação seja concluída
	*/
});

completable.subscribe(() -> System.out.println("Ok...a ação terminou sem erros."), Throwable::printStackTrace);
```

### Single

[Single](http://reactivex.io/RxJava/javadoc/io/reactivex/Single.html) é um objeto que pode emitir **apenas um valor**, ou um erro. Um `Single` não emite o evento *onCompleted*, pois o fato de emitir o *onNext* apenas uma vez indica de maneira implícita que o `Single` foi "completado".

```java
Single<String> single = Single.just("one");

single.subscribe(System.out::println);

/*
output:

one
*/
```

```java
Single<String> single = Single.error(new RuntimeException("oops..."));

single.subscribe(System.out::println, Throwable::printStackTrace);
/*
output:

java.lang.RuntimeException: oops...
*/
```

### Maybe

[Maybe](http://reactivex.io/RxJava/javadoc/io/reactivex/Maybe.html) é um objeto que **pode** emitir um valor, mas que talvez não emita nenhum. Caso esse valor exista, esse objeto emitirá um evento diferente chamado *onSuccess*; se não, poderá emitir os eventos *onError* ou *onCompleted*. Esses eventos são **excludentes**; se o *onSucess* for disparado, o `Maybe` será implicitamente completado (o *onError* tem a mesma semântica); se o `Maybe` não emitir nenhum valor apenas o *onCompleted* será disparado.

```java
Maybe<String> maybe = Maybe.just("any value");

maybe.subscribe(System.out::println); //onSuccess

/*
output:

any value
*/
```

```java
Maybe<String> maybe = Maybe.error(new RuntimeException("oops..."));

maybe.subscribe(System.out::println, Throwable::printStackTrace);

/*
output:

java.lang.RuntimeException: oops...
*/
```

```java
Maybe<String> maybe = Maybe.empty();

maybe.subscribe(System.out::println, Throwable::printStackTrace, () -> System.out.println("Completed..."));

/*
output:

Completed...
*/
```

```java
/* Esse exemplo demonstra bem a diferença entre um Maybe e um Observable.
   Aqui, estamos criando o Maybe a partir de uma computação que devolve null.
   Nessa situação, o Maybe irá emitir o evento onCompleted, pois não há valor a ser emitido para o onSuccess.
   Já um Observable nunca emite valores nulos (o código abaixo lançaria uma exceção, se fosse um Observable).
*/

Maybe<String> maybe = Maybe.fromCallable(() -> null);

maybe.subscribe(System.out::println, Throwable::printStackTrace, () -> System.out.println("Completed..."));

/*
output:

Completed...
*/
```

## Ciclo de vida de um Subscriber

Nos exemplos acima, nosso código se subscreve às fontes de eventos reativos (`Observable`, `Completable`, etc) e reage conforme as coisas acontecem. Como vimos no post anterior, o ato de vincular um *Subscriber* a um fluxo de dados é chamado de **subscription**. Na versão 1.x, o RxJava possuía um objeto chamado [Subscription](http://reactivex.io/RxJava/1.x/javadoc/rx/Subscription.html) para representar esse conceito, e esse objeto era responsável pelo ciclo de vida de uma subscrição. Na versão 2.x, essa classe foi renomeada para [Disposable](http://reactivex.io/RxJava/javadoc/io/reactivex/disposables/Disposable.html).

Eventualmente, um comportamento que podemos desejar é **cancelar** uma subscrição; podemos fazer isso facilmente. No exemplo abaixo, um `Observable` é criado a partir do método [interval](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#interval-long-java.util.concurrent.TimeUnit-); esse método cria um `Observable` que emite um valor do tipo `Long` a cada intervalo de tempo:

```java
Observable<Long> observable = Observable.interval(1000, TimeUnit.MILLISECONDS);

observable.subscribe(System.out::println);

Thread.sleep(5000);

/*
output:

0
1
2
3
4
*/
```

O método `subscribe` devolve um `Disposable`, que podemos utilizar para cancelar a subscrição:

```java
Observable<Long> observable = Observable.interval(1000, TimeUnit.MILLISECONDS);

Disposable subscription = observable.subscribe(System.out::println);

Thread.sleep(2000);

subscription.dispose(); //o método dispose cancela a subscrição; os eventos emitidos a partir daqui já não serão capturados por esse objeto

Thread.sleep(3000);

/*
output:

0
1
*/
```

## Posso ter mais de um subscriber?

Sim! Você pode vincular ao `Observable` quantos *subscribers* desejar (o mesmo se aplica ao `Completable`, `Single` e `Maybe`). Isso pode trazer uma questão cuja resposta pode não ser tão óbvia: digamos que criamos um `Observable` a partir de uma lista de valores finitos (como os exemplos acima), nos subscrevemos e recebemos todos os eventos *onNext* e depois o *onCompleted*, que é um evento **terminal**; o que acontece se fizemos outra subscrição após esse evento?

```java
Observable<String> observable = Observable.just("one", "two", "three");

observable.subscribe(System.out::println, Throwable::printStackTrace, () -> System.out.println("Completed..."));

/*
output:

one
two
three
Completed...
*/
```

Se adicionarmos um novo *subscriber*:

```java
Observable<String> observable = Observable.just("one", "two", "three");

observable.subscribe(System.out::println, Throwable::printStackTrace, () -> System.out.println("Completed..."));

observable.subscribe(v -> System.out.println("Second subscriber: " + v));

/*
output:

one
two
three
Completed...
Second subscriber: one
Second subscriber: two
Second subscriber: three
*/
```

A sequência de eventos foi re-executada quando o segundo *subscription* foi realizado. Com efeito, mesmo em relação ao primeiro *subscriber*, os eventos só foram enviados **após** a subscrição ter sido realizada, o que nos leva a concluir: até você se subscrever, **nada acontece**.

Mas será que sempre vamos desejar esse comportamento? E se nosso Observable fosse gerado a partir de um fluxo assíncrono e potencialmente infinito (digamos, um *stream* do Twitter), e quiséssemos que novos *subscribers* ouvissem os eventos gerados **a partir do momento em que eles se subscreveram**, seria possível?

### Observables "frios" e "quentes"

Nos frameworks Rx, existem dois "sabores" de Observables, chamados **cold** (frios) e **hot** (quentes). O comportamento que vimos acima é de um `Observable` frio; a sequência de eventos é executada **apenas quando e se o Observable tenha algum subscriber associado**, e o fluxo de eventos é executado para cada subscrição realizada. O exemplo abaixo (novamente usando o método `interval`) demonstra bem esse funcionamento:

```java
Observable<Long> observable = Observable.interval(1000, TimeUnit.MILLISECONDS);

observable.subscribe(v -> System.out.println("First subscriber: " + v));

Thread.sleep(2000);

observable.subscribe(v -> System.out.println("Second subscriber: " + v));

Thread.sleep(2000);

/*
output:

First subscriber: 0
First subscriber: 1
First subscriber: 2
Second subscriber: 0
First subscriber: 3
Second subscriber: 1
...
*/
```

Os dois *subscribers* não recebem os mesmos valores ao mesmo tempo, embora ambos estejam vinculados ao mesmo `Observable`. Eles recebem **a mesma sequência de eventos**, com a diferença que o "início" dos eventos para cada um se dará a partir do momento da subscrição.

Todo `Observable` criado a partir do método [create](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#create-io.reactivex.ObservableOnSubscribe-) é um "cold observable", incluindo todos os métodos auxiliares como [just](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#just-T-), [range](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#range-int-int-), [timer](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#timer-long-java.util.concurrent.TimeUnit-), `from*`([fromArray](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromArray-T...-), [fromCallable](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromCallable-java.util.concurrent.Callable-), etc) e o próprio `interval` do exemplo acima.

Um "hot observable" tem um comportamento diferente; ele emite eventos **independente de haver algum subscriber associado**. É possível converter um "cold observable" em "hot observable" usando o método [publish](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#publish--), que devolve um [ConnectableObservable](http://reactivex.io/RxJava/javadoc/io/reactivex/observables/ConnectableObservable.html), um tipo especial de `Observable` que passa a emitir sequências após a invocação do método [connect](http://reactivex.io/RxJava/javadoc/io/reactivex/observables/ConnectableObservable.html#connect--), havendo *subscribers* ou não. O código a seguir demonstra essa lógica:

```java
Observable<Long> observable = Observable.interval(1000, TimeUnit.MILLISECONDS); //emite um valor a cada segundo: 0, 1, 2...

ConnectableObservable<Long> hot = observable.publish(); //o método publish devolve o ConnectableObservable
hot.connect(); //aqui a sequência de eventos será iniciada

Thread.sleep(3000); //aguarda três segundos; nesse intervalo o Observable já terá emitido os valores 0, 1, e 2

hot.subscribe(System.out::println); //esse subscriber será notificado a partir do valor 3 da sequência

Thread.sleep(3000); //aguarda por mais três segundos...

/*
output:

3
4
5
*/
```

O método `connect` também devolve um `Disposable`, que poderia ser usado eventualmente para cancelar a emissão de eventos.

## Subjects

Um objeto reativo muito interessante é o [Subject](http://reactivex.io/RxJava/javadoc/io/reactivex/subjects/Subject.html). Essa classe implementa a interface [Observer](http://reactivex.io/RxJava/javadoc/io/reactivex/Observer.html), portanto pode **ouvir** eventos; também extende `Observable`, portanto, pode **enviar** eventos (ou reemitir).

Um `Subject` é ideal como "porta de entrada" para o mundo Rx, pois permite que você "empurre" valores para um *pipeline* reativo mesmo que tais valores sejam gerados fora do RxJava (lembre-se que o conceito de dados "empurrados" (push) é fundamental para a programação reativa).

```java
Observable<String> observable = Observable.just("one", "two", "three");

PublishSubject<String> subject = PublishSubject.create(); //spoiler :)...mais informações daqui a pouco!
subject.subscribe(System.out::println); //podemos nos subscrever ao Subject

observable.subscribe(subject); //podemos usar o Subject para nos subscrevermos a outros Observables

/*
output:

one
two
three
*/
```

No RxJava, o `Subject` tem várias implementações diferentes. Vamos analisar cada uma delas.

### PublishSubject

Um [PublishSubject](http://reactivex.io/RxJava/javadoc/io/reactivex/subjects/PublishSubject.html) emite eventos para o observador apenas a partir do instante em que a subscrição é realizada.

```java
PublishSubject<String> subject = PublishSubject.create();

// o primeiro subscriber
subject.subscribe(v -> System.out.println("First subscriber: " + v));

// emite dois eventos
subject.onNext("one");
subject.onNext("two");

// o segundo subscriber
subject.subscribe(v -> System.out.println("Second subscriber: " + v));

//emite outro evento
subject.onNext("three");

/*
output:

First subscriber: one
First subscriber: two
First subscriber: three
Second subscriber: three
*/
```

Se ocorrer um evento terminal (*onCompleted* ou *onError*) os *subscribers* posteriores receberão apenas este evento:

```java
PublishSubject<String> subject = PublishSubject.create();

subject.subscribe(v -> System.out.println("First subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to first subscriber"));

subject.onNext("one");
subject.onNext("two");

// emite o evento onCompleted
subject.onComplete();

subject.subscribe(v -> System.out.println("Second subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to second subscriber"));

/*
output:

First subscriber: one
First subscriber: two
OnComplete to first subscriber
OnComplete to second subscriber
*/
```

### ReplaySubject

O [ReplaySubject](http://reactivex.io/RxJava/javadoc/io/reactivex/subjects/ReplaySubject.html) emite todos os valores para todos os *subscribers*, independente do momento em que a subscrição foi feita.

```java
ReplaySubject<String> subject = ReplaySubject.create();

subject.onNext("one");
subject.onNext("two");
subject.onNext("three");
subject.onComplete();

subject.subscribe(v -> System.out.println("First subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to first subscriber"));
subject.subscribe(v -> System.out.println("Second subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to second subscriber"));

/*
output:

First subscriber: one
First subscriber: two
First subscriber: three
OnComplete to first subscriber
Second subscriber: one
Second subscriber: two
Second subscriber: three
OnComplete to second subscriber
*/
```

Armazenar todos os valores indefinidamente pode não ser o ideal. O método [createWithSize](http://reactivex.io/RxJava/javadoc/io/reactivex/subjects/ReplaySubject.html#createWithSize-int-) permite estabelecer um limite para o *buffer*:

```java
ReplaySubject<String> subject = ReplaySubject.createWithSize(2);

subject.onNext("one");
subject.onNext("two");
subject.onNext("three");
subject.onComplete();

subject.subscribe(v -> System.out.println("First subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to first subscriber"));
subject.subscribe(v -> System.out.println("Second subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to second subscriber"));

/*
output:

First subscriber: two
First subscriber: three
OnComplete to first subscriber
Second subscriber: two
Second subscriber: three
OnComplete to second subscriber
*/
```

Também é possível estabeler um limite de armazenamento baseado no tempo decorrido, com o método [createWithTime](http://reactivex.io/RxJava/javadoc/io/reactivex/subjects/ReplaySubject.html#createWithTime-long-java.util.concurrent.TimeUnit-io.reactivex.Scheduler-). Além dos parâmetros de tempo, esse método recebe um [Scheduler](http://reactivex.io/RxJava/javadoc/io/reactivex/Scheduler.html); para evitar *spoilers*, não entrarei em detalhes agora desse importantíssimo objeto mas falaremos dele em detalhes no próximo post :).

O `Observable` tem um método chamado [replay](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#replay--), que tem um comportamento equivalente.

```java
Observable<String> observable = Observable.just("one", "two", "three");

ConnectableObservable<String> hot = observable.replay();
hot.connect();

hot.subscribe(v -> System.out.println("First subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to first subscriber"));
hot.subscribe(v -> System.out.println("Second subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to second subscriber"));

/*
output:

First subscriber: one
First subscriber: two
First subscriber: three
OnComplete to first subscriber
Second subscriber: one
Second subscriber: two
Second subscriber: three
OnComplete to second subscriber
*/
```

O método [cache](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#cache--) também tem um comportamento semelhante, pois armazena todos os valores emitidos, mas não permite o gerenciamento do ciclo de vida das subscrições.

```java
Observable<String> observable = Observable.just("one", "two", "three");

// o método cache não devolve um ConnectableObservable, ao contrário do método replay;
// isso significa que não podemos usar o Disposable obtido após a chamada do método ConnectableObservable.connect
Observable<String> cached = observable.cache();

cached.subscribe(v -> System.out.println("First subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to first subscriber"));
cached.subscribe(v -> System.out.println("Second subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to second subscriber"));
```

### BehaviorSubject

O [BehaviorSubject](http://reactivex.io/RxJava/javadoc/io/reactivex/subjects/BehaviorSubject.html) emite o item mais recente e todos os subsequentes, a partir do momento da subscrição.

```java
BehaviorSubject<String> subject = BehaviorSubject.create();

subject.onNext("one");
subject.subscribe(v -> System.out.println("First subscriber: " + v));

subject.onNext("two");
subject.onNext("three");

subject.subscribe(v -> System.out.println("Second subscriber: " + v));

subject.onNext("four");

/*
output:

First subscriber: one
First subscriber: two
First subscriber: three
Second subscriber: three
First subscriber: four
Second subscriber: four
*/
```

Se ocorrer um evento terminal (*onCompleted* ou *onError*) os *subscribers* posteriores receberão apenas este evento:

```java
BehaviorSubject<String> subject = BehaviorSubject.create();

subject.onNext("one");
subject.subscribe(v -> System.out.println("First subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to first subscriber"));

subject.onNext("two");
subject.onComplete();

subject.subscribe(v -> System.out.println("Second subscriber: " + v), Throwable::printStackTrace, () -> System.out.println("OnComplete to second subscriber"));

/*
output:

First subscriber: one
First subscriber: two
OnComplete to first subscriber
OnComplete to second subscriber
*/
```

Uma motivação comum para utilizar o `BehaviorSubject` é a necessidade de sempre ter um valor disponível para a leitura, mesmo que seja um valor padrão ou um *null object*. É possível inicializar esse objeto com um valor *default*:

```java
BehaviorSubject<String> subject = BehaviorSubject.createDefault("one");

subject.subscribe(v -> System.out.println("First subscriber: " + v));
```

### AsyncSubject

O [AsyncSubject](http://reactivex.io/RxJava/javadoc/io/reactivex/subjects/AsyncSubject.html) também armazena o último valor, mas só o emite após a ocorrência de um evento terminal.

```java
AsyncSubject<String> subject = AsyncSubject.create();

subject.subscribe(System.out::println);

subject.onNext("one");
subject.onNext("two");
subject.onNext("three");
```

No exemplo acima, nenhuma saída é gerada, porque não houve nenhum evento terminal (*onCompleted* ou *onError*). Vejamos a diferença quando isso ocorre:

```java
AsyncSubject<String> subject = AsyncSubject.create();

subject.subscribe(System.out::println);

subject.onNext("one");
subject.onNext("two");

subject.onComplete(); //onCompleted emitido -> o último valor emitido pelo onNext será enviado ao subscriber

/*
output:

two
*/
```

```java
AsyncSubject<String> subject = AsyncSubject.create();

subject.subscribe(System.out::println, Throwable::printStackTrace);

subject.onNext("one");
subject.onNext("two");

subject.onError(new RuntimeException("ooops")); //onError emitido -> apenas esse erro será enviado ao subscriber (o último valor não)

/*
output:

java.lang.RuntimeException: ooops
*/
```

A emissão de valores para os *subscribers* subsequentes seguirá a mesma semântica: se o evento terminal foi o *onCompleted*, o *subscriber* mais recente receberá o último *onNext* e o *onCompleted*; se o evento terminal foi o *onError*, o *subscriber* mais recente receberá apenas o erro.

```java
AsyncSubject<String> subject = AsyncSubject.create();

subject.onNext("one");
subject.onNext("two");

subject.onComplete();

subject.subscribe(System.out::println, Throwable::printStackTrace, () -> System.out.println("OnCompleted"));

/*
output:

two
OnCompleted
*/
```

```java
AsyncSubject<String> subject = AsyncSubject.create();

subject.onNext("one");
subject.onNext("two");

subject.onError(new RuntimeException("ooops"));

subject.subscribe(System.out::println, Throwable::printStackTrace);

/*
output:

java.lang.RuntimeException: ooops
*/
```

### UnicastSubject

O [UnicastSubject](http://reactivex.io/RxJava/javadoc/io/reactivex/subjects/UnicastSubject.html) é um `Subject` que permite **apenas um subscriber** associado. Os eventos são armazenados em uma pilha interna, assim como na implementação do `ReplaySubject`, mas ao contrário deste, o *buffer* do `UnicastSubject` é **ilimitado**, sendo esvaziado apenas quando um evento terminal ocorre ou o *subscriber* é desassociado (pelo método `Dispose.dispose()`).

```java
UnicastSubject<String> subject = UnicastSubject.create();

subject.onNext("one");
subject.onNext("two");

subject.subscribe(System.out::println);

/*
output:

one
two
*/
```

Como dissemos, o `UnicastSubject` permite apenas um *subscriber*. Eis o que ocorre se tentarmos associar um segundo ouvinte de eventos:

```java
UnicastSubject<String> subject = UnicastSubject.create();

subject.onNext("one");
subject.onNext("two");

subject.subscribe(System.out::println, Throwable::printStackTrace);
subject.subscribe(System.out::println, Throwable::printStackTrace);

/*
output:

one
two
java.lang.IllegalStateException: Only a single observer allowed. //exceção indicando que não é permitido mais de um observer
*/
```

Mais informações sobre `Subjects` podem ser encontradas na documentação do [ReactiveX](http://reactivex.io/documentation/subject.html).

## Operadores reativos

A programação reativa é um paradigma que opera sobre **fluxos de dados observáveis**, e temos objetos que representam um *stream* (Observable e etc) e outros objetos que nos permitem observar o fluxo (os *subscribers*). Mas, mais do que apenas observar, também desejamos operar, filtrar, interagir, e modificar esses dados, e os frameworks que implementam o paradigma reativo fornecem uma fantástica caixa de ferramentas para esse propósito: os [operadores reativos](http://reactivex.io/documentation/operators.html), uma enorme quantidade de métodos e operações que efetivamente fazem a mágica acontecer. É importante relembrar que os operadores **não modificam o fluxo de dados**, pois um dos fundamentos da programação reativa é a **propagação de estado**; portanto, todos os operadores criam novos objetos imutáveis, com efeito, propagando o novo estado (o dado modificado) para o novo *stream*.

### Marble diagrams

O comportamento dos métodos reativos são demonstrados visualmente na documentação do Rx usando "marble diagrams", que demonstram uma **sequência de eventos ordenados no tempo**, que é o conceito principal que os objetos reativos representam. Uma explicação rápida dos conceitos nesse diagrama pode nos ser útil antes de nos aprofundarmos nesses métodos.

Essa é uma simples linha do tempo, sobre a qual os eventos ocorrem:

![Uma linha do tempo](/images/programacao-reativa-parte-2-1.png)

Os elementos emitidos são representados por figuras geométricas. Na imagem abaixo, três itens são emitidos e o `stream` é completado (três eventos *onNext* e o evento *onCompleted*, portanto). A linha vertical representa o *onCompleted*.

![Três itens emitidos e o evento onCompleted](/images/programacao-reativa-parte-2-2.png)

Abaixo, três itens são emitidos, seguidos de um erro (três eventos *onNext* e o evento *onError*). O "X" representa o *onError*.

![Três itens emitidos e o evento onError](/images/programacao-reativa-parte-2-3.png)

Juntando tudo, uma operação reativa completa sobre a linha do tempo seria representada da seguinte forma:

![Marble diagram completo](/images/programacao-reativa-parte-2-4.png)

Um *site* que demonstra esses diagramas de forma simples é o [RxMarbles](http://rxmarbles.com/), que utilizo bastante. No decorrer do post, vou utilizar diagramas retirados da documentação do RxJava para demonstrar o comportamento de cada operador.

### Métodos com efeitos colaterais

Antes de falarmos dos operadores (que são, com efeito, os principais métodos dos frameworks Rx), é importante conhecer os [side-effect methods](http://reactivex.io/documentation/operators/do.html): os métodos *do*. Esses métodos não modificam os dados (não trabalham com a *propagação de estado* do fluxo) e não criam novos `streams`, pois foram concebidos para efetivamente gerar efeitos colaterais durante a emissão de eventos. Dado que o `Observable` (e os outros) são objetos imutáveis, esses métodos não afetam o seu estado, mas permitem associar comportamentos **quando determinados eventos ocorrerem**; como operam apenas sobre os eventos, e não sobre o `pipeline` de transformação do `stream`, funcionam como *hooks* ou *callbacks* da ocorrência de cada evento, permitindo realizar ações muito específicas. São muito úteis para *logging* e depuração.

```java
Observable<String> observable = Observable.just("one", "two", "three");

observable
	.doOnSubscribe(d -> System.out.println("DoOnSubscribe: " + d)) 		// quando um subscriber se registra
	.doOnEach(v -> System.out.println("DoOnEach:" + v))					// quando ocorre qualquer evento; o parâmetro é um objeto do tipo Notification
	.doOnNext(v -> System.out.println("DoOnNext: " + v))				// quando ocorre o evento onNext
	.doOnError(t -> System.out.println("DoOnError: " + t))				// quando ocorre o evento onError
	.doOnComplete(() -> System.out.println("DoOnComplete"))				// quando ocorre o evento onComplete
	.doAfterNext(v -> System.out.println("DoAfterNext: " + v))			// após a ocorrência do evento onNext
	.doOnTerminate(() -> System.out.println("DoOnTerminate"))			// quando ocorre um evento terminal
	.doAfterTerminate(() -> System.out.println("DoAfterTerminate"))		// após a ocorrência de um evento terminal
	.doFinally(() -> System.out.println("DoFinally"))					// quando ocorre um evento terminal, ou quando um subscriber se desvincula do stream
	.subscribe(); // os callbacks acima são invocados para cada subscriber

/*
output:
DoOnSubscribe: io.reactivex.internal.observers.DisposableLambdaObserver@57fffcd7
DoOnEach:OnNextNotification[one]
DoOnNext: one
DoAfterNext: one
DoOnEach:OnNextNotification[two]
DoOnNext: two
DoAfterNext: two
DoOnEach:OnNextNotification[three]
DoOnNext: three
DoAfterNext: three
DoOnEach:OnCompleteNotification
DoOnComplete
DoOnTerminate
DoFinally
DoAfterTerminate
*/
```

Novamente, é importante destacar que nenhum dos métodos acima representa uma subscrição, e sim *callbacks* específicos para cada evento.

### Agora, sim: operadores reativos!

No caso do RxJava, que estamos utilizando aqui, o `Observable` possui [dezenas de métodos](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html) (sim, dezenas), e seria cansativo detalhar todos aqui. Vamos ver algumas demonstrações dos operadores que considero mais úteis e interessantes.

### Criação

#### create

![create](/images/programacao-reativa-parte-2-5.png)

O método [create](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html) é uma maneira simples de criar um *cold observable*. Ele recebe como parâmetro um [ObservableOnSubscribe](http://reactivex.io/RxJava/javadoc/io/reactivex/ObservableOnSubscribe.html), que pode ser representado como uma função que recebe um [ObservableEmitter](http://reactivex.io/RxJava/javadoc/io/reactivex/ObservableEmitter.html), um objeto que permite emitir eventos explicitamente.

```java
Observable<String> observable = Observable.create(e -> e.onNext("hello"));

observable.subscribe(System.out::println);

/*
output:

hello
*/
```

#### defer

![defer](/images/programacao-reativa-parte-2-6.png)

No exemplo acima, o `ObservableOnSubscribe` será invocado para cada subscrição realizada (um *cold observable*, portanto). Podemos ter algum caso de uso onde queremos gerar **preguiçosamente** os valores emitidos, e o método [defer](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#defer-java.util.concurrent.Callable-) permite fornecer uma fábrica (representada por um `Callable`) para a criação do [ObservableSource](http://reactivex.io/RxJava/javadoc/io/reactivex/ObservableSource.html), que será executado a cada subscrição.

```java
// a diferença aqui é que o parâmetro representa um função que devolve um ObservableSource,
// que pode ser gerado de maneira "lazy"
Observable<String> observable = Observable.defer(() -> Observable.just("one", "two"));

observable.subscribe(System.out::println);

/*
output:

one
two
*/
```

#### empty, never, error

![empty](/images/programacao-reativa-parte-2-7.png)

O método [empty](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#empty--) devolve um `Observable` que não emite nenhum valor, e emite imediatamente o evento *onCompleted* quando ocorre um subscrição:

```java
Observable.empty()
		.doOnComplete(() -> System.out.println("OnComplete"))
		.subscribe();

/*
output:

OnComplete
*/
```

![never](/images/programacao-reativa-parte-2-8.png)

O método [never](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#never--) devolve um `Observable` que nunca notifica nenhum *subscriber*. Isso é útil para ser utilizado como *null object*.

```java
// nenhuma saída é gerada para o código abaixo
Observable.never()
		.doOnNext(System.out::println)
		.doOnComplete(() -> System.out.println("OnComplete"))
		.subscribe();

```

![error](/images/programacao-reativa-parte-2-9.png)

O método [error](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#error-java.lang.Throwable-) devolve um `Observable` que imediatamente emite o evento *onError*. Também há uma [sobrecarga](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#error-java.util.concurrent.Callable-) desse método que recebe um `Callable`, permitindo gerar a exceção de maneira *lazy*.

```java
Observable.error(new RuntimeException("ooops..."))
		.subscribe(System.out::println, Throwable::printStackTrace);

/*
output:

java.lang.RuntimeException: ooops...
*/
```

#### from

Existe uma variedade de métodos *from*: [fromArray](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromArray-T...-), [fromCallable](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromCallable-java.util.concurrent.Callable-), [fromFuture](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromFuture-java.util.concurrent.Future-), [fromIterable](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromIterable-java.lang.Iterable-), [fromPublisher](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#fromPublisher-org.reactivestreams.Publisher-): a motivação desses métodos é converter outros tipos de objetos e estruturas de dados para um `Observable`.

#### just

![just](/images/programacao-reativa-parte-2-10.png)

Utilizado em praticamente todos os exemplos desse post, o [just](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#just-T-) simplesmente cria um `Observable` a partir de uma lista de valores, emitindo todos através do evento *onNext*.

```java
Observable.just("one", "two", "three")
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

one
two
three
*/
```

#### range

![range](/images/programacao-reativa-parte-2-11.png)

O método [range](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#range-int-int-) devolve um `Observable` que emite uma sequência de valores do tipo `Integer` dentro do intervalo especificado (há outro operador que emite valores do tipo `Long`, [rangeLong](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#rangeLong-long-long-)) .

```java
Observable.range(0, 5)
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

0
1
2
3
4
*/
```

#### interval e timer

![interval](/images/programacao-reativa-parte-2-12.png)

O método [interval](interval) devolve um `Observable` que emite um valor do tipo `Long` a cada intervalo de tempo especificado. Há uma sobrecarga em que é possível configurar um [delay inicial](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#interval-long-long-java.util.concurrent.TimeUnit-).

```java
Observable.interval(1000, TimeUnit.MILLISECONDS)
		.doOnNext(System.out::println)
		.subscribe();


Thread.sleep(5000);

/*
output:

0
1
2
3
4
*/
```

![timer](/images/programacao-reativa-parte-2-13.png)

Já com o método [timer](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#timer-long-java.util.concurrent.TimeUnit-), o `Observable` criado irá emitir o valor 0 (`Long`) após o intervalo de tempo especificado, e depois o evento *onCompleted*.

```java
Observable.timer(1000, TimeUnit.MILLISECONDS)
		.doOnNext(System.out::println)
		.doOnComplete(() -> System.out.println("Completed"))
		.subscribe();

Thread.sleep(1500);

/*
output:

0
Completed
*/
```

### Transformação

#### map

![map](/images/programacao-reativa-parte-2-14.png)

O operador [map](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#map-io.reactivex.functions.Function-) devolve um `Observable` que aplica uma função de transformação para cada item emitido, e então emite os novos valores.

```java
Observable.just("one", "two", "three")
		.map(value -> "Hello, i'm " + value) //lembrete importante: o retorno desse operador é um novo Observable (do tipo retornado pela função)
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

Hello, i'm one
Hello, i'm two
Hello, i'm three
*/
```

#### flatMap

![flatMap](/images/programacao-reativa-parte-2-15.png)

O operador [flatMap](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#flatMap-io.reactivex.functions.Function-) devolve um `Observable` que, para cada item, aplica uma função de transformação **que devolve um novo Observable**; todos os novos `Observables` gerados para cada chamada da função são então mergeados e "achatados" (essa operação se chama *flattern*) em um novo `Observable`.

```java
Observable.just("one", "two", "three")
		.flatMap(value -> Observable.just("Hello, i'm " + value))
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

Hello, i'm one
Hello, i'm two
Hello, i'm three
*/
```

#### timestamp

![timestamp](/images/programacao-reativa-parte-2-16.png)

O operador [timestamp](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#timestamp--) encapsula cada item emitido em um objeto do tipo [Timed](http://reactivex.io/RxJava/javadoc/io/reactivex/schedulers/Timed.html), contendo o *timestamp* do momento em que o *onNext* ocorreu e o valor.

```java
Observable.interval(1000, TimeUnit.MILLISECONDS)
	.timestamp()
	.map(t -> "Timestamp: " + t.time() + ", and value: " + t.value())
	.subscribe(System.out::println);

Thread.sleep(5000);

/*
output:

Timestamp: 1523914485689, and value: 0
Timestamp: 1523914486689, and value: 1
Timestamp: 1523914487689, and value: 2
Timestamp: 1523914488691, and value: 3
Timestamp: 1523914489692, and value: 4
*/
```

### Agregação e acumulação

#### groupBy

![groupBy](/images/programacao-reativa-parte-2-17.png)

O operador [groupBy](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#groupBy-io.reactivex.functions.Function-) permite o agrupamento de valores emitidos a partir do critério implementado na função, e devolve um `Observable` que emite valores do tipo [GroupedObservable](http://reactivex.io/RxJava/javadoc/io/reactivex/observables/GroupedObservable.html); o retorno da função será a chave de agrupamento que pode ser recuperada em cada `GroupedObservable`. Esse objeto também é um `Observable`, então podemos nos subscrever nele para obter os valores do grupo.

```java
Observable.range(0, 10)
		.groupBy(value -> value % 2 == 0 ? "even" : "odd") // "even" ou "odd" serão as chaves de agrupamento; são avaliadas para cada valor emitido
		.subscribe(group -> {

			// group é do tipo GroupedObservable
			group.subscribe(value -> System.out.println("Group " + group.getKey() + " and value " + value));

		});

/*
output:

Group even and value 0
Group odd and value 1
Group even and value 2
Group odd and value 3
Group even and value 4
Group odd and value 5
Group even and value 6
Group odd and value 7
Group even and value 8
Group odd and value 9
*/
```

#### buffer

![buffer](/images/programacao-reativa-parte-2-18.png)

O operador [buffer](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#buffer-int-) coleta os items emitidos baseado em um parâmetro de quantidade de elementos ou tempo transcorrido, e gera um novo `Observable` com um `List` dos valores bufferizados.

```java
Observable.interval(1000, TimeUnit.MILLISECONDS)
	.buffer(2) //buffer a cada dois elementos emitidos
	.doOnNext(System.out::println)
	.subscribe();

Thread.sleep(10000);

/*
output:

[0, 1] // um valor do tipo java.util.List é emitido no onNext
[2, 3]
[4, 5]
[6, 7]
[8, 9]
*/
```

```java
Observable.interval(1000, TimeUnit.MILLISECONDS)
	.buffer(2000, TimeUnit.MILLISECONDS) // buffer a cada dois segundos
	.doOnNext(System.out::println)
	.subscribe();

Thread.sleep(10000);

/*
output: // essa saída pode ter variacões

[0, 1]
[2, 3]
[4, 5]
[6, 7]
[8, 9]
*/
```

#### reduce

![reduce](/images/programacao-reativa-parte-2-19.png)

O operador [reduce](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#reduce-io.reactivex.functions.BiFunction-) aplica uma função de acumulação sobre o conjunto de items emitidos pelo `Observable`; a função é aplicada ao primeiro valor, e o retorno é reenviado à mesma função com o segundo valor, e assim sucessivamente, reduzindo o conjunto a um único valor final. Essa operação é chamada no RxJava de "reduce" (nome mais comum), mas também é conhecida como "fold" (mais comum em linguagens funcionais), "accumulate", "aggregate", dependendo do contexto. É importante observar que esse operador só pode gerar um valor de retorno após o evento *onCompleted* do `Observable` original, então essa operação é mais convenientemente aplicada em `streams` finitos. Um `Observable` infinito pode nunca emitir o *onCompleted*, podendo gerar um `OutOfMemoryError` pelo acúmulo de valores.

O parâmetro desse operador é um `BiFunction`, uma interface funcional do Java que representa uma função com dois argumentos e retorna um valor qualquer. O retorno é do tipo `Maybe`.

```java
Observable.range(1, 10)
		.doOnNext(System.out::println) // imprime cada valor emitido no range
		.reduce((a, b) -> a + b) //soma todos os valores emitidos no range
		.doOnSuccess(r -> System.out.println("Reduce: " + r))
		.subscribe();

/*
output:

1
2
3
4
5
6
7
8
9
10
Reduce: 55
*/
```

Existe uma [sobrecarga](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#reduce-R-io.reactivex.functions.BiFunction-) que permite passar à função um valor inicial:

```java
Observable.range(1, 10)
		.doOnNext(System.out::println)
		.reduce(100, (a, b) -> a + b) //100 é o valor inicial passado à função
		.doOnSuccess(r -> System.out.println("Reduce: " + r))
		.subscribe();

/*
output:

1
2
3
4
5
6
7
8
9
10
Reduce: 155
*/
```

#### scan

![scan](/images/programacao-reativa-parte-2-20.png)

O operador [scan](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#scan-io.reactivex.functions.BiFunction-) devolve um `Observable` que aplica uma função de acumulação sobre os valores emitidos, repassando o novo valor para a função subsequente. Cada retorno da função é emitido pelo novo `Observable`, diferindo, pois, de uma operação de redução, que gera um único valor final.

```java
Observable.range(0, 5)
		.doOnNext(v -> System.out.println("Value is: " + v)) // valores emitidos do range
		.scan((a, b) -> a + b) // o primeiro parâmetro é o resultado acumulado; o segundo é o valor emitido
		.doOnNext(v -> System.out.println("Scan result is: " + v)) // resultado da função passada ao scan
		.subscribe();

/*
output:

Value is: 0 // valor emitido pelo range
Scan result is: 0 // nenhum valor acumulado - a função não é aplicada

Value is: 1 // valor emitido pelo range
Scan result is: 1 // 0 + 1 = 1 (esse resultado será passado para a função subsequente)

Value is: 2 // valor emitido pelo range
Scan result is: 3 // 1 + 2 = 3 (e sucessivamente...)

Value is: 3 // valor emitido pelo range
Scan result is: 6 // 3 + 3 = 6

Value is: 4 // valor emitido pelo range
Scan result is: 10 // 6 + 4 = 10
*/
```

#### collect

![collect](/images/programacao-reativa-parte-2-21.png)

Outra operação comum é o [collect](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#collect-java.util.concurrent.Callable-io.reactivex.functions.BiConsumer-), que permite coletar os elementos, conforme eles são emitidos, dentro de uma estrutura mutável, como uma `Collection`:

```java
Observable.just("one", "two", "three", "four")
		.collect(ArrayList::new, (l, v) -> l.add(v)) // o retorno é um Single<ArrayList>
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

[one, two, three, four]
*/
```

### Temporização

#### window

![window](/images/programacao-reativa-parte-2-22.png)

O operador [window](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#window-long-) permite o agrupamento de items em "janelas", definidas por quantidade ou tempo. É essencialmente igual ao `buffer`, com a diferença que os valores são agrupados em um `Observable` ao invés de um `List`.

```java
Observable.range(0, 10)
		.window(3) // janela com três elementos
		.subscribe(window -> window.toList().subscribe(System.out::println)); // window é um Observable

/*
output:

[0, 1, 2]
[3, 4, 5]
[6, 7, 8]
[9]
*/
```

```java
Observable.interval(1000, TimeUnit.MILLISECONDS)
	.window(2000, TimeUnit.MILLISECONDS) // janela de dois segundos
	.subscribe(window -> window.toList().subscribe(System.out::println));

Thread.sleep(10000);

/*
output: // essa saída pode ter variações

[0, 1]
[2]
[3, 4, 5]
[6, 7]
[8, 9]
*/
```

#### throttle

Existem três sabores desse operador: [throttleFirst](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#throttleFirst-long-java.util.concurrent.TimeUnit-), [throttleLast](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#throttleLast-long-java.util.concurrent.TimeUnit-), e [throttleWithTimeout](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#throttleWithTimeout-long-java.util.concurrent.TimeUnit-). Os três aplicam uma **supressão** (selecionam um elemento e descartam os demais) sobre os items emitidos dentro de uma janela de tempo, gerando um `Observable` que reemite o valor adequado, dependendo do caso.

Os operadores `throttleFirst` e `throttleLast` geram um `Observable` que emite **apenas o primeiro ou último item emitidos dentro do intervalo**, descartando os demais.

![throttleFirst](/images/programacao-reativa-parte-2-23.png)

```java
Observable.interval(1000, TimeUnit.MILLISECONDS)
	.throttleFirst(3000, TimeUnit.MILLISECONDS) // reemite apenas o primeiro valor emitido dentro de uma janela de três segundos
	.doOnNext(System.out::println)
	.subscribe();

Thread.sleep(10000);

/*
output:

0
4
8
*/
```

![throttleLast](/images/programacao-reativa-parte-2-24.png)

```java
Observable.interval(1000, TimeUnit.MILLISECONDS) // emite um valor a cada segundo
	.throttleLast(3000, TimeUnit.MILLISECONDS) // reemite apenas o último valor emitido dentro de uma janela de três segundos
	.doOnNext(System.out::println)
	.subscribe();

Thread.sleep(10000);

/*
output:

2
4
8
*/
```

O operador `throttleWithTimeout` faz algo diferente: cria um `Observable` que reemite apenas o item que **não foi seguido por nenhuma outra emissão** dentro do intervalo.

![throttleWithTimeout](/images/programacao-reativa-parte-2-25.png)

```java
Observable.interval(3000, TimeUnit.MILLISECONDS) // emite um valor a cada três segundos
		.doOnNext(v -> System.out.println("Interval: " + v))
		.throttleWithTimeout(2000, TimeUnit.MILLISECONDS) // emite apenas o item que não foi seguido por nenhum outro, dentro do intervalo
		.doOnNext(v -> System.out.println("Throttled: " + v))
		.subscribe();

Thread.sleep(15000);

/*
output:

Interval: 0		// emitido em 3s
Throttled: 0	// essa emissão não foi seguida por nenhum outra dentro de 2s

// a mesma lógica se aplica aos items abaixo
Interval: 1
Throttled: 1

Interval: 2
Throttled: 2

Interval: 3
Throttled: 3

Interval: 4
*/
```

#### debounce

![debounce](/images/programacao-reativa-parte-2-26.png)

O [debounce](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#debounce-long-java.util.concurrent.TimeUnit-) têm o mesmo comportamento do `throttleWithTimeout`; devolve um `Observable` que inicializa um janela de tempo, e reemite os valores que não foram seguidos por nenhum outro dentro do intervalo (items que não satisfazem essa condição são descartados).

```java
Observable.interval(3000, TimeUnit.MILLISECONDS) // emite um valor a cada três segundos
		.doOnNext(v -> System.out.println("Interval: " + v))
		.debounce(2000, TimeUnit.MILLISECONDS) // emite apenas o item que não foi seguido por nenhum outro, dentro do intervalo
		.doOnNext(v -> System.out.println("Debounced: " + v))
		.subscribe();

Thread.sleep(15000);

/*
Interval: 0		// emitido em 3s
Debounced: 0	// essa emissão não foi seguida por nenhum outra dentro de 2s

// a mesma lógica se aplica aos items abaixo
Interval: 1
Debounced: 1

Interval: 2
Debounced: 2

Interval: 3
Debounced: 3

Interval: 4
*/
```

Uma possibilidade interessante desse operador é definir uma janela de tempo para cada item, usando [uma sobrecarga](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#debounce-io.reactivex.functions.Function-) que recebe uma funcão onde é possível calcular o tempo de duração da janela (isso é sinalizado criando um novo `Observable` para cada item).

```java
Observable.interval(1500, TimeUnit.MILLISECONDS)
	.doOnNext(v -> System.out.println("Interval: " + v))
	.debounce(value -> Observable.timer((value + 1) * 1000, TimeUnit.MILLISECONDS)) // calcula uma janela de tempo para cada item
	.doOnNext(v -> System.out.println("Debounced: " + v))
	.subscribe();

Thread.sleep(15000);


/*
output:

Observable.interval(1500, TimeUnit.MILLISECONDS)
	.doOnNext(v -> System.out.println("Interval: " + v))
	.debounce(value -> Observable.timer((value + 1) * 1000, TimeUnit.MILLISECONDS))
	.doOnNext(v -> System.out.println("Debounced: " + v))
	.subscribe();

Thread.sleep(15000);
*/
```

### Captura de elementos

#### forEach

![forEach](/images/programacao-reativa-parte-2-27.png)

O operador [forEach](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#forEach-io.reactivex.functions.Consumer-) é essencialmente um *alias* para o método `subscribe`.

```java
Observable.just("one", "two", "three")
		.forEach(System.out::println);

/*
output:

one
two
three
*/
```

#### filter

![filter](/images/programacao-reativa-parte-2-28.png)

O operador [filter](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#filter-io.reactivex.functions.Predicate-) filtra items emitidos utilizando um `Predicate`:

```java
Observable.just("one", "two", "three")
		.filter(v -> v.equals("one"))
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

one
*/
```

#### distinct

![distinct](/images/programacao-reativa-parte-2-29.png)

O operador [distinct](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#distinct--) elimina items duplicados **em qualquer momento da sequência emissão** (a comparação é feita usando o `equals` do objeto):

```java
Observable.just("one", "two", "one", "three", "one", "four")
		.distinct()
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

one
two
three
four
*/
```

O operador [distinctUntilChanged](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#distinctUntilChanged--) é ligeiramente diferente, pois a comparação é feita apenas com o item anterior da sequência. O mesmo código anterior produziria a saída:

```java
Observable.just("one", "two", "one", "three", "one", "four")
		.distinct()
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

one
two
one
three
one
four
*/
```

O código abaixo demonstra bem a motivação do `distinctUntilChanged`:

```java
Observable.just("one", "one", "one", "two", "one", "three")
		.distinctUntilChanged()
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

one
two
one
three
*/
```

#### first

![first](/images/programacao-reativa-parte-2-30.png)

O operador [first](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#first-T-) devolve um `Single` que emite o primeiro valor da sequência, ou um valor padrão caso o `Observable` seja completado sem emitir valores.

```java
Observable.just("one", "two", "three")
		.first("zero") //esse método devolve um Single
		.doOnSuccess(System.out::println) //o Single emite o evento onSuccess
		.subscribe();

/*
output:

one
*/
```

```java
Observable.empty()
		.first("zero")
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

zero
*/
```

Existem outros sabores desse operadores. O [firstElement](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#firstElement--) também retorna o primeiro valor da sequência, mas sem um valor padrão caso o mesmo não exista; como, então, o `Observable` **talvez** emitirá algo, o tipo do retorno é um `Maybe`:

```java
Observable.just("one", "two", "three")
		.firstElement() //esse método devolve um Maybe
		.doOnSuccess(System.out::println) //o Maybe emite o evento onSuccess
		.subscribe();

/*
output:

one
*/
```

```java
Observable.empty()
		.firstElement()
		.doOnSuccess(System.out::println)
		.doOnComplete(() -> System.out.println("OnCompleted"))
		.subscribe();

/*
output:

OnCompleted
*/
```

Já o [firstOrError](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#firstOrError--) retorna um `Single` que pode emitir o primeiro valor da sequência, ou um `NoSuchElementException` caso o `Observable` não emita nada:

```java
Observable.just("one", "two", "three")
		.firstOrError()
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

one
*/
```

```java
Observable.empty()
		.firstOrError()
		.doOnError(Throwable::printStackTrace)
		.subscribe();

/*
output:

java.util.NoSuchElementException
	...
*/
```

Existem também mais dois operadores semelhantes, chamados [single](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#single-T-) e [singleElement](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#singleElement--), que convertem um `Observable` em um `Single` (caso do método *single*, que recebe um valor padrão) ou em um `Maybe` (caso do *singleElement*). Semânticamente eles são mais elegantes, mas use-os com cuidado porque o objeto resultante irá emitir um erro caso o `Observable` original emita mais de um valor.

#### last

![last](/images/programacao-reativa-parte-2-31.png)

O operador [last](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#last-T-), naturalmente, tem um comportamento oposto ao `first`, devolvendo o último valor emitido.

```java
Observable.just("one", "two", "three")
		.last("zero")
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

one
*/
```

Assim como o `first`, o método `last` também vem nos sabores [lastElement](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#lastElement--) e [lastOrError](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#lastOrError--).

#### elementAt

![elementAt](/images/programacao-reativa-parte-2-32.png)

O operator [elementAt](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#elementAt-long-) permite recuperar um valor emitido a partir do seu índice (iniciando em zero); o retorno é encapsulado em um `Maybe`, portanto, caso o índice em questão não exista, o evento *onError* não será emitido mas o `Maybe` será completado sem emitir nada.

```java
Observable.just("one", "two", "three")
		.elementAt(1)
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

two
*/
```

```java
Observable.empty()
		.elementAt(1)
		.doOnSuccess(System.out::println)
		.doOnComplete(() -> System.out.println("OnComplete"))
		.subscribe();

/*
output:

OnComplete
*/
```

Outros sabores desse método são uma [sobrecarga](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#elementAt-long-T-) que permite passar um valor padrão caso o índice não exista na sequência, e o [elementAtOrError](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#elementAtOrError-long-), que devolve um `Single` que irá publicar o evento *onError* (com a exceção `NoSuchElementException`) caso o índice não exista.

```java
Observable.just("one", "two", "three")
		.elementAtOrError(1)
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

two
*/
```

```java
Observable.just("one", "two", "three")
		.elementAtOrError(10)
		.doOnSuccess(System.out::println)
		.doOnError(Throwable::printStackTrace)
		.subscribe();

/*
output:

java.util.NoSuchElementException
	...
*/
```

#### take

![take](/images/programacao-reativa-parte-2-33.png)

O operador [take](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#take-long-) permite obter os *n* primeiros elementos emitidos:

```java
Observable.just("one", "two", "three", "four")
	.take(2)
	.doOnNext(System.out::println)
	.subscribe();

/*
output:

one
two
*/
```

Também é possível obter os *n* últimos com o operador [takeLast](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#takeLast-int-):

```java
Observable.just("one", "two", "three", "four")
	.takeLast(2)
	.doOnNext(System.out::println)
	.subscribe();

/*
output:

three
four
*/
```

#### skip

![skip](/images/programacao-reativa-parte-2-34.png)

O operador [skip](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#skip-long-) descarta os primeiros *n* elementos emitidos:

```java
Observable.just("one", "two", "three", "four")
		.skip(2)
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

three
four
*/
```

Já o [skipLast](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#skipLast-int-) descarta os *n* últimos:

```java
Observable.just("one", "two", "three", "four")
		.skipLast(2)
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

one
two
*/
```

#### skipWhile e skipUntil

![skipWhile](/images/programacao-reativa-parte-2-35.png)

O operador [skipWhile](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#skipWhile-io.reactivex.functions.Predicate-) recebe como parâmetro um `Predicate`, omitindo os itens emitidos da sequência **enquanto essa condição for verdadeira**, e emite todos os items subsequentes a partir do elemento para o qual a condição for falsa:

```java
Observable.range(0, 10)
		.skipWhile(v -> v < 5) //omite todos os elements menores que 5
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

5
6
7
8
9
*/
```

![skipUntil](/images/programacao-reativa-parte-2-36.png)

Já o [skipUntil](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#skipUntil-io.reactivex.ObservableSource-) recebe um segundo `Observable`, e devolve um `stream` que omite todos os itens até que o segundo `Observable` emita algum valor:

```java

Observable<Long> timer = Observable.timer(5000, TimeUnit.MILLISECONDS); // emite um valor a cada 5 segundos

// o operador skipUntil fará com que o Observable abaixo aguarde o timer emitir algo;
// ou seja, apesar de emitir um valor a cada segundo (mais rapidamente que o timer, portanto), esses valores serão descartados

Observable.interval(1000, TimeUnit.MILLISECONDS)
	.skipUntil(timer)
	.doOnNext(System.out::println)
	.subscribe();

Thread.sleep(10000);

/*
output:

5
6
7
8
9
*/
```

#### takeWhile e takeUntil

![takeWhile](/images/programacao-reativa-parte-2-37.png)

O [takeWhile](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#takeWhile-io.reactivex.functions.Predicate-) tem uma semântica inversa ao `skipWhile`; esse operador também recebe um `Predicate` e retorna um `Observable` que **captura** os elementos emitidos **enquanto a condição for verdadeira**, descartando os demais a partir do primeiro elemento em que a condição é falsa:

```java
Observable.range(0, 10)
		.takeWhile(v -> v < 5) //captura os elementos menores que 5
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

0
1
2
3
4
*/
```

![takeUntil](/images/programacao-reativa-parte-2-38.png)

O [takeUntil](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#takeUntil-io.reactivex.functions.Predicate-) recebe um `Predicate` e devolve um `Observable` que captura os elementos emitidos **até que a condição seja satisfeita**, e então emite o *onCompleted*:

```java
Observable.range(0, 10)
		.takeUntil(v -> v >= 5) // captura todos menores ou iguais a 5; a partir do momento em que essa condição for satisfeita, os demais serão descartados
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

0
1
2
3
4
5
*/
```

Também existe uma [sobrecarga](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#takeUntil-io.reactivex.ObservableSource-) desse operador que funciona de maneira análoga ao `skipUntil` (recebendo um segundo `Observable`), mas tem um comportamento contrário: captura todos os elementos até que o segundo `Observable` emita algum valor:

```java
Observable<Long> timer = Observable.timer(5000, TimeUnit.MILLISECONDS); // emite um valor a cada 5 segundos

// o operador takeUntil criará um novo Observable que reemitirá os valores até o timer emitir algo, e depois completará
// o Observable abaixo emite valores mais rapidamente que o timer, mas emitirá apenas até o segundo Observable sinalizar

Observable.interval(1000, TimeUnit.MILLISECONDS)
	.takeUntil(timer)
	.doOnNext(System.out::println)
	.doOnComplete(() -> System.out.println("Completed"))
	.subscribe();

Thread.sleep(10000);

/*
output:

0
1
2
3
Completed
*/
```

#### ignoreElements

![ignoreElements](/images/programacao-reativa-parte-2-39.png)

O operador [ignoreElements](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#ignoreElements--) ignora todos os itens emitidos, simulando um evento terminal. O retorno desse método um `Completable`:

```java
Observable.just("one", "two", "three", "four")
		.ignoreElements()
		.doOnComplete(() -> System.out.println("OnComplete"))
		.subscribe();

/*
output:

OnComplete
*/
```

### Condicionais

#### all e any

![all](/images/programacao-reativa-parte-2-40.png)

O operador [all](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#all-io.reactivex.functions.Predicate-) devolve um `Single` do tipo `boolean`, indicando se **todos** os elementos emitidos atendem uma determinada condição. Já o [any](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#any-io.reactivex.functions.Predicate-) verifica se **algum** elemento atende à condição:

```java
Observable.range(1, 10)
		.all(v -> v <= 5)
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

false
*/
```

```java
Observable.just(2, 4, 6, 8, 10)
		.all(v -> v % 2 == 0)
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

true
*/
```

![any](/images/programacao-reativa-parte-2-41.png)

```java
Observable.range(1, 10)
		.any(v -> v <= 5)
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

true
*/
```

```java
Observable.just(2, 4, 6, 8, 10)
		.all(v -> v % 2 != 0)
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

false
*/
```

#### contains

![contains](/images/programacao-reativa-parte-2-42.png)

O operador [contains](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#contains-java.lang.Object-) retorna um `Single` do tipo `boolean`, indicando se o `Observable` emitiu um item específico:

```java
Observable.range(0, 5)
		.contains(2)
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

true
*/
```

```java
Observable.range(0, 5)
		.contains(10)
		.doOnSuccess(System.out::println)
		.subscribe();

/*
output:

false
*/
```

### Concatenação de streams

Uma vez que a programação reativa tem no `stream` sua figura principal, sob o princípio de que "tudo é um stream" e todas as origens e sequências de dados podem ser representadas em um `stream`, é muito comum a necessidade de concatenarmos de alguma forma diferentes fluxos de dados. Existem vários operadores para esses casos de uso. Todos os operadores demonstrados abaixo permitem também a concatenação de `streams` de **tipos diferentes**, o que também é uma necessidade comum (um `Observable` de `Strings` ser concatenado a um `Observable` de números, por exemplo, gerando um novo `Observable` como resultado).

#### concat

![concat](/images/programacao-reativa-parte-2-43.png)

[Existem](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#concat-java.lang.Iterable-) [vários](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#concat-io.reactivex.ObservableSource-io.reactivex.ObservableSource-io.reactivex.ObservableSource-io.reactivex.ObservableSource-) [sabores](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#concatArray-io.reactivex.ObservableSource...-) desse operador. A idéia básica da sua utilização é o formato de um método de fábrica estático que permite concatenar múltiplos `Observables` para gerar um novo.

```java
Observable<String> first = Observable.just("one", "two", "three");

Observable<String> second = Observable.just("four", "five", "six");

Observable<String> third = Observable.just("seven", "eight", "nine");

Observable.concat(first, second, third)
	.doOnNext(System.out::println)
	.subscribe();
```

Um ponto-chave dos vários métodos `concat` é que os `Observables` que funcionam como fontes de dados são drenados *na ordem em que foram enviados*, o que significa que o primeiro `stream` terá todos os seus valores coletados até emitir o `onCompleted`, e o processo será repetido com o `stream` seguinte, sucessivamente. Isso parece evidente nesse exemplo, mas nem sempre é o comportamento desejado. Mais abaixo vamos analisar operadores com semânticas diferentes.

Também existe o operador [concatMap](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#concatMap-io.reactivex.functions.Function-), que permite transformar cada elemento em um `Observable`, e o retorno é um novo `Observable` que é gerado a partir da concatenação dos `streams` resultantes:

```java
Observable.range(1, 10)
		.concatMap(i -> Observable.just("hello, i'm the number " + i)) //o retorno será o resultado da concatenação dos Observables gerados por essa função
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

hello, i'm the number 1
hello, i'm the number 2
hello, i'm the number 3
hello, i'm the number 4
hello, i'm the number 5
hello, i'm the number 6
hello, i'm the number 7
hello, i'm the number 8
hello, i'm the number 9
hello, i'm the number 10
*/
```

#### combineLatest

![combineLatest](/images/programacao-reativa-parte-2-44.png)

Um operador interessante é o [combineLatest](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#combineLatest-java.lang.Iterable-io.reactivex.functions.Function-), em suas diversas variações. A idéia desse método é gerar um `Observable` a partir dos **últimos valores emitidos** pelos `streams` utilizados como fontes de dados, conforme os itens são emitidos.
A função de concatenação recebe um *array* com todos os valores.

```java
Observable<String> first = Observable.just("one", "two", "three");

Observable<String> second = Observable.just("four", "five", "six");

Observable<String> third = Observable.just("seven", "eight", "nine");

// a função de transformação irá receber os últimos valores emitidos como um array.
// nesse exemplo, temos três Observables de entrada. O array será gerado com último valor de cada um e apenas quando os três emitirem algum valor.
// a função de concatenação continuará sendo invocada até que todos terminem (no exemplo abaixo, a "concatenação" é o toString sobre o array).

Observable.combineLatest(Arrays.asList(first, second, third), Arrays::toString)
	.doOnNext(System.out::println)
	.subscribe();

/*
output:

[three, six, seven]
[three, six, eight]
[three, six, nine]
*/
```

Uma sobrecarga desse método permite passar vários `Observables` e uma função que recebe cada valor individual, ao invés de um *array*:

```java
Observable.combineLatest(first, second, third, (a, b, c) -> a + "-" + b + "-" + c)
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

three-six-seven
three-six-eight
three-six-nine
*/
```

Um método de instância do `Observable` que tem um comportamento parecido é o [withLatestFrom](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#withLatestFrom-java.lang.Iterable-io.reactivex.functions.Function-), que gera um novo `Observable` com os valores emitidos pelo `stream` combinados com o último valor emitido por um segundo `Observable` (a lógica de combinação é representada em uma função).

#### merge

![merge](/images/programacao-reativa-parte-2-45.png)

Outra maneira de concatenar `Observables` é o operador [merge](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#merge-java.lang.Iterable-), que funciona de maneira equivalente ao `concat`, mas gera um novo `Observable` com os itens dos `streams` de origem **conforme eles são emitidos**, independente da ordem em que foram enviados.

```java
Observable<String> first = Observable.interval(2000, TimeUnit.MILLISECONDS)
		.map(v -> "First observable: " + v)
		.take(5);

Observable<String> second = Observable.interval(1000, TimeUnit.MILLISECONDS)
		.map(v -> "Second observable: " + v)
		.take(5);

Observable<String> third = Observable.interval(500, TimeUnit.MILLISECONDS)
		.map(v -> "Third observable: " + v)
		.take(5);

Observable.merge(first, second, third)
	.doOnNext(System.out::println)
	.subscribe();

Thread.sleep(10000);

/*
output:

Third observable: 0
Second observable: 0
Third observable: 1
Third observable: 2
Second observable: 1
First observable: 0
Third observable: 3
Third observable: 4
Second observable: 2
Second observable: 3
First observable: 1
Second observable: 4
First observable: 2
First observable: 3
First observable: 4
*/
```

Novamente, a diferença de destaque entre este operador e o `concat` é que o `merge` não aguarda um `Observable` de entrada ser completado para drenar o próximo. Utilize o `concat` caso precise manter a ordem de emissão dos `streams` de origem.

Embora o `merge` também seja um método estático (de fábrica), também é possível realizar essa operação em um `Observable` já existente, usando o método [mergeWith](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#mergeWith-io.reactivex.ObservableSource-). O comportamento é o mesmo, de modo que o novo `Observable` reemitirá os valores conforme são emitidos nos `streams` de origem:

```java
Observable.interval(2000, TimeUnit.MILLISECONDS)
		.map(v -> "Source observable: " + v)
		.mergeWith(
				Observable.interval(1000, TimeUnit.MILLISECONDS)
					.map(v -> "Merged observable: " + v)
		)
		.doOnNext(System.out::println)
		.subscribe();

/*
output:

Merged observable: 0
Source observable: 0
Merged observable: 1
Merged observable: 2
Merged observable: 3
Source observable: 1
Merged observable: 4
Merged observable: 5
Source observable: 2
Merged observable: 6
Merged observable: 7
Source observable: 3
Merged observable: 8
Merged observable: 9
Source observable: 4
*/
```

#### zip

![zip](/images/programacao-reativa-parte-2-46.png)

O operador [zip](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#zip-java.lang.Iterable-io.reactivex.functions.Function-) representa uma operação comum em linguagens funcionais. Esse operador irá concatenar os elementos de *n* `Observables` usando uma função de transformação, agrupando os items pelo **índice**. Ou seja, o novo `Observable` irá emitir primeiro o retorno da função aplicada ao primeiro item de cada `stream` de entrada; o segundo elemento emitido será o retorno da função aplicada ao segundo item de cada `stream`, e assim sucessivamente.

```java
// nesse exemplo, temos três Observables que emitem valores em intervalos diferentes, e vamos concatena-los usando o zip.
// O Observable gerado irá aguardar os três streams de entrada emitirem valores,
// pois a agregação do zip é realizada usando o índice do elemento emitido.

Observable<Long> first = Observable.interval(2000, TimeUnit.MILLISECONDS);

Observable<Long> second = Observable.interval(500, TimeUnit.MILLISECONDS);

Observable<Long> third = Observable.interval(500, TimeUnit.MILLISECONDS);

Observable.zip(first, second, third, (a, b, c) -> a + " - " + b + " - " + c)
		.doOnNext(System.out::println)
		.subscribe();

Thread.sleep(10000);

/*
output:

0 - 0 - 0
1 - 1 - 1
2 - 2 - 2
3 - 3 - 3
4 - 4 - 4
*/
```

O método de instância equivalente é o [zipWith](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#zipWith-java.lang.Iterable-io.reactivex.functions.BiFunction-), que tem o mesmo comportamento.

```java
Observable.just("one", "two", "three")
		.zipWith(Observable.interval(1000, TimeUnit.MILLISECONDS), (a, b) -> a + " - " + b)
		.doOnNext(System.out::println)
		.subscribe();

Thread.sleep(5000);

/*
output:

one - 0
two - 1
three - 2
*/
```

#### amb

![amb](/images/programacao-reativa-parte-2-47.png)

Outro operador de concatenação é o [amb](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#amb-java.lang.Iterable-), que gera um `Observable` que, dados múltiplos `streams` de entrada, reemite o primeiro elemento do **primeiro Observable que emitir algum valor**, completando a seguir. Os demais `Observables` são descartados.

```java
Observable<String> fast = Observable.timer(1000, TimeUnit.MILLISECONDS)
		.map(v -> "First observable: " + v)
		.take(5);

Observable<String> slow = Observable.timer(2000, TimeUnit.MILLISECONDS)
		.map(v -> "Second observable: " + v)
		.take(5);

Observable.amb(Arrays.asList(fast, slow))
		.doOnNext(System.out::println)
		.doOnComplete(() -> System.out.println("OnComplete"))
		.subscribe();

Thread.sleep(3000);

/*
output:

First observable: 0
OnComplete
*/
```

O método de instância equivalente é o [ambWith](http://reactivex.io/RxJava/javadoc/io/reactivex/Observable.html#ambWith-io.reactivex.ObservableSource-), que tem o mesmo comportamento:

```java
Observable.timer(2000, TimeUnit.MILLISECONDS)
		.map(v -> "First observable: " + v)
		.ambWith(
			Observable.timer(1000, TimeUnit.MILLISECONDS) // o segundo Observable emite valores mais rapidamente
					.map(v -> "Second observable: " + v)
		)
		.take(5)
		.doOnNext(System.out::println)
		.doOnComplete(() -> System.out.println("OnComplete"))
		.subscribe();

/*
output:

Second observable: 0
OnComplete
*/
```

Esse operador, embora talvez não pareça a primeira vista, é extremamente útil. Imagine que você precise ler múltiplas fontes de dados, como diversos servidores onde uma informação poderia estar, e quer utilizar a resposta mais rápida; o `amb` fará exatamente isso para você. Um código que seria complicado se torna trivial com o uso do `amb`.

## Conclusão

Ufa! E pensar que ainda faltaram muitos métodos...mas para este capítulo da nossa jornada reativa é o suficiente. Nesse post, vimos em detalhes o principal objeto dos frameworks Rx, o `Observable`, e seus irmãos `Completable`, `Single` e `Maybe`. Também olhamos os objetos do tipo `Subject`, que são muito úteis em várias situações e bastante utilizados no ecossistema Rx.

Nesse post também vimos em detalhes o verdadeiro poder dessas bibliotecas: os **operadores reativos**, um espetacular conjunto de métodos que tornam tarefas que seriam complicadas quase triviais. E todos esses operadores têm em comum a construção do `stream` como um **fluxo de dados**, em que as modificações dos dados são **propagadas**, em oposição ao modelo de mudança de estado. Isso facilita sobremaneira o modelo de programação, onde podemos nos basear em funções declarativas e livres de efeitos colaterais. Isso nos dá outros benefícios que iremos explorar no próximo post, onde falaremos sobre **paralelismo**, **programação concorrente** e **contrapressão**.

Apesar do post loooongo, espero que tenha gostado e que seja útil para você na utilização do RxJava! Em caso de dúvidas, críticas ou qualquer outra coisa, sinta-se livre para utilizar a caixa de comentários!

