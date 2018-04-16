## Bash na prática ##

Todo desenvolvedor que encontrou um problema em produção, já precisou extrair alguma informação dos logs do sistema para gerar um relatório, fazer uma chamada a uma API com os resultados, etc. Mas sempre nos deparamos com problemas simples que não tem necessidade de criar um programa para fazer parse do arquivo e executar essas ações, mas por falta de conhecimento de algumas ferramenta do sistema partimos para uma solução mais complexa.

Neste post vamos apresentar na prática alguns comandos disponíveis em alguns sistemas UNIX (Linux, MacOS, etc) que pode facilitar bastante a automação dessas tarefas.

Utilizando uma característica bem interessante dos sistemas Unix, o PIPE (|), podemos combinar vários comandos e criar relatórios, executar comandos em massa, automatizar chamadas a sistemas externos, etc.

Vamos discutir uma lista bem restrita de comandos, mas que usando a criatidade e o manual do sistema (man [comando]), você pode expandir os aprendizados destes post e sair criando automatizações de todas suas tarefas repetitivas do seu dia a dia.

Vamos restringir a lista a esses comandos:

```
*for
*grep
*cut
*xargs
*find
*echo
*sed
*awk
*diff
*wc
*seq
sleep
head
tail
*if
expr
*sort
*uniq
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
Agora vamos fazer um grep que utliza a palavra encontrada, para isso vamos utilizar uma funcionalidade chamada substituição de comando, que pode ser utilizada com comandos entre apóstrofo (\`) ou com sifrão e comandos entre parenteses ($()), que faz com que o resultado do comando entre apóstrofos seja utilizado como string pelo comando que está sendo executado.

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
Agora podemos estudar mais um caso do dia a dia, queremos comparar se as chaves dos arquivos de properties de produção e desenvolvimento estão iguais, para isso vamos analisar como fazer essa comparação. O arquivo de properties tem o formato "chave=valor", também possui comentários, linhas iniciando com #, e também possuem linhas em branco.

Dado um arquivo de properties `config.properties.dev`, podemos observar as caracteristicas descritas acima

```properties
# configurações da conexão com o banco
DB_URL=jdbc:mysql://127.0.0.1:3306/meublog
DB_USERNAME=root
DB_PASSWORD=

# configurações gerais
TIMEOUT=1000
RESULT_COUNT=20

