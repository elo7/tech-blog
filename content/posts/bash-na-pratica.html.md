## Bash na prática ##

Todo desenvolvedor que encontrou um problema em produção, já precisou extrair alguma informação dos logs do sistema para gerar um relatório, fazer uma chamada a uma API com os resultados, etc. Mas sempre nos deparamos com problemas simples que não tem necessidade de criar um programa para fazer parse do arquivo e executar essas ações, mas por falta de conhecimento de algumas ferramenta do sistema partimos para uma solução mais complexa.

Neste post vamos apresentar na prática alguns comandos disponíveis em alguns sistemas UNIX (Linux, MacOS, etc) que pode facilitar bastante a automação dessas tarefas.

Utilizando uma característica bem interessante dos sistemas Unix, o PIPE (|), podemos combinar vários comandos e criar relatórios, executar comandos em massa, automatizar chamadas a sistemas externos, etc.

Vamos discutir uma lista bem restrita de comandos, mas que usando a criatidade e o manual do sistema (man [comando]), você pode expandir os aprendizados destes post e sair criando automatizações de todas suas tarefas repetitivas do seu dia a dia.

Vamos restringir a lista a esses comandos:

```
for
grep
cut
xargs
find
echo
sed
awk
diff
wc
seq
sleep
head
tail
if
expr
sort
uniq
```

Agora vamos explicar alguns modos de utilizar cada um deles e como combiná-los para obter um resultado mais interessante, lembrando que todos os comandos possuem muitas opções de uso, e não vamos explorar todas elas, somente alguns usos que utilizo no dia a dia e que vou compartilhar com vocês. Para consultar tudo que o comando pode fazer, vocês devem utilizar o comando "man [nome do comando]" para explorar todas as opções e a descrição detalhada do que o comando faz.

grep: utilizo este comando serve para filtrar as linhas de um arquivo.

Exemplo:
dado um arquivo de log.txt com o conteúdo abaixo:
```
"timestamp","source","message"
"2017-12-11T17:26:13.000Z","406df9dfae99","GET /lista/bebe-categoria-lembrancinhas?sortBy=10&pageNum=17&qrid=Nh3N3TqdMNl0&nav=sch_pd_pg_17 HTTP/1.1"
"2017-12-11T17:26:13.000Z","aaa57134a243","GET /lista/save-the-date?sortBy=10&pageNum=3&qrid=2nPW5s3pWHJJ&nav=cat_pd_pg_3 HTTP/1.1"
"2017-12-11T17:26:13.000Z","7d5e23fabcbc","GET /lista/kit-natal?sortBy=4&pageNum=32&qrid=AULwiqjGWTjH&nav=sch_pd_pg_32 HTTP/1.1"
"2017-12-11T17:26:13.000Z","60a36d961cd9","GET /lista/quadro-principe?sortBy=10&pageNum=14&qrid=NFqOgAMHt1VR&nav=sch_pd_pg_14 HTTP/1.1"
```

gostaria de filtrar as linhas do arquivo que tenham a palavra GET e retirando do resultado o cabeçalho, utilizaria o comando abaixo:

```bash 
grep "GET" log.txt
```
o resultado:
```
"2017-12-11T17:26:13.000Z","406df9dfae99","GET /lista/bebe-categoria-lembrancinhas?sortBy=10&pageNum=17&qrid=Nh3N3TqdMNl0&nav=sch_pd_pg_17 HTTP/1.1"
"2017-12-11T17:26:13.000Z","aaa57134a243","GET /lista/save-the-date?sortBy=10&pageNum=3&qrid=2nPW5s3pWHJJ&nav=cat_pd_pg_3 HTTP/1.1"
"2017-12-11T17:26:13.000Z","7d5e23fabcbc","GET /lista/kit-natal?sortBy=4&pageNum=32&qrid=AULwiqjGWTjH&nav=sch_pd_pg_32 HTTP/1.1"
"2017-12-11T17:26:13.000Z","60a36d961cd9","GET /lista/quadro-principe?sortBy=10&pageNum=14&qrid=NFqOgAMHt1VR&nav=sch_pd_pg_14 HTTP/1.1"
```

