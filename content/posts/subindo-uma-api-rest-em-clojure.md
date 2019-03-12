---
date: 2018-01-22
category: back-end
layout: post
title: Subindo uma API REST em Clojure
description: Clojure é uma linguagem já conhecida para os amantes do paradigma funcional, neste post, demonstro alguns detalhes de uma biblioteca que faz uma ponte entre esta linguagem e o mundo WEB. Venha aprender como subir uma API REST em 10 minutos!
authors: [ericdallo]
tags:
  - API
  - REST
  - clojure
  - back-end
---

[Clojure](https://clojure.org/) é uma linguagem funcional e dinâmica que roda na JVM e que vem crescendo bastante no mercado de trabalho. Ela é tão performática quanto qualquer programa que roda em _Java_ e muito menos verbosa. Isso facilita e muito na manutenção do código, influenciando no custo do desenvolvimento.
Caso não esteja muito familiarizado com esta linguagem incrível, recomendo a leitura do livro [Clojure for the Brave and True](http://www.braveclojure.com/clojure-for-the-brave-and-true/) onde ensina desde o básico sobre Clojure.

Para testar algumas características da linguagem vamos criar uma aplicação com uma __API REST__ básica. Esse projeto, o [clojure7](https://github.com/ericdallo/clojure7), que será um _CRUD_ de posts de um blog.

Para quem programa ou já programou em _Clojure_, deve ter esbarrado em algum momento no [Leiningen](https://leiningen.org). Ele é um gerenciador de dependências e tasks, assim como o *gradle* e *maven* para os "javeiros".
Com o *Leinigen*, podemos construir a hierarquia do nosso novo projeto, rodar a aplicação com plugins, entre outros.

## Dependências

Vamos utilizar um plugin chamado **Compojure**, para criar a hierarquia e arquivos básicos para nossa aplicação.
O [Compojure](https://github.com/weavejester/compojure) é uma biblioteca, não um framework, baseado no [Ring](https://github.com/ring-clojure/ring) (biblioteca que consegue manipular **request** e **response**, semelhante à especificação **Servlet** no Java). A diferença entre os dois está no fato do compojure permitir o gerenciamento das rotas da aplicação mais facilmente.

Caso tenha dúvidas de como o _Ring_ funciona, sugiro a leitura de [seus conceitos](https://github.com/ring-clojure/ring/wiki/Concepts).

Vamos começar criando o projeto a partir do *Leiningen*:

```bash
$ lein new compojure clojure7
```

Ao rodar este comando, o *lein* irá criar alguns arquivos para nós:

* __project.clj__ - arquivo de configuração do projeto, parecido com o `build.gradle` ou `pom.xml`
* __resources/__  - pasta onde serão guardados arquivos como assets, templates html e migrações de banco
* __src/__        - pasta contendo todo o código clojure da aplicação
* __test/__       - pasta contendo os testes da aplicação


Vamos adicionar algumas dependências no arquivo `project.clj`:

* [ring-json](https://github.com/ring-clojure/ring-json) - Permite lidarmos com requisições que contenham _json_ e facilita as respostas da aplicação em _json_.
* [korma](http://sqlkorma.com/) - Uma das minhas _libs_ favoritas em clojure, um [ORM](http://www.devmedia.com.br/orm-object-relational-mapper/19056) que mapeia nossos modelos clojure em modelos relacionais no banco de dados.
* [mysql](https://github.com/clojure/java.jdbc) - Driver do *mysql* para clojure.

As dependências da aplicação ficarão assim:

```java
:dependencies [[org.clojure/clojure "1.8.0"]
               [compojure "1.5.2"]
               [ring/ring-defaults "0.2.1"]
               [ring/ring-json "0.4.0"]
               [korma "0.4.3"]
               [mysql/mysql-connector-java "5.1.6"]]

```

Ainda neste mesmo arquivo, podemos adicionar a configuração do `ring`:

```clojure
:ring {:handler clojure7.handler/app}
```

Na configuração acima temos um **handler**, um arquivo que deverá lidar com cada rota da aplicação, e o namespace apontando para o mesmo.

Ao abrirmos o `src/clojure7/handler.clj`, vamos alterar o _ring_ para realizar o _bind_ dos parâmetros da _request_ para _json_ e dizer ao ring que após passar pela nossa rota, transforme os dados da resposta em _json_ .

```clojure
(ns clojure7.handler
  (:require [compojure.core :refer :all]
            [compojure.route :as route]
            [ring.middleware.json :refer [wrap-json-response wrap-json-body]]))

(def app
  (-> all-routes
      wrap-json-response
      wrap-json-body))
```

Neste mesmo arquivo, teremos as definições de rotas:
```
(defroutes all-routes
  (GET "/" [] "Hello World")
  (route/not-found "Página não encontrada :("))
```

Com o Compojure, temos a definição da nossa rota com o `defroutes`, onde podemos passar uma lista de rotas para ele. Podemos ver que já temos uma rota *GET* para a raiz da aplicação que retornará uma _String_ no corpo da resposta, e outra que caso não encontre nenhuma rota definida deste método, exiba a página de 404, "Página não encontrada :(".

## Banco de dados

Criaremos então a nossa tabela `post` no nosso banco de dados mysql:

```sql
CREATE TABLE post (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `category` varchar(30) NOT NULL,
  PRIMARY KEY (`id`)
);
```

A título de curiosidade, assim como no *Ruby on Rails*, podemos ter migrações de banco de dados para facilitar na criação/alteração de novas tabelas. Neste post não irei demonstrar pela extensão do assunto, mas caso queira aprender, sugiro o uso do [migratus](https://github.com/yogthos/migratus) que também é outra _lib_ excelente.

Vamos criar o arquivo `src/clojure7/db.clj` contendo as configurações do banco de dados:

```clojure
(ns clojure7.db
  (:use korma.db))

  (defdb db (mysql
            { :classname "com.mysql.jdbc.Driver"
              :subprotocol "mysql"
              :subname "//localhost/clojure7"
              :user "root"
              :password ""}))
```

## Recursos

Se tratando de _REST_, nosso modelo `post` é um recurso, então vamos mapeá-lo no arquivo `src/clojure7/post/post.clj`:

```clojure
(ns clojure7.post.post
  (:require [korma.db :refer :all]
            [korma.core :refer :all]
            [clojure7.db :refer :all]))

(defentity post)
```

Podemos observar que com o `defentity` transformamos o objeto `post` em uma entidade gerenciada pelo **korma**. Agora podemos manipular os dados da tabela através do clojure, então vamos criar os métodos para cada operação do _CRUD_:

```clojure
(defn find-all []
  (select post))

(defn find-by-id [id]
    (select post
      (where {:id id})
      (limit 1)))

(defn create [name category]
  (insert post
    (values {:name name :category category})))

(defn update-by-id [id name category]
  (update post
    (set-fields {:name name :category category})
    (where {:id id})))

(defn delete-by-id [id]
  (delete post
    (where {:id id})))
```

Criaremos agora as rotas para alterar nosso recurso `post` no arquivo `src/clojure7/handler.clj` e adicionaremos no namespace dele o link para o namespace `post.clj`, assim conseguimos acessar os métodos daquele namespace:

```clojure
(ns clojure7.handler
    (:require [compojure.core :refer :all]
              [compojure.route :as route]
              [clojure7.post.post :as post]
              [ring.middleware.json :refer [wrap-json-response wrap-json-body]]))

(defroutes all-routes
  (GET "/posts" []
    (post/find-all))
  (POST "/posts" req
    (let [name (get-in req [:body "name"])
          category (get-in req [:body "category"])]
          (post/create name category)))
  (GET "/posts/:id" [id]
    (post/find-by-id id))
  (PUT "/posts/:id" req
    (let [id (read-string (get-in req [:params :id]))
          name (get-in req [:body "name"])
          category (get-in req [:body "category"])]
          (post/update-by-id id name category)
          (post/find-by-id id)))
  (DELETE "/posts/:id" [id]
    (post/delete-by-id id)
    (str "Deleted post " id))
  (route/not-found "Not Found"))
```
## Subindo a aplicação

Podemos agora subir nossa aplicação com o seguinte comando ``lein ring server``, por padrão ele irá subir na porta 3000.

Para executar cada uma das ações que criamos no código, seguem abaixo os comandos:

* Criando um `post`

```bash
curl -X POST localhost:3000/posts -H "Content-Type: application/json" -d '{"name":"Clojure com o Simbal", "category":"cool-posts"}'
```

* Listando todos os `post`'s

```bash
curl -X GET localhost:3000/posts
```

* Editando um `post`

```bash
curl -X PUT localhost:3000/posts/1 -H "Content-Type: application/json" -d '{"name":"Clojure com o Greg", "category":"other-posts"}'
```

* Encontrando um `post`

```bash
curl -X GET localhost:3000/posts/1
```

* Removendo um `post`

```bash
curl -X DELETE localhost:3000/posts/1
```

Gostou do post? Tem alguma dúvida? Alguma crítica? Comenta aqui em baixo :)
Espero que tenha despertado, para quem não conhece, aquela curiosidade que todo *dev* tem quando descobre que existe outra maneira de subir uma API REST nos seus novos projetos :D
