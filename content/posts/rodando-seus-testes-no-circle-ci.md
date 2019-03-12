---
date: 2018-05-14
category: back-end
tags:
  - testes
  - integracao continua
  - circle ci
authors: [thiagoandrad]
layout: post
title: Rodando seus testes no Circle CI
description: Integrar os testes a um servidor de integração contínua é uma tarefa importante para os sistemas hoje em dia. Nesse post vamos abordar o Circle CI como opção para essa tarefa.
---

![Circle CI](/images/rodando-seus-testes-no-circle-ci-1.png)

Em nossos projetos, testar e manter tudo funcionando antes de subir para produção é uma tarefa constante dentro do fluxo de trabalho. A cada modificação de código podemos quebrar algo, fazendo então com que os desenvolvedores adotem estratégias, como a criação de testes, para diminuir possíveis bugs. Hoje, com o uso muito comum do [GIT](https://git-scm.com/) para versionar nossos códigos, muitas ferramentas de integração surgiram como [Circle CI](https://circleci.com/), [Travis](https://travis-ci.com/), [Jenkins](https://jenkins.io/), [GO CD](https://www.gocd.org/) e outras, onde seus testes podem rodar e dar um feedback rápido do seu código.

Com o [Circle CI](https://circleci.com/) podemos integrar nossos repositórios que usam `git` como o [GitHub](https://github.com/) ou [Bitbucket](https://bitbucket.org/), de uma maneira bem simples a um custo interessante. Isso porque, mesmo para repositórios privados, [o serviço não é cobrado se somente uma máquina for usada](https://circleci.com/pricing/) (pelo menos até a data deste post =] ).

## Configurando seu projeto

A configuração é bem simples, baseando-se em um arquivo de extensão `.yml`. Basta criar, na raiz do projeto, um diretório com o nome de `.circleci` e dentro dele criamos o arquivo de configuração `config.yml`.

A estrutura de pastas ficará basicamente assim:
```
└── <pasta do projeto>
	└── .circleci
			└── config.yml
```
Dentro do nosso `config.yml` teremos várias divisões para determinar as configurações que o Circle CI fará para nós. Na [doc](https://circleci.com/docs/2.0/) oficial [existem vários exemplos básicos](https://circleci.com/docs/2.0/tutorials/) para várias linguagens diferentes. Para nosso exemplo iremos usar uma aplicação em Java usando como ferramenta de build o [Maven](https://maven.apache.org/), mas isso não impacta negativamente no exemplo caso queira usar outra linguagem.

Aqui definimos a versão usada do Circle CI como 2.0 (ainda existe uma 1.0 depreciada) e adicionamos configurações para definir o diretório, e qual imagem *docker* usará para poder buildar e rodar os testes. O próprio Circle CI tem várias imagens que são muito usadas no mercado, mas você poderia usar qualquer outra do [docker hub](https://hub.docker.com/) (neste caso estamos usando uma específica para Java 8).

```yml
version: 2 # use CircleCI 2.0
jobs: # a collection of steps
  build: # runs not using Workflows must have a `build` job as entry point

    working_directory: ~/circleci-test # directory where steps will run

    docker: # run the steps with Docker
      - image: circleci/openjdk:8-jdk # ...with this image as the primary container; this is where all `steps` will run
```

Na próxima etapa definimos os passos a serem executados no *pipeline*. Basicamente aqui baixamos as dependências e salvamos em um cache para melhorar a velocidade em uma próxima vez quando o *pipeline* de testes for iniciado.

```yml
steps: # a collection of executable commands

      - checkout # check out source code to working directory

      - restore_cache: # restore the saved cache after the first run or if `pom.xml` has changed
          key: circleci-test-{{ checksum "pom.xml" }}

      - run: mvn dependency:go-offline # gets the project dependencies

      - save_cache: # saves the project dependencies
          paths:
            - ~/.m2
          key: circleci-test-{{ checksum "pom.xml" }}
```

Por fim, executamos aqui o comando do `maven` para rodar os testes e gerar nosso pacote, então indicamos para o Circle CI onde estão os relatórios gerados pelo teste e o artefado gerado.

```yml
- run: mvn package # run the actual tests

      - store_test_results: # uploads the test metadata from the `target/surefire-reports` directory so that it can show up in the CircleCI dashboard.
          path: target/surefire-reports

      - store_artifacts: # store the uberjar as an artifact
          path: target/circleci-test-0.0.1-SNAPSHOT.jar
```
O arquivo completo fica basicamente como [este](https://circleci.com/docs/2.0/language-java/).

## Concluindo a configuração pelo Circle CI

Agora podemos logar no Circle CI usando a conta onde está seu projeto (nesse caso GitHub) e só precisamos clicar em `add projects` no menu lateral e depois adicionar seu projeto:

![Selecionando projeto](/images/rodando-seus-testes-no-circle-ci-2.png)

No próximo passo o primordial é escolher qual a tecnologia que será utilizada, no nosso caso é `Maven (Java)`:

![Selecionando tecnologia](/images/rodando-seus-testes-no-circle-ci-3.png)

Pronto! Seus testes já irão iniciar e logo você terá seu feedback =). Agora a cada *commit* que rolar no seu repositório os testes iniciarão automaticamente:

![feedback dos testes](/images/rodando-seus-testes-no-circle-ci-4.png)

## Conclusão

Se você precisa de integração com seu repositório de maneira simples e sem custo, talvez o Circle CI te atenda bem.
E se precisarmos de mais configuraçoes como workflows, paralelizar testes, mais máquinas, fazer um *ssh* para o *container* onde estão os testes estão sendo executados? Tudo isso é possível e outras coisinhas mais.
