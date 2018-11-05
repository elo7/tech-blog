---
date: 2016-05-02
category: back-end
tags:
  - java
  - mockito
  - tdd
authors: [ljtfreitas]
layout: post
title: Testes de código com Mockito
description: No trabalho da Engenharia do Elo7, valorizamos bastante a qualidade do código que produzimos. Isso passa por várias etapas: boas práticas de código, programação pareada, revisões cuidadosas e, claro, testes. Muitos testes...
cover: testes-de-codigo-com-mockito.png
---
No trabalho da Engenharia do Elo7, valorizamos bastante a qualidade do código que produzimos. Isso passa por várias etapas: boas práticas de código, programação pareada, revisões cuidadosas e, claro, testes. Muitos testes.

Para as aplicações baseadas em Java (nossa principal linguagem), utilizamos o <a href="http://mockito.org/" target="_blank">Mockito</a> como ferramenta de criação de _<a href="https://pt.wikipedia.org/wiki/Objeto_Mock" target="_blank">objetos mocks</a>_. Neste post, vamos explorar as principais funcionalidades e alguns recursos avançados desse framework.

## O básico

Não é o objetivo desse post explicar em detalhes a idéia de "mock", mas podemos arranhar a superfície desse conceito: pense em um mock como um objeto criado em tempo de execução, que devolve **respostas pré-configuradas**. Mocks não são obrigatórios (ou mesmo desejados) em todas as circunstâncias; mocks são úteis em situações em que o código que desejamos testar possui _dependências de outros objetos_ (outras classes da nossa aplicação, interfaces de terceiros, etc), e os detalhes dessas dependências não são importantes para o teste em questão. Queremos testar apenas o nosso código, e não depender do comportamento de outros objetos ou recursos de infraestrutura.

No exemplo abaixo, temos uma classe chamada AddressSearch, que encapsula um serviço de pesquisa de endereços a partir de um CEP. Esse serviço externo pode ser um banco de dados dos endereços brasileiros (acessado por JDBC), ou um web service SOAP/REST disponibilizado por outra empresa. A interface que representa esse serviço devolve o resultado da pesquisa no formato String, separando os campos por colunas.

``` java
public class AddressSearch {

    private final AddressSearchService addressSearchService;

    public AddressSearch(AddressSearchService addressSearchService) {
        this.addressSearchService = addressSearchService;
    }

    public Address findBy(ZipCode zipCode) {
        String addressAsString = addressSearchService.searchByZipCode(zipCode.get());

        String[] parts = addressAsString.split("\\|");

        Address address = new Address();
        address.setStreet(parts[0]);
        address.setCity(parts[1]);
        address.setState(parts[2]);
        address.setZipCode(new ZipCode(parts[3]));

        return address;
    }
}

public interface AddressSearchService {

    public String searchByZipCode(String zipCode);
}

```

E o nosso caso de teste:

``` java
public class AddressSearchTest {

    private AddressSearch addressSearch;

    @Before
    public void setup() {
        addressSearch = new AddressSearch(/* o que passamos aqui??? */);
    }

    @Test
    public void shouldFindAddressByZipCode() {
        Address address = addressSearch.findBy(new ZipCode("12345678"));

        assertEquals("Rua Beira Rio", address.getStreet()); // como garantir que o endereço retornado é este?
        // assert nos demais campos de Address
    }
}

```

Vamos usar o Mockito para facilitar a escrita do nosso teste.

## Introduzindo Mockito

#### Criação de mocks

Existe mais de uma maneira de criar mocks no Mockito, que diferem umas das outras quanto à configuração mas com os mesmos resultados finais. Uma maneira é por configuração programática, usando a DSL do framework;

``` java
import org.mockito.Mockito;

public class AddressSearchTest {

    private AddressSearch addressSearch;

    @Before
    public void setup() {
        AddressSearchService mockAddressSearchService = Mockito.mock(AddressSearchService.class);
        addressSearch = new AddressSearch(mockAddressSearchService);
    }
```

Para melhorar a legibilidade do código, podemos importar estáticamente os métodos da classe Mockito:

``` java
import static org.mockito.Mockito.*;

public class AddressSearchTest {

    private AddressSearch addressSearch;

    @Before
    public void setup() {
        AddressSearchService mockAddressSearchService = mock(AddressSearchService.class);
        addressSearch = new AddressSearch(mockAddressSearchService);
    }
```

Outra maneira é declarar os mocks utilizando anotações:

``` java
import org.mockito.MockitoAnnotations;

public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);

        addressSearch = new AddressSearch(mockAddressSearchService); // mockAddressSearchService inicializado
    }
```

Adicionamos a anotação _@Mock_ ao atributo, e, no setup do nosso teste, incluímos uma chamada para a classe MockitoAnnotations, que é responsável por processar as anotações da classe enviada para o método _initMocks_. Podemos utilizar um <a href="https://github.com/junit-team/junit/wiki/Test-runners" target="_blank">TestRunner</a> do Mockito que faz o mesmo trabalho:

``` java
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @Before
    public void setup() {
        addressSearch = new AddressSearch(mockAddressSearchService); // mockAddressSearchService inicializado
    }
```

Observe no topo a anotação @RunWith (do JUnit), passando como parâmetro a classe MockitoJUnitRunner do Mockito. Pessoalmente considero essa configuração a mais fácil de utilizar no Mockito, pois simplifica o código do teste. Mas pode haver situações em que você quer utilizar mocks, porém o seu teste já utiliza o TestRunner de algum outro framework (o JUnit permite parametrizar apenas um runner). Nesses casos, saber criar mocks sem utilizar o MockitoJUnitRunner pode ser útil.

Uma terceira maneira é utilizar um <a href="https://github.com/junit-team/junit/wiki/Rules" target="_blank">TestRule</a> fornecido pelo Mockito:

``` java
import org.mockito.Mock;

public class AddressSearchTest {

    @Rule
    public MockitoRule mockitoRule = MockitoJUnit.rule();

    @Mock
    private AddressSearchService mockAddressSearchService;

    @Before
    public void setup() {
        addressSearch = new AddressSearch(mockAddressSearchService); // mockAddressSearchService inicializado
    }
```

O MockitoRule realiza o mesmo processamento de anotações demonstrado nos exemplos anteriores. Também é útil ter essa opção se você não puder utilizar o MockitoJUnitRunner (lembre que os campos anotados com @Rule devem ser públicos!).

#### Injeção de mocks

Nos exemplos acima, estamos injetando manualmente nosso mock dentro do objeto que estamos testando, através do construtor da classe AddressSearch. Esse é um trabalho que o Mockito também é capaz de realizar, com o uso da anotação @InjectMocks:

``` java
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        //addressSearch pronto para uso, com o mockAddressSearchService injetado
    }
```

