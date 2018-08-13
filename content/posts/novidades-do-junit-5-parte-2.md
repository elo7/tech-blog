---
date: 2017-11-20
category: back-end
tags:
  - java
  - junit
  - tdd
authors: [ljtfreitas]
layout: post
title: Novidades do JUnit 5 - parte 2
description: Neste post, vamos continuar a explorar as mudanças da nova versão do JUnit. No post anterior, vimos os principais novos recursos. Agora, vou comentar sobre a migração dos nossos testes já existentes.
cover: novidades-do-junit-5-parte-2.png
---

Em setembro/2017, após pouco mais de um ano de versões *milestones* e testes, foi lançado o JUnit 5, a nova versão do principal framework para testes de código na plataforma Java. Escrevi um post sobre as principais novas funcionalidades e recursos. Váááárias coisas legais, mas o que fazemos com os testes **que já existem no nosso projeto**?

## Adorei o JUnit 5! Mas...e os meus testes já escritos nas versões anteriores do JUnit?

Ok, vamos assumir que você **já tem** testes escritos com o JUnit 3/4 na sua base de código (potencialmente, dezenas, centenas ou milhares). Precisamos alterá-los para começar a usar o JUnit 5? A resposta, ainda bem, é **não**. Podemos fazer as duas versões conviverem no mesmo projeto (como as novas classes do JUnit Jupiter estão sob o pacote base *org.junit.jupiter*, não há nenhum conflito com as versões anteriores), enquanto modificamos os testes já existentes e implementamos os novos no JUnit 5.

Como exemplo, no meu projeto há dois testes (quebrados propositalmente para fins de exemplo):

```java
import org.junit.Assert; // <- pacotes do junit 4
import org.junit.Test;

public class JUnit4Test {

    @Test // <- junit 4
    public void test() {
        Assert.fail("fail...on junit 4"); // <- junit 4
    }
}
```

```java
import org.junit.jupiter.api.Assertions; // <- pacotes do junit 5
import org.junit.jupiter.api.Test;

public class JUnit5Test {

    @Test // <- junit 5
    public void sample() {
        Assertions.fail("fail...on junit 5!"); <- junit 5
    }

}
```

### Build

Vamos começar configurando o JUnit 5 para rodar no build da aplicação (nos exemplos abaixo, utilizo o Maven). O resultado do `mvn test` no meu projeto será:

```bash
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running com.elo7.sample.junit.JUnit4Test
Tests run: 1, Failures: 1, Errors: 0, Skipped: 0, Time elapsed: 0.208 sec <<< FAILURE!
test(com.elo7.sample.junit.JUnit4Test)  Time elapsed: 0.02 sec  <<< FAILURE!
java.lang.AssertionError: fail...on junit 4
    at org.junit.Assert.fail(Assert.java:88)

Results :

Failed tests:   test(com.elo7.sample.junit.JUnit4Test): fail...on junit 4

Tests run: 1, Failures: 1, Errors: 0, Skipped: 0
```

