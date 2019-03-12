---
title: Controlando e melhorando a performance do build no Travis CI
date: 2018-02-12
category: front-end
layout: post
description: "Aprenda como criar fluxos de forma simples e flexível em uma das ferramentas mais famosas de Integração Contínua: o Travis CI. Além disso, veja  como podemos otimizar o seu tempo de execução."
authors: [williammizuta]
tags:
  - travis ci
  - integracao continua
  - testes
---

![Alt "Travis CI"](/images/travis-build-stages-1.png)

Hoje a maioria dos projetos, tanto de código livre quanto fechado, utilizam **<a href="https://git-scm.com" target="_blank">git</a>** como a ferramenta de controle de versão. E muitos destes estão hospedados no **<a href="https://github.com" target="_blank">GitHub</a>**, uma das plataformas mais comuns para armazenamento de projetos. Além disso, muitos projetos adotam a prática conhecida como integração contínua ou **<a href="https://martinfowler.com/articles/continuousIntegration.html" target="_blank">continuous integration</a>**, a qual visa facilitar a integração do código sendo desenvolvido e encontrar problemas mais rapidamente. Há inúmeras ferramentas que auxiliam a implementação dessa prática. Aqui no **<a href="https://www.elo7.com.br?utm_source=tech-blog&utm_medium=travis-build-stages" target="_blank">Elo7</a>**, utilizamos tanto o **<a href="https://jenkins.io" target="_blank">Jenkins</a>** quanto o **<a href="https://travis-ci.org" target="_blank">Travis CI</a>**. Neste post falarei um pouco mais sobre como controlar este processo e como melhorar o tempo de build no **<a href="https://travis-ci.org" target="_blank">Travis CI</a>**.

## Por que utilizar o Travis CI?
O Travis CI é uma plataforma de integração contínua que se integra com o GitHub de forma bem simples. E não importa se o time utiliza a metodologia do GitHub Flow, feature branches ou commit direto na master, o Travis CI auxilia na entrega do código. Além disso, já traz ambientes preparados para diversas linguagens como JavaScript, Java, PHP, Python, Ruby e Swift.

E como não há nenhum custo para projetos de código livre (open source), vários deles o utilizam, como por exemplo **<a href="https://travis-ci.org/angular/angular" target="_blank">Angular</a>**, **<a href="https://travis-ci.org/jquery/jquery" target="_blank">jQuery</a>** e **<a href="https://travis-ci.org/twbs/bootstrap" target="_blank">Bootstrap</a>**. Inclusive alguns dos projetos abertos do **<a href="https://travis-ci.org/elo7" target="_blank">Elo7</a>** utilizam essa ferramenta.

## Criando workflows com build stages
Recentemente, o Travis CI anunciou a adição de uma nova ferramenta que permite criar fluxos (_pipelines_) de forma bem flexível: **<a href="https://blog.travis-ci.com/2017-05-11-introducing-build-stages" target="_blank">build stages</a>**. Nós já a adotamos para manter o nosso **<a href="https://travis-ci.org/elo7/tech-blog" target="_blank">blog técnico</a>**:

![Alt "Build stages do blog"](/images/travis-build-stages-2.png)

Com isso, conseguimos definir o que cada estágio do fluxo precisa fazer de forma bem simples:

```yaml
jobs:
  include:
    - stage: test
      script: <script de teste>
    - stage: deploy
      script: <script de deploy>
```

Além disso, conseguimos definir a ordem que os estágios devem executar:

```yaml
stages:
  - name: test
  - name: deploy
```

E se um deles falhar, os seguintes não rodarão. No caso do blog, o deploy não é realizado se os testes falharem.

Outra vantagem dos _build stages_ é que conseguimos definir facilmente regras que um estágio deve rodar. Por exemplo, podemos definir que o processo de deploy rode apenas quando o CI for disparado a partir da _branch_ _master_ e que não seja um _pull request_.

```yaml
stages:
  - name: test
  - name: deploy
  if: branch = master AND NOT type = pull_request
```

Juntando tudo, temos o seguinte código:

```yaml
stages:
  - name: test
  - name: deploy
  if: branch = master AND NOT type = pull_request
jobs:
  include:
    - stage: test
      script: <script de teste>
    - stage: deploy
      script: <script de deploy>
```

## Otimizando o Travis com build stages

Outra vantagem do _build stages_ é que podemos paralelizar a execução do fluxo da aplicação. Para isso, basta escrever mais de uma _job_ com o mesmo estágio:

```yaml
jobs:
  include:
    - stage: test
      script: <script de teste 1>
    - stage: test
      script: <script de teste 2>
    - stage: test
      script: <script de teste 3>
    - stage: deploy
      script: <script de deploy>
```

Dessa forma, o estágio de teste disparará 3 _jobs_ que rodarão em paralelo. Se todos eles passarem, o estágio de _deploy_ é iniciado.

Veja como ficou o arquivo de configução (**<a href="https://github.com/elo7/tech-blog/blob/master/.travis.yml" target="_blank">.tavis.yml</a>**) do nosso blog no final.

## Conclusão

O _build stages_ veio para facilitar a criação de fluxos de integração contínua de projetos além de ajudar a otimizar o processo paralelizando a execução de _scripts_.
