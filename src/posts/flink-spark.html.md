---
date: 2017-06-27
category: back-end
tags:
  - spark
  - flink
  - big data
authors: [mikedias,gmcoringa]
layout: post
title: Flink vs Spark
description: O título do post é polêmico para chamar sua atenção, mas a ideia deste post é mostrar a nossa visão sobre essas duas excelentes ferramentas: Apache Flink e Apache Spark.
---

O título do post é polêmico para chamar sua atenção, mas a ideia deste post é mostrar a nossa visão sobre essas duas excelentes ferramentas: [Apache Flink](http://flink.apache.org/) e [Apache Spark](http://spark.apache.org/). Nós não entraremos em detalhes profundos de cada ferramenta, nem faremos qualquer tipo de benchmark. Nós vamos apenas apontar as características que são relevantes para o nosso dia-a-dia.
Se você não conhece o [Flink](http://flink.apache.org/) nem o [Spark](http://spark.apache.org/), na homepage dos projetos tem uma introdução bacana sobre cada um deles.

## Flink

O Flink é um projeto que nasceu com a mentalidade **streaming-first**, isto é,
o objetivo principal da plataforma é processar dados que são produzidos de maneira contínua e infinita:

![Flink Stream](../images/flink-spark-1.png)

Essa arquitetura permite que o job que processa o *stream* seja mais rápido e resiliente. Tal velocidade é atingida porque os eventos são processados assim que eles chegam.

## Spark

Já o Spark possui uma mentalidade **batch-first**. Isso acontece porque o projeto foi criado com o propósito de ser mais rápido e eficiente do que o Hadoop, principal técnica de processamento na época. Influenciado por essa mentalidade, o Spark Streaming foi criado para resolver o problema de fluxos contínuos utilizando **microbatches**, aproveitando a implementação fundamental de batches do Spark (os famosos RDDs):
![Spark Microbatches](../images/flink-spark-2.png)

Para nós isso não faz muita diferença, afinal, os dados serão processados de maneira semelhante.

### Back Pressure

Os eventuais picos de eventos, também conhecidos como *back pressure*, podem impactar o processamento de seus *streams*. O Flink os gerencia de forma automática devido a forma a qual foi projetado, na qual os dados são processados assim que chegam. No Spark há a necessidade de configurá-lo para lidar com tais situações corretamente, o que varia de acordo com a sua fonte de dados. Isto ocorre em situações onde picos de eventos são gerados, devido o Spark processá-los em intervalos nos quais você os configurou (*micro-batches*).
No nosso caso utilizamos o [Kafka Direct Aproach](https://spark.apache.org/docs/latest/streaming-kafka-0-8-integration.html#approach-2-direct-approach-no-receivers) que, para conseguir lidar com *back pressures*, precisa das seguintes *flags* habilitadas:
* ``spark.streaming.backpressure.enabled=true``
* ``spark.streamng.kafka.maxRatePerPartition``

Para limitar o número de eventos processados em um *micro-batch* utilizamos a *flag* ``spark.streamng.kafka.maxRatePerPartition``. Já a *flag* ``spark.streaming.backpressure.enabled=true`` faz com que o Spark analise os tempos de processamentos de *micro-batches* anteriores para se adaptar a flutuações em micro-batches subsequentes, eventualmente alterando o valor da flag ``spark.streamng.kafka.maxRatePerPartition``.

Podemos concluir então, que, para lidar com *back-pressures* o Flink é muito mais simples e o Spark exige que o usuário possua pelos menos um conhecimento intermediário para assim, configurá-lo da melhor maneira.

### APIs

O Flink utiliza as mesmas APIs para seus processamentos *batch* e *streams*, já o Spark possui APIs diferentes, exceção se faz caso você utilize [Spark Structured Streaming](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html), diponível a partir do Spark 2, o qual utiliza a mesma API tanto para batch quanto para *streams*. Porém esta não é a única vantagem desta nova API, que conta com diversas otimizações, além do suporte a SQLs.

Com isso, em ambas as ferramentas é possível emular um *stream* usando o backup dos dados do Kafka e reprocessar o histórico usando **exatamente o mesmo código** implementado sobre a API de streams. Isso nos dá o poder de olhar para o passado sempre que for necessário sem nenhum esforço adicional.

### Garantias de entrega

Ambas as ferramentas garantem **exactly-once**, o Flink através da sua computação de estado e o Spark através dos checkpoints, o que nos dá a segurança de que os resultados dos streams estarão corretos, mesmo em cenários de falha. Esse estado é persistido através do mecanismo de savepoints.

### Atualizações dos jobs

Com o flink é possível fazer o deploy de novas versões do stream sem perder o estado atual computado. No Spark, isto somente é possível a partir da versão 2, nas versões anteriores todo o código era serialzado juntamente com os estados salvos nos checkpoints, desta forma, um novo diretório de checkpoint deve ser utilizado, dependendo da sua fonte de dados será necessário código adicional para lidar com este problema. Seguem dois exemplos:

* [Kafka Receiver Based](https://spark.apache.org/docs/latest/streaming-kafka-0-8-integration.html#approach-1-receiver-based-approach): como os offsets do Kafka são controlados pelo Zookeeper, basta iniciar um novo job em paralelo, assim que o job com código antigo parar o novo job assumirá;
* [Kafka Direct Aproach](https://spark.apache.org/docs/latest/streaming-kafka-0-8-integration.html#approach-2-direct-approach-no-receivers): você precisará persistir os offsets em um database para que possa saber qual a sua posição inicial quando o job for reiniciado sem a existência do checkpoint.

No Elo7 utilizamos [Kafka Direct Aproach](https://spark.apache.org/docs/latest/streaming-kafka-0-8-integration.html#approach-2-direct-approach-no-receivers) persistindo os offsets no Cassandra.

### Configurações

O Flink não possui muitas configurações, o que o deixa mais simples. O Spark possuí diversas configurações, algumas não documentadas, o que pode ser uma vantagem ou uma desvantagem, onde é possível otimizar o Spark para se encaixar com suas necessidades mas, ao mesmo tempo, exigirá mais esforço para domínio de tais configurações.

### Métricas

Este é um item no qual o Flink peca, são poucas as métricas existentes no mesmo. O Spark por outro lado, tem diversas métricas e uma interface web que mostra muitas informações sobre o estado de um job, como tempos de processamento, utização de memória e disco:

![Spark UI](../images/flink-spark-3.png)

Com o [Spark Structured Streaming](https://spark.apache.org/docs/latest/structured-streaming-programming-guide.html#monitoring-streaming-queries) as métricas podem ser coletadas conforme o progresso do stream, dessa forma, fica fácil enviar métricas para ferramentas externas e gerar alarmes a partir desses dados. Veja mais detalhes da nossa arquitetura de *streams* em [Elo7 + Analytics = Elytics](/elo7-analytics-elytics/).

### Comunidade

Por fim, um dos principais diferenciais do Spark é a sua **comunidade**: Desde 2009, mais de 1000 desenvolvedores já contribuíram para o projeto! Essa comunidade faz com que o ecossistema em torno do Spark seja muito rico, especialmente no que se refere a machine learning e processamento em batch.

Este é um dos pontos fracos do Flink, sua **comunidade** ainda é pequena. Isso faz com que o ecossistema não seja tão rico, o que leva à falta de integrações para outras ferramentas. Por exemplo, para conseguirmos utilizar o Flink na nossa *pipeline*, nós mesmos adicionamos o [suporte para o Elasticsearch 5.x](https://github.com/apache/flink/pull/2767).

## Conclusão

Ambas as ferramentas tem seus pontos positivos e negativos. Aqui no Elo7 nós usamos o Flink na nossa [pipeline analítica](/elo7-analytics-elytics/) mas também utilizamos Spark em alguns projetos internos com a ajuda do [Nightfall](/nightfall/).
