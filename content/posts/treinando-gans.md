---
date: 2019-12-16
category: machine-learning
tags:
  - generative adversarial networks
  - redes geradoras adversariais
  - machine learning
  - deep learning
  - artificial intelligence
  - redes neurais
authors: [onimaru]
layout: post
title: Estratégias e dicas para treinar GANs
description: GANs, redes geradoras adversariais, são famosas por produzirem resultados incríveis, mas serem muito difíceis de treinar. Nesse post contamos alguns segredos para otimizar e estabilizar o treino dessas redes.
cover: treinando-gans-1.png
---

Recentemente realizamos no Elo7 um evento chamado de GAN School 1, ele deu início a série de workshops e meetups promovidos pelo time de engenharia. Os elo7.dev workshops  visam compartilhar conhecimento sobre técnicas e soluções usadas aqui no Elo7. A GAN School tem como objetivo divulgar as redes geradoras adversariais no Brasil ensinando o básico necessário sobre para que os participantes que não conhecem a técnica possam começar a acompanhar a literatura, a entender diferentes arquiteturas e aplicá-las em problemas próprios. Os notebooks usados no curso estão [aqui](https://github.com/onimaru/GAN_School) e os slides [aqui](https://www.slideshare.net/elo7tech/gan-school-elo7-workshops).

Pelo que pesquisamos é a primeira vez no Brasil que ocorre um evento exclusivamente dedicado ao estudo, ensino e discussão de GANs. Mesmo a nível mundial poucas vezes isso cocorreu. Nesta primeira edição abordamos teoria e prática da GAN convencional (NSGAN) e da Conditional GAN (CGAN). O NSGAN é basicamente o mesmo que foi abordado no [post passado](https://elo7.dev/gan/), com alguns upgrades.

## Por que GANs ainda não são tão populares?

Se você fez o curso ou já tem experiência com GANs sabe que a elas são difíceis de treinar, mas não acho que seja esse o único motivo. Baseado na minha experiência levantei alguns pontos que podem explicar isso:  
1. GANs são novas: elas surgiram em 2014 e apesar de serem bastante utilizadas por grandes empresas ainda são um tema mais de pesquisa. Fora do Brasil a maioria das pessoas que utiliza GANs aprendeu durante seu mestrado ou doutorado, já que muitos pesquisadores mergulharam forte nesta área. Aqui no Brasil a pesquisa feita em Universidades (sim, estou julgando) é muito voltada para as técnicas que os pesquisadores tem muita experiência, ou seja, é necessário que jovens pesquisadores se interessem pelo assunto, estudem por conta própria e passem esse conhecimento adiante. É isso que estamos tentando atingir com o GAN School.  
2. Modelos geradores são difíceis: a maneira mais popular de se aprender machine learning é através de cursos online. Há um número grande por aí e a maioria foca em assuntos como regressão e classificação, pois podem se beneficiar de bibliotecas como o scikit-learn. Agora, ensinar modelos geradores envolve falar de estatística bayesiana, modelagem matemática e técnicas para estimar distribuições. Isso toma tempo e exige um background mais forte do aluno, portanto não é foco de cursos online.
3. GANs são instáveis: se você decidiu seguir esse caminho deve estar preparado para ter muitos hiperparâmetros para ajustar antes que seu modelo sequer comoce a ficar aceitável. Mesmo que você tenha uma GAN que funciona muito bem para um determinado dataset não há garantia que ela funcione para outro dataset, você precisará ajustar os hiperparâmetros novamente. Não estou falando apenas de fazer uma busca pelos valores ideais de learning rate, número de épocas, etc. Várias coisas podem ser diferentes como o número de camadas nas redes neurais, a arquitetura das redes, as funções de ativação, a quantidade de vezes que o gerador e o discriminador são treinados um em relação ao outro, o batch size e os tipos de ruído. Isso tudo pode tornar frustrante aprender e usar GANs.

Durante o curso já fui dando algumas dicas de coisas que podem ajudar em relação a esse último item, mas como não focamos nisso usarei este post para complementar o curso.

## Problemas comuns

Há principalmente três problemas típicos que podemos encontrar ao usar GANs, o primeiro e crucial é a instabilidade do treino. Durante o _loop_ de treino buscamos o Equilíbrio de Nash, ou seja, queremos que O Discriminador e o Gerador tentem minimizar os seus erros e acabem empatando. Isso acontece quando o Discriminador identifica que 50% dos dados reais e falsos são reais. Ao dizer que GANs são instáveis estamos falando que o estado ótimo, para uma dada arquitetura, pode estar em um ponto de equilíbrio instável. Assim, o sistema que é sensível às condições iniciais pode nunca atingir esse ponto e o pior, o Gerador vai continuar tentando buscar minimizar o seu erro, mas o Discriminador já em seu estado de mínima perda identificará os dados falsos fazendo a perda do Gerador apenas aumentar. Com isso dizemos que o treino diverge.

Outro problema clássico de GANs é o _mode collapse_. Esse problema é caracterizado por um treino aparentemente bem sucedido, mas ao verificar os dados vemos que o Gerador aprendeu apenas dados que conseguem enganar bem o Discriminador. Um bom exemplo disso ocorre quando o Gerador aprende apenas os valores médios de cada feature. Como são valores bem comuns acabam enganando o Discriminador.

O último problema é um pouco similar ao anterior. O _Failure mode_ ocorre quando temos modos bem claros no dataset, os números no caso do MNIST. Com o GAN tradicional não há garantia de que o Gerador vai aprender todos o modos. No exemplo do MNIST é possível que o Gerador crie dados de alta qualidade, mas apenas de um dos dígitos.

O _mode collapse_ e o _failure mode_ podem ser evitados se usarmos arquiteturas que usem alguma informação extra sobre o dataset original, como o CGAN e o InfoGAN.



## Boas estratégias no treino de GANs - nível 1

O nível 1 é composto de estratégias que uso já na primeira vez que vou rodar o treino.  
1. Normalizar os inputs em (-1,1) ou (0,1). Ao normalizar os inputs você pode escolher usar uma função tanh, para (-1,1), ou sigmoid, para (0,1). Isto não deveria afetar o treino de uma rede neural comum, mas devido a instabilidade do treino é possível que o Gerador, nas primeiras épocas, produza valores em uma escala muito distante dos valores e isso seja suficiente para que ocorra divergência no treino.  
2. Na loss function do discriminador troque _min log(1-D)_ por _max log(D)_. Fazendo isso estaremos tentando maximizar os dois termos na função de perda do Discriminador e eles podem ser calculados da mesma forma, com a _binary cross entropy_. Devemos assim, utilizar labels para informar ao discriminador se o _input_ é real ou falso.  
3. No Gerador trocar a label de _false_ para _real_. Assim temos a mesma utilidade de usar a _binary cross entropy_.  
4. Usar como ruído uma distribuição gaussiana e não uma uniforme. A distribuição uniforme tem suas utilidades principalmente em arquiteturas como a do InfoGAN, mas como ruído principal do Gerador ela acaba dando peso muito grande para gerar dados que seriam outliers nos dados originais. Isso não ocorre com ao usar uma gaussiana.  
5. Utilizar o _Adam_ como otimizador. De maneira geral ele é melhor otimizador e portanto uma boa aposta tanto para o Gerador quanto para o Discriminador.  
6. Fazer a inicialização de pesos com a _Xavier normal_. Essa é uma boa prática em qualquer tipo de rede neural, ajuda a evitar gradientes zerados no início do treino.  
7. Se seu dataset é composto de imagens, comece com o Deep Convolutional GAN (DCGAN). Essa arquitetura não é famosa sem motivo, ela se mostrou muito eficiente tanto na estabilização do treino como na qualidade dos dados gerados.  

## Boas estratégias no treino de GANs - nível 2

Se após isso sua GAN ainda não está boa pode partir para o nível 2. Neste nível temos alterações que podem ser testadas rapidamente e alterando minimamente o que você já fez.  
1. Testar adição de ruído na forma de _dropout_. Isso pode ser testado tanto no Gerador quanto no Discriminador. Em ambos as ativações pouco informativas são ignoradas, então o Gerador produz dados de melhor qualidade e o Discriminador consegue usar dados mais significativos para identificar a realidade dos _inputs_.  
2. Testar ativações na forma de _leaky relu_. Eu costumo começar usando a ativação _relu_ no Gerador e _leaky relu_ no Discriminador, mas algumas vezes os gradientes do Gerador começam a ficar pouco informativos. Usar a _leaky relu_ também no Gerador pode ser uma boa saída para isso.  
3. Treinar o Discriminador mais vezes que o Gerador. Se você observar que o Gerador está enganando o Discriminador com facilidade ou que a probabilidade de acerto para os dados reais estabiliza em _0.5_, enquanto para os dados falsos é maior que isso, pode ser um sinal de que a velocidade de aprendizado do Discriminador seja menor que a do Gerador. Para corrigir isso tente treinar o Discriminador mais vezes que o Gerador. Não existe um meio para descobrir essa quantidade, mas teste algo entre _2_ e _5_.  
4. Treinar o Gerador mais vezes que o Discriminador. Isso é o inverso do item anterior, pode ser que o Discriminador comece de maneira muito acertiva ao identificar os dados falsos. Isso pode não dar chances para o Gerador e fazer o treino divergir.  

## Boas estratégias no treino de GANs - nível 3

Agora partimos para mudanças mais drásticas e meu conselho é que para cada mudança de nível 3 você volte e teste novamente todas as novas alterações de nível 2. Isso pode ser trabalhoso, portanto tente uma abordagem bem científica e anota as diferenças no resultado para cada alteração que fizer.  
1. Aumentar o número de camadas do Gerador. Comece com uma rede pequena e vá aumentando o número de camadas aos poucos. Na minha experiência o número de camadas se mostrou mais importante que o número de neurônios por camada.  
2. Testar o otimizador Stochastic Gradient Descent (SGD) no Discriminador. Apesar do que foi dito sobre o Adam, em alguns testes o treino mehorou muito ao usar o SGD no Discriminador usando o mesmo _learning rate_.  
3. Usar _mini batches_ de dados apenas reais e apenas falsos. Essa é outra estratégia que quando funciona melhora muito o treino. Na etapa de treino do Discriminador forneça apenas dados reais primeiro, treine e atualize os pesos da rede e em seguida repita o procedimento apenas com dados falsos. Isso faz com que o Discriminador consiga diferenciar melhor entre os dados, forçando o Gerador a melhorar também.  
4. Testar arquiteturas diferentes nas redes. Em princípio o Gerador e o Discriminador são redes neurais quaisquer e podemos usar qualquer tipo de arquitetura. Portanto, experimente algumas como uma rede com número de neurônios constante e arquiteturas de autoencoder. Uma alternativa mais avançada é usar um _Variational AutoEncoder_ como Gerador, mas nesse caso estamos entrando no ramo de _Adversarial Variational AutoEncoder_.  

## Boas estratégias no treino de GANs - nível 4

Pode ser que nada disso esteja funcionando então devemos ir atrás de mais informação usando outras GANs.  
1. Se tiver algum tipo de _label_, use. Qualquer tipo de _label_ que seus dados possuam, mesmo que não estejam ligadas ao problema que você quer resolver, pode ser usadas com sucesso no CGAN, por exemplo.  
2. Faça o Discriminador ter mais funções. Além de identificar o dado como verdadeiro ou falso, faça ele também ser um classificador de _labels_. Isso melhora muito o papel do Discriminador e força a melhora do Gerador. A arquitetura que usa isso em conjunto com o CGAN é chamada de _Auxiliary CGAN_.  
3. Suavize as _labels_. O caso mais comum é usar a label _1_ para dados reais e _0_ para os falsos. Suavizar as _labels_ é adicionar algum ruído pequeno às _labels_, fazendo elas ficarem algo como _0.9_ e _0.2_.  
4. Apele para teoria de informação, InfoGAN. Assim como a CGAN, a InfoGAN vai produzir os mesmos resultados da GAN original, mas usa de informação extra para treinar. Além de produzir dados de alta qualidade ainda possui a característica de poder aprender variáveis latentes para controlar os dados gerados.  
5. Teste outras formas de ruído. Outra técnica bastante usada é adicionar um ruído aos _inputs_ do Discriminador com um decaimento ao longo das épocas. Isso pode ser muito útil se o Discriminador está aprendendo muito rápido não dando oportunidade ao Gerador.  
6. Utilize diversas formas de métricas para monitorar o treino. Como dito algumas vezes, apenas monitorar a probabilidade de erro do Discriminador não é suficiente para um treino bem sucedido. Verifique que tipo de métrica é útil para os seus dados e acompanhe elas durante o treino. Por exemplo, para datasets de imagens as métricas mais comuns são _Inception Score_ e _Fréchet Inception Distance_.  
7. Com uma boa métrica use _early stop_. Se você encontrou uma boa métrica pode utilizá-la como critério de parada do seu treino. Isso é especialmente útil para economizar tempo e evitar os casos em que o treino diverge depois de muitas épocas.  
8. Tente a WGAN. Esta arquitetura é conhecida por apresentar resultados tão bons quanto ou melhores que a GAN tradicional. Possui algumas diferenças significativas na arquitetura e no treino, mas pode ser usada com qualquer GAN.  

## Trabalha e confia

Bom, testar todas essas mudanças pode levar um bom tempo, mas com certeza aumentará o seu domínio sobre a técnica e fará com que você perceba novas aplicações facilmente. O grande objetivo do GAN School é permitir que você possa contribuir para a compreensão das GANs e colocar o Brasil no mapa desta área. Quem sabe futuramente não realizamos um evento internacional para divulgar o seu trabalho ;)
