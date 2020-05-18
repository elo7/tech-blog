---
date: 2020-05-18
category: devops
layout: post
title: Subindo uma aplicação no Kubernetes usando o Helm
description: Helm é um poderoso gerenciador de pacotes para Kubernetes. Venha aprender a criar uma aplicação baseada nele!
authors: [rodrigovedovato]
tags:
  - kubernetes
  - helm
  - containers
  - devops
  - continuous-delivery
cover: kubernetes-logo.png

---

Talvez o Kubernetes seja, hoje, um dos nomes mais famosos do mercado quando falamos em DevOps, e não é para menos. A plataforma é um grande facilitador quando se trata de gerenciar a infraestrutura de aplicações, tornando muito mais fáceis tarefas como escalar as instâncias, automatizar o deployment e até mesmo gerenciar o ciclo de vida das aplicações baseadas em Docker.

Apesar de todos os benefícios, ainda há algumas coisas trabalhosas no dia a dia de quem trabalha com Kubernetes. Todos os recursos criados no Kubernetes são baseados em arquivos yaml, Talvez o Kubernetes seja, hoje, um dos nomes mais famosos do mercado quando falamos em DevOps, e não é para menos. A plataforma é um grande facilitador quando se trata de gerenciar a infraestrutura de aplicações, tornando muito mais fáceis tarefas como escalar as instâncias, automatizar o deployment e até mesmo gerenciar o ciclo de vida das aplicações baseadas em Docker.

Apesar de todos os benefícios, ainda há algumas coisas trabalhosas no dia a dia de quem trabalha com Kubernetes. Todos os recursos criados no Kubernetes são baseados em arquivos yaml, então como garantir que todos os arquivos necessários para rodar uma mesma versão da sua aplicação estejam sincronizados caso haja a necessidade de, por exemplo, um rollback? Como saber todos os recursos que foram criados para uma mesma aplicação caso seja necessário removê-la? Como ter exatamente o mesmo arquivo tanto para deployments de desenvolvimento quanto de produção, e mudar somente os valores que variam entre um e outro?

E é exatamente nesse procedimento de gerenciamento de pacotes das nossas aplicações que o Helm brilha. A ideia deste post é demonstrar como subir uma aplicação simples usando o helm, e demonstrar algumas funcionalidades deste gerenciados de pacotes para Kubernetes. Prontos?

### A nossa aplicação

Para manter tudo bem simples, iremos subir uma aplicação sem muitos recursos: um contâiner do Nginx que irá expor um endpoint na porta 80

