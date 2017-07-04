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

O título do post é polêmico para chamar sua atenção mas a idéia deste post é mostrar um pouco da nossa visão sobre essas duas excelentes ferramentas: [Apache Flink](http://flink.apache.org/) e [Apache Spark](http://spark.apache.org/). Nós não entraremos em detalhes profundos de cada ferramenta, nem faremos qualquer tipo de benchmark. Nós vamos apenas apontar as características que são relevantes para o nosso dia-a-dia. 
Se você não conhece o Flink nem o Spark, na homepage dos projetos tem uma introdução bacana sobre cada um deles.

## Flink

O Flink é um projeto que nasceu com a mentalidade **streaming-first**, isto é, 
o objetivo principal da plataforma é processar dados que são produzidos de maneira contínua e infinita:

![Flink Stream](../images/flink-spark-1.png)

Essa arquitetura permite que o job que processa o stream seja mais rápido e resiliente. Mais rápido porque os eventos são processados assim que eles chegam e mais resiliente porque os eventuais picos de eventos (também conhecidos como back pressure) são gerenciados de maneira automática pelo Flink.

No Flink, os streams podem ser tratados como finitos ou infinitos. Com isso é possível emular um stream usando o backup dos dados do Kafka e reprocessar o histórico usando **exatamente o mesmo código** implementado sobre a API de streams. Isso nos dá o poder de olhar para o passado sempre que for necessário sem nenhum esforço adicional.

A garantia **exactly-once** na computação de estado do Flink nos dão a segurança de que os resultados dos streams estarão corretos, mesmo em cenários de falha. Como esse estado é persistido utilizando o mecanismo de savepoints, é possível fazer o deploy de novas versões do stream sem perder o estado atual computado.

O ponto fraco do Flink é a sua **comunidade** que ainda é pequena. Isso faz com que o ecossistema não seja tão rico, o que leva à falta de conectores para outras ferramentas. Por exemplo, para conseguirmos utilizar o Flink na nossa pipeline, nós mesmos adicionamos o [suporte para o Elasticsearch 5.x](https://github.com/apache/flink/pull/2767).

## Spark

Já o Spark possui uma mentalidade **batch-first**. Isso acontece porque o projeto foi criado com o propósito de ser mais rápido e eficiente do que o MapReduce, principal técnica de processamento na época. Influenciado por essa mentalidade, o Spark Streaming foi criado para resolver o problema de fluxos contínuos utilizando **microbatches**, aproveitando a implementação fundamental de batches do Spark (os famosos RDDs):
![Spark Microbatches](../images/flink-spark-2.png)

Para nós isso não faz muita diferença, afinal, os dados serão processados de maneira semelhante a um stream mesmo com um pouco mais de latência. O problema desta implementação é que o tamanho da window e o tamanho do microbatch precisam estar muito bem configurados para conseguir sobreviver a um volume de eventos maior do que o esperado.

Falando em configuração, isso é o que não falta no Spark: existem muitas e **muitas configurações**, sendo que algumas delas não estão nem documentadas. Por um lado isso é positivo, pois é possível fazer algum tunning. Por outro lado é negativo, pois é necessário acertar todas as combinações de configuração para que o cluster funcione corretamente.

Mas tem outra coisa que sobra no Spark e não tem o lado negativo: **métricas e estatísticas**. A interface padrão possui informações sobre basicamente tudo o que esta acontecendo no cluster durante a execução de um job, o que ajuda bastante na hora de encontrar um possível gargalo no processamento.

Uma característica que nos incomodou bastante no Spark foi a maneira como os **checkpoints** foram implementados: as classes envolvidas no job são serializadas e armazenadas no checkpoint. O problema é que se as classes deste job forem atualizadas, não é possível fazer o deploy dessa nova versão sem excluir o checkpoint com a serialização das classes antigas...

Por fim, um dos principais diferenciais do Spark é a sua **comunidade**: Desde 2009, mais de 1000 desenvolvedores já contribuiram ao projeto! Essa comunidade faz com que o ecossistema em torno do Spark seja muito rico, especialmente no que se refere a machine learning e processamento em batch. 

## Conclusão

Ambas as ferramentas tem seus pontos positivos e negativos, mas na nossa avaliação o Flink leva a vantagem quando o quesito é processamento de streams. Aqui no Elo7 nós usamos o Flink na nossa [pipeline analítica](/elo7-analytics-elytics/) mas também utilizamos Spark em alguns projetos internos com a ajuda do [Nightfall](/nightfall/).