outra forma de utilizar o grep é ao invés de filtrar linhas, é excluir as linhas que possuem determinada palavra, exemplo:

```bash 
grep -v "timestamp" log.txt
```

o resultado é o mesmo:
```
"2017-12-11T17:26:13.000Z","406df9dfae99","GET /lista/bebe-categoria-lembrancinhas?sortBy=10&pageNum=17&qrid=Nh3N3TqdMNl0&nav=sch_pd_pg_17 HTTP/1.1"
"2017-12-11T17:26:13.000Z","aaa57134a243","GET /lista/save-the-date?sortBy=10&pageNum=3&qrid=2nPW5s3pWHJJ&nav=cat_pd_pg_3 HTTP/1.1"
"2017-12-11T17:26:13.000Z","7d5e23fabcbc","GET /lista/kit-natal?sortBy=4&pageNum=32&qrid=AULwiqjGWTjH&nav=sch_pd_pg_32 HTTP/1.1"
"2017-12-11T17:26:13.000Z","60a36d961cd9","GET /lista/quadro-principe?sortBy=10&pageNum=14&qrid=NFqOgAMHt1VR&nav=sch_pd_pg_14 HTTP/1.1"
```
Uma outra forma que também utilizo é o grep -o que é bem útil quando queremos extrair alguma informação da linha do arquivo, e gostariamos de ignorar as outras:

```bash 
grep -o "GET[^\"]*" log.txt
```

