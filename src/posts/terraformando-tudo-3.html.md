---
title: Terraformando tudo - parte 3
date: 2017-09-18
category: devops
layout: post
description: Terceiro post da série 'Terraformando Tudo', que conta a nossa trajetória em busca da codificação da nossa infraestrutura. Neste post mostraremos como "terraformar" uma infra já existente.
authors: [lucasvasconcelos]
tags:
  - devops
  - terraform
  - iac
  - infrastructure as code
  - infra
cover: terraformando-tudo-3.jpg
---

Veja os outros *posts* da série:
- [Terraformando tudo - parte 1](/terraformando-tudo-1/)
- [Terraformando tudo - parte 2](/terraformando-tudo-2/)

Olár!

Como foi prometido no [segundo post](/terraformando-tudo-2/), estamos aqui novamente. Agora, para responder uma das perguntas que sempre são feitas na hora de adotar uma nova ferramenta: "E o legado?"

No contexto de Infraestrutura como Código, o legado é a infra já existente. No caso do Elo7, são todos os recursos criados "na base do mouse" pelo console da AWS.

Também é válido lembrar que esse cenário não ocorre apenas com ambientes legados. Ele pode ocorrer em uma situação de emergência, onde o plantonista ou time responsável é obrigado a fazer alguma alteração na infra via console/interface web para corrigir algum problema. Nesse caso também teremos inconsistências entre o estado encontrado no código e no *provider*.

## O caminho inverso

Se até agora o Terraform gerou estados baseados no código, agora vamos fazer o caminho inverso: vamos gerar estados de uma infra já existente no *provider* e escrever código que se encaixa nesse estado.

