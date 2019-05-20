---
date: 2019-03-25
category: front-end
tags:
  - javascript
  - npm
authors: [luiz]
layout: post
title: Builds mais rápidos e portáveis com npm-run-all
description: Lutando para deixar o build de sua aplicação Javascript mais rápido? Sofrendo com cadeias intermináveis de comandos num único script npm? Esse post mostra como o pacote npm-run-all pode ajudar.
cover: npm-run-all.png
---

Quando precisamos baixar dependências, compilar arquivos e gerar assets em nossas aplicações, é comum utilizarmos alguma ferramenta para automatizar esse processo. Uma ferramenta que tem se tornado cada vez mais popular para esse fim são os scripts do **npm**. Cada um dos scripts pode ser um comando qualquer de terminal, inclusive uma combinação de comandos usando os operadores `&&`, `|` (*pipe*) e `;`. Além disso, nos scripts do **npm** conseguimos chamar comandos de pacotes **npm** referenciados pelo nosso projeto de forma bem direta. O exemplo abaixo mostra como poderia ser um script para minificar os arquivos Javascript de um projeto.

```json
...
"name": "meuprojeto",
"scripts": {
    "build:js": "concat-cli -f js/*.js -o js/build.js && uglify js/build.js -o js/build.min.js",
    ...
},
...
```

Um olhar atento nos permite perceber alguns problemas com esse script:

- **Só funciona em Linux e Mac OSX**: por usar o operador `&&`, o script não funciona em todas as plataformas.
- **Pouco legível**: conforme a quantidade de comandos ou de parâmetros aumenta, fica cada vez mais difícil entender o que o comando faz.

Podemos até usar os scripts especiais `pre` e `post` (no exemplo, `prebuild:js` e `postbuild:js`) para diminuir esses problemas. Porém, caso nosso script tenha mais de três passos, voltaremos a ter esses mesmos problemas. Podemos tentar dividir um script em mais partes ainda:

```json
...
"name": "meuprojeto",
"scripts": {
    "build:js": "npm run build:js:desktop && npm run build:js:mobile && npm run build:js:app",
    "build:js:desktop": "concat-cli -f js/desktop/*.js -o js/desktop/build.js && uglify js/desktop/build.js -o js/desktop/build.min.js",
    "build:js:mobile": "...",
    ...
},
...
```

Com isso, conseguimos melhorar um pouco a legibilidade de comandos mais complexos mas, ainda assim, temos o problema da compatibilidade entre plataformas. Além disso, surge um novo problema: caso usemos variáveis em nosso `package.json` em nossos scripts, precisamos lembrar de repassá-las em cada uma dessas chamadas `npm run`. Por exemplo:

```json
...
"name": "meuprojeto",
"config": {
    "jsdir": "js"
},
"scripts": {
    "build:js": "npm run build:js:desktop --meuprojeto:jsdir=$npm_package_config_jsdir && npm run build:js:mobile --meuprojeto:jsdir=$npm_package_config_jsdir && npm run build:js:app --meuprojeto:jsdir=$npm_package_config_jsdir",
    "build:js:desktop": "concat-cli -f $npm_package_config_jsdir/desktop/*.js -o $npm_package_config_jsdir/desktop/build.js && uglify $npm_package_config_jsdir/desktop/build.js -o $npm_package_config_jsdir/desktop/build.min.js",
    "build:js:mobile": "...",
    ...
},
...
```

