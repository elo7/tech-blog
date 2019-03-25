---
date: 2017-10-23
category: big-data
layout: post
title: Otimização de busca em faixas de valores
description: Explicamos como utilizamos um método de bissecção para otimizar a busca de valores em uma coleção de faixas de CEP, aumentando em mais de 100 vezes a performance do algoritimo.
authors: [ftfarias]
tags:
  - algoritmo
  - back-end
  - python
  - otimizacao
  - busca
---

Recentemente, nossa equipe fez algumas análises de frete e um dos desafios foi classificar todos os fretes de 2016 de acordo com as faixas dos Correios, que separam as regiões do Brasil em várias categorias: Locais, Divisa, Capitais e Interior. Cada categoria é subdividida em grupos, sendo de 1 a 4 ou de 1 a 6.

Para descobrir qual a categoria de um frete, temos que consultar diversas tabelas, em geral em um formato CSV ou planilha:

```
AC,ACRELANDIA,69945-000,69949-999,AC,ACRELANDIA,69945-000,69949-999,L4
AC,ASSIS BRASIL,69935-000,69939-999,AC,ASSIS BRASIL,69935-000,69939-999,L4
AC,BRASILEIA,69932-000,69933-999,AC,BRASILEIA,69932-000,69933-999,L4
...
SP,SOROCABA,18000-001,18109-999,SP,VOTORANTIM,18110-001,18119-999,L4
SP,SUD MENNUCCI,15360-000,15369-999,SP,SUD MENNUCCI,15360-000,15369-999,L4
SP,SUMARE,13170-001,13182-999,MG,EXTREMA,37640-000,37649-999,L3

```

Estas tabelas têm entre 15 mil e 25 mil registros, cada registro com um faixa de CEPs de entrada e uma faixa de CEPs de saída.

Nosso problema foi processar todos do dados de 2016 e classificar todos os fretes nas faixas acima. Estamos falando de alguns milhões de pedidos...

### Os dados

Toda a nossa solução foi implementada em Python. O carregamento dos dados é simples, diretamente do CSV:

``` python
# faixas_ceps_divisa é um dicionário, com as faixas como chave e o código como valor
faixas_ceps_divisa = {}
with open('divisas.csv','r', encoding='utf_8') as input_file:
    next(input_file)
    next(input_file)
    input_csv = csv.reader(input_file, delimiter=',', quotechar='"')
    for i,t in enumerate(input_csv):
        f1_inicio = int(t[2].replace('-',''))
        f1_fim = int(t[3].replace('-',''))
        f2_inicio = int(t[6].replace('-',''))
        f2_fim = int(t[7].replace('-',''))
        faixa = t[8]
        faixas_ceps_divisa[(f1_inicio,f1_fim,f2_inicio,f2_fim)] = faixa
```

``` python
print(len(faixas_ceps_divisa))
24304
```

``` python
print(list(faixas_ceps_divisa)[:3])
[ (75430000, 75439999, 70000001, 72799999),
  (19800001, 19819999, 87110001, 87119999),
  (86730000, 86749999, 12200001, 12249999) ]
```

``` python
faixas_ceps_divisa[(75430000, 75439999, 70000001, 72799999)]
'E4'
```

### Força bruta

A primeira abordagem foi carregarmos as tabelas em memória e fazer uma busca por força bruta:

``` python
def is_cep_divisa(cep1,cep2):
    r = [y for x,y in faixas_ceps_divisa.items() if x[0]<= cep1 <=x[1] and x[2]<= cep2 <=x[3]]
    if len(r) == 1:
            return r[0]
    else:
        return None
​
​
assert is_cep_divisa(57935000,53520001) == 'E4'
assert is_cep_divisa(32000000,12345001) == None
```

``` python
%timeit is_cep_divisa(57935000,53520001)
7.66 ms ± 539 µs per loop (mean ± std. dev. of 7 runs, 100 loops each)
```
A chamada %timeit automaticamente faz um teste de performance para uma dada função. Nesse caso a função is_cep_divisa() foi executada repetidamente por 7 rodadas (runs), cada rodada com 100 repetições, e para cada rodada (100 chamadas) uma média foi calculada. No fim das 7 rodadas, a média final (7.66 milisegundos) e o desvio padrão (+/- 539 microsegundos) são mostrados.

``` python
%timeit is_cep_divisa(32000000,12345001)
6.37 ms ± 602 µs per loop (mean ± std. dev. of 7 runs, 100 loops each)
```

Como vemos, a performance não é tão ruim para uma chamada de is_cep_divisa(). Contudo, vamos ter que realizar esta chamada para todos os registros de 2016, então algumas otimizações podem ajudar.

Uma possível melhoria seria parar a execução assim que encontrássemos um faixa de frete correspondente a nossa procura (saindo do loop), reduzindo o número de comparações.

### Força bruta 2