O atributo anotado com @InjectMocks será instanciado pelo Mockito, e todos os atributos anotados com @Mock e @Spy (veremos o que é um "spy" em detalhes mais à frente) são considerados dependências desse objeto. Essa "injeção de dependências" realizada pelo Mockito segue algumas regras:

  * Injeção por construtor

    Para construir o objeto, a primeira tentativa é via **construtor**. O maior construtor da classe é escolhido, e os argumentos são resolvidos a partir dos mocks/spies declarados no teste. Dois pontos de atenção aqui são: se algum argumento não for encontrado no teste, _null_ é passado; se algum argumento "não mockável" for esperado (um tipo primitivo, por exemplo), a injeção por construtor não acontece.
  * Injeção por propriedade (_setter_)

    Se a injeção por construtor não acontece, a segunda tentativa é através das **propriedades** do objeto. Lembre-se que uma _propriedade_ em Java não é necessariamente um campo declarado na classe, e sim os campos expostos via getter/setter. Os mocks são resolvidos pelo tipo (em caso de ambiguidade, além do tipo, é utilizado o nome). O construtor utilizado será o construtor padrão (sem argumentos).
  * Injeção por campos

    Se a injeção por propriedades também não acontece (caso de não existirem _setters_), a terceira e última tentativa do Mockito é injetar os mocks diretamente nos **campos do objeto**, utilizando **reflection**. Assim como na injeção por propriedade, os mocks são resolvidos pelo tipo e, em caso de ambiguidade, pelo nome. O construtor padrão da classe é o construtor utilizado.

Se nenhuma dessas situações puder ser satisfeita, a injeção dos mocks não é realizada e você deverá fornecer as dependências do seu objeto manualmente. Lembre-se também que o Mockito não é um framework de injeção de dependências, então não espere que um grafo complexo de mocks ou objetos reais seja resolvido.

#### Configuração de mocks

Nos exemplos acima, declaramos um mock da interface AddressSearchService e inicializamos o objeto AddressSearch, que queremos testar. Vamos rever nosso caso de teste:

``` java
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        Address address = addressSearch.findBy(new ZipCode("12345678"));

        assertEquals("Rua Beira Rio", address.getStreet());
        assertEquals("São Paulo", address.getCity());
        assertEquals("SP", address.getState());
        assertEquals(new ZipCode("12345678"), address.getZipCode());
    }
}
```

O cenário que montamos consiste em uma busca por um determinado CEP, e esperamos um objeto Address contendo os dados devolvidos pelo serviço de busca de endereços. Nosso teste ainda não passa, pois precisamos configurar o mock para devolver o endereço esperado. Recapitulando o início do post, um mock é um objeto **que devolve respostas pré-configuradas**, e vamos aprender como fazer isso com a DSL do Mockito:

``` java
import static org.junit.Assert.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        String zipCode = "12345678";

        String addressResult = "Rua Beira Rio|São Paulo|SP|12345678";

        Mockito.when(mockAddressSearchService.searchByZipCode(zipCode)).thenReturn(addressResult);

        Address address = addressSearch.findBy(new ZipCode(zipCode));

        assertEquals("Rua Beira Rio", address.getStreet());
        assertEquals("São Paulo", address.getCity());
        assertEquals("SP", address.getState());
        assertEquals(new ZipCode("12345678"), address.getZipCode());
    }
}
```

No exemplo acima, o método chave é o _Mockito.when_. O que estamos dizendo ao Mockito é essencialmente: "quando o método searchByZipCode, do objeto mockAddressSearchService, for invocado com um argumento igual a &#8216;12345678&#8217;, devolva esse resultado". A DSL de fácil entendimento e leitura do Mockito é um dos motivos da larga adoção desse framework. Detalhe: a literatura de testes de código chama esse tipo de configuração de **expectativas**.

Podemos também utilizar o import estático para omitir o "Mockito.":

``` java
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        String zipCode = "12345678";

        String addressResult = "Rua Beira Rio|São Paulo|SP|12345678";

        when(mockAddressSearchService.searchByZipCode(zipCode)).thenReturn(addressResult);

        Address address = addressSearch.findBy(new ZipCode(zipCode));

        assertEquals("Rua Beira Rio", address.getStreet());
        assertEquals("São Paulo", address.getCity());
        assertEquals("SP", address.getState());
        assertEquals(new ZipCode("12345678"), address.getZipCode());
    }
}
```

O método _when_ oferece alguns outros recursos. Imagine que o método que estamos testando fizesse uso do "searchByZipCode" mais de uma vez; poderíamos configurar **chamadas consecutivas** para nosso mock:

``` java
@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    // código omitido

    @Test
    public void shouldFindAddressByZipCode() {
        // código omitido

        when(mockAddressSearchService.searchByZipCode(zipCode))
            .thenReturn(addressResult, "resultado da segunda chamada", "resultado da terceira chamada");

        // ou alternativamente,

        when(mockAddressSearchService.searchByZipCode(zipCode))
            .thenReturn(addressResult)
            .thenReturn("resultado da segunda chamada")
            .thenReturn("resultado da terceira chamada");
    }
}
```

E se nosso código implementasse algum tratamento de erro na chamada do método "searchByZipCode" (digamos, envolvendo a chamada um try/catch específico para o caso de endereço não encontrado)? Podemos instruir nosso mock a, ao invés de devolver um retorno de método, lançar uma exceção:

``` java
@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    // código omitido

    @Test
    public void shouldFindAddressByZipCode() {
        // código omitido

        when(mockAddressSearchService.searchByZipCode(zipCode))
            .thenThrow(ZipCodeNotFoundException.class);

        // ou alternativamente,

        when(mockAddressSearchService.searchByZipCode(zipCode))
            .thenThrow(new ZipCodeNotFoundException("zipcode not found")));
    }
}
```

#### Argument matchers

Um detalhe importante na configuração dos mocks são os argumentos do método configurado. No nosso teste, estamos configurando a invocação do método "searchByZipCode" com um argumento do tipo String cujo valor é "12345678". E se nosso código invocasse esse método com um argumento de valor diferente, o que aconteceria? A resposta é que o Mockito NÃO devolveria a resposta que desejamos, pois a configuração do mock esperava um argumento com um valor específico.

Esse é o cenário ideal, pois torna o teste mais seguro e a configuração mais assertiva, uma vez que estamos trabalhando com os valores que definimos no nosso teste. Mas existem diversas situações onde podemos/queremos flexibilizar nosso teste; no exemplo acima, por exemplo, poderíamos mover a configuração do mock para o setup do teste, e configurar a resposta para "qualquer String" enviada para o método. Podemos fazer isso utilizando os **argument matchers** do Mockito:

``` java
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Before
    public void setup() {
        String addressResult = "Rua Beira Rio|São Paulo|SP|12345678";

        when(mockAddressSearchService.searchByZipCode(anyString())).thenReturn(addressResult);
    }

    @Test
    public void shouldFindAddressByZipCode() {
        Address address = addressSearch.findBy(new ZipCode("12345678"));

        assertEquals("Rua Beira Rio", address.getStreet());
        assertEquals("São Paulo", address.getCity());
        assertEquals("SP", address.getState());
        assertEquals(new ZipCode("12345678"), address.getZipCode());
    }
}
```

Nossa configuração do mock está levemente diferente; o argumento que estamos passando para o método "searchByZipCode" é o matcher _anyString()_. Agora, o que estamos dizendo ao Mockito é: "quando o método searchByZipCode, do objeto mockAddressSearchService, for invocado com uma String qualquer, devolva esse resultado". Os argument matchers permitem maior flexibilidade em situações onde você pode se dar a esse luxo, ou os argumentos do método mockado são menos importantes no seu teste, ou você simplesmente não é capaz de prever os valores. O Mockito possui dezenas de matchers prontos para uso: _anyInt(), any(Class<T>), isNull(), notNull(), same()_. Para a lista completa, consulte os métodos disponíveis na classe _Matchers_ (os métodos estarão disponíveis quando você importar estáticamente a classe Mockito, que por sua vez extende Matchers) e _AdditionalMatchers_.