O Terraform vai nos ajudar na primeira parte do caminho, gerando os estados da infra existente através do [comando `import`](https://www.terraform.io/docs/import/index.html).

Antes das demonstrações, devemos nos atentar às limitações dessa funcionalidade:
- Os `resources` suportados pelo `import` do Terraform não são os mesmos que temos à disposição para criar do zero no Terraform. Ou seja, nem todos recursos que podem ser criados através do código podem ser importados. A boa notícia é que a cada nova *release* do Terraform (que possui ciclo de vida de aproximadamente 20 dias) novos recursos para importação são adicionados. Em um caso onde o recurso (Redshift, Lambda, etc) não for suportado pelo `import`, pode-se criar um estado manualmente ou utilizar ferramentas de terceiros. [Uma lista dos `resources` suportados atualmente pode ser vista aqui](https://www.terraform.io/docs/import/importability.html). E, caso quiser, é relativamente fácil fazer com que um `resource` seja "importável", como pode ser visto nesse [PR](https://github.com/hashicorp/terraform/pull/15237/files);
- O `import` não gera código! Ele gera o estado daquele recurso apenas, cabendo a nós a escrita do código referente ao estado gerado.

Com esses pontos em mente, vamos ver como podemos utilizar o `import`.

## Usando o `import`

Para o `import`, devemos ter em mãos três informações (mais informações sobre o *pattern* do Terraform [no segundo post](/terraformando-tudo-2/)):
- Tipo do recurso
- Nome do recurso
- ID do recurso na AWS

Vamos ver como funciona o `import` de uma instância EC2?

### Importando um `resource`

O exemplo a seguir mostra o `import` de uma instância existente na AWS. Primeiro, vamos nomear nossas variáveis:
- **Tipo do recurso:** `aws_instance`
- **Nome do recurso:** `elo7-ec2-example`
- **ID do recurso na AWS:** `i-a1b2c3` (Como a instância já existe na AWS, temos o ID dela)

Agora, vamos rodar o `import` (sim! É apenas um comando!):

```python
$ terraform import aws_instance.elo7-ec2-example i-a1b2c3
```

Onde

```python
$ terraform  import  aws_instance.elo7-ec2-example  i-a1b2c3
|__________| |_____| |___________| |______________| |______|
      |       |           |           |                |
Comando do    |        Tipo de        |         ID do resource
 Terraform    |        Resource       |            na AWS
              |                       |
          Funcionalidade         Nome do resource
            de import             no Terraform
```

Ao executar o comando, temos uma saída dizendo que tudo correu bem:

```
$ terraform import aws_instance.elo7-ec2-example i-a1b2c3
aws_instance.elo7-ec2-example: Importing from ID "i-a1b2c3"...
aws_instance.elo7-ec2-example: Import complete!
  Imported aws_instance (ID: i-a1b2c3)
aws_instance.elo7-ec2-example: Refreshing state... (ID: i-a1b2c3)

Import success! The resources imported are shown above. These are
now in your Terraform state. Import does not currently generate
configuration, so you must do this next. If you do not create configuration
for the above resources, then the next `terraform plan` will mark
them for destruction
```

E por último, mas não menos importante, o estado que o Terraform gera:

```python
"aws_instance.elo7-ec2-example": {
    "type": "aws_instance",
    "depends_on": [],
    "primary": {
        "id": "i-a1b2c3",
        "attributes": {
            "ami": "ami-z9e334",
            "availability_zone": "us-west-1a",
            "disable_api_termination": "false",
            "ebs_block_device.#": "0",
            "ebs_optimized": "false",
            "ephemeral_block_device.#": "0",
            "iam_instance_profile": "example-web-app",
            "id": "i-a1b2c3",
            "instance_state": "running",
            "instance_type": "t2.large",
            "key_name": "key-web-app",
            "monitoring": "false",
            "network_interface_id": "eni-5643f442",
            "private_dns": "ip-10-0-3-54.us-west-1.compute.internal",
            "private_ip": "10.0.3.54",
            "public_dns": "",
            "public_ip": "",
            "root_block_device.#": "1",
            "root_block_device.0.delete_on_termination": "true",
            "root_block_device.0.iops": "100",
            "root_block_device.0.volume_size": "8",
            "root_block_device.0.volume_type": "gp2",
            "security_groups.#": "0",
            "source_dest_check": "true",
            "subnet_id": "subnet-674f3556",
            "tags.%": "3",
            "tags.Name": "web-app",
            "tags.env": "dev",
            "tenancy": "default",
            "user_data": "d2a580ddfbcb7e5ba2e00833805981ac61d500df",
            "vpc_security_group_ids.#": "1",
            "vpc_security_group_ids.4021914259": "sg-8f38de4"
        },
        "meta": {
            "schema_version": "1"
        },
        "tainted": false
    },
    "deposed": [],
    "provider": "aws"
}
```

Pronto! Já rodamos o `import` e possuímos nossa infra criada manualmente no idioma do Terraform! :)

Mas lembram que isso é só a primeira parte do caminho? Esse comando não gera o código, e isso pode trazer consequências gravíssimas, pois **podemos destruir a infra que acabamos de importar**.

Sim, isso é possível. Porque, no momento em que um `apply` for executado, o Terraform irá tentar destruir a infra que não existe em seu código e existe em seu estado que, [como já vimos](/terraformando-tudo-1/), é o comportamento esperado. Para provar esse ponto, vejamos a saída de um `terraform plan`:

```python
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.

aws_instance.elo7-ec2-example: Refreshing state... (ID: i-a1b2c3)

The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

- aws_instance.elo7-ec2-example


Plan: 0 to add, 0 to change, 1 to destroy.
```

**NUNCA execute o `apply` nesse momento :|**

## Segunda parte do caminho: escrevendo o código

Temos duas opções:
- Escrever o código manualmente;
- Gerar o código utilizando a ferramenta [terraforming](https://github.com/dtan4/terraforming) (essa ferramenta é específica para recursos na AWS).

A escolha mais correta é utilizar uma ferramenta que vai fazer o trabalho para nós mas, por questões didáticas, vamos mostrar o processo de escrita manual do código.

Para fazer isso, devemos pegar as informações relevantes do estado e gerar um *configuration*. Nesse caso, estamos importando uma instância EC2 e vamos precisar retirar do estado as seguintes informações:
- **Nome do resource:** `elo7-ec2-example`
- **ID da AMI:** `ami-z9e334`
- **Tipo da instância:** `t2.large`
- **Nome da chave:** `key-web-app`
- **ID da subnet:** `subnet-674f3556`
- **Security groups:** `sg-8f38de4`
- **IAM Instance Profile:** `example-web-app`
- **EC2 Tags:** `Name: web-app, env: test`

Cada `resource` depende de um conjunto mínimo de informações para que possa ser definido. Mais informações podem ser vistas na [documentação oficial](https://www.terraform.io/docs/).

Com os dados obtidos, podemos gerar o código:

```python
resource aws_instance "elo7-ec2-example" {
    ami = "ami-z9e334"
    instance_type = "t2.large"
    key_name = "key-web-app"
    subnet_id = "subnet-674f3556"
    vpc_security_group_ids = [ "sg-8f38de4" ]
    iam_instance_profile = "example-web-app"

    tags {
        Name = "web-app"
        env = "test"
    }
}
```

Podemos testar nosso código executando o comando `plan`. O sucesso da importação se dá quando esse comando indica que nenhuma mudança será feita, nos dizendo que não há inconsistências entre código e estado:

```python
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.

aws_instance.elo7-ec2-example: Refreshing state... (ID: i-a1b2c3)

No changes. Infrastructure is up-to-date. This means that Terraform
could not detect any differences between your configuration and
the real physical resources that exist. As a result, Terraform
doesn't need to do anything.
```

No dia-a-dia, com certeza iremos preferir utilizar a ferramenta `terraforming` citada acima. Nós já usamos ela bastante por aqui e não tivemos problemas. Mais informações sobre como utilizá-la podem ser vistas [na página da ferramenta](https://github.com/dtan4/terraforming).

## Conclusões

Esperamos ter respondido com clareza a resposta da pergunta "E o legado?" quando se trata de Infraestrutura como Código e Terraform.

É recomendado que, ao utilizar o comando `import`, o usuário já possua alguma vivência com o Terraform e conheça bem os conceitos dos `resources` que serão importados, pois existem pontos do procedimento nos quais os estados são inconsistentes e um comando errado pode causar catástrofes. Cuidado com `resources` como registros de DNS e *load balancers*.

Um outro detalhe foi que, aqui no Elo7, não saímos importando tudo que já existia de uma vez, decidimos fazer por demanda. Assim, quando uma mudança na infra de uma aplicação era necessária, aproveitávamos e fazíamos o `import`.

Logo voltamos com mais posts sobre Terraform! Obrigado! :D