``` python
def is_cep_divisa(cep1,cep2):
    for x,v in faixas_ceps_divisa.items():
        if x[0]<= cep1 <=x[1] and x[2]<= cep2 <=x[3]:
            return v
    else:
        return None


assert is_cep_divisa(57935000,53520001) == 'E4'
assert is_cep_divisa(32000000,12345001) == None
```

``` python
%timeit is_cep_divisa(57935000,53520001)
3.66 ms ± 183 µs per loop (mean ± std. dev. of 7 runs, 100 loops each)
```

``` python
%timeit is_cep_divisa(32000000,12345001)
5.83 ms ± 245 µs per loop (mean ± std. dev. of 7 runs, 100 loops each)
```

No primeiro caso a performance é melhor, porém no segundo teste o cep de destino "12345001" não existe, forçando o loop da função a testar todos os 40 mil registros, o que torna o teste mais lento que o primeiro caso. Em geral é possível ver que a performance melhora um pouco, mas depende muito da posição na lista.

Quando testamos esta versão, o tempo de processamento ficou em aproximadamente 10 horas.

### Procurando uma solução

Após algumas horas procurando no Google por alguma biblioteca que fizesse a procura, percebemos que estávamos indo pelo caminho errado. Com certeza a biblioteca padrão do Python já teria solução!!!

Começamos a (re)ler todos os módulos do Python e achamos o que precisavamos: o módulo [bisect!](https://docs.python.org/3.0/library/bisect.html)

Bisect é um método relacionado à busca binária, para achar raizes de funções. No caso da biblioteca do Python, ele é usado de um modo um pouco diferente. Seu objetivo é encontrar o ponto de inserção de um novo valor em uma lista já ordenada para que ela continue ordenada após a inclusão do novo valor. Mas como o bisect pode ajudar a procura em listas? O processo que usamos foi:

- Pegar o começo de cada faixa e colocar em ordem crescente:

``` python
faixas_ceps_divisa = []

# PSEUDO CODIGO: carrega os inícios das faixas de cep:
for cep_origem_inicio in open( 'faixas_ceps.txt','r'):
	faixas_ceps_divisa.append(cep_origem_inicio)


faixas_ceps_divisa = sorted(set(faixas_ceps_divisa))

# é necessário converter de list para tuple por causa do bisect
faixas_ceps_divisa = tuple(faixas_ceps_divisa)
```

- Em seguida criamos um dicionário, sendo a chave o CEP inicial da faixa de valores e o valor uma lista de possíveis faixas com aquele CEP inicial:

``` python
faixas_ceps_divisa_dict = collections.defaultdict(list)

# PSEUDO CODIGO: carrega os inícios das faixas de cep:
for cep_origem_inicio, cep_origem_fim, cep_destino_inicio, cep_destino_fim, categoria in open( 'faixas_ceps.txt','r'):
        faixas_ceps_divisa_dict[cep_origem_inicio].append((cep_origem_fim, categoria))
```

- Dado dois CEPs (origem e destino) a serem procurados, usamos o bisect na lista de CEPs para achar a faixa inicial. Como o bisect é implementado em C, esta procura é muito rápida.

``` python
def is_cep_divisa(cep1,cep2):
    i = bisect.bisect_right(faixas_ceps_divisa, cep1)
    if not i:
        return False
    inicio = faixas_ceps_divisa[i-1]
    ...
```

- Se encontramos o início da faixa, basta usar o dicionário para resgatar as faixas com este início e fazer uma busca por força bruta. Uma análise rápida mostrou que estas subfaixas têm em média 44 itens, tendo a maior 135 elementos. Um ganho sobre os 25.000 registros iniciais!

``` python
    sub_faixas = faixas_ceps_divisa_dict[inicio]
    for sf in sub_faixas:
        if cep1 <= sf[0] and sf[1]<= cep2 <= sf[2]:
            return sf[3]
```

A versão completa ficou:

``` python
def is_cep_divisa(cep1,cep2):
    i = bisect.bisect_right(faixas_ceps_divisa, cep1)
    if not i:
        return False
    inicio = faixas_ceps_divisa[i-1]
    sub_faixas = faixas_ceps_divisa_dict[inicio]
    for sf in sub_faixas:
        if cep1 <= sf[0] and sf[1]<= cep2 <= sf[2]:
            return sf[3]

    return False
```

### Resultados

O tempo de procura ficou em:

``` python
%timeit is_cep_divisa(57935000,53520001)
1.54 µs ± 3.05 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```

``` python
%timeit is_cep_divisa(32000000,12345001)
1.43 µs ± 119 ns per loop (mean ± std. dev. of 7 runs, 1000000 loops each)
```

E o processamento total foi reduzido de 10 horas para 4 minutos! Existe espaço para melhoria, mas essa performance é excelente e preferimos parar as otimizações por aqui.