### Preparando o ambiente
Em um cenário real, estaríamos utilizando um cluster de Kubernetes em alguma nuvem - possivelmente o [Amazon EKS]([https://aws.amazon.com/pt/eks/](https://aws.amazon.com/pt/eks/)) ou o [Google Kubernetes Engine]([https://cloud.google.com/kubernetes-engine?hl=pt-br](https://cloud.google.com/kubernetes-engine?hl=pt-br)) - mas como o foco deste tutorial está em criar nossa aplicação usando Helm, iremos utilizar o [Minikube]([https://kubernetes.io/docs/tasks/tools/install-minikube/](https://kubernetes.io/docs/tasks/tools/install-minikube/)), que é uma maneira prática de rodar localmente um cluster de Kubernetes completamente funcional. 

Como estou usando o Linux, é possível subir o Minikube usando o próprio Docker para subir as imagens necessárias para o funcionamento usando o comando `minikube start --driver=docker`. Uma vez executado, é possível rodar o comando `kubectl get pods` para nos certificarmos de que o cluster local foi criado com sucesso.

Até a versão 2 do Helm, era necessário subir um componente chamado _Tiller_ no cluster de Kubernetes onde iríamos instalar os nossos _helm charts_. A partir da versão 3, no entanto, ele já funciona como um componente _standalone_, sendo necessário somente executá-lo localmente. No nosso caso, iremos utilizar uma imagem docker que já contém o executável do helm, então basta executar o comando `docker run -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.minikube:/root/.minikube --entrypoint=sh alpine/helm` dentro da pasta de sua preferência. Execute o comando `helm list` para verificar se o helm está sendo executado com sucesso

 :warning: Caso ocorra o erro `invalid configuration: unable to read client-cert` ao executar o comando `helm list`, pode ser necessário alterar o arquivo `~/.kube/config` para apontar os arquivos de certificado do Kubernetes para um _path_ relativo. Exemplo:

#### Antes
```yaml
- name: minikube
  user:
    client-certificate: /home/rodrigo/.minikube/profiles/minikube/client.crt
    client-key: /home/rodrigo/.minikube/profiles/minikube/client.key
```
#### Depois
```yaml
- name: minikube
  user:
    client-certificate: ../.minikube/profiles/minikube/client.crt
    client-key: ../.minikube/profiles/minikube/client.key
```

 :warning: Caso isso ainda não dê certo, é possível instalar o helm localmente.

### Criando nosso Helm Chart
O Helm estrutura nossa aplicações em _releases_. Em um ambiente de produção onde hajam vários releases já criados, o comando de listagem deve retornar algo do gênero (modifiquei o formato para facilitar a leitura):

```
NAME: hello-helm
NAMESPACE: default
REVISION: 3
UPDATED: 2020-04-16 18:03:33.648387866 +0000 UTC
STATUS: deployed
CHART: hello-helm-0.1.0
APP VERSION: 0.0.11
```
Cada um desses releases é definido a partir de um conjunto de pastas e arquivos que o helm chama de  _charts_. Este conjunto de pastas  e arquivos tem um estrutura previamente definida, que é a seguinte:

```
├── hello_helm
│   ├── Chart.yaml
│   ├── templates
│     ├── deployment.yaml
│   ├── values.yaml
```
Vamos começar pelo principal: o arquivo Chart.yaml. O conteúdo dele é o seguinte:
```yaml
apiVersion: v2
name: hello-helm
description: Meu primeiro Helm chart!

type: application
version: 0.1.0
appVersion: 0.0.0
```
Este arquivo define, basicamente, três coisas: qual será o nome do chart, a versão dele e a versão da aplicação, que é opcional. Aqui no Elo7, optamos por deixar o `appVersion` obrigatório e o utilizamos para informar qual a versão da aplicação que está rodando. Desta forma, sempre que algum desenvolvedor der um `helm list`, será possível ver a qual versão da aplicação está associado um determinado release, deixando as operações de rollback muito mais simples.

Em seguida, temos a pasta templates. Dentro dela, devemos colocar todos os arquivo que definem os recursos que iremos utilizar na nossa aplicação. No nosso caso, iremos criar um arquivo chamado `deployment.yaml`, que irá definir um recurso do tipo `Deployment` no Kubernetes

```yaml
# deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: {{ .Values.replicas }}
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:{{ .Chart.AppVersion }}
        ports:
        - containerPort: 80
```
Mas o que são esses valores entre `{{ }}`? Lembra que dissemos lá começo que gostaríamos de ter a capacidade de ter o mesmo arquivo para servir diferentes ambientes? O Helm, além de ser um gerenciador de pacotes, possui um poderoso motor de templates baseado na linguagem de template do Go, e esses símbolos são os _placeholders_ que definimos para dizer que, naquele determinado ponto do arquivo, iremos utilizar um valor externo. No caso do nosso deployment, essa informação vem de dois lugares diferentes: da propriedade appVersion no arquivo `Chart.yaml` que criamos mais cedo, e do arquivo `values.yaml`.

Este arquivo não possui nenhum formato pré-estabelecido e pode ter qualquer nome. Ele é simplesmente um yaml onde colocamos todas as variáveis utilizadas no nosso template. Como a única propriedade que iremos colocar por enquanto é quantidade de réplicas que nossa aplicação irá ter, nosso arquivo fica assim:

```yaml
replicas: 2
```
Pronto! Acabamos de criar o nosso chart! Simples, né? Vamos ver como fazemos para instalar?

### Instalando seu chart
A instalação do chart pode ser feita de diversas formas. Aqui, iremos realizá-la em dois passos:

1) Gerar um pacote contendo todos os arquivos
2) Instalar o pacote no cluster

#### Passo 1 - Gerando o pacote

Um pacote do helm é nada mais nada menos que um arquivo `.tar.gz` contendo todos os arquivos que fizemos anteriormente. Para gerá-lo, precisamos executar o seguinte comando:

```bash
helm package hello_helm --app-version 1.17.10
```
Isso irá gerar um arquivo local chamado `hello-helm-0.1.0.tar.gz`. Perceba que colocamos o número da versão da aplicação já nesta parte do processo. Mas por que isso acontece? Há uma limitação no helm que não permite a passagem do parâmetro da versão na hora da instalação da aplicação, então é necessário gerar o pacote já com a versão que queremos instalar.
### Passo 2 - Instalando o pacote
Uma vez que já geramos o pacote de instalação localmente, chegou a hora de instalá-lo no servidor. A instalação é tão simples quanto a geração do pacote, bastando executar o seguinte comando

