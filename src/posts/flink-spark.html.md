---
date: 2017-06-27
category: back-end
tags:
  - spark
  - flink
  - big data
author: mikedias
layout: post
title: Flink vs Spark
description: O título do post é polêmico para chamar sua atenção mas a idéia deste post é mostrar um pouco da nossa visão sobre essas duas excelentes ferramentas: Apache Flink e Apache Spark.
---

O título do post é polêmico para chamar sua atenção mas a idéia deste post é mostrar um pouco da nossa visão sobre essas duas excelentes ferramentas: [Apache Flink](http://flink.apache.org/) e [Apache Spark](http://spark.apache.org/). Nós não entraremos em detalhes profundos de cada ferramenta, nem faremos qualquer tipo de benchmark, nós vamos apenas apontar as características que são relevantes para o nosso dia-a-dia. 
Se você não conhece o Flink nem o Spark, na homepage dos projetos tem uma introdução bacana sobre cada um deles.

## Flink

WIP
<!-- 
- Mentalidade stream-first: o Flink tem o conceito de streams infinitos, diferente do Spark Streaming que é baseado em micro batches. 
- Back pressure automatico

![Flink Stream](../images/flink-spark-1.png)

- Garantias exactly-once: A implementação do connector para o Kafka do Flink tem suporte essas garantias, coisa que o Spark não oferecia.

- Mesmo código para stream e batch: Com o Flink, nós conseguimos emular um stream usando o backup dos dados do Kafka e reprocessar o histórico usando o mesmo código implementado sobre a API de streams. Para fazer isso no Spark seria necessário duas versões do código devido a diferenças na API.
 -->

## Spark

Já o Spark possui uma mentalidade **batch-first**. Isso acontece porque o projeto foi criado com o propósito de ser mais rápido e eficiente do que o MapReduce, principal técnica de processamento na época.

Influenciado por essa mentalidade, o Spark Streaming foi criado para resolver o problema de streaming utilizando **microbatches**, aproventando a implementação fundamental de batches do Spark (os famosos RDDs):
![Spark Microbatches](../images/flink-spark-2.png)

Para nós isso não faz muita diferença, afinal, os dados serão processados de maneira semelhante a um stream mesmo com um pouco mais de latência. O problema desta implementação é que o tamanho da window e o tamanho do microbatch precisam estar muito bem configurados para conseguir sobreviver a um volume de eventos maior do que o esperado.

Falando em configuração, isso é o que não falta no Spark: existem muitas e **muitas configurações**, sendo que algumas delas não estão nem documentadas. Por um lado isso é positivo, pois é possível fazer algum tunning. Por outro lado é negativo, por que é necessário acertar todas as combinações de configuração para que o cluster funcione corretamente.

Mas tem outra coisa que sobra no Spark e não tem o lado negativo: **métricas e estatísticas**. A interface padrão possui informações sobre basicamente tudo o que esta acontecendo no cluster durante a execução de um job, o que ajuda bastante na hora de encontrar um possível gargalo no processamento.

Por fim, um dos principais diferenciais do Spark é a sua **comunidade**: Desde 2009, mais de 1000 desenvolvedores já contribuiram ao projeto! Essa comunidade faz com que o ecossistema em torno do Spark seja muito rico, especialmente no que se refere a machine learning e procesamento em batch. 

## Conclusão

As duas ferramentas são equivalentes em diversos aspectos, e portanto, podem ser utilizadas em cenários semelhantes. Aqui no Elo7 optamos por usar o Flink na nossa pipeline analítica (também conhecido como [Elytics](/elo7-analytics-elytics/) mas também utilizamos Spark em alguns projetos internos com a ajuda do [Nightfall](/nightfall/).

