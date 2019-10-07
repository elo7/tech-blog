---
date: 2019-10-07
category: big-data
tags:
  - big data
  - airflow
  - spark
  - kubernetes
authors: [gmcoringa]
layout: post
title: Agendando jobs Spark no k8s através do Airflow
description: Neste post iremos demonstrar como agendamos jobs Spark para serem executados no kubernetes através do Airflow.
---

[Apache Spark](https://spark.apache.org/) é uma ferramenta para processamento de dados em larga escala, já consolidada no mercado. O [Apache Airflow](https://airflow.apache.org/) é uma ferramenta para agendamento e monitoração de _workflows_, criado pelo [Airbnb](https://airbnb.io/), vem ganhando destaque nos ultimos anos. O [Kubernetes](https://kubernetes.io/) é uma ferramenta para orquestração de *containers* extremamente consolidada no mercado e com muitos recursos que facilitam a administração, diminuindo o _overhead_ operacional de se manter ambientes com *containers*.

## Como utilizamos o Apache Spark no Elo7

Atualmente utilizamos o [Apache Spark](https://spark.apache.org/) para realizar [ETL](https://pt.wikipedia.org/wiki/Extract,_transform,_load) de dados produzidos por aplicações. Os dados são consumidos do nosso [datalake](https://en.wikipedia.org/wiki/Data_lake) e utilizados em diversos casos, como por exemplo analises do time de Data Science.

Vale mencionar que possuímos apenas processos _batches_ utilizando [Apache Spark](https://spark.apache.org/).

Utilizamos duas plataformas para agendar estes processos, o [EMR](https://aws.amazon.com/pt/emr/) e o [Kubernetes](https://kubernetes.io/), e estamos movendo todos os processos que utilizam o [EMR](https://aws.amazon.com/pt/emr/) para o [Kubernetes](https://kubernetes.io/), com auxilio do [Apache Airflow](https://airflow.apache.org/). Para que este _post_ não fique muito longo deixarei os motivos referente aos motivos desta movimentação para um _post_ futuro.

## Como utilizamos o Apache Airflow

O [Apache Airflow](https://airflow.apache.org/) roda dentro do _cluster_ de [Kubernetes](https://kubernetes.io/), utilizamos o [Celery](http://www.celeryproject.org/) como _executor_ do airflow, estes _executors_ também rodam dentro do _cluster_ de [Kubernetes](https://kubernetes.io/).

Temos premissa não executar nenhum processamento pesado nestes _executors_, desta forma, o _workers_ do [Celery](http://www.celeryproject.org/) não ficam bloqueados. O que fazemos é a criação de pods no [Kubernetes](https://kubernetes.io/) através do [Kubernetes Operator](https://airflow.apache.org/kubernetes.html#kubernetes-operator). Uma alternativa seria o uso do [Kubernetes Executor](https://airflow.apache.org/kubernetes.html#kubernetes-executor) como _executor_ do [Apache Airflow](https://airflow.apache.org/), porém ainda não o testamos e também gostamos da liberdade de executar qualquer container através do [Kubernetes Operator](https://airflow.apache.org/kubernetes.html#kubernetes-operator).

## Agendando jobs Spark no Airflow

O [Apache Airflow](https://airflow.apache.org/) possuí o [Spark Subimit Operator](https://airflow.apache.org/_api/airflow/contrib/operators/spark_submit_operator/index.html), porém este requer a instalação do [Apache Spark](https://spark.apache.org/) no _container_ do [Apache Airflow](https://airflow.apache.org/). O _container_ que criamos do [Apache Airflow](https://airflow.apache.org/) possuí um tamanho de aproximadamente 767Mb, a instalação do [Apache Spark](https://spark.apache.org/) acrescentaria cerca de 1.5Gb, isto somente para conseguir utilizar o [Spark Subimit Operator](https://airflow.apache.org/_api/airflow/contrib/operators/spark_submit_operator/index.html).

Devido ao fatos acima mencionados optamos por utilizar o [Kubernetes Operator](https://airflow.apache.org/kubernetes.html#kubernetes-operator) para criar um _pod_ utilizando o _container_ do [Apache Spark](https://spark.apache.org/), o qual realiza o _submit_ do job spark, que é executado em modo _cluster_ (https://spark.apache.org/docs/latest/running-on-kubernetes.html#cluster-mode) e com a _flag_ `spark.kubernetes.submission.waitAppCompletion-false`. 

Porém para utilizar o [Kubernetes Operator](https://airflow.apache.org/kubernetes.html#kubernetes-operator) são necessárias algumas alteraçoes no _entrypoint_ do _container_ do [Apache Spark](https://spark.apache.org/):

```shell
function airflow-submit() {
	# disable randomized hash for string in Python 3.3+
	export PYTHONHASHSEED=0

	"${SPARK_HOME}"/bin/spark-class org.apache.spark.deploy.SparkSubmit "$@" 2>&1 | tee /tmp/out.log
	tac /tmp/out.log \
		| grep -m1 -B12 LoggingPodStatusWatcherImpl \
		| head -n12 \
		| sed 's/\t //g' \
		| awk -F": " '{gsub(" ", "_", $1); printf("\"%s\":\"%s\", ", $1, $2);}' \
		| awk '{printf("{%s}", substr($0, 1, length($0)-2));}' > /airflow/xcom/return.json
	echo "Gererated /airflow/xcom/return.json: $(cat /airflow/xcom/return.json)"
}
```

O trecho de código acima realiza o _submit_ de um _job_ [Apache Spark](https://spark.apache.org/), capptura a resposta deste _submit_, extraí o _json_ que o [Apache Spark](https://spark.apache.org/) gera como resposta e salva ele no arquivo `/airflow/xcom/return.json`. Isto é necessário devido o [Apache Airflow](https://airflow.apache.org/) experar que o retorno de um _operator_ seja escrito neste arquivo.

Além disso, criamos nosso próprio operator para realizar o _submit_ de _jobs_ [Apache Spark](https://spark.apache.org/), o qual captura o retorno do submit e o salva no _xcom_ da _task_. Isto é necessário para a monitoração do estado do _pod_, que será descrito a seguir.

Com estas alterações já é possível realizar submit de jobs [Apache Spark](https://spark.apache.org/), mas, o [Apache Airflow](https://airflow.apache.org/) possui um _bug_ na biblioteca que ele utiliza para comunicação com o [Kubernetes](https://kubernetes.io/), o qual não efetua o tratamento correto na captura do _stdout_ e/ou _stderr_.

Para correção do _bug_ copiamos todo o conteúdo do arquivo [pod_laucher.py](https://github.com/apache/airflow/blob/1.10.0/airflow/contrib/kubernetes/pod_launcher.py) alterando a função abaixo, e o incluímos como um novo arquivo, o qual é utilizado pelo nosso _operator_:

```python
    def _exec_pod_command(self, resp, command):
        if resp.is_open():
            self.log.info('Running command... %s\n', command)
            resp.write_stdin(command + '\n')
            executed = False
            while resp.is_open():
                resp.update(timeout=1)
                if resp.peek_stdout():
                    return resp.read_stdout()
                if resp.peek_stderr():
                    self.log.info(resp.read_stderr())
                    break
                else:
                    if executed:
                        self.log.info('Command executed, breaking loop')
                        break
                    executed = True
        return None
```

Com o nosso _operator_ e as alterações realizadas no _entrypoint_ do _container_ do [Apache Spark](https://spark.apache.org/) já conseguimos realizar o _submit_ de _jobs_ spark, porém ainda é necessário monitorar sua execução, para tal, criamos um [Sensor](https://airflow.apache.org/_api/index.html#basesensoroperator), o qual lê o json retornado pelo _submit_ para extrair o *pod_name* e verificar o _status_ deste _pod_ no [Kubernetes](https://kubernetes.io/).

## Conclusão

O [Apache Spark](https://spark.apache.org/) é uma excelente ferramenta e tem nos atendido bem. Para utilizar o [Apache Spark](https://spark.apache.org/) através do airflow dentro da nossa infra-estrutura de [Kubernetes](https://kubernetes.io/) foram necessárias algumas alterações:
- A criação de um _operator_ para efetuar o _submit_ de _jobs_ [Apache Spark](https://spark.apache.org/) através da criação de um _pod_
- A correção do _bug_ no tratamento das saídas de um _pod_
- A criação de um _sensor_ para monitorar o estado em que um _pod_ se encontra

Para estas alterações são necessários bons conhecimentos do funcionamento do [Apache Spark](https://spark.apache.org/) e [Apache Airflow](https://airflow.apache.org/).
