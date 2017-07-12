---
date: 2016-07-20
category: mobile
tags:
  - java
  - android
  - dependency-inversion
  - dagger2
authors: [rsicarelli]
layout: post
title: Desmistificando o Dagger 2
description: Uma das bibliotecas mais famosas e mais faladas no Android e também é a que gera mais dúvidas em sua implementação. Iremos tornar fácil a compreensão dessa poderosa ferramenta.
---

Sem dúvidas, uma das bibliotecas mais famosas da “atualidade” (embora tenha vários anos de vida) no universo Android, mas que mesmo assim nos causa muita confusão e dúvida.

Até mesmo para engenheiros experientes, o <a href="http://google.github.io/dagger/" target="_blank">Dagger 2</a> causa um pouco de “medo” para implementar. 

Mas a parte boa é que ele é muito simples! Vamos juntos tentar dissecar o problema até que você tenha o famoso Eureka! 

## Inversion of Control e Dependency Inversion

Para entender bem o _Dagger 2_, precisamos entender o que significa <a href="https://en.wikipedia.org/wiki/Dependency_inversion_principle" target="_blank">**DI**</a> e <a href="https://en.wikipedia.org/wiki/Inversion_of_control" target="_blank">**IoC**</a>. 

Vamos criar uma classe qualquer:

```
public class NossaClasse {
    private NossasDependencia nossaDependencia;

    public NossaClasse (){
      	nossaDependencia = new nossaDependencia();
    }

    public String retornaAlgumAtributo(){
        nossaDependencia.retornaAlgumAtributo();
    }
}
```

Agora, como vamos testar essa classe? Perceba que não temos como "controlar" a `NossaDependencia`, já que a responsabilidade de criar está nas mãos da `NossaClasse`. 

Para resolver isso, podemos remover a responsabilidade da `NossaClasse` de _criar_ , utilizando o princípio do **IoC**:

```
public class NossaClasse {
    private NossasDependencia nossaDependencia;

    public NossaClasse (NossasDependencia nossaDependencia){
       this.nossaDependencia = nossaDependencia;
    }

    public String retornaAlgumAtributo(){
       nossaDependencia.retornaAlgumAtributo();
    }
}
```
E, em nossa `Activity`:
```
public class NossaActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        NossaDependencia nossaDependencia = new NossaDependencia();
        NossaClasse nossaClasse = new NossaClasse(nossaDependencia);
    }
}
```

Para testar fica super fácil. 
Vamos usar o <a href="http://junit.org/junit4/" target="_blank">**JUnit**</a> e o <a href="http://mockito.org/" target="_blank">**Mockito**</a> para isso. Caso não esteja familirializado com o **Mockito**, <a href="http://engenharia.elo7.com.br/testes-codigo-mockito/" target="_blank">sugiro dar uma lida nesse post incrível do nosso engenheiro Tiago Lima sobre o assunto</a>

```
public class TestandoNossaClasse {
    @Test
    public void deveRetornarAlgumAtributo(){
        NossaDependencia target = Mockito.mock(NossaDependencia.class);
        Mockito.when(nossaDependencia.retornaAlgumAtributo()).thenReturn("Dagger 2!");
        NossaClasse alvo = new NossaClasse(target);
        Assert.assertEquals(alvo.retornaAlgumAtributo(), "Dagger 2!");
    }
}
```

Conseguiu perceber? Podemos criar testes excepcionais apenas aplicando esse princípio de **IoC**! E, de bandeja, entendemos o que é "injetar uma dependência", já que a dependência está sendo fornecida para a `NossaClasse`.

## Facilitando as coisas

Agora, vamos precisar utilizar a `NossaClasse` em vários lugares, e vai ser bem "chato" ficar repetindo essa linha:

```
NossaDependencia nossaDependencia = new NossaDependencia();
NossaClasse nossaClasse = new NossaClasse(nossaDependencia);
```