```bash
helm upgrade hello-helm hello-helm-0.1.0.tar.gz --values values.yaml --install
```
Este comando diz para o helm criar um release chamado `hello-helm`, que irá conter os arquivos do pacote `hello-helm-0.1.0.tar.gz` e irá se basear nos valores do arquivo `values.yaml`. A opção `--install` diz para o helm que, caso não haja um release com este nome, ele deve realizar a instalação. 

Neste comando também é possível passar valores dinâmicos que não tenham sido colocados no arquivo passado na opção `--values`. Isso é feito passando a opção `--set` no mesmo comando. Exemplo: `--set replicas=3`

Se executarmos o comando `kubectl get pods` para listar os pods no nosso cluster, os dois pods rodando o contâiner do nginx devem estar rodando com sucesso!

```
$ kubectl get pods

NAME                               READY   STATUS              RESTARTS   AGE
nginx-deployment-cc5db57d4-6dttc   0/1     ContainerCreating   0          15s
nginx-deployment-cc5db57d4-zlg4v   0/1     ContainerCreating   0          15s
```

### Fase bônus

#### Rollback
Vamos supor que uma nova versão do nginx tenha saído, e nós queremos fazer o upgrade. Ok, usando o que aprendemos, é só rodar:

```bash
helm package hello-helm --app-version 1.18
helm upgrade hello-helm hello-helm-0.1.0.tar.gz --values values.yaml --install
```
Atualização feita com sucesso! Mas e se começarmos a ter erros com essa nova versão? Com o helm, fica muito fácil resolver este problema. Se executarmos o comando `helm history hello-helm`, conseguimos ver um histórico de todas as versões que foram instaladas naquele cluster

```
REVISION	UPDATED                 	STATUS    	CHART           	APP VERSION	DESCRIPTION
1       	Mon May 18 18:05:00 2020	superseded	hello-helm-0.1.0	1.17.10    	Install complete
2       	Mon May 18 18:10:40 2020	deployed  	hello-helm-0.1.0	1.18       	Upgrade complete
```
Vendo todas as versões que foram previamente instaladas, é possível saber para qual versão queremos voltar e podemos executar o comando `helm rollback` para voltar para uma determinada revisão

```bash
helm rollback hello-helm 1
```
Pronto! Nosso histórico agora está assim:

```
REVISION	UPDATED                 	STATUS    	CHART           	APP VERSION	DESCRIPTION     
1       	Mon May 18 18:05:00 2020	superseded	hello-helm-0.1.0	1.17.10    	Install complete
2       	Mon May 18 18:10:40 2020	superseded	hello-helm-0.1.0	1.18       	Upgrade complete
3       	Mon May 18 18:13:34 2020	deployed  	hello-helm-0.1.0	1.17.10    	Rollback to 1   
```
#### Deletando seu release
Esse é bem simples: para remover um release e todos os arquivos associados a ele, basta executar o comando `helm delete [release]`, onde `[release]` é o nome que colocamos ao executar o `helm upgrade`

#### Description
Perceberam como, ao ver o histório das versões, temos um descritivo automatizado do que foi realizado naquela versão? Bem, isso também pode ser customizado! Ao gerar o pacote, basta passar a opção `--description`!

Happy Helming!então como garantir que todos os arquivos necessários para rodar uma mesma versão da sua aplicação estejam sincronizados caso haja a necessidade de, por exemplo, um rollback? Como saber todos os recursos que foram criados para uma mesma aplicação caso seja necessário removê-la? Como ter exatamente o mesmo arquivo tanto para deployments de desenvolvimento quanto de produção, e mudar somente os valores que variam entre um e outro?

E é exatamente nesse procedimento de gerenciamento de pacotes das nossas aplicações que o Helm brilha. A ideia deste post é demonstrar como subir uma aplicação simples usando o helm, e demonstrar algumas funcionalidades deste gerenciados de pacotes para Kubernetes. Prontos?

### A nossa aplicação

Para manter tudo bem simples, iremos subir uma aplicação sem muitos recursos: um contâiner do Nginx que irá expor um endpoint na porta 80