Onde vamos ler somente os dados do GET para frente excluíndo as aspas (").
```
GET /lista/bebe-categoria-lembrancinhas?sortBy=10&pageNum=17&qrid=Nh3N3TqdMNl0&nav=sch_pd_pg_17 HTTP/1.1
GET /lista/save-the-date?sortBy=10&pageNum=3&qrid=2nPW5s3pWHJJ&nav=cat_pd_pg_3 HTTP/1.1
GET /lista/kit-natal?sortBy=4&pageNum=32&qrid=AULwiqjGWTjH&nav=sch_pd_pg_32 HTTP/1.1
GET /lista/quadro-principe?sortBy=10&pageNum=14&qrid=NFqOgAMHt1VR&nav=sch_pd_pg_14 HTTP/1.1
```

Também podemos utilizar o grep -o para mostrar somente um "string param", por exemplo se eu quiser a maior paginação que um usuário fez no site

```bash 
grep -o "pageNum=[0-9]*" log.txt
```

neste caso obtemos os resultados:
```
pageNum=17
pageNum=3
pageNum=32
pageNum=14
```
Neste caso visualmente podemos identificar qual o maior valor, porém se tivermos um arquivo com algumas milhares de linha, torna a tarefa mais dificil. E como podemos fazer isso combinando as ferramentas acima? Sempre temos que pensar em uma estratégia antes de começar a tratar o dado. Nesse caso o que eu pensei foi extrair os números que estão separados por um sinal de igual (=), ordená-los em ordem crescente e pegar o ultimo resultado da minha consulta. Então vamos lá:

Vamos demonstrar a estratégia passo a passo:

1. já temos o resultado acima utilizando o "grep -o", então agora vamos combinar a saida do comando acima, seguindo a estratégia descrita, que em primeiro lugar vamos separar os números:

```bash 
grep -o "pageNum=[0-9]*" log.txt | cut -d \= -f 2
```

e obtivemos o resultado:
```
17
3
32
14
```

1. agora vamos ordernar, como se trata de números vamos utilizar o comando sort para ordenar e temos um parametro especial para números, pois o default do sort é ordenar strings.

```bash 
grep -o "pageNum=[0-9]*" log.txt | cut -d \= -f 2 | sort -n
```

resultado:
```
3
14
17
32
```

1. agora seguindo a estratégia, vamos pegar a ultima linha do resultado, utilizando o tail -1

```bash 
grep -o "pageNum=[0-9]*" log.txt | cut -d \= -f 2 | sort -n | tail -1
```

resultado:
```
32
```

Para continuar exemplificando o uso dos outros comandos, vamos pensar em um outro problema. Agora que descobrimos quais são paginações mais distantes, nos precisamos saber quais pesquisas resultam nessas paginações. E para isso pensei na seguinte estratégia, vamos pegar a consulta em que retornavam os GETs com o path e separar todos os paths com pageNum=32. Para isso precisamos da palavra que vamos utilizar no nosso grep, que é pageNum=32, depois vamos fazer um outro grep para filtrar todos os GETs com essa palavra.

Para obter o pageNum=32 vamos utilizar o awk para concatenar a palavra com o resultado da consulta que traz o número da maior página.

```bash 
grep -o "pageNum=[0-9]*" log.txt | cut -d \= -f 2 | sort -n | tail -1 | awk '{ print "pageNum="$1 }'
```
obtemos:

```
pageNum=32
```
Agora vamos fazer um grep que utliza a palavra encontrada, para isso vamos utilizar uma funcionalidade chamada substituição de comando, que pode ser utilizada com comandos entre apóstrofo (`) ou com sifrão e comandos entre parenteses ($()), que faz com que o resultado do comando entre apóstrofos seja utilizado como string pelo comando que está sendo executado.

exemplo:
```bash
grep `nosso comando anterior` log.txt
```
vamos ao nosso problema:

```bash 
grep `grep -o "pageNum=[0-9]*" log.txt | cut -d \= -f 2 | sort -n | tail -1 | awk '{ print "pageNum="$1 }'` log.txt
```

```
"2017-12-11T17:26:13.000Z","7d5e23fabcbc","GET /lista/kit-natal?sortBy=4&pageNum=32&qrid=AULwiqjGWTjH&nav=sch_pd_pg_32 HTTP/1.1"
```
porém o resultado não ficou como os do GETs que gostaríamos, então vamos incluir o grep que separa somente os GETs:

```bash 
grep `grep -o "pageNum=[0-9]*" log.txt | cut -d \= -f 2 | sort -n | tail -1 | awk '{ print "pageNum="$1 }'` log.txt | grep -o GET[^\"]*
```
agora melhorou o nosso resultado:
```
GET /lista/kit-natal?sortBy=4&pageNum=32&qrid=AULwiqjGWTjH&nav=sch_pd_pg_32 HTTP/1.1
```
Agora podemos estudar mais um caso do dia a dia, queremos comparar se as chaves dos arquivos de properties de produção e desenvolvimento estão iguais, para isso vamos analiar como fazer essa comparação. O arquivo de properties tem o formato "chave=valor", também possui comentários, linhas iniciando com #, e também possuem linhas em branco.

```bash 
for x in `seq 2`;
  do
    if [ $x == 1 ]; then
      echo "---------------------------------------- Chaves a mais no ./config.properties.dev ----------------------------------------";
      diff <(grep -v ^# ./config.properties.dev | grep -v "^[ ]*$" | sort | cut -d = -f 1) <(grep -v ^# ./config.properties.prd | grep -v "^[ ]*$" | sort | cut -d = -f 1) | grep ^[\<\>] | sort | grep \< | sed "s/\<\ //g"
    else
      echo "---------------------------------------- Chaves a mais no ./config.properties.prd ----------------------------------";
      diff <(grep -v ^# ./config.properties.dev | grep -v "^[ ]*$" | sort | cut -d = -f 1) <(grep -v ^# ./config.properties.prd | grep -v "^[ ]*$" | sort | cut -d = -f 1) | grep ^[\<\>] | sort | grep \> | sed "s/\>\ //g"
    fi;
  done
```





... continue in next hackday





for x in $(for i in $(wget -q -O - coinmarketcap.com | grep -E "currency-symbol|class=\"price\""); do echo $i ; done | grep -E "/a></span|data-usd|data-btc"); do echo $x; done | cut -d \= -f 2|cut -d \> -f 2 | cut -d \< -f 1 | sed s/\"//g | xargs -n3


echo $(expr `grep -o "pageNum=[0-9]*" ~/Downloads/graylog-search-result-relative-300.csv | cut -d \= -f 2 | awk '{ print a = a + $1 }' | tail -1` / `grep -o "pageNum=[0-9]*" ~/Downloads/graylog-search-result-relative-300.csv | wc -l`)


