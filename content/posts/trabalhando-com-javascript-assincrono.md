---
title: Trabalhando com JavaScript Assíncrono
date: 2019-08-26
category: front-end
layout: post
description: "Aprenda as formas que o JavaScript oferece para trabalharmos com requisições assíncronas."
authors: [andrepbap]
tags:
  - javascript
  - async
cover:
---

Não podemos negar que JavaScript é uma linguagem extremamente versátil. Por muito tempo usada apenas em aplicações *Front-end*, hoje podemos fazer apps *full-stack* utilizando apenas essa linguagem. Essa versatilidade está fazendo com que cada vez mais desenvolvedores se tornem adeptos a ela.

Nesse post irei focar em um assunto muito importante para aplicações web: requisições assíncronas. Trabalhar com isso pode ser bem chato em várias linguagens, porém mostrarei aqui como o JavaScript fornece ferramentas bastante interessantes para resolver esse problema.

## Callback

Para exemplificar as chamadas assíncronas, vamos pensar em uma aplicação cliente que precisa fazer chamadas a uma API para obter os dados que ela precisa. A forma mais conhecida para fazer isso é utilizando *callbacks*.

Pensando na linguagem Java, faríamos da seguinte maneira:

``` java

public interface Callback {
    void sucesso(Object resultado);
    void erro(Object erro);
}

public class Exemplo {
    ClientExemplo clientExemplo = new ClientExemplo();

    clientExemplo.chamadaAssincrona(new Callback() {
        @Override
        public void sucesso(Object resultado) {
            // faz algo com resultado
        }

        @Override
        public void erro(Object erro) {
            // faz algo com erro
        }
    });
}
```

Como mostra o exemplo acima, em Java o mais comum é utilizar uma interface ou classe abstrata, a qual será passada como parâmetro para uma função assíncrona. No final da execução, ou método "sucesso" ou o método "erro" será chamado. Ainda é possível simplificar o exemplo fazendo com que a classe ou interface `Callback` tenha apenas uma função. Dessa maneira, podemos passar como parâmetro da chamada uma função lambda, disponível a partir da versão 8 do Java:

``` java
public interface Callback {
    void resultado(Object erro, Object resultado);
}

public class Exemplo {
    ClientExemplo clientExemplo = new ClientExemplo();

    clientExemplo.chamadaAssincrona((erro, resultado) -> {
        if (erro) {
            // faz algo com resultado
            return;
        }
        // faz algo com erro
    });
}
```

Em JavaScript podemos usar uma sintaxe muito parecida com o segundo exemplo, com a vantagem de não precisarmos criar uma classe ou interface para sobrescrever na chamada. Exemplo:

``` javascript
ClientExemplo clientExemplo = new ClientExemplo();

clientExemplo.chamadaAssincrona(function callback(erro, resultado) {
    if(erro) {
        // faz algo com erro
        return;
    }
    // faz algo com resultado
});
```
Para explicar melhor o assunto, usarei um exemplo um pouco mais concreto. Vamos pensar que temos uma página de produto de um *marketplace* em que precisamos exibir, além de seus atributos, alguns dados de seu vendedor. O problema que teremos que resolver é que a única forma de pegar esses dados é por meio das seguintes rotas: https://api.com/product/:id e https://api.com/seller/:id, onde `:id` será substituido pelo id de cada objeto.

Nesse post utilizarei JavaScript puro, com exceção das classes DAO, que serão responsáveis por fazer a requisição. Nelas usarei uma lib para facilitar.

Criaremos duas classes DAO, uma para o produto e outra para o vendedor:

``` javascript
class ProductDAO {
    getProduct(id, callback) {
        $.get("https://api.com/product/" + id, function(data, status) {
            callback(data);
        });
    }
}

class SellerDAO {
    getSeller(id, callback) {
        $.get("https://api.com/seller/" + id, function(data, status) {
            callback(data);
        });
    }
}
```

A partir daqui, veremos como obter esses dois objetos com o padrão *callback*. Veja que, nas classes DAO, o método `get` recebe o *callback* como parâmetro e, no fim da execução, ele é executado passando a resposta como parâmetro.

A classe controladora, que utilizará o DAO para obter os objetos, ficará da seguinte maneira:

``` javascript
class ProductController {
    getProduct(productId) {
        let productDAO = new ProductDAO();
        let sellerDAO = new SellerDAO();

        productDAO.getProduct(productId, product => {
            sellerDAO.getSeller(product.seller, seller => {

                this._render({
                    product: product,
                    seller: seller
                });
            });
        });
    }

    _render(data) {
        // monta página com objetos retornados
    }
}
```

Temos dois pontos importantes para analisar no exemplo acima. O primeiro é que, como precisamos da resposta de produtos para obter o id do vendedor, tivemos que fazer a requisição para o `sellerDAO` dentro da resposta de `productDAO`. Imagine agora que, por algum motivo, esse controlador precise acessar várias outras rotas para montar a página, e que um dos requisitos da nossa aplicação é que todos os dados tenham que ser retornados de uma só vez. Usando callbacks, teríamos que encadear um dentro do outro. Chamamos esse problema de *callback hell*.

O segundo ponto é o uso de *arrow functions*. Veja que, ao invés de passar uma função com a sintaxe tradicional como parâmetro dos métodos `get`, utilizei uma versão simplificada: `(parametro) => {corpo}`. Essa maneira de escrever uma função não tem apenas o propósito de simplificar, mas também o de preservar o contexto. Ou seja, podemos usar o `this` para referenciar objetos da classe e não apenas locais da própria função. Se tivesse utilizado a sintaxe tradicional, não teria conseguido acessar o método `_render` dentro da resposta, já que o `this` passaria a ser o próprio método, e não a classe.