Poderiamos facilitar as coisas criando um pattern de <a href="https://sourcemaking.com/design_patterns/factory_method" target="_blank">**Factory**</a>:

```
public class DependenciaFactory {
   private static NossaDependencia nossaDependencia;
   private static NossaClasse nossaClasse;

   public static NossaDependencia fornecerNossaDependencia(){
      if(nossaDependencia == null){
         nossaDependencia = new NossaDependencia();
      }
      return nossaDependencia;
   }

   public static NossaClasse fornececerNossaClasse(){
      if(nossaClasse == null){
         nossaClasse = new NossaClasse(fornecerNossaDependencia())
      }
      return nossaClasse;
   }
}
```

Agora, irá ficar mais transparente pra nós:

```
public class OutraActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        NossaClasse nossaClasse = DependenciaFactory.fornececerNossaClasse();
    }
}
```

Elegante, não é? Também achei.

## Dagger 2

Agora que entendemos o por que de _inverter as responsabilidades_, podemos falar sobre o **Dagger 2**. 

O que seria o **Dagger 2**? Seria, basicamente, o nosso `DependenciaFactory`, só que com uma implementação um pouco mais "avançada"!. 

## Cenário

Para explicar a arquitetura utilizada no **Dagger 2**, vamos fazer um paralelo com um cenário mais convencional para nós.

Vamos imaginar que iremos ter uma _fábrica de cadeiras_. Já temos as madeiras e os pregos, só _precisamos das nossas ferramentas_.

Bom, como iremos construir várias cadeiras, seria bom se comprassemos nossas ferramentas para não ter que ter o trabalho de ir buscá-las em algum lugar todas as vezes que iremos utilizá-las.

Também, seria ótimo se tivéssemos uma caixa de ferramentas para guardar todas elas. Caso comprássemos uma nova, era só jogar lá dentro.

Com o **Dagger 2** nossas ferramentas são os `Modules` e nossa caixa de ferramentas são nossos `Componentes`! Ou seja, um `Component` nada mais é que um conjunto de `Modules`.

## Criando nossas ferramentas (Modules)

Para se constuir uma cadeira, precisamos de pelo menos um martelo, certo? Temos vários martelos e precisamos fornecer esses martelos de alguma maneira:

```
@Ferramenta
public class Martelos {

    @Fornecedor
    public MarteloPequeno fornecerMarteloPequeno() {
        return new MarteloPequeno();
    }

    @Fornecedor
    public MarteloMedio fornecerMarteloMedio() {
        return new MarteloMedio();
    }

    @Fornecedor
    public MarteloGrande fornecerMarteloGrande() {
        return new MarteloGrande();
    }
}
```

Percebe que estamos usando `@AlgumaCoisa`? Isso é uma API chamada **Annotation Processor**! Você "anota" um método, e algum processador irá gerar todo o código para você. Sugiro que você dê uma lida no <a href="https://medium.com/android-dev-br/annotation-processing-no-android-d28b734b8043#.uvndm6yz3" target="_blank">artigo</a> que nosso engenheiro **Felipe Theodoro** escreveu sobre esse assunto!

Aqui, estamos anotando que nossa classe `Martelos` é uma fornecedora de ferramentas do tipo **martelo**, e que temos métodos que "fornecem" nossas classes. 

O **Dagger 2** tem dois processors que irão gerar toda as implementações necessárias. Vamos adaptar nossa classe para o "universo" do **Dagger 2**:

```
@Module
public class Martelos {

	@Provides
    public MarteloPequeno providesMarteloPequeno() {
        return new MarteloPequeno();
    }

    @Provides
    public MarteloMedio providesMarteloMedio() {
        return new MarteloMedio();
    }

    @Provides
    public MarteloGrande providesMarteloGrande() {
        return new MarteloGrande();
    }
}
```

Fácil, né? Agora, podemos "comprar" vários martelos e irá ser bem simples de fornecer (_provides_) eles para quem quiser usa-los.

## Colocando as ferramentas na caixa

