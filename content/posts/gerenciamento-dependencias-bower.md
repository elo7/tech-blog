---
title: Gerenciamento de dependências front-end com bower
date: 2015-03-05
authors: [williammizuta]
layout: post
category: front-end
description: Durante o desenvolvimento de um projeto, nos deparamos com diversos problemas que não são exclusivos do mesmo. Muitos destes problemas, como persistência de dados, troca de mensagens assíncronas, transação e segurança, já possuem soluções que foram compiladas em bibliotecas para facilitar o nosso dia-a-dia ao resolver diversos problemas, tanto no back-end quando no front-end.
tags:
  - bower
  - front-end
  - gerenciamento de dependencias
  - produtividade
---

![Bower logo](../images/gerenciamento-dependencias-bower-1.png)

Durante o desenvolvimento de um projeto, nos deparamos com diversos problemas que não são exclusivos do mesmo. Muitos destes problemas, como persistência de dados, troca de mensagens assíncronas, transação e segurança, já possuem soluções que foram compiladas em bibliotecas para facilitar o nosso dia-a-dia ao resolver diversos problemas, tanto no back-end quando no front-end.

Só que essas bibliotecas também podem depender de outras bibliotecas. Então, ao importar uma delas para o nosso projeto, precisamos também importar as suas dependências e as bibliotecas as quais elas necessitam. Além disso, nós podemos querer alterar a versão de uma dependência devido a bugs resolvidos ou a novas funcionalidades.

Enquanto o projeto tem poucas **dependências**, é possível gerenciar estes projetos manualmente, mas com o crescer do projeto e das suas dependências, este gerenciamento manual custará cada vez mais tempo. Para solucionar este problema, existem ferramentas que nos ajudam a gerenciar as dependências de um projeto. No back-end, existem várias ferramentas que nos ajudam a resolver este problema, como é o caso do gradle, do ivy e do maven para Java, sbt para Scala, bundler para Ruby, npm para JavaScript entre outros.

E o mundo front-end? Será que precisamos uma ferramenta que gerencie as dependências? Imagine um caso onde utilizamos jQuery em nosso projeto e queremos utilizar um plugin que necessita dele. Porém ao importar o plugin, verificamos que a funcionalidade não está funcionando e verificando melhor descobrimos que o plugin necessita de uma versão diferente da que estamos utilizando em nosso projeto. Será que existe alguma forma mais simples de resolver este problema? Se tivéssemos uma ferramenta que gerenciasse nossas dependências ao adicionar o plugin, também já seria adicionado uma versão compatível do jQuery.

Existem algumas ferramentas que já resolvem este problema para as dependências Front-End. A mais conhecida e utilizada entre elas é o <a title="Bower" href="http://bower.io/" target="_blank"><strong>Bower</strong></a>, a qual descreveremos a seguir.

## Instalação

Para usar o Bower é necessário que tenhamos o node instalado junto com o npm. Com isso, basta rodarmos **`npm install -g bower`** que teremos o bower em nosso projeto.

## Instalando pacotes

Imagine que você já tem um projeto configurado com o bower. Você pode baixar um exemplo clicando <a title="aqui" href="https://s3.amazonaws.com/files.elo7.com.br/craftedbits/bower/aprendendo-bower.zip" target="_blank">aqui</a>. Ao descompactar, você notará que tem um arquivo chamado **bower.json** na raiz do projeto semelhante ao seguinte:

```json
{
  "name": "aprendendo-bower",
  "version": "0.0.0",
  "authors": [
      "Elo7 <blog@elo7.com>"
  ],
  "dependencies": {
      "jquery": "~2.1.3"
  },
  "devDependencies": {
      "cucumber": "~0.4.7"
  }
}
```

Execute o comando ``bower install`` na raiz do projeto, a ferramenta irá gerar uma pasta chamada **bower_components** que, seguindo o exemplo acima, irá conter as bibliotecas cucumber e jquery.

_Oba! Consegui baixar bibliotecas do projeto! Mas afinal, o que aconteceu?_

O arquivo bower.json é responsável pelas configurações do nosso projeto, é nele que adicionamos as dependências do nosso projeto. Se observarmos o arquivo podemos notar que temos uma configuração "dependencies" onde é declarado a dependência do "jquery", e uma outra configuração chamada  "devDependencies" com a declaração da dependência do "cucumber".

Portanto ao executar o `bower install`, a ferramenta irá ler o arquivo e verificar a versão e os arquivos a qual ele deve baixar.

## Adicionando novas dependências

Supondo que você queira adicionar mais uma dependência, por exemplo, o "backbone", como adicionaria esta dependência ao projeto? Neste caso você pode adicionar na mão alterando o arquivo bower.json ou utilizar o comando `bower install backbone`, este comando irá baixar mais uma biblioteca à sua pasta "bower_components", entretanto esta nova dependência não estará descrita dentro do bower.json. Para adicionar automaticamente, precisamos passar um argumento a mais no comando para dizer para o bower que a nova instalação deve ser salva no arquivo bower.json. Se a sua dependência for apenas para desenvolvimento, o argumento é **`--save-dev`**; se for de produção, **`--save`**. Portanto, para dizer que o backbone é uma dependência de produção, rodamos o comando `bower install backbone --save`.

Ao rodar o comando acima, verificamos que o bower abaixou a biblioteca backbone dentro da pasta bower_components. Mas, não foi só isso que ele abaixou. Ele também instalou uma biblioteca chamada undescore que é necessária para o backbone, ou seja, uma dependência da dependência instalada automaticamente.

Ao final teremos a seguinte estrutura:

```bash
├── bower.json
└── bower_components
    ├── backbone
    ├── cucumber
    ├── jquery
    └── underscore

```

E o seguinte arquivo bower.json:

```json
{
  "name": "aprendendo-bower",
  "version": "0.0.0",
  "authors": [
      "Elo7 <blog@elo7.com>"
  ],
  "dependencies": {
      "jquery": "~2.1.3",
      "backbone": "~1.1.2"
  },
  "devDependencies": {
      "cucumber": "~0.4.7"
  }
}
```

### Como posso saber se a biblioteca é compatível com o bower?

Você pode pesquisar utilizado o comando para busca de pacotes disponíveis na ferramenta, para buscar basta utilizar o comando `bower search <nome-do-pacote>` e será listado uma lista que contêm este termo.

### Mas como começamos um projeto do zero?

Para isso basta executar o comando **bower init** dentro da raiz do projeto, este comando irá gerar as configurações iniciais do projeto a partir das informações que serão solicitadas durante o processo, como o nome, descrição, versão, etc. Ao final, as configurações serão exibidas e pede-se para confirmar se as mesmas estão corretas para gerar o arquivo [bower.json](https://github.com/bower/bower.json-spec).

**Erika Takahara e William Mizuta**