### Preparando o ambiente
Em um cenário real, estaríamos utilizando um cluster de Kubernetes em alguma nuvem - possivelmente o [Amazon EKS]([https://aws.amazon.com/pt/eks/](https://aws.amazon.com/pt/eks/)) ou o [Google Kubernetes Engine]([https://cloud.google.com/kubernetes-engine?hl=pt-br](https://cloud.google.com/kubernetes-engine?hl=pt-br)) - mas como o foco deste tutorial está em criar nossa aplicação usando Helm, iremos utilizar o [Minikube]([https://kubernetes.io/docs/tasks/tools/install-minikube/](https://kubernetes.io/docs/tasks/tools/install-minikube/)), que é uma maneira prática de rodar localmente um cluster de Kubernetes completamente funcional. 

Como estou usando o Linux, é possível subir o Minikube usando o próprio Docker para subir as imagens necessárias para o funcionamento usando o comando `minikube start --driver=docker`. Uma vez executado, é possível rodar o comando `kubectl get pods` para nos certificarmos de que o cluster local foi criado com sucesso.

Até a versão 2 do Helm, era necessário subir um componente chamado _Tiller_ no cluster de Kubernetes onde iríamos instalar os nossos _helm charts_. A partir da versão 3, no entanto, ele já funciona como um componente _standalone_, sendo necessário somente executá-lo localmente. No nosso caso, iremos utilizar uma imagem docker que já contém o executável do helm, então basta executar o comando `docker run -ti --rm -v $(pwd):/apps -v ~/.kube:/root/.kube -v ~/.helm:/root/.helm -v ~/.minikube:/root/.minikube --entrypoint=sh alpine/helm` dentro da pasta de sua preferência. Execute o comando `helm list` para verificar se o helm está sendo executado com sucesso

 :warning: Caso ocorra o erro `invalid configuration: unable to read client-cert` ao executar o comando `helm list`, pode ser necessário alterar o arquivo `~/.kube/config` para apontar os arquivos de certificado do Kubernetes para um _path_ relativo. Exemplo:

#### Antes
```yaml
- name: minikube
  user:
    client-certificate: /home/rodrigo/.minikube/profiles/minikube/client.crt
    client-key: /home/rodrigo/.minikube/profiles/minikube/client.key
```
#### Depois
```yaml
- name: minikube
  user:
    client-certificate: ../.minikube/profiles/minikube/client.crt
    client-key: ../.minikube/profiles/minikube/client.key
```

 :warning: Caso isso ainda não dê certo, é possível instalar o helm localmente.

### Criando nosso Helm Chart
O Helm estrutura nossa aplicações em _releases_. Em um ambiente de produção onde hajam vários releases já criados, o comando de listagem deve retornar algo do gênero (modifiquei o formato para facilitar a leitura):

```
NAME: hello-helm
NAMESPACE: default
REVISION: 3
UPDATED: 2020-04-16 18:03:33.648387866 +0000 UTC
STATUS: deployed
CHART: hello-helm-0.1.0
APP VERSION: 0.0.11
```
Cada um desses releases é definido a partir de um conjunto de pastas e arquivos que o helm chama de  _charts_. Este conjunto de pastas  e arquivos tem um estrutura previamente definida, que é a seguinte:

```
├── hello_helm
│   ├── Chart.yaml
│   ├── templates
│     ├── deployment.yaml
│   ├── values.yaml
```
Vamos começar pelo principal: o arquivo Chart.yaml. O conteúdo dele é o seguinte:
```yaml
apiVersion: v2
name: hello-helm
description: Meu primeiro Helm chart!

type: application
version: 0.1.0
appVersion: 0.0.0
```
Este arquivo define, basicamente, três coisas: qual será o nome do chart, a versão dele e a versão da aplicação, que é opcional. Aqui no Elo7, optamos por deixar o `appVersion` obrigatório e o utilizamos para informar qual a versão da aplicação que está rodando. Desta forma, sempre que algum desenvolvedor der um `helm list`, será possível ver a qual versão da aplicação está associado um determinado release, deixando as operações de rollback muito mais simples.

Em seguida, temos a pasta templates. Dentro dela, devemos colocar todos os arquivo que definem os recursos que iremos utilizar na nossa aplicação. No nosso caso, iremos criar um arquivo chamado `deployment.yaml`, que irá definir um recurso do tipo `Deployment` no Kubernetes

```yaml
# deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: {{ .Values.replicas }}
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:{{ .Chart.AppVersion }}
        ports:
        - containerPort: 80
```
Mas o que são esses valores entre `{{ }}`? Lembra que dissemos lá começo que gostaríamos de ter a capacidade de ter o mesmo arquivo para servir diferentes ambientes? O Helm, além de ser um gerenciador de pacotes, possui um poderoso motor de templates baseado na linguagem de template do Go, e esses símbolos são os _placeholders_ que definimos para dizer que, naquele determinado ponto do arquivo, iremos utilizar um valor externo. No caso do nosso deployment, essa informação vem de dois lugares diferentes: da propriedade appVersion no arquivo `Chart.yaml` que criamos mais cedo, e do arquivo `values.yaml`.

Este arquivo não possui nenhum formato pré-estabelecido e pode ter qualquer nome. Ele é simplesmente um yaml onde colocamos todas as variáveis utilizadas no nosso template. Como a única propriedade que iremos colocar por enquanto é quantidade de réplicas que nossa aplicação irá ter, nosso arquivo fica assim:

```yaml
replicas: 2
```
Pronto! Acabamos de criar o nosso chart! Simples, né? Vamos ver como fazemos para instalar?

### Instalando seu chart
A instalação do chart pode ser feita de diversas formas. Aqui, iremos realizá-la em dois passos:

1) Gerar um pacote contendo todos os arquivos
2) Instalar o pacote no cluster