Agora, precisamos colocar isso tudo junto. Então, vamos colocar nossas ferramentas na caixa de ferramentas:

```
@CaixaDeFerramentas(ferramentas = {Martelos.class})
public interface NossaCaixaDeFerramentas {...}
```
Traduzindo pro dagger:
```
@Component(modules = {Martelos.class})
public interface NossoComponent {}
```
Pronto, "já está tudo lá".

## Fornecendo as ferramentas

Temos todas as nossas ferramentas criadas. Agora, precisamos disponibilizá-las para todo mundo que quiser utilizar. Para isso, podemos colocar nossa caixa de ferramentas em um lugar que _todo mundo tenha acesso_: na `Application`:

```
public class NossaApplication extends Application {
    private static NossoComponent component;

    @Override
    public void onCreate() {
        super.onCreate();

        component = NossoComponent.builder()
                .martelos(new Martelos())
                .build();
    }
}
```

Mas pera lá. O `NossoComponent` tem um <a href="https://sourcemaking.com/design_patterns/builder" target="_blank">`Builder Pattern`</a>? E esse método "martelos()"? Não temos nada.

Veja que o **Dagger 2** gerou eles para nós, "automaticamente" (precisa fazer o build no projeto), e colocou um _"Dagger"_ na frente, que é a classe gerada através do _Annotation Processor_ que já vimos. 

Vamos ajustar noso código:

```
component = DaggerNossoComponent.builder()
    .martelos(new Martelos())
    .build();
```

Ótimo.

Só precisamos "pegar" essa caixa de ferramenta de algum jeito, então:

```
public static NossoComponent getComponent() {
    return nossoComponent;
}
```

## Definindo quem pode utilizar

Só temos um problema. Somos um pouco "ciumentos" com nossas ferramentas, assim como o **Dagger 2**. Ou seja, precisamos deixar explícito quem pode utilizá-las.

Na nossa caixa de ferramentas, vamos colocar algumas "etiquetas" com o nome de quem pode utilizá-las (classes):

```
@Component(modules = {Martelos.class})
public interface NossoComponent {
    void nossaActivityPodeUsarNossasFerramentas(NossaActivity nossaActivity);
}
```

Agora, precisamos pegar as ferramentas na nossa classe:

```
public class NossaActivity extends AppCompatActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
      ...
      NossaApplication.getNossoComponent().nossaActivityPodeUsarNossasFerramentas(this);
  }
}
```

E como vamos utilizar nosso martelo? Simples:

```
@NossoMarteloMedio
MarteloMedio marteloMedio;
```

Agora, traduzindo tudo pro Dagger 2:

```
@Component(modules = {Martelos.class})
public interface NossoComponent {
	void inject(NossaActivity nossaActivity);
}
```

E usando o `Martelo` na nossa `Activity`:

```
public class NossaActivity extends AppCompatActivity {
    @Inject
    MarteloMedio marteloMedio;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        ...
        NossaApplication.getNossoComponent().inject(this);
    }
}
```

_Momento Eureka!_

## Boas práticas

Em nossa caixa de ferramentas, podemos colocar várias ferramentas. Então, é bom "categorizá-las" de alguma maneira. Uma boa prática é agrupar todos os "martelos", "parafusos", "madeiras", "chaves de fenda" etc. Traduzindo para o mundo Java/Android:

```
component = DaggerNossoComponent.builder()
    .presenters(new PresenterModule())
    .repositories(new RepositoryModule())
    .clients(new ClientModule())
    .build();
```

## Conclusão

Como vimos, podemos não utilizar o **Dagger 2** em nosso projeto e termos o mesmo resultado. Porém, a praticidade e o poder que ganhamos com o **Dagger 2**, são muito vantajosos que acaba valendo muito a pena utilizamos.

No próximo post, irei falar sobre o uso avançado do **Dagger 2** no nossos projetos, focando bastante em testes.


Gostou? Deixe suas impressões nesse post e também compartilhe!
