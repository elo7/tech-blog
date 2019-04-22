---
title: Nightfall - Injetando dependências no Spark (Parte 1)
date: 2017-05-29
category: big-data
layout: post
description: Conheça o Nightfall, um projeto criado pela Engenharia do Elo7 para simplificar a criação de streams e batches no Spark, fornecendo injeção de dependências, configuração e facilidades na criação de tasks.
authors: [gadsc]
tags:
  - spark
  - big data
  - dependency injection
  - java
  - kafka
---

## O início
Começamos a utilizar o [Spark](http://spark.apache.org/) no **Elo7** para processar métricas em tempo real, enviando eventos assíncronos do nosso site para serem consumidos em um sistema de agregação. Essa foi uma forma de remover o acoplamento entre as métricas e o negócio.

### Mas o que é Spark?
[Spark](http://spark.apache.org/) é uma plataforma para computação distribuída, que extende o modelo de MapReduce. É uma ferramenta de propósito geral e projetada para alta performance, incluindo queries iterativas e processamento em batch e streaming.

### Por que Spark?
Precisávamos de uma ferramenta para análise em tempo real, e tínhamos preferência por opções com recursos de machine learning (que pensamos em utilizar futuramente). Optamos pelo Spark, que além de atender esses requisitos, possui integração nativa com o [Apache Kafka](https://kafka.apache.org/) e o [Amazon Kinesis](https://aws.amazon.com/kinesis/), que eram ferramentas cogitadas para Streams de mensagem.

!["Exemplo de arquitetura"](../images/nightfall-1.png)

Após a produção dos eventos, precisamos criar os consumidores para processá-los, que são nossos *jobs* do _Spark_. Nossos *jobs* possuem várias *tasks* onde cada uma processa um tipo de evento de uma forma específica. O nosso código no início do desenvolvimento dos *jobs* era parecido com:
- Job
```java
public class SparkJobExample {

    public static void main(String[] args) {
    	MyJobConfiguration config = new MyJobConfiguration(args);
        JavaStreamingContext context = null;

        try {
            if (config.getSparkCheckpoint().isPresent()) {
                context = JavaStreamingContext.getOrCreate(
                        config.getSparkCheckpoint().get(),
                        (Function0<JavaStreamingContext>) () -> MyJob.createContext(config));
            } else {
                context = MyJob.createContext(config);
            }
            context.start();
            context.awaitTermination();
        } catch (Exception e) {
            throw e;
        } finally {
            if(context != null) {
                context.stop(true, true);
            }
        }
    }

    [...]
```
Para mais detalhes veja [aqui](https://github.com/gadsc/spark-samples/blob/master/jobs/spark/src/main/java/com/gadsc/spark/SparkJobExample.java)

Dessa forma, tínhamos uma injeção de dependência para as configurações do banco e do job. Caso precisássemos fazer injeção em outras classes seria necessário fazer algo assim:
```java
    @SuppressWarnings("unchecked")
    private static JavaStreamingContext createContext(MyJobConfiguration config) {
        [...]
        MyFilter myFilter = new MyFilter(config);

        Arrays.asList(
                new MyTask(config),
                new OtherTask(config, myFilter)
        ).stream().forEach(processor -> processor.process(stream));

        checkpoint.ifPresent(context::checkpoint);

        return context;
    }
}
```

Ou seja, para cada nova classe que nossa _task_ (a classe que efetivamente executa o processamento dos eventos) utilize, precisamos instanciá-la no *Job*. Um pouco ruim não acham?

## Simplificando as coisas
Para **resolver** nosso problema, criamos um projeto chamado **Nightfall**, que utiliza o [Netflix Governator](https://github.com/Netflix/governator/wiki) e o [Google Guava](https://github.com/google/guava/wiki) para prover o contexto do **Spark**, injeção de dependência e configuração. Com o **Nightfall**, simplificamos o código dos nossos novos jobs, utilizando inversão de controle e injeção de dependências. Um exemplo do código:
```java
@KafkaSimple
public class KafkaSimpleTest {

    public static void main(String[] args) {
        NightfallApplication.run(KafkaSimpleTest.class, args);
    }
}
```
Muito mais simples, não? O código acima provê um *job* **SparkStream** que utiliza o *Simple API* do _Kafka_.

## Criando um Stream
Agora que já sabemos o que nos motivou a criar o **Nightfall**, vejamos como utilizá-lo para facilitar nossa vida :D

Digamos que temos um produtor de evento que envia um payload como o json abaixo:
```json
{
	"type": "OrderStarted",
	"date": "2016-11-07T14:22:08.592-03:00",
	"payload": {
		"orderCreatedAt": "2016-11-02T18:00:50.798-03:00",
		"orderId": 1,
		"deviceFamily": "DESKTOP",
		"sellerName": "Vendedor 1",
		"buyerId": 3,
		"sellerId": 3,
		"products": [{
			"itemId": 1,
			"quantity": 3,
			"price": 500.00,
			"itemTitle": "Product 1"
		}],
		"access": "WEB_BROWSER",
		"totalPrice": 1500.00,
		"browser": "CHROME"
	}
}
```

Abaixo, o código para consumir esse evento como um *Stream*:
```java
@KafkaSimple
public class OrderJob {

    public static void main(String[] args) {
        NightfallApplication.run(OrderJob.class, args);
    }
}

```
Após a criação do nosso *job*, precisamos criar a *task* para processar a mensagem. Nossa task é uma classe Java simples, anotada com [@Task](https://github.com/elo7/nightfall/wiki/how-to-use#dependency-injection-on-spark-jobs) (anotação fornecida pelo NightFall). Ao inicializar o NightfallApplication, é realizado um *classpath scan* para encontrar todas as classes que contem essa anotação.
Utilizarei a implementação que usa *DataPoint* (*DataPoint é um contrato criado para padronizar a estrutura das mensagens, representando o evento a ser processado, possuindo uma **data**, **tipo** e um **payload***):

```java
@Task
public class HelloWorldTask implements StreamTaskProcessor<DataPoint<String>> {
	private static final String ORDER_STARTED = "OrderStarted";

	@Override
	public void process(JavaDStream<DataPoint<String>> dataPointsStream) {
		dataPointsStream
				.filter(dataPoint -> DataPointValidator.isValidForType(dataPoint, ORDER_STARTED))
				.foreachRDD(rdd -> {
					if (!rdd.isEmpty()) {
						rdd.foreachPartition(partition -> partition.forEachRemaining(this::log));
					}
				});
	}

}
```
Esse é um exemplo de *task* que processaria apenas os eventos do tipo *OrderStarted*.

Já sabemos porque o NightFall foi criado e como ele funciona, então vejamos mais alguns exemplos. Primeiramente veremos um exemplo de *Stream*.

- Siga as intruções do [Quick Start Kafka](https://kafka.apache.org/082/documentation.html#quickstart) para:
  1. Instalação e startup. **OBS**: utilizar a versão 0.8.2 do _Kafka_.
  2. Crie um tópico no Kafka.
  3. Enviar mensagens para o tópico criado.

Uma vez que temos um tópico, podemos criar um stream para consumir as mensagens. Para isso, podemos utilizar o próprio projeto do **Nightfall** para adicionar a task que criamos acima, adicionando-a no sub-módulo *examples* do **Nightfall**.
Além de adicionar o *job* e a *task*, precisaremos configurar o arquivo `nightfall.properties`:
```bash
# Kafka Consumer
kafka.brokers=localhost:9092
kafka.topics=${NOME_DO_TÓPICO_CRIADO}

# Kafka Offset
kafka.offset.persistent=false
kafka.cassandra.hosts=cassandra
kafka.cassandra.keyspace=kafka
kafka.cassandra.auto.migration=false
kafka.cassandra.user=
kafka.cassandra.password=
kafka.cassandra.datacenter=

# Stream Configurations
stream.batch.interval.ms=20000
stream.provider.converter=com.elo7.nightfall.di.providers.spark.stream.DataPointStreamContextConverter
stream.checkpoint.directory=/Users/developer/dev/tmp/examples/HelloWorldJob

# Monitoring config
reporter.statsd.host=localhost
reporter.statsd.port=8125
reporter.statsd.prefix=dev.spark
reporter.enabled=false
reporter.class=com.elo7.nightfall.di.providers.reporter.jmx.JMXReporterFactory
```

Após a configuração do arquivo localizado em `examples/src/main/resources` podemos executar o *job* através do comando:
```bash
./gradlew 'jobs/example':run -PmainClass="${JOB_PACKAGE}.OrderJob"
```
Após o *job* ser iniciado podemos enviar um evento do tipo **OrderStarted** (como no exemplo mais acima). Será impresso o *json* nos logs; caso enviemos um outro tipo de evento, ele não será exibido.

## Criando um Batch
Agora podemos criar nosso *job*, *task* e configurações para processar em *Batch* ao invés de *Stream*. Para isso, precisaremos criar o seguinte job:
```java
@FileRDD
public class BatchOrderJob {

    public static void main(String[] args) {
        NightfallApplication.run(OrderJob.class, args);
    }
}

```
Precisamos criar a task também:
```java
@Task
public class BatchHelloWorldTask implements BatchTaskProcessor<DataPoint<String>> {
	private static final String ORDER_STARTED = "OrderStarted";

	@Override
	public void process(JavaRDD<DataPoint<String>> dataPointsStream) {
		dataPointsStream
				.filter(dataPoint -> DataPointValidator.isValidForType(dataPoint, ORDER_STARTED))
				.foreachPartition(
					rdd.foreachPartition(partition -> partition.forEachRemaining(this::log))
				);
	}

}
```
Não podemos esquecer de criar as seguintes configurações:
```bash
# Batch Configuration
# File Configuration
file.s3.access.key=
file.s3.secret.key=
file.source=/tmp/nightfall

# Batch
batch.history.enabled=false

# Batch - Job History
batch.cassandra.hosts=cassandrar
batch.cassandra.port=9042
batch.cassandra.user=
batch.cassandra.password=
batch.cassandra.keyspace=kafka
batch.cassandra.datacenter=
batch.history.ttl.days=7
```
Como passamos na configuração `file.source` um arquivo local, precisaremos criar o arquivo compactado contendo os eventos que serão processados pelo *Batch*. O arquivo que vamos utilizar é um txt (zipado) com os eventos, localizado no caminho especificado.
Para executar o *Batch* executamos o seguinte comando:
```bash
./gradlew 'jobs/example':run -PmainClass="${JOB_PACKAGE}.BatchOrderJob"
```
Podemos ver a impressão dos eventos que são do tipo *OrderStarted* no log da aplicação :)

### É hora da revisão
Nesse post vimos o que nos motivou a criar o *Nightfall*, as configurações básicas para conseguir criar um *Stream* e um *Batch*. [Aqui](https://github.com/gadsc/spark-samples) vocês podem acessar o repositório contendo todos os códigos mostrados nesse post ;D
Por hoje é só, pessoal, mas iremos fazer uma série de posts para explicar mais usos do *Nigthfall*. Gostou? Se tiver algo para acrescentar/sugerir/dúvida, deixe nos comentários e aguardem os próximos posts.