#### Passo 1 - Gerando o pacote

Um pacote do helm é nada mais nada menos que um arquivo `.tar.gz` contendo todos os arquivos que fizemos anteriormente. Para gerá-lo, precisamos executar o seguinte comando:

```bash
helm package hello_helm --app-version 1.17.10
```
Isso irá gerar um arquivo local chamado `hello-helm-0.1.0.tar.gz`. Perceba que colocamos o número da versão da aplicação já nesta parte do processo. Mas por que isso acontece? Há uma limitação no helm que não permite a passagem do parâmetro da versão na hora da instalação da aplicação, então é necessário gerar o pacote já com a versão que queremos instalar.
### Passo 2 - Instalando o pacote
Uma vez que já geramos o pacote de instalação localmente, chegou a hora de instalá-lo no servidor. A instalação é tão simples quanto a geração do pacote, bastando executar o seguinte comando

```bash
helm upgrade hello-helm hello-helm-0.1.0.tar.gz --values values.yaml --install
```
Este comando diz para o helm criar um release chamado `hello-helm`, que irá conter os arquivos do pacote `hello-helm-0.1.0.tar.gz` e irá se basear nos valores do arquivo `values.yaml`. A opção `--install` diz para o helm que, caso não haja um release com este nome, ele deve realizar a instalação. 

Neste comando também é possível passar valores dinâmicos que não tenham sido colocados no arquivo passado na opção `--values`. Isso é feito passando a opção `--set` no mesmo comando. Exemplo: `--set replicas=3`

Se executarmos o comando `kubectl get pods` para listar os pods no nosso cluster, os dois pods rodando o contâiner do nginx devem estar rodando com sucesso!

```
$ kubectl get pods

NAME                               READY   STATUS              RESTARTS   AGE
nginx-deployment-cc5db57d4-6dttc   0/1     ContainerCreating   0          15s
nginx-deployment-cc5db57d4-zlg4v   0/1     ContainerCreating   0          15s
```

### Fase bônus

#### Rollback
Vamos supor que uma nova versão do nginx tenha saído, e nós queremos fazer o upgrade. Ok, usando o que aprendemos, é só rodar:

```bash
helm package hello-helm --app-version 1.18
helm upgrade hello-helm hello-helm-0.1.0.tar.gz --values values.yaml --install
```
Atualização feita com sucesso! Mas e se começarmos a ter erros com essa nova versão? Com o helm, fica muito fácil resolver este problema. Se executarmos o comando `helm history hello-helm`, conseguimos ver um histórico de todas as versões que foram instaladas naquele cluster

```
REVISION	UPDATED                 	STATUS    	CHART           	APP VERSION	DESCRIPTION
1       	Mon May 18 18:05:00 2020	superseded	hello-helm-0.1.0	1.17.10    	Install complete
2       	Mon May 18 18:10:40 2020	deployed  	hello-helm-0.1.0	1.18       	Upgrade complete
```
Vendo todas as versões que foram previamente instaladas, é possível saber para qual versão queremos voltar e podemos executar o comando `helm rollback` para voltar para uma determinada revisão

```bash
helm rollback hello-helm 1
```
Pronto! Nosso histórico agora está assim:

```
REVISION	UPDATED                 	STATUS    	CHART           	APP VERSION	DESCRIPTION     
1       	Mon May 18 18:05:00 2020	superseded	hello-helm-0.1.0	1.17.10    	Install complete
2       	Mon May 18 18:10:40 2020	superseded	hello-helm-0.1.0	1.18       	Upgrade complete
3       	Mon May 18 18:13:34 2020	deployed  	hello-helm-0.1.0	1.17.10    	Rollback to 1   
```
#### Deletando seu release
Esse é bem simples: para remover um release e todos os arquivos associados a ele, basta executar o comando `helm delete [release]`, onde `[release]` é o nome que colocamos ao executar o `helm upgrade`

#### Description
Perceberam como, ao ver o histório das versões, temos um descritivo automatizado do que foi realizado naquela versão? Bem, isso também pode ser customizado! Ao gerar o pacote, basta passar a opção `--description`!

Happy Helming!