## Promise

Outra maneira de trabalhar com chamadas assíncronas com JavaScript é através de *promises*. Essa maneira resolve alguns problemas que enfrentamos ao utilizar callbacks. O maior ganho é evitarmos o *callback hell*.

A primeira modificação que precisamos fazer para começar a usar *promises* é na classe DAO:

``` javascript
class ProductDAO {
    getProduct(id) {
        return new Promise((resolve, reject) => {
            $.get("https://api.com/product/" + id, function(data, status) {
                resolve(data);
            });
        });
    }
}

class SellerDAO {
    getSeller(id) {
        return new Promise((resolve, reject) => {
            $.get("https://api.com/seller/" + id, function(data, status) {
                resolve(data);
            });
        });
    }
}
```

Ao invés de receber um *callback* como parâmetro, agora retornamos uma `Promise`. A `Promise` recebe em seu construtor uma função com dois parâmetros: `resolve` e `reject`. O primeiro usamos para passar dados no caso de sucesso e o segundo para passar um erro.

Para fazer uma chamada ao DAO, podemos chamar o método `then` da classe `Promise` que retornamos no `get`: `productDAO.getProduct(productId).then(product => {...})`.

Vamos agora resolver parcialmente um dos problemas que o *callback* trazia, o *callback hell*. Nesse primeiro exemplo, assumiremos que nosso `ProductController` conhece o id do produto e do vendedor. Por enquanto, iremos apenas sincronizar a resposta de um jeito mais elegante:

``` javascript
class ProductController {
    getProduct(productId, sellerId) {
        let productDAO = new ProductDAO();
        let sellerDAO = new SellerDAO();

        let promises = [
            productDAO.getProduct(productId),
            sellerDAO.getSeller(sellerId)
        ];

        Promise.all(promises).then(([product, seller]) => {
            this._render({
                product,
                seller
            });
        });
    }

    _render(data) {
        // monta página com objetos retornados
    }
}
```

Uma grande vantagem de usar essa abordagem é que, através do método `all` da classe `Promise`, podemos passar um *array* de `Promise`. Todas serão executadas e retornarão, ao final, através do método `then`, um *array* de resultados com os objetos na mesma ordem do *array* de origem.

Ok, mas e se não conhecermos o id do vendedor? Podemos escrever um código um pouco mais enxuto para resolver o problema:

``` javascript
class ProductController {
    getProduct(productId) {
        let productDAO = new ProductDAO();
        let sellerDAO = new SellerDAO();

        productDAO.getProduct(productId)
            .then(product => Promise.all([Promise.resolve(product), sellerDAO.getSeller(product.seller)]))
            .then(([product, seller]) => this._render({ product, seller }));
    }

    _render(data) {
        // monta página com objetos retornados
    }
}
```
Nesse exemplo, fizemos a chamada ao `ProductDAO` e, dentro do seu `resolve`, com o objeto `product` já resolvido, pudermos chamar o `SellerDAO`. Nesse momento há um truque que precisamos fazer para termos o objeto `product` no resultado do `SellerDAO`, já que estaremos em outro contexto. Para isso, usamos o `Promise.resolve`. Essa função retorna uma `Promise`, cujo `resolve` é o próprio objeto passado como parâmetro. Isso permite que usemos o `Promise.all` e, consequentemente, consigamos obter no segundo `then` os dois objetos de que precisamos para renderizar a página.

Sei que provavelmente precisou ler mais de uma vez esse último parágrafo para entender o que foi feito. Realmente essa estratégia apesar de enxuta, não é tão trivial.

Vamos agora passar para o último exemplo desse post, onde poderemos resolver todos os problemas que apresentei de uma forma mais simples.

## Async Await

Para essa solução manteremos as classes DAO retornando uma `Promise`. O que muda agora é o jeito que nosso controller irá utilizá-las. A ideia é criar uma função assíncrona onde podemos chamar uma `Promise` de forma síncrona:

``` javascript
class ProductController {
    getProduct(productId) {
        let productDAO = new ProductDAO();
        let sellerDAO = new SellerDAO();

        async function request() {
            let product = await productDAO.getProduct(productId);
            let seller = await sellerDAO.getSeller(product.seller);

            return {
                product,
                seller
            }
        }

        request().then(data => {
            this._render(data);
        });

    }

    _render(data) {
        // monta página com objetos retornados
    }
}
```

Vamos entender o exemplo acima. Criamos dentro do método `getProduct` uma função assíncrona através do marcador `async`. Em JavaScript, funções marcadas com `async` retornam uma `Promise`. Dentro de uma função assíncrona, podemos usar o marcador `await` para um método que retorne uma `Promise`. Esse marcador fará com que, dentro dessa função, a `Promise` seja executada de forma síncrona, retornando como resultado o próprio objeto que definimos no `resolve`.

Dessa forma, na hora de fazer uma requisição para o `sellerDAO`, já conhecemos o objeto `product` e, consequentemente, o id do vendedor relacionado a ele.

## Conclusão

Como desenvolvedores, sabemos que sempre existirão diversas formas de resolver um problema. Cabe a nós escolher a forma mais eficiente para o contexto do nosso projeto. Quem trabalha com aplicações web sabe da importância de deixarmos chamadas a serviços bem organizadas, assim melhoramos a legibilidade do código, além de ganhar performance e evitarmos bugs.

Caso tenha interesse em testar os exemplos desse post, o projeto está disponível no meu [github](https://github.com/andrepbap/estudo-javascript-async).