Um detalhe importante: se o método que estamos configurando possui mais de um argumento, e queremos utilizar argument matchers, teremos que utilizá-los em **todos** os argumentos. Vamos imaginar que nossa interface AddressSearchService possui um método que devolve o CEP a partir de um logradouro, uma cidade e um estado:

``` java
public interface AddressSearchService {

    //codigo omitido

    public String searchZipCodeByAddress(String street, String city, String state);
}
```

E queremos mockar esse método para nossos testes:

``` java
@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Before
    public void setup() {
        // codigo omitido

        // essa configuração não funciona!
        when(mockAddressSearchService.searchZipCodeByAddress(anyString(), "São Paulo", "SP"))
            .thenReturn("12345678");

        // correto - matchers em todos os argumentos
        when(mockAddressSearchService.searchZipCodeByAddress(anyString(), eq("São Paulo"), eq("SP"))
            .thenReturn("12345678");
    }

    // codigo omitido
}
```

#### Argument matchers do Hamcrest

O [Hamcrest](http://hamcrest.org/) é um framework de argument matchers bastante utilizado em conjunto com o Junit. O Mockito fornece matchers iguais/equivalentes à maioria dos existentes no Hamcrest, mas se você preferir utilizar essa biblioteca (por exemplo, por ter implementado matchers customizados orientados ao domínio da sua aplicação), é fácil integrá-los ao Mockito. Existe um matcher especial chamado _argThat()_, cujo parâmetro é um Matcher do Hamcrest.

``` java
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import static org.hamcrest.Matchers.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        String zipCode = "12345678";

        String addressResult = "Rua Beira Rio|São Paulo|SP|12345678";

        when(mockAddressSearchService.searchByZipCode(argThat(equalTo(zipCode)))) // equalTo é um matcher do Hamcrest
            .thenReturn(addressResult);

        // codigo omitido
    }
}
```

Até aqui, aprendemos como configurar o método de um mock para devolver a resposta que queremos. Mas o que acontece se um método **não configurado** for invocado?

#### Respostas

Esse detalhe é uma diferença importante quando comparamos o Mockito com outros frameworks; bibliotecas como o <a href="http://www.jmock.org/" target="_blank">JMock</a> ou o <a href="http://easymock.org/" target="_blank">EasyMock</a> lançam exceções quando métodos não configurados são invocados; o Mockito possui uma abstração chamada _Answer_ que representa o retorno de método de um mock. Vamos entender mais detalhadamente como isso funciona.

##### Resposta "padrão"

Até aqui, declaramos nosso mock da seguinte forma:

``` java
@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        Address address = addressSearch.findBy(new ZipCode("12345678"));
    }
}
```

A declaração acima configura nosso mock com o Answer "padrão". O comportamento dessa resposta é: se algum método **não configurado** desse mock for invocado,

  * Se o método retornar algum tipo primitivo ou um tipo wrapper, devolve um retorno apropriado e consistente (exemplo: se o método retornar um int ou Integer, devolve 0; se retornar long ou Long, devolve 0; se retornar boolean ou Boolean, devolve false);
  * Se o método retornar uma _Collection_, devolve uma coleção vazia (usando os tipos mais comuns. exemplo: por padrão devolve ArrayList se o método retorna uma Collection ou List; se o método devolver um Set, retorna um HashSet; se o método devolver um Map, retorna um HashMap);
  * Se o método invocado for o _toString()_, devolve uma descrição do mock;
  * Para qualquer outro caso, devolve _null_.

Outras respostas estão disponíveis. Podemos mudar o Answer utilizado pelo nosso mock, usando o parâmetro _answer_ da anotação @Mock. Vamos explorar outra opção:

##### RETURNS\_SMART\_NULLS

``` java
@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock(answer = Answers.RETURNS_SMART_NULLS)
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        Address address = addressSearch.findBy(new ZipCode("12345678"));
    }
}
```

Dessa vez, estamos utilizando o Answer _RETURNS\_SMART\_NULLS_. O comportamento dessa resposta é diferente: se algum método **não configurado** desse mock for invocado,

  * Se o método retornar algum tipo primitivo ou um tipo wrapper, devolve um retorno apropriado e consistente (exemplo: se o método retornar um int ou Integer, devolve 0; se retornar long ou Long, devolve 0; se retornar boolean ou Boolean, devolve false);
  * Se o método retornar uma _Collection_, devolve uma coleção vazia (usando os tipos mais comuns);
  * Se o método retornar um _array_, devolve uma array vazio;
  * Se o método retornar uma _String_, devolve uma String vazia;
  * Se o método invocado for o _toString()_, devolve uma descrição do mock;
  * Para qualquer outro caso, devolve um _"smart null"_.

E o que é um "smart null"? É um objeto que irá lançar uma _SmartNullPointerException_ quando o seu código tentar utilizá-lo. A vantagem aqui é que a mensagem gerada pelo Mockito (e exibida no relatório de erro do Junit) irá lhe mostrar exatamente qual chamada de método originou esse NullPointerException, e como você deve configurá-lo para que isso não aconteça; com a resposta padrão você teria que procurar o problema no seu código de teste.

``` java
org.mockito.exceptions.verification.SmartNullPointerException:
You have a NullPointerException here:
-> at com.elo7.mockito.AddressSearch.findBy(AddressSearch.java:12)
because this method call was *not* stubbed correctly:
-> at com.elo7.mockito.AddressSearch.findBy(AddressSearch.java:12)
mockAddressSearchService.searchByZipCode(
    "12345678"
);
```

Uma observação importante: o RETURNS\_SMART\_NULLS será a resposta padrão a partir da versão 2 do Mockito (no momento da escrita desse post (abril/2016), essa versão ainda está em beta)

##### RETURNS\_DEEP\_STUBS

Nesse exemplo, vamos criar uma nova implementação do serviço de busca de CEP, consultando um serviço REST que expõe uma consulta de endereços a partir de um CEP. O endpoint desse serviço também devolve os campos do endereço separados por colunas, o que atende o contrato da nossa interface AddressSearchService. Eis nosso código:

``` java
public class WebServiceAddressSearchService implements AddressSearchService {

    private final RestClient restClient;

    public WebServiceAddressSearchService(RestClient restClient) {
        this.restClient = restClient;
    }

    public String searchByZipCode(String zipCode) {
        return (String) restClient.target("http://my.service")
            .path("postal_code")
            .path(zipCode)
            .request()
            .get();
    }
}
```

O objeto RestClient é responsável por realizar a requisição HTTP propriamente dita; para nós os detalhes dessa implementação não são importantes. O que nos importa aqui é que as operações desse objeto são expostas através de uma _interface fluente_. Como podemos testar esse código?

``` java
@RunWith(MockitoJUnitRunner.class)
public class WebServiceAddressSearchServiceTest {

    @Mock
    private RestClient mockRestClient;

    @InjectMocks
    private WebServiceAddressSearchService webServiceAddressSearchService;

    @Test
    public void shouldGetAddressByZipCode() {
        String zipCode = "12345678";

        String expected = "Rua Beira Rio|São Paulo|SP|12345678";

        when(mockRestClient.target("http://my.service")
            .path("postal_code")
            .path(zipCode)
            .request()
            .get())
        .thenReturn(expected);

        String result = webServiceAddressSearchService.searchByZipCode(zipCode);

        assertEquals(expected, result);
    }
}
```

Estamos configurando toda a cadeia de métodos que utilizamos do RestClient, e configurando a resposta final do método ".get()". Isso irá funcionar? NÃO. O retorno do método "mockRestClient.target("http://my.service")" será nulo, e não conseguiremos prosseguir em toda a cadeia de invocações. O que precisamos aqui é que o método "target" devolva um novo mock; após isso precisamos de um novo mock para o retorno do método "path", e assim sucessivamente até alcançarmos o método ".get()". Esse é um complicador adicional de mockarmos objetos com interfaces fluentes (outro exemplo seriam objetos Builder), mas o Mockito pode nos ajudar nessa situação. Podemos utilizar o Answer _RETURNS\_DEEP\_STUBS_:

``` java
@RunWith(MockitoJUnitRunner.class)
public class WebServiceAddressSearchServiceTest {

    @Mock(answer = Answers.RETURNS_DEEP_STUBS)
    private RestClient mockRestClient;

    @InjectMocks
    private WebServiceAddressSearchService webServiceAddressSearchService;

    @Test
    public void shouldGetAddressByZipCode() {
        String zipCode = "12345678";

        String expected = "Rua Beira Rio|São Paulo|SP|12345678";

        when(mockRestClient.target("http://my.service") // retorna um novo mock
            .path("postal_code") // retorna um novo mock
            .path(zipCode) // retorna um novo mock
            .request() // retorna um novo mock
            .get()) // método que iremos configurar
        .thenReturn(expected);

        String result = webServiceAddressSearchService.searchByZipCode(zipCode);

        assertEquals(expected, result);
    }
}
```

Outro Answer com comportamento parecido é o _RETURNS_MOCKS_. A diferença entre este e o RETURNS\_DEEP\_STUBS é que o RETURNS\_MOCKS, inicialmente, tenta criar o retorno do método de forma semelhante ao RETURNS\_SMART\_NULLS (valor padrão para tipos primitivos, coleções e arrays vazios, etc); não sendo possível, é retornado um novo mock. O RETURNS\_DEEP_STUBS, ao contrário, SEMPRE tenta criar um novo mock para o retorno do método.

Uma observação importante é que, até a versão do Mockito com a qual esse post foi escrito (1.10.19), estes dois Answers não funcionam com retornos de tipos genéricos (é um bug já reportado para os desenvolvedores do Mockito).

O caso de uma interface fluente é um uso válido para o RETURNS\_DEEP\_STUBS, mas reflita se você realmente necessita dele ao implementar os seus testes. Um exemplo onde você poderia ficar tentado ao utilizar esse recurso é um código como o abaixo:

``` java
public class Person {

    private Address address;

    public Address getAddress() {
        return address;
    }
}

public class Address {

    private ZipCode zipCode;

    public ZipCode getZipCode() {
        return zipCode;
    }
}

public class ZipCode {

    private String value;

    public String getValue() {
        return value;
    }
}

// em algum outro lugar que utiliza uma instância de Person

Person person ... //código omitido; obtém uma instancia de Person de alguma forma
String zipCode = person.getAddress().getZipCode().getValue();

```

Digamos que no seu teste surja a necessidade de mockar essa cadeia de métodos até obtermos o zipCode. Poderíamos criar um mock da classe Person com o answer RETURN\_DEEP\_STUBS e configurar o retorno do método "getValue" da classe ZipCode. Funcionaria sem problemas. O detalhe é que o código acima apresenta um problema de design: ele viola a <a href="https://en.wikipedia.org/wiki/Law_of_Demeter" target="_blank">Lei de Demeter</a>, pois o seu código cliente conhece a estrutura interna do objeto Person. Lembre-se que os testes de unidade fornecem feedback sobre o design do seu código; no exemplo acima, poderíamos refatorar para algo como isto:

``` java
public class Person {

    private Address address;

    public String getZipCode() {
        return address.getZipCode();
    }
}

public class Address {

    private ZipCode zipCode;

    public String getZipCode() {
        return zipCode.getValue();
    }
}

public class ZipCode {

    private String value;

    public String getValue() {
        return value;
    }
}

Person person ...
String zipCode = person.getZipCode();

```

Agora estamos encapsulando melhor a estrutura interna de cada objeto, de modo que nosso código cliente desconhece que existe um objeto Address e um objeto ZipCode; apenas sabemos que Person tem um código postal no formato String. O RETURN\_DEEP\_STUBS não é mais necessário.

O ponto que gostaria de reforçar com o exemplo acima é: sempre que um mock precise retornar outro mock, repense o design do seu código e avalie se isso é realmente necessário. A documentação do Mockito é um pouco mais explícita: <a href="http://site.mockito.org/mockito/docs/current/org/mockito/Mockito.html#RETURNS_DEEP_STUBS" target="_blank">sempre que um mock devolve outro mock, uma fada morre</a>.

##### Respostas customizadas

Caso queira implementar uma lógica em particular sobre o retorno do método, você também pode criar sua própria Answer:

``` java
@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        when(mockAddressSearchService.searchByZipCode("12345678")).then(new Answer<String>() {

            public String answer(InvocationOnMock invocation) throws Throwable {
                // sua logica aqui. O objeto InvocationOnMock permite acessar os argumentos enviados para o mock
                return null;
            }
        });
    }
}
```

Existem outras Answers disponibilizadas pelo Mockito para casos mais específicos (por exemplo, retornar sempre o valor do primeiro ou do segundo argumento), disponíveis na classe _AdditionalAnswers_.

#### Verificação de mocks

Nos exemplos acima, configuramos nossos mocks com o cenário de testes que queríamos montar, e exercitamos nosso código com os retornos de métodos que desejávamos. Nosso código interage com outros objetos; será que ele está interagindo corretamente? Para nos ajudarmos com isso podemos usar as _verificações_ de mocks disponibilizadas pelo Mockito.

Voltando ao nosso primeiro exemplo:

``` java
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Mock
    private AddressSearchService mockAddressSearchService;

    @InjectMocks
    private AddressSearch addressSearch;

    @Test
    public void shouldFindAddressByZipCode() {
        String zipCode = "12345678";

        String addressResult = "Rua Beira Rio|São Paulo|SP|12345678";

        when(mockAddressSearchService.searchByZipCode(zipCode)).thenReturn(addressResult);

        Address address = addressSearch.findBy(new ZipCode(zipCode));

        assertEquals("Rua Beira Rio", address.getStreet());
        assertEquals("São Paulo", address.getCity());
        assertEquals("SP", address.getState());
        assertEquals(new ZipCode("12345678"), address.getZipCode());
    }
}
```

Podemos **garantir** que nosso mock foi invocado da maneira que configuramos adicionando essa linha no final do teste:

``` java
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Test
    public void shouldFindAddressByZipCode() {
        // código omitido

        // O método verify está na classe Mockito, que importamos estaticamente
        verify(mockAddressSearchService).searchByZipCode(zipCode);
    }
}
```

O método _verify_ do Mockito, como o nome sugere, verifica se aquele método, daquele mock, foi chamado com aqueles argumentos; se não, é lançada uma exceção (quebrando o teste). Essa exceção tem uma mensagem bastante explicativa informando como a chamada de método realmente ocorreu. Por exemplo, nosso mock está configurado com o argumento "12345678"; se por algum bug nosso código invocasse o método com o argumento "123", a mensagem da exceção lançada pelo _verify_ seria:

``` java
Argument(s) are different! Wanted:
mockAddressSearchService.searchByZipCode(
    "12345678"
);
-> at com.elo7.mockito.AddressSearchTest.shouldFindAddressByZipCode(AddressSearchTest.java:40)
Actual invocation has different arguments:
mockAddressSearchService.searchByZipCode(
    "123"
);
```

##### Outras maneiras de utilizar a verificação

Por padrão, o _verify_ confirma se o método em questão foi invocado **apenas uma vez**. E se não fosse o caso? Se nosso método mockado fosse invocado, digamos, duas vezes, o Mockito lançaria uma mensagem de erro com esta mensagem:

``` java
org.mockito.exceptions.verification.TooManyActualInvocations:
mockAddressSearchService.searchByZipCode(
    "12345678"
);
Wanted 1 time:
-> at com.elo7.mockito.AddressSearchTest.shouldFindAddressByZipCode(AddressSearchTest.java:42)
But was 2 times. Undesired invocation:
```

Indicando que o método foi chamado duas vezes, ao invés de uma, e apontando a linha de código onde a segunda chamada ocorreu.

Para verificações como essa e outras variações, podemos utilizar uma sobrecarga do método verify:

``` java
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Test
    public void shouldFindAddressByZipCode() {
        ...

        // O método times está na classe Mockito, que importamos estaticamente
        verify(mockAddressSearchService, times(2)).searchByZipCode(zipCode);
    }
}
```

A verificação acima checa se método searchByZipCode foi chamado exatamente duas vezes. Existem outras variações como _atLeastOnce()_ (pelo menos uma vez), _atLeast(número de invocações)_ (pelo menos quantas invocações você precisar), _never()_ (verifica se o método nunca foi invocado), _atMost(número máximo de invocações)_, _only()_ (se **apenas** aquele método do objeto foi invocado). Consulte [a documentação do Mockito](http://site.mockito.org/mockito/docs/current/org/mockito/Mockito.html#verify(T)) para mais detalhes e exemplos desses métodos.

#### Argument matchers

Mais acima nós exploramos o uso dos argument matchers na configuração dos nossos mocks; os mesmos conceitos se aplicam para a verificação dos métodos mockados. Podemos fazer uso dos argument matchers em conjunto com a verificação.

``` java
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class AddressSearchTest {

    @Test
    public void shouldFindAddressByZipCode() {
        String zipCode = "12345678";

        String addressResult = "Rua Beira Rio|São Paulo|SP|12345678";

        when(mockAddressSearchService.searchByZipCode(eq(zipCode)).thenReturn(addressResult);
        ...

        verify(mockAddressSearchService).searchByZipCode(startsWith("123"));
    }
}
```

No exemplo acima configuramos o método searchByZipCode para devolver uma resposta caso o argumento seja igual a "12345678" (usando o argument matcher _eq()_); na verificação dizemos ao Mockito para confirmar se o método foi invocado usando um argumento do tipo String iniciado com "123" (usando o argument matcher _startsWith()_). As mesmas regras de utilização dos argument matchers que analisamos na configuração dos mocks se aplicam para o método verify.

#### Verificação de ordem de métodos

Vamos imaginar um código como o exemplo abaixo:

``` java
public class UserPasswordService {

    private UserDao userDao;
    private EmailSender emailSender;

    public UserPasswordService(UserDao userDao, EmailSender emailSender) {
        this.userDao = userDao;
        this.emailSender = emailSender;
    }

    public void changePassword(User user, String newPassword) {
        String encryptNewPassword = Crypto.encrypt(newPassword);

        user.setPassword(encryptNewPassword);

        userDao.save(user);

        Email email = new Email();
        email.setReceiverAddress(user.getEmail());
        email.setSubject("Alteração de senha");
        email.setBody("Sua senha foi alterada com sucesso");

        emailSender.send(email);
    }
}
```

Nossa classe UserPasswordService gerencia a alteração de senha de usuários; o método _changePassword_ recebe uma instância de User e a nova senha; utilizamos uma classe utilitária para encriptar a senha utilizando algum algoritmo qualquer; usamos o UserDao para salvas as alterações na base de dados; e enviamos um email ao usuário notificando-o que a sua senha foi alterada com sucesso. Um detalhe importante da nossa implementação: o envio do email deve obrigatoriamente ocorrer APÓS a persistência, pois não queremos enviar um email notificando o usuário sobre algo que não aconteceu (afinal, poderia ocorrer um erro durante a atualização da base de dados e a senha não ser alterada). Nosso teste poderia ser algo como:

``` java
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class UserPasswordServiceTest {

    @Mock
    private UserDao mockUserDao;

    @Mock
    private EmailSender mockEmailSender;

    @InjectMocks
    private UserPasswordService userPasswordService;

    @Test
    public void shouldSaveNewPasswordAndSendEmailToUser() {
        User user = new User();

        userPasswordService.changePassword(user, "newPassword");

        verify(mockUserDao).save(user);
        verify(mockEmailSender).send(notNull(Email.class));
    }
}
```

Nosso teste está apenas validando se a interação com os outros objetos está funcionando adequadamente. Estamos verificando se o usuário foi salvo adequadamente na nossa base de dados (através do método UserDao.save), e se o email foi enviado (através do método EmailSender.send recebendo uma instância da classe Email). Dissemos que a ordem dos métodos é importante, mas se invertermos nosso código:

``` java
public class UserPasswordService {

    public void changePassword(User user, String newPassword) {
        // código omitido

        emailSender.send(email);
        userDao.save(user);
    }
}
```

Nossas verificações de mock continuam passando sem nenhum problema! Porque, afinal, os métodos foram invocados! Em um cenário como esse, precisamos garantir que os métodos foram utilizados na ordem que precisamos. Para nos ajudar, podemos utilizar um objeto do Mockito chamado _InOrder_:

``` java
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class UserPasswordServiceTest {

    @Mock
    private UserDao mockUserDao;

    @Mock
    private EmailSender mockEmailSender;

    @InjectMocks
    private UserPasswordService userPasswordService;

    @Test
    public void shouldSaveNewPasswordAndSendEmailToUser() {
        User user = new User();

        // o método inOrder está na classe Mockito, que importamos estáticamente
        InOrder inOrder = inOrder(mockUserDao, mockEmailSender);

        inOrder.verify(mockUserDao).save(user);
        inOrder.verify(mockEmailSender).send(notNull(Email.class));
    }
}
```

Com o InOrder, podemos garantir exatamente a ordem de invocação; o Mockito irá lançar um erro se os métodos não foram invocados na ordem em que estão sendo verificados. No exemplo mais acima, onde invertemos a ordem de chamadas no código, a mensagem de erro seria:

``` java
org.mockito.exceptions.verification.VerificationInOrderFailure:
Verification in order failure
Wanted but not invoked:
mockEmailSender.send(
    com.elo7.mockito.Email@3532ec19
);
-> at com.elo7.mockito.UserPasswordServiceTest.shouldSaveNewPasswordAndSendEmailToUser(UserPasswordServiceTest.java:34)
Wanted anywhere AFTER following interaction:
mockUserDao.save(
    com.elo7.mockito.User@3532ec19
);
-> at com.elo7.mockito.UserPasswordService.changePassword(UserPasswordService.java:19)
```

A mensagem de erro indica que a invocação do EmailSender.send era esperada APÓS a chamada do método UserDao.save. Agora sabemos que a ordem de invocações dos métodos do nosso código está errada.

É importante lembrar que é perigoso nosso código depender desse tipo de detalhe; seria muito fácil para alguém que não tem o entendimento da regra de domínio da aplicação introduzir um potencial bug invertendo a ordem dos métodos (alteração aparentemente inocente). Mas o Java é uma linguagem baseada no paradigma imperativo, então esse tipo de implementação é praticamente inevitável (em outras linguagens baseadas no paradigma funcional poderíamos, por exemplo, enviar um bloco de código para ser executado como um callback pelo próprio método UserDao.save, após a persistência ser realizada com sucesso; claro que em Java também poderíamos fazer dessa forma, apenas não é usual).

#### Captura de argumentos

No exemplo acima, utilizamos a classe Email. Uma classe simples:

``` java
public class Email {

    private String receiverAddress;
    private String subject;
    private String body;

    public void setReceiverAddress(String receiverAddress) {
        this.receiverAddress = receiverAddress;
    }

    public String getReceiverAddress() {
        return receiverAddress;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getSubject() {
        return subject;
    }

    public void setBody(String body) {
        this.body = body;
    }

    public String getBody() {
        return body;
    }

}
```

No nosso código, criamos uma instância de Email e enviamos para a classe EmailSender através do método _send_. Um detalhe interessante é que nossa verificação garante que enviamos uma instância não-nula de Email, mas não que essa instância está preenchida da maneira que gostaríamos. Se um bug for introduzido no código:

``` java
public class UserPasswordService {

    public void changePassword(User user, String newPassword) {
        // código omitido

        Email email = new Email();
        email.setReceiverAddress(user.getName()); // Trocamos o getEmail por getName!
        email.setSubject("Alteração de senha");
        email.setBody("Sua senha foi alterada com sucesso");

        emailSender.send(email);
    }
}
```

Nosso teste continua passando!

``` java
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class UserPasswordServiceTest {

    @Test
    public void shouldSaveNewPasswordAndSendEmailToUser() {
        // código omitido

        InOrder inOrder = inOrder(mockUserDao, mockEmailSender);

        inOrder.verify(mockUserDao).save(user);

        //Essa verificação passa sem problema. Afinal, a ordem das chamadas está correta, e passamos uma instância não-nula de Email, certo?
        inOrder.verify(mockEmailSender).send(notNull(Email.class));
    }
}
```

E agora? Nosso problema é que precisamos acessar a instância de Email que foi enviada para o método _send_ para validarmos o seu estado; não é algo tão difícil de se resolver. Poderíamos implementar o método equals do objeto Email para comparar os campos relevantes entre duas instâncias e utilizar o matcher _eq()_.

``` java
public class Email {

    //código omitido
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof Email) {
            Email that = (Email) obj;

            return Objects.equals(this.receiverAddress, that.receiverAddress)
                && Objects.equals(this.subject, that.subject)
                && Objects.equals(this.body, that.body);

        } else {
            return false;
        }
    }

}
```

``` java
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class UserPasswordServiceTest {

    @Test
    public void shouldSaveNewPasswordAndSendEmailToUser() {
        // código omitido

        Email email = new Email();
        email.setReceiverAddress(user.getEmail()); // nosso código ainda está utilizando user.getName()
        email.setSubject("Alteração de senha");
        email.setBody("Sua senha foi alterada com sucesso");

        //a verificação quebra pois os dados do Email enviado para o método serão diferentes dessa instância
        inOrder.verify(mockEmailSender).send(eq(email));
    }
}
```

Normalmente essa é uma boa solução, mas a implementação do equals do Email pode ficar complicada se surgirem novos campos, e nosso teste irá depender da regra de igualdade do objeto envolvido, o que nem sempre é o desejado. Outra possibilidade é usarmos um argument matcher chamado _refEq_ que compara dois objetos via reflection:

``` java
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class UserPasswordServiceTest {

    @Test
    public void shouldSaveNewPasswordAndSendEmailToUser() {
        // código omitido

        Email email = new Email();
        email.setReceiverAddress(user.getEmail()); // nosso código ainda está utilizando user.getName()
        email.setSubject("Alteração de senha");
        email.setBody("Sua senha foi alterada com sucesso");

        //a verificação quebra pois a comparação do campo receiverAddress irá indicar que são diferentes
        inOrder.verify(mockEmailSender).send(refEq(email));
    }
}
```

O matcher _refEq_ também resolve nosso problema, mas é desencorajado pelo Mockito porque seu uso pode obscurecer o propósito do teste (está claro pra você como a igualdade do objeto é resolvida?).

Um terceiro modo seria criarmos nosso próprio argument matcher para termos acesso à instância de Email enviada ao método send:

``` java
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class UserPasswordServiceTest {

    @Test
    public void shouldSaveNewPasswordAndSendEmailToUser() {
        // código omitido

        inOrder.verify(mockUserEmailSender).send(new ArgumentMatcher<Email>() {

            @Override
            public boolean matches(Object argument) {
                Email email = (Email) argument; // instância de Email enviada ao método send; podemos validar se o estado do objeto é o que desejamos

                return email.getReceiverAddress().equals(user.getEmail())
                    && email.getSubject().equals("Alteração de senha")
                    && email.getBody().equals("Sua senha foi alterada com sucesso");
            }
        });
    }
}
```

Essa abordagem é desencorajada pelo Mockito porque a criação de um ArgumentMatcher, feita como no exemplo acima, pode afetar a legibilidade do teste; normalmente implementar o equals do objeto é uma solução melhor, mas sugiro que considere a criação de matchers customizados, orientados ao modelo da sua aplicação (são úteis especialmente quando desejamos reaproveitar a validação).

As três soluções acima resolvem o nosso problema, que é garantirmos o estado do Email, e todas tem o seu lado positivo e negativo. Mas existe uma quarta possibilidade que na minha opinião é a mais elegante, além de ser a maneira recomendada pelo Mockito: o uso de uma classe especial para esse propósito, chamada _ArgumentCaptor_.

``` java
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;
import static org.junit.Assert.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class UserPasswordServiceTest {

    @Test
    public void shouldSaveNewPasswordAndSendEmailToUser() {
        // código omitido

        // Um ArgumentCaptor é criado pelo método de fábrica forClass; passe o tipo do argumento que você quer capturar
        ArgumentCaptor<Email> emailCaptor = ArgumentCaptor.forClass(Email.class);

        // Usamos o método capture() na verificação; esse método irá obter e armazenar a instância do argumento enviado para o método send
        inOrder.verify(mockUserEmailSender).send(emailCaptor.capture());

        // Agora podemos obter a instância de Email que foi criada dentro nosso código
        Email email = emailCaptor.getValue();

        // E podemos validar se o Email realmente está correto
        assertEquals(user.getEmail(), email.getReceiverAddress()) // falha aqui, pois o código utiliza email.getName()
        assertEquals("Alteração de senha", email.getSubject());
        assertEquals("Sua senha foi alterada com sucesso", email.getBody());
    }
}
```

Também podemos criar um ArgumentCaptor utilizando a anotação _@Captor_:

``` java
import static org.mockito.Matchers.*;
import static org.mockito.Mockito.*;
import static org.junit.Assert.*;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

@RunWith(MockitoJUnitRunner.class)
public class UserPasswordServiceTest {

    @Mock
    private UserDao mockUserDao;

    @Mock
    private EmailSender mockEmailSender;

    @InjectMocks
    private UserPasswordService userPasswordService;

    @Captor
    private ArgumentCaptor<Email> emailCaptor;

}
```

Para obter o Email capturado na chamada do método utilizamos o método _getValue()_ do ArgumentCaptor; se o método fosse chamado mais de uma vez, e fosse necessário validarmos todas as invocações, isso também seria possível, pois o ArgumentCaptor possui outro método chamado _getAllValues()_ que devolve uma coleção com todos os argumentos capturados (em todas as invocações do método mockado).

#### Precisamos verificar?

Uma discussão recorrente no universo dos mocks é sobre a necessidade de verificação. Afinal, configuramos nossos mocks tendo um cenário de testes em mente, e nosso código interage com os métodos mockados. Podemos inferir que, se nosso teste passa, então os mocks estão se comportando da maneira correta. Ou seja, se nosso teste está passando, em teoria nossos mocks **já estão verificados**. Então, precisamos do método _verify_?

Pessoalmente, eu utilizo verificações somente em interações mais complicadas entre objetos, como chamar o método "a" ou "b" dependendo de alguma validação, métodos que são invocados com argumentos diferentes dos que tenho acesso direto no teste, e outras situações do tipo. O fato é que é muito simples introduzir um bug com alterações aparentemente inocentes, e a verificação é a melhor maneira de confirmar que a interação entre nosso código e nossas dependências está acontecendo como queremos.

Sempre que precisar dessa garantia, ou quiser deixar explícito no teste que o comportamento testado depende da interação com outro objeto, recomendo que utilize o _verify_.

## Objetos espiões

Além dos mocks, outro personagem bastante comum em testes é o objeto **spy**. Não vou me concentrar aqui nas diferenças teóricas entre um mock e um spy, mas uma pequena explicação conceitual (superficial, admito) pode nos ajudar: um spy é essencialmente um objeto que "engole" uma **instância real** do tipo "espionado", de modo que podemos utilizar normalmente esse objeto com o seu comportamento verdadeiro (é uma diferença fundamental em relação ao mock, que apenas sabe fazer o que lhe é "ensinado"). O termo "espião" se refere justamente a esse detalhe: podemos observar como nosso teste interagiu com esse objeto (como fizemos mais acima com as verificações), apesar de estarmos utilizando o seu real comportamento. Além disso, o spy também pode ter seus métodos configurados para devolver respostas pré-fabricadas, assim como os mocks.

Ou seja, com um spy podemos utilizar tanto o comportamento real do objeto quanto configurar ("mockar") os métodos que forem necessários para o nosso teste. Isso é chamado de "partial mock", e é assim que o Mockito se refere a estes objetos.

#### Criando um Spy no Mockito

Para entendermos o funcionamento do spy (e demonstrar melhor a explicação acima), vamos utilizar objetos conhecidos da api do Java: List e ArrayList.

``` java
import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

public class SpySampleTest {

    @Test
    public void test() {

        List<String> list = new ArrayList<String>(); // instância real
        List<String> spyList = spy(list); // método spy -> importado estáticamente na classe Mockito

        spyList.add("one"); //usa o comportamento real do método add
        spyList.add("two");

        assertEquals(2, spyList.size()); // o objeto spy é alterado

        assertEquals(0, list.size()); // o objeto real NÃO é alterado. Por que?
    }
}
```

Explicando em detalhes os comentários do código, iniciamos o teste criando uma instância de ArrayList, e em seguida passamos esse objeto para o método _spy_ da classe Mockito. Esse método cria o objeto espião encapsulando a instância real do objeto ao qual o spy faz referência. Quando utilizamos o método "add", estamos utilizando de fato o método da classe ArrayList, então podemos esperar com segurança que a lista tenha dois elementos. Mas o objeto original (a variável "list") não foi alterada!

Isso é um detalhe de implementação importante no Mockito: ao criar um spy, a partir de uma instância, o Mockito cria uma **cópia do objeto**, de modo que alterações no objeto real não são refletidos no spy e vice-versa. É importante ser cuidadoso com esse detalhe; o ideal é que, uma vez criado o spy, você interaja com ele no seu teste, uma vez que, pela definição do que é um spy, você pode assumir que ele tem o mesmo comportamento real do objeto.

Uma outra maneira de declarar spies é utilizando anotações:

``` java
@RunWith(MockitoJUnitRunner.class)
public class SpySampleTest {

    @Spy
    private List<String> spyList = new ArrayList<String>();

    @Test
    public void test() {
        ...
    }
}
```

Atributos anotados com @Spy também são elegíveis para serem injetados dentro do objeto anotado com @InjectMocks (com as mesmas considerações da anotação @Mock que analisamos antes).

Um detalhe importante sobre essas duas abordagens é que estamos inicializando um objeto que por sua vez é utilizado pelo Mockito na criação do spy. Poderíamos não fazer isso e criar o spy apenas através do tipo (seja utilizando Mockito.spy(MyType.class) ou no exemplo acima, não inicializando a variável "spyList"). Se você não fornecer a instância real, o Mockito tentará criá-la usando o construtor padrão do tipo; a criação do spy irá falhar se este construtor não existir, ou o tipo declarado for uma classe interna, classe abstrata ou interface.

#### Configurando um Spy

Como dissemos antes, um spy é um "partial mock"; podemos configurar os métodos que desejamos com respostas pré-configuradas do mesmo modo que faríamos com um mock. Mas existem algumas diferenças na DSL do Mockito. Com o mesmo exemplo anterior, vamos tentar configurar o método "get" da interface List:

``` java
@RunWith(MockitoJUnitRunner.class)
public class SpySampleTest {

    @Spy
    private List<String> spyList = new ArrayList<String>();

    @Test
    public void test() {
        when(spyList.get(0)).thenReturn("element"); //configurando com o método when, idêntico a como fizemos com os mocks

        String value = spyList.get(0);

        assertEquals("element", value);
    }
}
```

No exemplo acima, configuramos nosso spy utilizando a DSL do Mockito da mesma maneira que fizemos com os mocks, através do método _when_. Mas este código NÃO funcionará. Por que? Porque a invocação do método "spyList.get(0)" irá invocar o comportamento real existente na classe ArrayList, e o comportamento é lançar uma exceção se aquele índice não existir na lista! Para configurar um spy, devemos utilizar um método diferente:

``` java
import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.class)
public class SpySampleTest {

    @Spy
    private List<String> spyList = new ArrayList<String>();

    @Test
    public void test() {
        doReturn("element").when(spyList).get(0); // o método doReturn também está na classe Mockito

        String value = spyList.get(0);

        assertEquals("element", value);
    }
}
```

Agora o nosso teste passa sem problema. O método _doReturn_ é o método correto a ser utilizado ao trabalhar com um spy; ele pode ser utilizado também com um mock mas não é recomendado, pois sua legibilidade não é tão clara quanto a do método _when_, de modo que o doReturn deve ser usado em raras ou específicas situações (o mesmo se aplica aos outros métodos iniciados com "do&#8230;": _doThrow_, _doAnswer_, _doCallRealMethod_, _doNothing_).

#### Verificações de métodos do spy

O método verify funciona para spies exatamente da mesma forma que analisamos para os mocks. Você pode verificar inclusive as invocações de métodos "não mockados".

#### Devemos usar um spy?

A documentação do Mockito indica que o spy é uma prática a ser evitada. Uma boa prática da orientação a objetos é o <a href="https://en.wikipedia.org/wiki/Single_responsibility_principle" target="_blank">príncipio da responsabilidade única</a>, que consiste em criar objetos coesos com uma única responsabilidade; o fato de você precisar utilizar um "partial mock" (e não utilizar o comportamento real do objeto) _pode_ (ênfase no "pode") indicar que algum eventual comportamento complexo foi movido para um método específico. Esta abordagem parece boa porque, aparentemente, o seu código está "mais fácil de testar"; mas será que essa complexidade não deveria estar representada em OUTRO objeto?

Nos casos de objetos com menor granularidade (digamos, uma classe de modelo), eu prefiro sempre utilizar objetos reais. Se o objeto faz parte do contexto do teste, não tem dependências externas e eu posso criar esse objeto facilmente (com um simples "new"), eu considero que o teste fica mais claro e mais simples de ser entendido. Mas eventualmente esse objeto pode ter algum método cuja implementação não é conveniente para o nosso teste; para esse tipo de caso, eu prefiro utilizar o Spy.

Um exemplo: em uma aplicação e-commerce, um objeto que provavelmente teríamos é o que representa o "carrinho de compras"; digamos que internamente esse objeto possui uma lista de produtos, entre outras coisas. Digamos que esse mesmo objeto possui um método que retorne o valor total do carrinho, somando o valor de todos os produtos, custo do frete, algum eventual cupom de desconto inserido pelo cliente&#8230;Em algum teste que faz uso do "carrinho de compras" e da lista de produtos, pode ser mais legível instanciá-lo e preencher os produtos manualmente (pode ser mais legível do que utilizar um mock), mas talvez toda essa lógica que envolve o "valor total" não seja relevante (mesmo que você precise utilizar esse método). Neste caso, poderíamos fazer uso do comportamento verdadeiro do "carrinho de compras" e configurar os métodos que necessitarmos com os valores pré-estabelecidos no nosso teste.

Essa observação do Mockito é relevante e deve ser levada em consideração mas, obviamente, você não deve vê-la como uma regra escrita na pedra. Deixe que o seu teste forneça feedback sobre o seu design e refatore onde fizer sentido.

## Outras dicas

#### Mock com mais de uma interface

Temos as interfaces abaixo:

``` java
public interface FooService {

    public void foo();
}

public interface BarService {

    public void bar();
}
```

E este código:

``` java
public class MyType {

    private final FooService myService;

    public MyType(FooService myService) {
        this.myService = myService;
    }

    public void process() {
        myService.foo();

        if (myService instanceof BarService) {
            ((BarService) myService).bar();
        }
    }
}
```

Nosso maior problema aqui é a verificação de tipo realizada com o "instanceof" do Java. É um código estranho (e não incomum!), afinal FooService não tem nenhuma relação de tipo com BarService (não fazem parte da mesma hierarquia). Um teste possível para essa classe poderia ser:

``` java
@RunWith(MockitoJUnitRunner.class)
public class MyTypeTest {

    @Mock
    private FooService mockFooService;

    @InjectMocks
    private MyType myType;

    @Test
    public void test() {
        myType.process();

        verify(mockFooService).foo();
    }
}
```

Esse teste irá passar, mas a execução não vai entrar no "if" da verificação pelo instanceof; afinal, um FooService não é um BarService. Como podemos testar esse trecho do código?

Poderíamos alterar a declaração do BarService para:

``` java
public interface BarService extends FooService {

    public void bar();
}
```

E injetar um mock de BarService. Isso resolveria, mas essa relação faz sentido (um BarService É UM FooService)? Mesmo que sim, e se não pudéssemos alterar o código (se fossem interfaces de uma biblioteca de terceiros)?

Poderíamos criar um objeto para os propósito do nosso teste que resolvesse essa questão (uma prática conhecida como "objeto stub"):

``` java
public class MyStub implements FooService, BarService { //implementando as duas interfaces

    public void bar() {
    }

    public void foo() {
    }
}
```

E injetarmos uma instância de MyStub dentro do nosso código. Essa abordagem também resolveria nosso problema mas parece que estamos fazendo "código demais". Como o Mockito pode nos ajudar nessa situação?

No início do post, dissemos que um mock, entre outras coisas, é **um objeto criado em tempo de execução**. Criar um mock é o equivalente a criarmos dinamicamente um objeto como o _MyStub_ acima; então, também podemos criar um mock que "implemente" mais de uma interface!

A anotação @Mock possui um parâmetro chamado _extraInterfaces_ que podemos utilizar para esse fim:

``` java
@RunWith(MockitoJUnitRunner.class)
public class MyTypeTest {

    @Mock(extraInterfaces = BarService.class)
    private FooService mockFooService;

    @InjectMocks
    private MyType myType;

    @Test
    public void test() {
        myType.process();

        verify(mockFooService).foo();

        verify((BarService) mockFooService).bar(); // podemos inclusive fazer o cast, pois agora a variável mockFooService É UM BarService
    }
}
```

Esse parâmetro é um array de interfaces; você pode passar quantas forem necessárias. Esse recurso também funciona se o tipo declarado da variável for um tipo concreto.

Lembrando: aquele código é realmente uma prática que você NÃO deve utilizar (viola o <a href="https://en.wikipedia.org/wiki/Liskov_substitution_principle" target="_blank">príncipio da substituição de Liskov</a>), mas não é raro encontrá-lo em códigos legados :(.

## Configuração de métodos void

Para esse exemplo vou usar a interface FooService que declaramos no exemplo anterior. Digamos que queremos configurar o lançamento de uma exceção quando o método "FooService.foo()" for invocado:

``` java
@Mock
private FooService mockFooService;

@Test
public void test() {
    when(mockFooService.foo())... //foo() é um método void -> é impossível para o Mockito continuar
}
```

O parâmetro do método _when_ é o **tipo** do objeto retornado pelo método a ser configurado; a partir dele completamos a configuração com os métodos thenReturn(o tipo esperado), thenThrow, etc. Se o método que desejamos configurar tem o seu retorno do tipo _void_, é impossível ao Mockito continuar a cadeia de métodos. A conclusão é: essa DSL de configuração de métodos "when().then*()" **funciona apenas com métodos de retorno não-void**. A solução é outra parte da API do Mockito que já vimos antes com os spies: a família de métodos _do*_:

``` java
@Mock
private FooService mockFooService;

@Test
public void test() {
    doThrow(new RuntimeException("error")).when(mockFooService).foo();
}
```

Como comentei antes, os métodos _doReturn_, _doNothing_, _doAnswer_ e _doThrow_ não são tão legíveis quanto a estrutura "when().then*()", e devem ser usados em casos raros e específicos; o exemplo acima é um desses cenários.

Um detalhe a respeito da configuração de métodos void: pessoalmente eu só os configuro quando desejo lançar alguma exceção. Há quem goste de configurar o mock para deixar explícito que aquela invocação do método não terá efeito:

``` java
@Mock
private FooService mockFooService;

@Test
public void test() {
    doNothing().when(mockFooService).foo();
}
```

É uma preocupação justa, mas acho desnecessário; o comportamento padrão da invocação de um método void é justamente não fazer nada :).

## Conclusão

Apesar do post longo, espero ter conseguido abordar as principais funcionalidades e recursos mais avançados do Mockito. Espero que tenha gostado, e que este post seja útil para você. Em caso de dúvidas ou críticas, sinta-se à vontade para utilizar a caixa de comentários!

Até a próxima!
