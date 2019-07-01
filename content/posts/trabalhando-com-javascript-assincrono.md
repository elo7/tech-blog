---
title: Trabalhando com Javascript Assíncrono
date: 2019-07-01
category: front-end
layout: post
description: "Aprenda as formas que o Javascript oferece para trabalharmos com requisições assíncronas."
authors: [andrepbap]
tags:
  - javascript
  - async
cover:
---

Não podemos negar que Javascript é uma linguagem extremamente versátil. Por muito tempo usada apenas em aplicações Front-end, hoje podemos fazer apps full-stack utilizando apenas essa linguagem. Essa versatilidade está fazendo com que cada vez mais desenvolvedores se tornem adeptos a ela.

Nesse post irei focar em um assunto muito importante para aplicações web: requisições assíncronas. Trabalhar com isso pode ser bem chato em várias linguagens, porém mostrarei aqui como o Javascript fornece ferramentas bastante interessantes para resolver esse problema.

## Callback

Para exemplificar as chamadas assíncronas, vamos pensar em uma aplicação cliente que precisa fazer chamadas à uma API para obter os dados que ela precisa. A forma mais conhecida para fazer isso é utilizando Callbacks.

Pensando na linguagem java, faríamos da seguinte maneira:

``` java

ClientExemplo clientExempo = new ClientExemplo();

clientExempo.chamadaAssincrona(new Callback() {
    @Override
    public void sucesso(Object resultado) {
        // faz algo com resultado
    }

    @Override
    public void erro(Object erro) {
        // faz algo com erro
    }
});
```

Como mostra o exemplo acima, em Java o mais comum é utilizar uma interface ou classe abstrata que será passada como parâmetro de uma função assíncrona, ao final de sua execução, o método sucesso ou erro será chamado.

Em Javascript podemos fazer isso de uma forma mais simples, apenas passando uma função como parâmetro da função assíncrona. Exemplo:

``` javascript

    ClientExemplo clientExempo = new ClientExemplo();

    clientExempo.chamadaAssincrona(function callback(erro, resultado) {
        if(erro) {
            // faz algo com erro
            return;
        }
        // faz algo com resultado
    });
```
Para explicar melhor o assunto, usarei um exemplo um pouco mais concreto. Vamos pensar que temos uma página de produto de um marketplace em que precisamos exibir, além de seus atributos, alguns dados de seu vendedor. O problema que teremos que resolver, é que a única forma de pegar esses dados é através das seguintes rotas: https://api.com/product/:id e https://api.com/seller/:id, onde `:id` será substituido pelo id de cada objeto.

Nesse post utilizarei Javascript puro, com exceção das classes DAO que serão responsáveis por fazer a requisição. Nelas usarei Ajax para facilitar.

Criaremos duas classes DAO, uma para o produto e outra para o vendedor:

``` javascript
class ProductDAO {
    getProduct(id, callback) {
        $.get(this._url + "product/" + id, function(data, status) {
            callback(data);
        });
    }
}

class SellerDAO {
    getSeller(id, callback) {
        $.get(this._url + "seller/" + id, function(data, status) {
            callback(data);
        });
    }
}
```

A partir daqui, veremos como obter esses dois objetos com o padrão callback. Veja que nas classes DAO, o método `get` recebe o callback como parâmetro, e no fim da execução, ele é executado passando a resposta como parâmetro.

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

Temos dois pontos importantes para analisar no exemplo acima. O primeiro é que como precisamos da resposta de produtos para obter o id do vendedor, tivemos que fazer a requisição para o `sellerDAO` dentro da resposta de `productDAO`. Imagine agora que por algum motivo esse controlador precisasse acessar várias outras rotas para montar a página, e que um dos requisitos da nossa aplicação é que todos os dados tenham que ser retornados de uma só vez. Usando callbacks, teríamos que encadear um dentro do outro. Chamamos esse problema de Callback Hell.

O segundo ponto é o uso de Arrow Functions. Veja que ao invés de passar uma função com a sintaxe tradicional como parâmetro dos métodos `get`, utilizei uma versão simplificada: `(parametro) => {corpo}`. Essa maneira de escrever uma função não tem apenas o propósito de simplificar, mas também o de preservar o contexto. Ou seja, podemos usar o `this` para referenciar objetos da classe e não apenas locais da própria função. Se tivesse utilizado a sintaxe tradicional, não teria conseguido acessar o método `_render` dentro da resposta, já que o `this` passaria a ser o próprio método, e não a classe.