```

No arquivo acima, observamos as caracteristicas do arquivo e o que precisamos comparar. Com o comando bash abaixo, podemos fazer essa comparação, e vamos detalhar o que está acontecendo em cada passo.

```bash
for x in `seq 2`;
  do
    if [ $x == 1 ]; then
      echo "---------------------------------------- Chaves a mais no ./config.properties.dev ----------------------------------------";
      diff <(grep -v ^# ./config.properties.dev | grep -v "^[ ]*$" | sort | cut -d = -f 1) <(grep -v ^# ./config.properties.prd | grep -v "^[ ]*$" | sort | cut -d = -f 1) | grep ^[\<] | sed "s/\<\ //g"
    else
      echo "---------------------------------------- Chaves a mais no ./config.properties.prd ----------------------------------";
      diff <(grep -v ^# ./config.properties.dev | grep -v "^[ ]*$" | sort | cut -d = -f 1) <(grep -v ^# ./config.properties.prd | grep -v "^[ ]*$" | sort | cut -d = -f 1) | grep ^[\>] | sed "s/\>\ //g"
    fi;
  done
```

```bash
for x in `seq 2`;
```
Neste exemplo, precisamos fazer duas comparações, uma para identificarmos as chaves que estão faltando no arquivo de desenvolvimento e outra para identificarmos as chaves que estão faltando no arquivo de produção, portando utilizandos o comando `seq 2` que apenas gera uma sequencia de números até 2 e como o `for` executa um comando n vezes o resultado da lista que foi passada depois do argumento `in`. Neste caso usamos o `seq`, apenas para exemplificar que existe uma possibilidade executar quantas vezes forem necessarias o loop utilizando esse comando, mas para o exemplo acima um `for x in 1 2;`, resolveria.

Os comandos `do` e `if` são para criar um bloco e controlar o fluxo de execução respectivamente, não vou entrar em detalhes, pois o `do` não tem muita explicação além de juntar as linhas que serão executas pelo for e o if tem tandos detalhes e opções que sugiro consultar o manual sempre que for necessário a sua utilização, além da comparação de dois valores, existe um comparador para cada tipo de valor, comparadores específicos para arquivos, operadores unários etc.

Vamos direto aos comandos que utilizam os pipes.

O `diff` é um comando que deve receber dois valores para serem comparados, dos comandos que estamos vendo neste post é o unico que tem essa caracteristica e apresentamos como trabalhamos com comandos que possuem duas entradas no bash. Neste caso vamos utilizar o <() que idendificará o resultado de cada uma das entradas do comando, lembrando que isso não funciona como script e somente na linha de comando.

Para podermos comparar os dois arquivos, temos que normalizá-los, pois os valores das chaves de produção serão diferentes das chaves de desenvolvimento. Portanto a normalização aplicada para um arquivo, deve ser a mesma aplicada ao outro. Vamos começar pelo `grep`:

Como vimos anteriormente, o grep pode ser usado para selecionar linhas, mas também para excluir linhas indesejadas. E nesse caso é o que fazeremos:

`grep -v ^# ./config.properties.dev` - vai excluir todas as linhas que são comentário do arquivo properties, restando apenas os dados abaixo:

```properties
DB_URL=jdbc:mysql://127.0.0.1:3306/meublog
DB_USERNAME=root
DB_PASSWORD=

TIMEOUT=1000
RESULT_COUNT=20

```

`grep -v "^[ ]*$"` irá excluir as linhas em branco, resultando em um arquivo bem mais limpo:

```properties
DB_URL=jdbc:mysql://127.0.0.1:3306/meublog
DB_USERNAME=root
DB_PASSWORD=
TIMEOUT=1000
RESULT_COUNT=20
```

`sort` este comando garante que os dados estarão na mesma ordem, pois para o nosso propósito a ordem não nos interessa.

```properties
DB_PASSWORD=
DB_URL=jdbc:mysql://127.0.0.1:3306/meublog
DB_USERNAME=root
RESULT_COUNT=20
TIMEOUT=1000
```

`cut -d = -f 1` e por fim não vamos precisar dos valores depois do sinal de igual (=), e utilizamos o `cut` utilizando como separador de campos o sinal de `=` (-d =) e pegando apenas o primeiro campo (-f 1). Com isso vamos obter a seguinte saída:

```properties
DB_PASSWORD
DB_URL
DB_USERNAME
RESULT_COUNT
TIMEOUT
```

se aplicarmos as mesmas regras para outro arquivo de properties, vamos obter uma saída parecida, com as chaves do outro arquivo e então usamos o diff para comparar os 2 arquivos. O comando diff tem um formato específico de saida, onde são informados os dados que o arquivo da esquerda tem a mais que o arquivo da direita e vice-versa, seguindo a ordem dos arquivos passado no parâmetro do comando diff. Exemplo, dado 2 arquivos com as chaves x e y em um e x e z no outro, obetemos a seguinte saída do comando diff:

```
2c2
< y
---
> z
```

Onde 2c2 é a localização de onde ocorreu a diferença, < y é que a chave y só existe no arquivo passado no primeiro parâmetro do diff e > z é que a chave z só existe no arquivo passado no segundo parâmetro do diff, e só sobrou --- que só é um divisor da comparação feita pelo diff. Portanto sabendo essas informações, agora podemos extrair do diff os valores que nos interessa, que são os que começan com > ou <, e para isso usamos o grep novamente:

```
grep ^[\<] | sed "s/\<\ //g"
```

Onde, `grep ^[\<]` selecionará todas as linhas que comçam com o sinal de <, que são os dados que existem no arquivo passado no primeiro parâmetro. E `sed "s/\<\ //g` apagará o valor `< ` que aparece antes de cada palavra que foi selecionada pelo grep anterior.

portanto chegamos ao final da explicação do que aconteceu por trás dos vários comandos:

```
diff <(grep -v ^# ./config.properties.dev | grep -v "^[ ]*$" | sort | cut -d = -f 1) <(grep -v ^# ./config.properties.prd | grep -v "^[ ]*$" | sort | cut -d = -f 1) | grep ^[\<] | sed "s/\<\ //g"
```

e assim, rodando todos os comandos de uma vez só, descobrimos a seguinte saída:

```
---------------------------------------- Chaves a mais no ./config.properties.dev ----------------------------------------
TIMEOUT
---------------------------------------- Chaves a mais no ./config.properties.prd ----------------------------------
CONNECTION_TIMEOUT
```

Onde podemos identificar quais propriedades estão diferente e que ação devemos tomar.

Agora para finalizarmos nossa lista de comandos, vamos fazer o seguinte exemplo. Digamos que desejamos identificar arquivos duplicados em nosso HD. Para isso não vamos utilizar o nome para identificar a duplicidade mas sim o conteúdo, para isso o comando md5 analísa o conteúdo do arquivo e gera um hash e podemos identificar um arquivo duplicado quando o hash for o mesmo.

exemplo da saída do md5:
```
MD5 (out.txt) = 776429d23139dde20a897f3dfaf99d39
```

Com isso podemos utilizar o comando find para executar o comando md5 para todos os arquivos que desejamos comparar. No nosso exemplo o find faz uma busca em todos os aquivos com extensão .java e salva essa busca em um arquivo out.txt, salvando a busca em um arquivo economizamos tempo de execução para os passos da próxima etapa, pois o calculo do md5 e varrer todos os arquivos .java de um projeto, pode ser demorado, dependendo do tamanho do seu projeto.

```
find . -name "*.java" -exec md5 {} \; >out.txt
```

Com a busca e o calculo do md5 salvas no arquivo out.txt podemos passar para a próxima etapa.

Para identificarmos as duplicidades, vamos fazer o seguinte: sabendo que o hash gerado para um arquivo com o conteúdo duplicado é o mesmo, e o nosso arquivo out.txt possui 3 colunas, uma com o nome do algoritimo utilizado pelo md5, outra com o nome do arquivo e a ultima com o hash, temos que isolar o hash e descobrir quais são duplicados.
Uma maneira que pensei em fazer isso é limpar o conteúdo e listar somente o hash, ordenar e contar os hashs que aparecem mais de uma vez, com isso iremos descobrir todos os hash duplicados e com essa informação podemos consultar novamente o out.txt e listar os arquivos duplicados.

Vamos aos passos:

primeiro vamos limpar as outras informações do arquivo que não nos interessa nesse primeiro momento, também vou utilizar aqui comando `head -5` para mostrar somente as primeiras linhas do aquivo, utilizo isso para quando estou limpando o conteúdo dos que não me interessa e não ser preciso listar o arquivo todo sempre que estou testando um comando:

```
grep -o \=.* out.txt | head -5
```

neste caso obtivemos
```
= 1ae8b96a0f57ed2d588b011885e0d8fc
= 3220485cb6c4671c5f313f153f135e7c
= 7884ee1c6e7aa4fb2aafa801ef394122
= e716fbf5c1e95685dd71d582178d532f
= 34b017e57df545ef70b3206f0af9e634
```

Agora precisamos limpara o `= `, e vamos utilizar novamente o grep, agora excluir o `=` e o ` ` (espaço), que está antes da informação que precisamos.

```
grep -o \=.* out.txt | grep -oE "[^= ].*" | head -5
```
E agora temos a informação limpa:

```
1ae8b96a0f57ed2d588b011885e0d8fc
3220485cb6c4671c5f313f153f135e7c
7884ee1c6e7aa4fb2aafa801ef394122
e716fbf5c1e95685dd71d582178d532f
34b017e57df545ef70b3206f0af9e634
```

no próximo passo, vamos ordernar e mostrar tudo que está repetido:

```
grep -o \=.* out.txt | grep -oE "[^= ].*" | sort | uniq -c | head -5
```

agora obtivemos duas informações, uma coluna com a quantidade de repetições e a outra qual informação se repete:

```
   3 00013973ccb0ea7aac55bc0095665162
   1 000c5b7902459a79e767ba58ead289b8
  10 000daf65224ab503ed8c6330684acc5b
   1 00131e12fb1bd9a730dbcff6f86d847e
   1 0014c253b14ceee66015d12c4537eee5
```

Uma forma de obtermos o hashs com mais de uma repetição é excluir todos que não se repetem, ou seja, o contador só mostra um. Para isso vamos utilizar o recurso do grep que exclui todas as linhas que a expressão regular é válida.

```
grep -o \=.* out.txt | grep -oE "[^= ].*" | sort | uniq -c | grep -v "^[ ]*1 " | head -5
```

E agora nosso comando, já mostra a informação que queremos, o hash de todos os arquivos duplicados.
```
   3 00013973ccb0ea7aac55bc0095665162
  10 000daf65224ab503ed8c6330684acc5b
   2 0ac93dd2e3d9cfb0ee5ede24212ccf37
   2 16d92ba9d6abcb1d96d148ef64b0febd
   2 1b15a5246900027d6a3c6e7adbca059c
```

E por fim a informação de quantidade de repetições não interessa nesse momento e vamos limpá-la para utilizarmos somente o hash dos arquivos que se repetem em um for para listarmos do nosso arquivo out.txt somente as linhas que possuem os hashs que encontramos.

Desta vez limparemos a informação utilizando o awk, que facilita a leitura de colunas de um arquivo separado por espaços.

```
grep -o \=.* out.txt | grep -oE "[^= ].*" | sort | uniq -c | grep -v "^[ ]*1 " | awk '{print $2}'
```

Agora com a lista de hashs duplicados, vamos colocá-la no loop:
```
for i in $(grep -o \=.* out.txt | grep -oE "[^= ].*" | sort | uniq -c | grep -v "^[ ]*1 " | awk '{print $2}');  do echo $i; done | head -5
```

vamos obter o que o loop está processando:

```
0ac93dd2e3d9cfb0ee5ede24212ccf37
16d92ba9d6abcb1d96d148ef64b0febd
1b15a5246900027d6a3c6e7adbca059c
1ddff19b29628f05caf18f1e6cb9fa92
1fdb1c5ee5b4ac9c770e6d9071073182
```

E com o resultado que estamos vendo podemos iterar a lista e imprimir o path de cada arquivo repetido e a quantidade de repetições, no comando `echo`, podemos substituir o `$i` por `$(grep $i out.txt | wc -l)` que vai obter o número de repetições do hash utilizando o comando `wc -l`. E também devemos acrescentar `$(grep $i out.txt | head -1)` para imprimir a linha que contém o path. E finalmente conseguimos obter a informação que estavamos procurando, que são os arquivos que estão duplicados na máquina.

```
for i in $(grep -o \=.* out.txt | grep -oE "[^= ].*" | sort | uniq -c | grep -v "^[ ]*1 " | awk '{print $2}');  do echo $(grep $i out.txt | wc -l) $(grep $i out.txt | head -1); done | head -5
```

Obtemos nosso arquivo final, com a quantidade de repetições que o hash apareceu e o path do arquivo, lembrando que para obter todos os arquivos, devemos retirar o `head -5`

```
2 MD5 (./elo7/src/test/acceptance/vendor/ruby/1.9.1/gems/thread_safe-0.3.5/ext/org/jruby/ext/thread_safe/jsr166e/ConcurrentHashMap.java) = 0ac93dd2e3d9cfb0ee5ede24212ccf37
2 MD5 (./elo7/src/test/acceptance/vendor/ruby/1.9.1/gems/json-1.8.1/java/src/json/ext/StringDecoder.java) = 16d92ba9d6abcb1d96d148ef64b0febd
2 MD5 (./elo7/src/test/acceptance/vendor/ruby/1.9.1/gems/thread_safe-0.3.5/ext/org/jruby/ext/thread_safe/JRubyCacheBackendLibrary.java) = 1b15a5246900027d6a3c6e7adbca059c
2 MD5 (./elo7/src/test/acceptance/vendor/ruby/1.9.1/gems/json_pure-1.8.3/java/src/json/ext/GeneratorService.java) = 1ddff19b29628f05caf18f1e6cb9fa92
2 MD5 (./elo7/src/test/acceptance/vendor/ruby/1.9.1/gems/json_pure-1.8.3/java/src/json/ext/OptionsReader.java) = 1fdb1c5ee5b4ac9c770e6d9071073182
```

```
for i in $(curl -q https://coinmarketcap.com/coins/ | grep -E "volume|currency-name|currency-symbol" | grep -oE "(\<a.*\<)" | cut -d \< -f 1 ); do echo $i | grep -E "currenc|data" | sed "s/\>/ /g" | grep -oE "( .*$)|(data-btc=\"[\.0-9]*\")"; done | xargs -n4 | sed "s/=/ /g" | awk '{ print $4 " " $1"-BTC " $2 " " $5}' | grep -vE "Monthly|BTC Bitcoin" | sort -n | awk '{ print $2 }' | xargs | sed "s/ /,/g"
```