O teste implementado com o JUnit 5 não foi executado. Precisamos configurar o [Surefire](http://maven.apache.org/surefire/maven-surefire-plugin/) (o plugin padrão para execução de testes no Maven), no `pom.xml`, para utilizar um *provider* customizado para rodar os testes sobre o JUnit Platform:

```xml
<build>
    <plugins>
        <plugin>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>2.19</version>
            <dependencies>
                <!-- JUnit Platform provider -->
                <dependency>
                    <groupId>org.junit.platform</groupId>
                    <artifactId>junit-platform-surefire-provider</artifactId>
                    <version>1.0.1</version>
                </dependency>
                <!-- Também precisamos de um TestEngine -->
                <dependency>
                    <groupId>org.junit.jupiter</groupId>
                    <artifactId>junit-jupiter-engine</artifactId>
                    <version>5.0.1</version>
                </dependency>
            </dependencies>
        </plugin>
    </plugins>
</build>
```

E agora...

```bash
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running com.elo7.sample.junit.JUnit5Test
Tests run: 1, Failures: 1, Errors: 0, Skipped: 0, Time elapsed: 0.302 sec <<< FAILURE! - in com.elo7.sample.junit.JUnit5Test
sample()  Time elapsed: 0.102 sec  <<< FAILURE!
org.opentest4j.AssertionFailedError: fail...on junit 5!
    at com.elo7.sample.junit.JUnit5Test.sample(JUnit5Test.java:10)

Results :

Failed tests:
  JUnit5Test.sample:10 fail...on junit 5!

Tests run: 1, Failures: 1, Errors: 0, Skipped: 0
```

Configuramos a execução dos testes para utilizar o JUnit5, mas agora nosso problema se inverteu; o teste escrito com JUnit 4 não rodou :(. Nosso próximo passo é rodar TODOS os testes usando o JUnit Platform.

Precisamos adicionar uma nova dependência abaixo à nossa configuração do Surefire; um artefato com o estiloso nome de *junit-vintage-engine*.

```xml
<plugin>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>2.19</version>
    <dependencies>
        ...
        <dependency>
            <groupId>org.junit.vintage</groupId>
            <artifactId>junit-vintage-engine</artifactId>
            <version>4.12.1</version>
        </dependency>
    </dependencies>
</plugin>
```

O `TestEngine` disponibilizado pelo *junit-vintage* é capaz de **rodar os testes escritos com JUnit 3/4 sobre a plataforma do JUnit 5!**.

Com a modifação acima, a saída do `mvn test` é:

```bash
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running com.elo7.sample.junit.JUnit4Test
Tests run: 1, Failures: 1, Errors: 0, Skipped: 0, Time elapsed: 0.204 sec <<< FAILURE! - in com.elo7.sample.junit.JUnit4Test
test  Time elapsed: 0.022 sec  <<< FAILURE!
java.lang.AssertionError: fail...on junit 4
    at com.elo7.sample.junit.JUnit4Test.test(JUnit4Test.java:10)

Running com.elo7.sample.junit.JUnit5Test
Tests run: 1, Failures: 1, Errors: 0, Skipped: 0, Time elapsed: 0.098 sec <<< FAILURE! - in com.elo7.sample.junit.JUnit5Test
sample()  Time elapsed: 0.07 sec  <<< FAILURE!
org.opentest4j.AssertionFailedError: fail...on junit 5!
    at com.elo7.sample.junit.JUnit5Test.sample(JUnit5Test.java:10)

Results :

Failed tests:
  JUnit4Test.test:10 fail...on junit 4
  JUnit5Test.sample:10 fail...on junit 5!

Tests run: 2, Failures: 2, Errors: 0, Skipped: 0
```

Ambos os testes, JUnit 4 e 5, rodaram :).

Na [documentação](http://junit.org/junit5/docs/current/user-guide/#running-tests-build), há mais exemplos de customizações do Surefire para o JUnit 5.

Caso você utilize o Gradle, basta seguir a [documentação](http://junit.org/junit5/docs/current/user-guide/#running-tests-build-gradle) para configurar o [plugin](http://junit.org/junit5/docs/current/user-guide/#running-tests-build-gradle-junit-enable) do JUnit 5.

### IDE

Caso utilize uma IDE que ainda não suporta nativamente o JUnit 5, podemos adicionar mais duas dependências que permitem executarmos testes do JUnit Platform sobre a estrutura do Junit 4 (!):

```xml
<dependency>
    <groupId>org.junit.platform</groupId>
    <artifactId>junit-platform-runner</artifactId>
    <version>1.0.1</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter-engine</artifactId>
    <version>5.0.1</version>
    <scope>test</scope>
</dependency>
```

O artefato *junit-platform-runner* irá fornecer o runner [JUnitPlatform](http://junit.org/junit5/docs/current/api/org/junit/platform/runner/JUnitPlatform.html), que podemos usar com a anotação `RunWith` do JUnit 4 (o *junit-jupiter-engine* deve ser adicionado para fornecer algum `TestEngine`):

```java
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.platform.runner.JUnitPlatform;
import org.junit.runner.RunWith;

@RunWith(JUnitPlatform.class) // <- @RunWith do junit 4
public class JUnit5Test {

    @Test // <- junit 5
    public void sample() {
        Assertions.fail("fail...on junit 5!"); // <- junit 5
    }
}
```

O teste acima funcionará normalmente em qualquer IDE que suporte o JUnit 4. No build, também não é necessária nenhuma customização adicional.

### Migrando o código

Considerando tudo o que vimos até aqui, podemos dizer que a mudança para o JUnit 5 é bem mais do que apenas "adicionar o jar" da nova versão. Para fins de migração de código, um resumo das diferenças mais significativas (algumas já detalhadas neste mesmo post) que você deve considerar:

* Anotações no pacote *org.junit.jupiter.api*

* `Assert` substituída pela classe `Assertions`

* `Assume` substituída pela classe `Assumptions`

* `@Before` e `@After` substituídas por `@BeforeEach` e `@AfterEach`

* `@BeforeClass` e `@AfterClass` substituídas por `@BeforeAll` e `@AfterAll`

* `@Ignore` substituída por `@Disabled`

* `@Category` substituída por `@Tag`

* `@RunWith` substituída por `@ExtendeWith` (o que????? explicado mais abaixo!)

* `@Rule` e `@ClassRule` substituídas por...`@ExtendeWith` também (como????? explicado mais abaixo!)

Um comentário específico sobre as `Rules`: como dito acima, as anotações `@Rule` e `@ClassRule` não existem no JUnit 5. Essas duas classes eram utilizadas por vários frameworks como ponto de extensão, uma vez que as `Rules` podem ser usadas para externalizar configurações/parametrizações de ambiente necessárias para o teste, como inicializar mocks (caso do [Mockito](https://static.javadoc.io/org.mockito/mockito-core/2.10.0/org/mockito/junit/MockitoRule.html)) ou subir um servidor HTTP (caso do [MockServer](http://www.mock-server.com/)). Dada a importância das `Rules` no ecossistema do JUnit e para os desenvolvedores, foi implementado um suporte específico para três `Rules` em particular: [ExternalResource](http://junit.org/junit4/javadoc/4.12/org/junit/rules/ExternalResource.html), [Verifier](http://junit.org/junit4/javadoc/4.12/org/junit/rules/Verifier.html) e [ExpectedException](http://junit.org/junit4/javadoc/4.12/org/junit/rules/ExpectedException.html). A [documentação](http://junit.org/junit5/docs/current/user-guide/#migrating-from-junit4-rule-support) explica com mais detalhes a motivação para suportar especificamente essas três classes (também é necessário o uso de algumas anotações adicionais: [ExpectedExceptionSupport](http://junit.org/junit5/docs/current/api/org/junit/jupiter/migrationsupport/rules/ExpectedExceptionSupport.html), [ExternalResourceSupport](http://junit.org/junit5/docs/current/api/org/junit/jupiter/migrationsupport/rules/ExternalResourceSupport.html) e [VerifierSupport](http://junit.org/junit5/docs/current/api/org/junit/jupiter/migrationsupport/rules/VerifierSupport.html)).

## Extendendo o JUnit 5

No JUnit 4, os principais pontos de extensão do framework são as [Rules](https://github.com/junit-team/junit4/wiki/Rules) (que permitem alterar/introduzir comportamentos externos no teste) e os [Test Runners](https://github.com/junit-team/junit4/wiki/Test-runners) (um objeto responsável por toda a execução do teste, permitindo customizá-lo à vontade). Esses dois modelos **não existem** no JUnit 5, que introduz um novo conceito de extensão baseado na interface [Extension](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/Extension.html) (essa interface não possui métodos; é apenas uma interface de marcação).

O novo modelo de extensão do JUnit é mais flexível do que as opções das versões anteriores. Podemos implementar extensões para customizações mais específicas; diferentes customizações são representadas por diferentes interfaces, de modo que podemos implementar apenas o detalhe que queremos extender. Por exemplo, resolução de argumentos de métodos ([ParameterResolver](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/ParameterResolver.html)), callbacks de pré/pós execução de testes ([AfterAllCallback](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/AfterAllCallback.html), [AfterEachCallback](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/AfterEachCallback.html), [AfterTestExecutionCallback](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/AfterTestExecutionCallback.html), [BeforeAllCallback](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/BeforeAllCallback.html), [BeforeEachCallback](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/BeforeEachCallback.html), [BeforeTestExecutionCallback](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/BeforeTestExecutionCallback.html)), captura de erros ([TestExecutionExceptionHandler](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/TestExecutionExceptionHandler.html)), pós-processamento da instância da classe de teste ([TestInstancePostProcessor](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/TestInstancePostProcessor.html)) ou executar um teste condicionalmente ([ExecutionCondition](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/ExecutionCondition.html)).

### Usando extensões

Para utilizar uma extensão no teste, devemos usar a anotação [ExtendWith](http://junit.org/junit5/docs/current/api/org/junit/jupiter/api/extension/ExtendWith.html).

```java
import org.junit.jupiter.api.extension.ExtendWith;

@ExtendWith(YourExtension.class)
public class JUnit5Test {

}
```

Essa anotação é *repetível*, de modo que podemos utilizar várias extensões diferentes no mesmo teste.

```java
import org.junit.jupiter.api.extension.ExtendWith;

@ExtendWith(YourExtension.class)
@ExtendWith(OtherExtension.class)
public class JUnit5Test {

}
```

### Implementando extensões

Para entendendermos o uso das interfaces comentadas mais acima, vou adaptar e comentar aqui um exemplo que consta na documentação para criarmos uma extensão para o [Mockito](http://site.mockito.org/) (se você ainda não conhece o Mockito, recomendo a leitura destes [dois](/testes-codigo-mockito) [posts](/testes-codigo-mockito-2) do nosso blog). Essa extensão irá permitir a injeção de mocks como argumentos dos testes:

```java
import org.junit.jupiter.api.extension.TestInstancePostProcessor;
import org.junit.jupiter.api.extension.ParameterResolver;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.junit.jupiter.api.extension.ParameterResolutionException;
import org.junit.jupiter.api.extension.ParameterContext;
import org.junit.jupiter.api.extension.ExtensionContext.Namespace;
import org.junit.jupiter.api.extension.ExtensionContext.Store;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

import java.lang.reflect.Parameter;

// uma extensão deve sempre implementar Extension; é o caso da classe abaixo pois implementa TestInstancePostProcessor e ParameterResolver (que extendem Extension)
public class MockitoExtension implements TestInstancePostProcessor, ParameterResolver {

    // método da interface TestInstancePostProcessor; será invocado após a criação da instância da classe de teste
    @Override
    public void postProcessTestInstance(Object testInstance, ExtensionContext context) throws Exception {
        //inicializa os campos da classe marcados com anotações do Mockito
        MockitoAnnotations.initMocks(testInstance);
    }

    // método da interface ParameterResolver; será invocado SE o método de teste tiver algum argumento
    @Override
    public boolean supportsParameter(ParameterContext parameterContext, ExtensionContext extensionContext) throws ParameterResolutionException {
        // nossa extensão só se aplica para argumentos anotados com @Mock
        return parameterContext.getParameter().isAnnotationPresent(Mock.class);
    }

    // método da interface ParameterResolver; será invocado SE o método de teste tiver algum argumento e SE passar na verificação do método supportsParameter
    @Override
    public Object resolveParameter(ParameterContext parameterContext, ExtensionContext extensionContext) throws ParameterResolutionException {
        Parameter parameter = parameterContext.getParameter();

        Class<?> mockType = parameter.getType();

        // Store e Namespace são dois objetos para persistência de estado da extensão
        Store mocks = extensionContext.getStore(Namespace.create(MockitoExtension.class, mockType));

        // cria um novo mock caso ainda não exista
        return mocks.getOrComputeIfAbsent(mockType.getCanonicalName(), key -> Mockito.mock(mockType));
    }
}
```

E no nosso teste:

```java
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class) //usando nossa extensão
public class JUnit5Test {

    @BeforeEach
    public void setup(@Mock Person mockPerson) { //nossa extensão irá injetar o parâmetro anotado com @Mock
        when(mockPerson.name()).thenReturn("Tiago");
    }

    @Test
    public void sample(@Mock Person person) { //nossa extensão irá retornar o mesmo mock criado no setup
        assertEquals("Tiago", person.name());
    }

    private interface Person {

        String name();
    }
}
```

A [documentação](http://junit.org/junit5/docs/current/user-guide/#extensions) explica em detalhes, com vários exemplos e casos de uso, o novo modelo de extensão do JUnit 5.

## Conclusão

Nesse segundo post, tentei abordar os principais pontos de atenção para começarmos a utilizar o JUnit 5 em um projeto já existente, incluindo configuração do build, IDE e migração do código. É possível fazer a transição de forma gradual e natural, pois é perfeitamente possível incluir o JUnit 5 em um projeto que já utilize alguma versão anterior do framework.

Apesar dos dois posts loooongos, é possível que algo tenha ficado de fora; se quiser se aprofundar mais, recomendo a excelente [documentação](http://junit.org/junit5/docs/current/user-guide/) e o repositório com [exemplos de código](https://github.com/junit-team/junit5-samples).

Obrigado e espero que tenha gostado! Em caso de dúvidas ou qualquer outra observação, sinta-se à vontade para usar a caixa de comentários!
