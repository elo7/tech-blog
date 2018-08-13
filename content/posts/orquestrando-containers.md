---
title: Orquestrando containers
date: 2017-11-13
category: devops
layout: post
description: Neste post mostraremos como decidimos utilizar o Kubernetes para orquestrar nossos containers e quais os pontos de atenção ao utilizar uma ferramenta desse tipo.
authors: [lucasvasconcelos]
tags:
  - devops
  - kubernetes
  - containers
  - orquestracao
  - infra
---

![Orquestrando containers](../images/orquestrando-containers.png)

Olar, amigos. Prontos para mais um *post* de infra aqui no nosso *blog*?

O objetivo deste post é mostrar o porquê de termos escolhido o Kubernetes (spoiler :P) como solução definitiva para orquestração dos nossos containers. Não entraremos no mérito dos motivos para orquestrar algo, pois consideramos que isso já está bem difundido em nosso meio.

Para te situar, querido leitor, antes de começarmos a falar de Kubernetes e outras soluções de orquestração, vamos fazer um *overview* do nosso cenário até então.

Nós migramos nossas aplicações para *containers* Docker em meados de 2014, levando isso para ambiente de produção, inclusive. Na época ainda se falava pouco sobre orquestração de *containers* e as soluções estavam começando a aparecer aqui e acolá.

