---
title: Boas práticas na utilização do Kubernetes em produção
date: 2018-04-16
category: devops
layout: post
description: Neste post discutiremos alguns pontos de atenção importantes e necessários ao implementar o Kubernetes em ambientes de produção.
authors: [marcusrios]
tags:
  - devops
  - kubernetes
  - containers
  - AWS
---

O [Kubernetes](https://kubernetes.io/) é uma ferramenta para orquestração de *containers* extremamente consolidada no mercado e com muitos recursos que facilitam a administração, diminuindo o _overhead_ operacional de se manter ambientes com *containers*. Contudo, quando falamos de ambientes de produção, alguns pontos como segurança, disponibilidade, escalabilidade e outros precisam ser tratados com muito afinco para que tenhamos uma plataforma resiliente e preparada para receber grandes cargas de trabalho. A ideia desse _post_ é apresentar alguns dos vários pontos de atenção que precisamos ter na hora de implementar/utilizar nosso cluster.

## Autenticação e autorização

Existem várias estrátegias de [autenticação](https://kubernetes.io/docs/admin/authentication/#authentication-strategies) no `Kubernetes`. Aqui no Elo7 usamos certificados *x509* que são gerados pelo [vault](https://www.vaultproject.io/). No nosso caso, a autorização é feita pelo `vault` com base no usuário do *GitHub*. Independentemente da estratégia adotada, a ideia aqui é não deixar o *cluster* acessível sem autenticação e, preferencialmente, que seja adotado um mecanismo de autorização com base nas permissões que cada usuário precise.

## Liveness e Readiness probes

Para o `Kubernetes`, por padrão, o seu *container* estará apto a receber requisições a partir do momento em que o *pod* estiver com o status de _Ready_, mas não necessariamente ele está de fato "pronto". Um bom exemplo disso seria uma aplicação Java com Spring que pode levar alguns segundos até carregar todas as suas dependências e iniciar a *app*. Nesse meio tempo, as requisições que forem encaminhadas para esse *pod* retornaram erro 500 para o [Service](https://kubernetes.io/docs/concepts/services-networking/service/) e consequentemente para o usuário. Pensando nisso, existe uma técnica para garantir que o *pod* só receberá requisições quando a *app* estiver realmente pronta. Podemos fazer isso usando [readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#define-readiness-probes). Vejamos abaixo um exemplo:

```yaml
readinessProbe:
  httpGet:
    path: "/health"
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  successThreshold: 3
```

**initialDelaySeconds** = Tempo em segundos que o `Kubernetes` aguarda antes de realizar uma operação de _readiness_ ou _liveness_, após o container ser iniciado.

**periodSeconds** = De quantos em quantos segundos o `Kubernetes` deve realizar uma operação de _readiness_ ou _liveness_.

**successThreshold** = Quantas vezes consecutivas o *probe* precisa responder com **OK** para ser considerado pronto para receber tráfego.

No nosso exemplo estamos realizando um GET em `POD_IP:8080/health`

Assim como temos o `readinessProbe` para avaliar se o *pod* está pronto, também temos o `livenessProbe` para dizer se o *pod* está vivo, ou seja, para dizer se a *app* está de pé ou não. O funcionamento é basicamente o mesmo do `readinessProbe`. É importante destacar que essas checagens podem ser feitas com comandos também. Vejamos um exemplo:

```yaml
readinessProbe:
  exec:
    command:
    - test
    - -e
    - /tmp/endpoints.json
  initialDelaySeconds: 15
  periodSeconds: 30
```

Nesse caso o que será avaliado para considerar esse *container* como saudável é a existencia do arquivo `/tmp/endpoints.json`

## Quanto de recurso eu defino aqui?

Por padrão, se nada foi informado, o `Kubernetes` irá subir seus *containers* sem limites para uso de CPU e memória (por exemplo). Quando estamos definindo alguns objetos como [deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/), temos a possibilidade de configurar valores de *requests* e *limits* na sessão de [`resources`](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/). Vejamos abaixo o que cada um significa e um exemplo de implementação:

**requests** = Qual o valor de CPU e memória que o `Kubernetes` precisa reservar para o meu container ser iniciado.

**limits** = Qual o valor máximo de CPU e memória que meu *container* pode consumir no `Kubernetes`.


```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "1000m"
  limits:
    memory: "512Mi"
    cpu: "2000m"
```

No exemplo acima, estamos definindo 512MB de memória/2000 *millicores* para limits e 128 MB de memória/1000 *millicores* para requests (lembrando que 1m representa 1/1000 = 0,001 de um *core* de CPU, assim como 500m = 500/1000 = 0,5 *core* de uma CPU ou 50% de uma CPU).

Estamos falando para o Kubernetes reservar 1 *core* de uma CPU para nosso *container*, mas a grande pergunta é: precisamos realmente reservar 1 *core* de CPU para esse container? Provavelmente a resposta vai ser não, mas a única forma de termos certeza é acompanharmos o consumo de recursos no container (podemos utilizar ferramentas como o [cAdivisor](https://github.com/google/cadvisor) e o [Prometheus](https://github.com/prometheus/prometheus) para nos ajudar nessa tarefa).

O grande problema de usar valores "altos" na configuração das *requests* é que podemos estar superdimensionando nosso *cluster*, logo precisaremos de mais *nodes* e consequentemente teremos um desperdício de recursos, visto que o `Kubernetes` está pré-alocando 1 *core* de CPU, mas na verdade estamos usando apenas 30% disso, por exemplo. Isso pode parecer pouco, mas se pensarmos em um cenário com centenas de *containers* com esse mesmo perfil de configuração, ao final do mês estaremos rodando alguns *nodes* sem necessidade.

## Definindo limits padrão

Como dito anteriormente, em configurações padrões e se não for informado nada na criação do _deployment_, o `Kubernetes` irá criar o mesmo com recursos "ilimitados". Para contornar essa situação, o `Kubernetes` disponibiliza um recurso que define valores de *requests* e *limits* _defaults_, caso não sejam informados. Isso pode ser feito utilizando o objeto [`LimitRange`](https://kubernetes.io/docs/tasks/administer-cluster/memory-default-namespace/)

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: ns-limits-range
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 200m
      memory: 256Mi
    type: Container
```

## nodeSelector

A [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) é um recurso que permite criar *clusters* "virtuais". A idéia aqui seria organizar seus objetos (*deployments*, *secrets*, *configMaps* e afins) em ambientes separados como produção e desenvolvimento ou até mesmo por projeto ou times. Mas a *namespace* em si é só um recurso lógico, ou seja, ela não vai garantir que seus _deployments_ de produção não rodem no mesmo node que os _deployments_ de desenvolvimento. Para resolver isso, umas das alternativas seria usar [nodeSelector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).

O `nodeSelector` é um recurso que permite especificar em qual *node* seu container será executado. Vejamos um exemplo disso na declaração de um _pod_:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    elo7-environment: dev
```

Essa declaração irá criar um *pod* usando a imagem do [nginx](https://www.nginx.com/) e criará o mesmo em qualquer *node* que tenha a label `elo-environment=dev`. Quando estamos adicionando um novo *node* no nosso *cluster*, temos a possibilidade de passar uma *flag* para o [kubelet](https://kubernetes.io/docs/reference/generated/kubelet/) que irá informar as _labels_ que aquele *node* terá. No exemplo acima, ao criar o *node* passariamos a seguinte *flag*:

 `--node-labels=elo7-environment=dev`

## Qual é a melhor forma de autorizar minhas aplicações rodando no k8s para usar recursos na AWS?

No nosso caso, nosso *Cloud Provider* é a AWS. Existem uma série de serviços externos que talvez nossa aplicação precise acessar (como S3, SQS e afins). Para consumir tais serviços precisamos ser autorizados, e esse mecanismo de autorização pode ser feito usando [AWS Access e Secret Keys](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) ou [roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html). Por questões de segurança e boas práticas não é recomendado usar _Access Keys_ para aplicações na AWS. Ao invés disso, é recomendado usar _IAM roles_. Pensando nisso, foi criado o *plugin* [kube2iam](https://github.com/jtblin/kube2iam). Esse *plugin* permite que você adicione no campo de `annotations` qual *role* estará vinculada com sua *app*, permitindo que a mesma acesse recursos da AWS. Lembrando que esse *plugin* é implementado no `Kubernetes` como um [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/). Para maiores informações de como configurá-lo, recomendo a leitura da configuração disponível no Readme do projeto no GitHub. Abaixo temos um exemplo simples de como usar esse recurso:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: aws-cli
  labels:
    name: aws-cli
  annotations:
    iam.amazonaws.com/role: role-arn
spec:
  containers:
  - image: fstab/aws-cli
    command:
      - "/usr/local/bin/aws"
      - "s3"
      - "ls"
      - "some-bucket"
    name: aws-cli
```


## Conclusão

Nesse _post_ elencamos alguns dos muitos tópicos que precisam ser tratados com a implementação do `Kubernetes` em produção. E você? Como está lidando com os desafios e dilemas na implementação em sua empresa? Aproveite o espaço no campo de comentários para deixar seu ponto de vista ou compartilhar como você lidou com esses desafios. Um abraço e até a próxima!