Novamente a legibilidade acaba prejudicada, além de ser um ponto fácil de se esquecer e difícil de perceber (pelo menos pela experiência que tivemos até aqui). Foi com o intuito de resolver esses problemas de uma forma elegante que surgiu o pacote [npm-run-all](https://github.com/mysticatea/npm-run-all).


## Uso básico

Instalar o pacote `npm-run-all` é simples como instalar qualquer pacote `npm`:

```
$ npm install npm-run-all --save-dev
# ou
$ yarn add npm-run-all --dev
```

Uma vez instalado, teremos a nossa disposição o comando `npm-run-all` nos nossos scripts do **npm**. Esse comando recebe uma lista de nomes de scripts do **npm** e executa-os em sequência. Por exemplo, podemos re-escrever o exemplo anterior da seguinte forma:

```json
...
"name": "meuprojeto",
"config": {
    "jsdir": "js"
},
"scripts": {
    "build:js": "npm-run-all build:js:desktop build:js:mobile build:js:app",
    "build:js:desktop": "concat-cli -f $npm_package_config_jsdir/desktop/*.js -o $npm_package_config_jsdir/desktop/build.js && uglify $npm_package_config_jsdir/desktop/build.js -o $npm_package_config_jsdir/desktop/build.min.js",
    "build:js:mobile": "...",
    ...
},
...
```

Repare que não é necessário repassar as variáveis de configuração do `package.json` para cada um dos scripts: o `npm-run-all` já faz isso para nós! Caso um dos scripts não execute corretamente, os scripts seguintes não serão executados, igualzinho o que acontece quando usamos o operador `&&`. Se, por acaso, quisermos que a execução continue no caso de um erro (como se estivéssemos usando o operador `;`), basta usarmos a opção `-c`.

## Facilidades

O `npm-run-all` oferece algumas facilidades para a execução de muitos scripts. Por exemplo, podemos usar a opção `-l` (ou `--print-label`) para que cada linha de saída dos scripts executados receba um rótulo, facilitando a identificação do script executado em cada momento.

```
[build:js:desktop] Excluindo arquivos gerados anteriormente
[build:js:desktop] Concatenando...
[build:js:desktop] Minificando build.js
[build:js:desktop] Concluído
[build:js:mobile] Excluindo arquivos gerados anteriormente
[build:js:mobile] Concatenando...
[build:js:mobile] Minificando build.js
[build:js:mobile] Concluído
...
```

Mais interessante ainda: caso usemos a nomenclatura `script:subscript` para nomear nossos scripts, conseguimos especificar um conjunto de scripts para ser executado usando o operador `*`. Por exemplo:

```json
...
"name": "meuprojeto",
"config": {
    "jsdir": "js"
},
"scripts": {
    "build:js": "npm-run-all build:js:*",
    "build:js:desktop": "concat-cli -f $npm_package_config_jsdir/desktop/*.js -o $npm_package_config_jsdir/desktop/build.js && uglify $npm_package_config_jsdir/desktop/build.js -o $npm_package_config_jsdir/desktop/build.min.js",
    "build:js:mobile": "...",
    ...
},
...
```

Os scripts serão executados na ordem em que foram especificados no `package.json`. Assim, no exemplo acima, ao executar o script `build:js`, o script `build:js:desktop` seria executado e, em seguida, o script `build:js:mobile`.

## Paralelismo

Quando dividimos nossos scripts em pequenas partes e essas partes são independentes umas das outras, ganhamos a possibilidade de executá-los em paralelo. No exemplo anterior, poderíamos executar os scripts `build:js:desktop` e `build:js:mobile` em paralelo.

Sem o `npm-run-all` e em um ambiente Linux ou Mac OSX, poderíamos atingir esse objetivo usando o operador `&`:

```json
...
"name": "meuprojeto",
"scripts": {
    "build:js": "npm run build:js:desktop & npm run build:js:mobile",
    "build:js:desktop": "concat-cli -f js/desktop/*.js -o js/desktop/build.js && uglify js/desktop/build.js -o js/desktop/build.min.js",
    "build:js:mobile": "...",
    ...
},
...
```

Porém, novamente estaríamos usando uma solução não portável, além de não termos muito controle sobre a execução paralela. Agora, com o `npm-run-all`, executar scripts em paralelo de forma portável torna-se muito simples!

```json
...
"name": "meuprojeto",
"scripts": {
    "build:js": "npm-run-all -p build:js:*",
    "build:js:desktop": "concat-cli -f js/desktop/*.js -o js/desktop/build.js && uglify js/desktop/build.js -o js/desktop/build.min.js",
    "build:js:mobile": "...",
    ...
},
...
```

Repare que a forma de usar o `npm-run-all` não muda praticamente nada, só uma opção a mais na chamada já faz com que a execução seja paralela.

Além de tornar a execução paralela de scripts mais fácil e portável, o `npm-run-all` provê alguns recursos para controlar essa execução. Por exemplo, podemos controlar o nível de paralelismo, que por padrão é ilimitado, com a opção `--max-parallel <n>`, em que `n` é o número máximo de tarefas que aceitamos executar paralelamente. Também há a opção `--race` ou `-r`, que faz com que o `npm-run-all` encerre todos os scripts em execução paralela assim que o primeiro terminar.

A opção `-l` torna-se especialmente interessante no modo de execução paralelo, pois nos permite verificar o paralelismo e entender melhor a saída dos scripts. Por exemplo, se tivermos o seguinte `package.json`:

```json
...
"name": "meuprojeto",
"scripts": {
    "build:js": "npm-run-all -l -p build:js:*",
    "build:js:desktop": "concat-cli -f js/desktop/*.js -o js/desktop/build.js && uglify js/desktop/build.js -o js/desktop/build.min.js",
    "build:js:mobile": "...",
    ...
},
...
```

E executarmos o script `build:js`, é possível que tenhamos a seguinte saída:

```
[build:js:desktop] Excluindo arquivos gerados anteriormente
[build:js:mobile] Excluindo arquivos gerados anteriormente
[build:js:desktop] Concatenando...
[build:js:mobile] Concatenando...
[build:js:desktop] Minificando build.js
[build:js:mobile] Minificando build.js
[build:js:desktop] Concluído
[build:js:mobile] Concluído
...
```

Se quisermos tornar a saída mais organizada mesmo numa execução paralela, podemos passar a opção `--aggregate-output`. Com ela, o `npm-run-all` vai armazenando a saída de um script até que ele termine sua execução para, só então, imprimir a saída completa, evitando que a saída dos subscripts apareça intercalada.

## run-p, run-s e execuções avançadas

Para facilitar ainda mais a nossa vida, o pacote `npm-run-all` fornece mais dois **comandos**: o `run-s` e o `run-p`. Eles são atalhos para o `npm-run-all` e o `npm-run-all -p`, respectivamente. Ou seja, podemos re-escrever o último exemplo da seguinte forma:

```json
...
"name": "meuprojeto",
"scripts": {
    "build:js": "run-p -l build:js:*",
    "build:js:desktop": "concat-cli -f js/desktop/*.js -o js/desktop/build.js && uglify js/desktop/build.js -o js/desktop/build.min.js",
    "build:js:mobile": "...",
    ...
},
...
```

Repare que podemos passar a opção `-l` para o `run-p` também. Ambos os comando aceitam *praticamente todas* as opções do `npm-run-all`. As exceções são as opções `-s` e `-p`, já que o `run-s` e o `run-p` são abreviações dessas opções, e, no caso do `run-s`, as opções `--max-parallel` e `-r`, que só fazem sentido na execução paralela.

Mas então quando usar o comando `npm-run-all` diretamente? Imagine que queremos criar um script que processa paralelamente arquivos Javascript e CSS do projeto e, em seguida, acrescenta uma assinatura MD5 ao nome dos arquivos e envia-os a um servidor. Esses dois últimos passos não podem ser executados em paralelo, então temos um fluxo de processamento misto, com partes paralelas e partes sequenciais. Podemos fazer isso num único comando com o `npm-run-all`:

```json
...
"name": "meuprojeto",
"scripts": {
    "deploy": "npm-run-all -l -p build:* -s md5 upload",
    "build:js": "concat-cli ...",
    "build:css": "node-sass ...",
    "md5": "...",
    "upload": "scp ..."
},
...
```

Conforme vamos passando as opções `-s` e `-p`, o `npm-run-all` vai alternando a forma de execução dos scripts passados como parâmetro. Assim, conseguimos combinações bastante flexíveis!

Contudo, recomendo quebrar o script em tarefas menores sempre que possível, para facilitar a legibilidade e a manutenção do `package.json`. No exemplo acima, poderíamos fazer da seguinte forma:

```json
...
"name": "meuprojeto",
"scripts": {
    "deploy": "run-s -l md5 upload",
    "build": "run-p -l build:*",
    "build:js": "concat-cli ...",
    "build:css": "node-sass ...",
    "md5": "...",
    "upload": "scp ..."
},
...
```

Vale observar, também, que os scripts `pre` e `post` do **npm** funcionam normalmente com o `npm-run-all`, o que significa que podemos quebrar ainda mais nossos scripts sem precisar necessariamente complicar os scripts de nível mais alto. Por exemplo, caso queiramos concatenar, compilar e minificar os arquivos Javascript no exemplo anterior, podemos fazer:

```json
...
"name": "meuprojeto",
"scripts": {
    "deploy": "run-s -l md5 upload",
    "build": "run-p -l build:*",
    "prebuild:js": "concat-cli ...",
    "build:js": "babel-node ...",
    "postbuild:js": "uglify ...",
    "build:css": "node-sass ...",
    "md5": "...",
    "upload": "scp ..."
},
...
```

Dessa forma, cada script fica com uma única responsabilidade bem definida e o fluxo de execução fica bem definido, sem muita complicação na especificação:

```
       +--> prebuild:js +-> build:js +-> postbuild:js +
deploy |                                              +-> md5 +-> upload
       +--> build:css +-------------------------------+
```

## Conclusão

Usar o `package.json` para especificar os scripts de que sua aplicação depende é uma prática cada vez mais comum mas que, como toda tecnologia, tem suas limitações. O `npm-run-all` soluciona algumas dessas limitações de forma bastante elegante, tornando os scripts **npm** ainda mais interessantes como ferramenta de desenvolvimento.

Contudo, vale sempre o cuidado e o bom senso para não abusar de suas funcionalidades. Uma especificação de dependências entre scripts muito complexa pode tornar o projeto muito difícil de manter, e as facilidades que o `npm-run-all` traz tornam mais fácil escrever uma especificação complexa.

Vale observar, também, que o `npm-run-all` não é a única ferramenta que fornece esse tipo de funcionalidade. A biblioteca [concurrently](https://github.com/kimmobrunfeldt/concurrently) também permite a execução paralela de scripts, dá mais controle sobre a entrada e saída dos scripts, reinicia scripts que falharam, dentre outras funcionalidades.

Você já usou ou usa o `npm-run-all`, o `concurrently` ou outra ferramenta similar? Conte para nós sua experiência!