## Promise

Outra maneira de trabalhar com chamadas assíncronas com Javascript é através de `Promises`. Essa maneira resolve alguns problemas que enfrentamos ao utilizar callbacks. O maior ganho é evitarmos o Callback Hell em alguns casos.

A primeira modificação que precisamos fazer para começar a usar Promise é na classe DAO:

``` javascript
class ProductDAO {
    getProduct(id) {
        return new Promise((resolve, reject) => {
            $.get(this._url + "product/" + id, function(data, status) {
                resolve(data);
            });
        });
    }
}

class SellerDAO {
    getSeller(id) {
        return new Promise((resolve, reject) => {
            $.get(this._url + "seller/" + id, function(data, status) {
                resolve(data);
            });
        });
    }
}
```

Ao invés de receber um callback como parâmetro, agora retornamos uma `Promise`. A `Promise` recebe em seu contrutor uma função com dois parâmetro: `resolve` e `reject`. O primeiro usamos para passar em dados no caso de sucesso e o segundo para passar um erro.

Vamos agora resolver parcialmente um dos problemas que o callback trazia, o Callback Hell. Nesse primeiro exemplo, assumiremos que nosso `ProductController` conhece o id do produto e do vendedor. Por enquanto, iremos apenas sincronizar a resposta de um jeito mais elegante:

``` javascript
class ProductController {
    getProduct(productId, sellerId) {
        let productDAO = new ProductDAO();
        let sellerDAO = new SellerDAO();

        let promises = [
            productDAO.getProduct(productId),
            sellerDAO.getSeller(sellerId)
        ];

        Promise.all(promises).then(data => {
            console.log(data);

            this._render({
                product: data[0],
                seller: data[1]
            });
        });
    }

    _render(data) {
        // monta página com objetos retornados
    }
}
```

Uma grande vantagem de usar essa abordagem, é que através do método `all` da classe Promise, podemos passar um array de `Promises`. Todas serão executadas e retornarão ao final através do método `then`, um array de resultados com os objetos na mesma ordem do array de origem.

Ok, mas e se não conhecermos o id do vendedor? Utilizando apenas promises cairiamos no mesmo problema. Teríamos que colocar a requisição do vendedor dentro da resposta de produto:

``` javascript
class ProductController {
    getProduct(productId) {
        let productDAO = new ProductDAO();
        let sellerDAO = new SellerDAO();

        productDAO.getProduct(productId).then(product => {
            sellerDAO.getSeller(product.seller).then(seller => {
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
Vamos passar para o último exemplo desse post, onde poderemos resolver todos os problemas que apresentei aqui.

## Async Await

Para essa solução manteremos as classes DAO retornando uma `Promise`. O que muda agora é o jeito que nosso controller irá utilizá-las. A ideia é criar uma função assíncrona onde dentro dela, podemos chamar uma Promise de forma síncrona:

``` javascript
class ProductController {
    getProduct(productId) {
        let productDAO = new ProductDAO();
        let sellerDAO = new SellerDAO();

        async function request() {
            let product = await productDAO.getProduct(productId);
            let seller = await sellerDAO.getSeller(product.seller);

            return {
                product: product,
                seller: seller
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

Vamos entender o exemplo acima. Criamos dentro do método `getProduct` uma função assíncrona através do marcador `async`. Em Javascript funções marcadas com `async` retornam uma `Promise`. Dentro de uma função assíncrona, podemos usar o marcador `await` para um método que retorne uma Promise. Esse marcador fará com que dentro dessa função, a `Promise` sejá executada de forma síncrona, retornado como resultado o próprio objeto que definimos no `resolve`.

Dessa forma, na hora de fazer uma requisição para o `sellerDAO`, já conhecemos o objeto `product` e consequentemente, o id do vendedor relacionado a ele.

## Conclusão

Como desenvolvedores, sabemos que sempre existirão diversas formas de resolver um problema. Cabe a nós escolher a forma mais eficiente para o contexto do nosso projeto. Quem trabalha com aplicações web sabe da importância de deixarmos chamadas à serviços bem organizadas, assim melhoramos a legibilidade do código, além de ganhar performance e evitarmos bugs.

Caso tenha interesse em testar os exemplos desse post, o projeto está disponível no meu [github](https://github.com/andrepbap/estudo-javascript-async).