Uma das ferramentas que surgiram nessa época foi o [*fleet* da CoreOS](https://github.com/coreos/fleet) que, naquele cenário, nos atendeu perfeitamente: implantação fácil e barata, onde a única dependência é um [*cluster* de etcd](https://coreos.com/etcd/) e baixa curva de aprendizado, pois o *fleet* funciona como um "[*systemd*](https://pt.wikipedia.org/wiki/Systemd) distribuído" (mais detalhes podem ser vistos na página do projeto).

O *fleet* nos atendia bem e todo o time de Engenharia se habituou facilmente com a ferramenta, mas, junto com novas soluções mais atraentes surgindo, ele começou a demonstrar problemas com a escala que estávamos tomando. Confirmamos os problemas na comunidade e já decidimos que o *fleet* teria um prazo de validade.

Nessa ocasião, começamos a analisar as demais ferramentas existentes e ver qual delas poderia se adequar melhor ao nosso cenário. Dentre as que foram analisadas, ficamos com o [Kubernetes](https://kubernetes.io).

Vamos descrever brevemente cada uma delas, fazendo um paralelo com o Kubernetes e mostrando o(s) motivo(s) pelos quais as ferramentas não serviram **para nós** (esse tipo de escolha depende muito do momento e cenário de cada empresa). Vamos fazer o possível para trazer uma ótica mais atual mas, em alguns pontos, mostramos a ótica do momento em que fizemos esses estudos, que datam de mais de 1 ano atrás. Entretanto, mesmo com as mudanças que presenciamos como, por exemplo, o [Mesos+Marathon virarem DC/OS](https://dcos.io/) e o [Docker Swarm](https://docs.docker.com/engine/swarm/) ficarem mais estáveis, nossa decisão não mudaria.

Após a análise, entraremos em mais detalhes do Kubernetes.

## [ECS (Amazon EC2 Container Service)](https://aws.amazon.com/pt/ecs/)

Como já foi dito em posts anteriores, nossa infraestrutura está 100% situada na AWS. Então, sempre faz sentido olhar para os serviços internos da própria provedora de serviços de *cloud*.

Uma grande vantagem do ECS é a integração nativa com os outros serviços da AWS, como IAM, ELB e CloudWatch. Entretanto, o *lock-in* com o serviço é muito grande, fazendo com que a opção fosse descartada rapidamente.

Ainda hoje não temos intenção de utilizá-la, ainda mais depois que a AWS divulgou uma nota dizendo que existe a possibilidade de [fornecer Kubernetes como Serviço](http://www.businessinsider.com/amazon-joins-google-born-kubernetes-project-2017-8).

## [Docker Swarm](https://docs.docker.com/engine/swarm/)

Uma ferramenta óbvia quando falamos de orquestração de *containers* é a solução da própria Docker Inc. Subconscientemente já esperamos que seja a opção que melhor se integra com o Docker.

O deploy do ambiente se mostrou mais fácil e barato entre todas as ferramentas, mas na ocasião dos testes, a solução ainda estava bem instável e ainda não tinha sido usada em ambientes críticos de produção. Dado esse cenário, o Docker Swarm foi descartado.

Atualmente, apesar de o caminho que a solução está tomando ter sido alvo de algumas [controvérsias](https://thenewstack.io/docker-fork-talk-split-now-table/), a ferramenta está mais madura e tem um foco muito legal em segurança.

Porém, ainda carece de algumas funcionalidades já existentes em outras soluções e possui uma comunidade pequena, além de ter um foco mais Enterprise do que Opensource, que faz com que ela continue a não chamar nossa atenção.

## [Mesos + Marathon (e agora DC/OS)](https://dcos.io/)

Das ferramentas já citadas, era a mais bem estabelecida e com uma base de usuários considerável na ocasião da análise.

Ao contrário das outras soluções que nasceram para orquestrar *containers*, o [Mesos](http://mesos.apache.org/) nasceu para administrar recursos e *workloads* em *data-centers*, sendo a ferramenta de orquestração preferida para gerenciar plataformas/ferramentas como [Hadoop](http://hadoop.apache.org/) e [Spark](https://spark.apache.org/).

Para obter tal funcionalidade com *containers* Docker no Mesos, é necessário o uso do [Marathon](https://mesosphere.github.io/marathon/), um *framework* que adiciona uma camada no Mesos e abstrai o *scheduling* de *containers* na infraestrutura.

Essa solução é a que mais se aproximava do que tínhamos experimentado com o Kubernetes. As duas ferramentas têm diversas funcionalidades em comum, inclusive a dificuldade e complexidade de implantação :P.

O uso de *frameworks* no Mesos traz uma funcionalidade interessante que é a capacidade de orquestrar *workloads* genéricos, sejam eles "conteinerizados" ou não, como executar *jobs* no Spark (como já citado anteriormente).

O Mesos também demonstrava capacidade de lidar com *clusters* maiores: 10.000 nós *versus* 5.000 nós do Kubernetes (na data da pesquisa).

Porém, 99% das nossas aplicações estavam rodando em *containers* e não iríamos ter 1.000 nós em produção em um futuro próximo. E uma outra funcionalidade já existente no Kubernetes, que o Mesos não nos oferecia, é a capacidade de gerenciar discos no [EBS (Elastic Block Storage)](https://aws.amazon.com/ebs/) da AWS, de muito interesse para nós.

Recentemente, a empresa que encabeça o desenvolvimento do Mesos, a [Mesosphere](https://mesosphere.com/), apresentou o [DC/OS](https://dcos.io/). Uma *stack* em cima do Mesos que inclui diversas funcionalidades nativas, como orquestração de *containers* e gerenciamento de pacotes. Porém, a Mesosphere está diretamente relacionada com a ferramenta e decide os rumos dela, o que pode se tornar um problema.

Por fim, vimos que a comunidade não era atrativa, endossando ainda mais a escolha do Kubernetes.

## [Kubernetes](https://kubernetes.io)

Chegou a hora de falar da ferramenta que decidimos adotar como nosso orquestrador de *containers* definitivo. Vamos dissertar sobre as características que motivaram nossa escolha e alguns contras da ferramenta.

Como a própria [página do projeto](https://kubernetes.io) já diz: "Kuberbetes é um sistema *open-source* para automatizar a implantação, escala e gerenciamento de aplicações "conteinerizadas".

O projeto foi inspirado pelo [Borg](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/43438.pdf), que traz como resultado décadas de experiência em orquestração de Linux *containers* pelo Google. Existem diversas empresas, como o próprio Google e a RedHat, que possuem funcionários contribuindo *fulltime* para o projeto. Ele se encontra sob o guarda-chuva da [CNCF (Cloud Native Computing Foundation)](https://www.cncf.io/), garantindo que não haja viés de nenhuma empresa nas decisões de projeto, fazendo com que os padrões de mercado sejam sempre seguidos e nunca buscar obter vantagens comerciais. Em 2016, o Kubernetes se tornou a ferramenta de orquestração mais [pesquisada no Google](http://fixate.io/kubernetes-stole-docker-swarms-share-voice).

Ele é escrito em [Go](https://golang.org/), linguagem que os membros do time responsável aqui no Elo7 possuem uma certa familiaridade, podendo ajudar em um possível *PullRequest* ou para analisar o código na ausência de documentações para uma determinada funcionalidade.

O Kubernetes possui um dos repositórios mais populares e movimentados do [GitHub](https://github.com/kubernetes/kubernetes/graphs/contributors)! Isso demonstra o tamanho e vontade de contribuir da comunidade. Vale dizer que isso pode trazer alguns problemas: devemos ficar de olho, pois, como muitas funcionalidades são adicionadas, algumas delas mudam de nome posteriormente e também entram sem documentação. Usuários *early adopters* de funcionalidades do Kubernetes (como nós :D) devem conhecer bem o ciclo [de sua API](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md).

O Kubernetes se adere muito bem ao [TwelveFactorApp](https://12factor.net/) e a ambientes de cloud público, como AWS e GCP (o GKE - [Google Container Engine](https://cloud.google.com/container-engine/) - usa o Kubernetes como plataforma).

Seguem algumas *features* que o Kubernetes pode nos oferecer. Nos desculpem por jogar alguns termos específicos da ferramenta a ermo, pretendemos elucidá-los em posts futuros:

- [**HPA (Horizontal Pod Autoscaling)**](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/): *Autoscaling* de *pods* baseando-se em métricas como consumo de CPU. Fornece também uma API para utilizar métricas customizadas;
- [**Service Discovery**](https://kubernetes.io/docs/concepts/services-networking/service/): Conceito de *services*, que podem ser expostos e associados a um ou mais *pods*. Oferecendo descoberta de serviços com um servidor de DNS interno e balanceamento de carga;
- [**Deployment rollout/rollback**](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/): Abstrai a lógica de *deploy* das aplicações (sem *scripts* de *deploy*, pessoal). Também é capaz de detectar falhas (através dos [*probes*](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)) em uma nova *release* e efetuar um *rollback* automaticamente;
- [**ConfigMaps**](https://kubernetes.io/docs/tasks/configure-pod-container/configmap/): Para aplicações cuja configuração não é feita através de variáveis de ambiente (i.e. NGINX), o Kubernetes é capaz de entregar uma configuração em forma de arquivo para o *container* em questão;
- [**Storage Management**](https://kubernetes.io/docs/concepts/storage/volumes/): É possível criar *volumes* para as aplicações que precisam persistir algo em disco, por exemplo. Os tipos de *storages* fornecidos dependem do ambiente. Por exemplo, na AWS o Kubernetes consegue criar um EBS (Elastic Block Storage), ligá-lo à instância onde o *pod* em questão irá ser executado e entregá-lo para a aplicação;
- [**Jobs**](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/): Podemos utilizar os recursos computacionais existentes no *cluster* para executar *jobs* finitos em geral, como uma consolidação de dados, por exemplo.

Legal, parece promissor, certo? Mas sabem o que aconteceu com o homem que teve tudo que sempre quis? (na verdade ele viveu feliz para sempre - WONKA, W. - mas achei que aqui caberia uma frase de efeito, pois é onde o bicho pega).

A arquitetura do Kubernetes não é simples e tampouco sua implantação. Isso implica que o time responsável pela administração tenha um conhecimento profundo da ferramenta e deve estar sempre atento à todas as mudanças que surgem a cada semana. É interessante que a implantação seja feita de maneira automatizada (cenas dos próximos posts) e que facilite a atualização do *cluster*.

Para ambientes de produção, é extremamente importante que os componentes estejam em modo de alta disponibilidade, seguindo os requisitos de [*hardware* recomendados](https://kubernetes.io/docs/admin/cluster-large/) (lembrando do cálculo do custo da infraestrutura para o *cluster* nessa etapa). Uma dica é que, se possível, tenha um ambiente de testes para o *cluster* (para testar uma nova versão, por exemplo). Aqui nós [utilizamos Terraform](/terraformando-tudo-1/) e subimos *clusters* de testes por demanda quando precisamos. Não se esqueça de preparar [monitoração](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/) e [logging](https://kubernetes.io/docs/concepts/cluster-administration/logging/) para seu *cluster*.

É desejável que os usuários estejam familiarizados com *containers*, afinal, por mais que o Kubernetes ofereça muitas abstrações, a aplicação será executada em *containers* e estará sujeita às limitações desse ambiente.

Mesmo que o time já esteja habituado com *containers* (nosso caso), há uma mudança de paradigma, pois o Kubernetes oferece um modelo que entra a fundo no conceito [Pets vs. Cattle](https://www.slideshare.net/gmccance/cern-data-centre-evolution/17). Isso pode causar uma certa desconfiança, pois o usuário não irá mais "dar um *ssh*" na máquina onde seu *container* está rodando (com o *fleet*, isso ainda acaba acontecendo bastante).

A passagem de conhecimento para outros times é importantíssima na implantação do Kubernetes. Ele possui diversos termos e conceitos próprios (Pods, Services, Deployments, etc) e leva um tempo para os usuários se acostumarem com os termos e entender o propósito de cada um deles. O uso do *resource* certo na hora certa é crucial para o bom uso da ferramenta e para o sucesso da migração.

A segurança também é uma parte importante no *design* do *cluster*. Isso depende dos requisitos do seu ambiente, mas é recomendado que o acesso ao *cluster* seja autenticado, ao menos. Alguns requisitos de segurança (i.e. bloquear comunicação entre *pods*) só podem ser cumpridos com [overlays de rede](https://kubernetes.io/docs/concepts/cluster-administration/networking/) que suportam tal funcionalidade (nós optamos [pelo Calico](https://docs.projectcalico.org/)).

## Conclusão

Enfim, nestes últimos parágrafos tentamos colocar os pontos que pegaram/estão pegando para nós. Muitos deles poderão afetar você também :).

Contudo, qualquer ferramenta de orquestração de *containers* traz com ela esse tipo de complexidade. Ter escolhido outra ferramenta não iria nos poupar destes pormenores.

Grandes responsabilidades implicam em grandes poderes, então depois que isso tudo é solucionado (mesmo que em partes), as vantagens tendem a ser enormes, sejam financeiras (com o melhor uso de recursos que a orquestração traz) ou técnicas e de produto (não é mais necessário pensar em infra, aumentando ainda mais a agilidade dos times).

Ufa! Obrigado por nos acompanhar até aqui! Pretendemos escrever mais posts sobre o assunto, entrando em maiores detalhes sobre a ferramenta e mostrando como implantamos e como estamos usando o Kubernetes aqui no Elo7 :).

Um abraço.

