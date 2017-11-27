---
date: 2017-11-27
category: front-end
tags:
  - javascript
  - web
authors: [tcelestino]
layout: post
title: Credential Managament API
description: Conheça a Credential Managament API e veja como aprender a implementa-la em seu projeto.
---

Nos dias atuais, passamos muito tempo em diversos serviços online. Seja em redes sociais, fóruns, blogs e e-commerce, sabemos que é bastante chato ter que ficar gerenciando manualmente nossos dados de acesso nesses serviços. Existem diversos serviços/aplicativos que gerenciam essas informações, posso citar alguns como o [LastPass](https://www.lastpass.com), [1Password](https://1password.com/), [bitwarden](https://bitwarden.com/), [Dashlane](https://www.dashlane.com/) entre outros. E como nós sabemos, os principais navegadores do mercado também possuem recursos para fazer esse gerenciamento. Pois bem! Mas dai surge uma dúvida: como que fazemos para informar esses dados para os navegadores? Como que consigo integrar meu sistema de login com o navegador? Para resolver essas perguntas, te apresento a [Credential Management API](https://www.w3.org/TR/credential-management-1/), API que pelo o próprio nome já diz, faz o gerenciamento de seus credenciais através do navegador. No momento, apenas o Chrome (Android e desktop) já tem a API implementada. Acredito que logo logo veremos em outros navegadores.

O Credential Management API segue três pilares:

- Permitir acesso com um toque com o seletor de contas;
- Salvar e gerenciar seus dados;
- Simplificar o fluxo de acesso.

Existem diversas maneiras de melhorar o fluxo de uso do seu site com a Credential Managament API, seja para facilitar o login automático, caso o usuário tenha multiplas contas no navegador, tem a opção de escolhar qual conta usar e até mesmo garantir o *logout* dessa conta.

## Como usamos no Elo7

Antes de mostrar a implementação da API, queria exemplificar com usamos a API aqui no [Elo7](https://elo7.com.br).

Utilizamos a Credential Management API no sistema de login na versão web mobile do marketplace (tivemso problemas na implementação na versão desktop) e olhando os dados que obtemos através do Google Analytics, observamos que realmente nossos usuários utilizam os recursos, independente do nível de conhecimento.

![Alt "Gráfico do Google Analytics sobre o uso da Credential Management API"](../images/credential-management-api-1.png)
<div style="text-align: center; font-style: italic">Gráfico de uso da Credential Management API no Elo7</div>

Mas deixamos de conversa e vamos a implementação!

## Implementando a API

Como grande maioria das API's Javascript lançadas hoje em dia, precisamos garantir a segurança das informações. Ou seja, para usar a Credential Management API você vai precisar ter um servidor com uma conexão segura. Em palavras curtas precisa ter o *https* habilitado no seu servidor. Para testar localmente, você pode utilizar o [ngrok](https://ngrok.com/).

O que primeiro precisamos fazer é garantir que a API esteja disponível no navegador. Detalhe: nos exemplos, vou usar o ES6. Caso não tenha conhecimento ou nunca tenha ouvido falar, recomendo [ler isso](https://github.com/lukehoban/es6features).

```javascript
(function() {
	if ('credentials' in navigator) {
		const form = document.forms.login;

		form.addEventListener('submit', () => {
			let cred = new PasswordCredential({
				id: form.elements[0].value,
				password: form.elements[1].value
			});

			navigator.credentials.store(cred).then(() => {
				console.log('Dados salvos')
			}).catch(() => {
				console.log('Não foi possível salvar os dados')
			});
		});
	}
})();
```

No código acima, chamamos o objeto `PasswordCredential` quando é feito um `submit` em um formulário. Será retornado uma [Promise](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript/Reference/Global_Objects/Promise) e passamos para o `navigator.credentials.store`. Pode ler mais sobre o metódo `store`, [leia aqui](https://developers.google.com/web/fundamentals/security/credential-management/store-credentials).

Além de salvar, podemos recuperar informações que já foram salvas. Para isso, precisamos utilizar o `navigator.credentials.get`, que também retornará uma Promise com as informações obtidas através do objeto `cred`. Caso não exista nenhuma informação, será retornado um `null`. Para mais detalhes, [leia aqui](https://developers.google.com/web/fundamentals/security/credential-management/retrieve-credentials).

```javascript
(function() {
	if ('credentials' in navigator) {
		const form = document.forms.login;

		form.addEventListener('submit', () => {
			let cred = new PasswordCredential({
				id: form.elements[0].value,
				password: form.elements[1].value
			});

			navigator.credentials.store(cred).then(() => {
				console.log('Dados salvos')
			}).catch(() => {
				console.log('Não foi possível salvar os dados')
			});
		});

		document.querySelector('.login').addEventListener('click', (evt) => {
			navigator.credentials.get({
				password: true,
				unmediated: true
			}).then((cred) => {
				if (cred) {
					// faz algo
				}
			});

			evt.preventDefault();
		});
	}
})();
```

**Observação: existe um objeto chamado `FederatedCredential`, mas não vamos entrar em detalhes sobre nesse post. Caso queira mais detalhes, recomendo [ler aqui](https://developer.mozilla.org/pt-BR/docs/Web/API/FederatedCredential).**

Como podem observar, passamos para o `navigator.credentials.get` duas informações:

- password: por padrão, o valor é `false`, por isso é preciso setar `true` para recuperar informações do `PasswordCredential`;
- unmediated: quando for `true`, habilita o login automático, sem precisar exibir a interface de seleção de contas.

Podemos criar diversas abordagens, inclusive integrando como serviços de autenticação de terceiros como o [Google Sign-In](https://developers.google.com/identity/sign-in/web/sign-in) e [Facebook Login](https://developers.facebook.com/docs/facebook-login/). Para isso, existe o `federated`, no qual podemos informar em qual serviços será o fornecedor desses dados. Leia mais [aqui](https://developers.google.com/web/fundamentals/security/credential-management/retrieve-credentials).

Vamos melhorar nosso código para melhorar o fluxo de funcionamento caso ele tenha diversas contas. Lembrando que isso é uma abordagem, você pode criar a sua a partir da necessidade de fluxo do projeto.

```javascript
(function() {
	if ('credentials' in navigator) {
		const form = document.forms.login;

		form.addEventListener('submit', function() {
			let cred = new PasswordCredential({
				id: form.elements[0].value,
				password: form.elements[1].value
			});

			navigator.credentials.store(cred).then(() => {
				console.log('Dados salvos');
			}).catch(() => {
				console.log('Não foi possível salvar os dados');
			});
		});

		document.querySelector('.login').addEventListener('click', (evt) => {
			navigator.credentials.get({
				password: true,
				unmediated: true
			}).then((cred) => {
				if (cred) {
					login(cred);
				} else {
					navigator.credentials.get({
						password: true,
						unmediated: false
					}).then((cred) => {
						if(cred) {
							login(cred);
						}
					}).catch((e) => { console.error(e) });
				}
			}).catch((e) => console.error(e));

			evt.preventDefault();
		});
	}
})()
```

Se você percebeu, adicionamos uma função `login` em nosso código. Mas o que vamos ter nela? Como sabe, precisamos fazer o usuário logar em nosso sistema, logo precisamos fazer uma requisição para o nosso sistema. Vou simular que temos uma rota que recebe essas informações.

```javascript
(function() {
	if ('credentials' in navigator) {
		const form = document.forms.login;

		var login = (cred) => {
			cred.idName = 'email';

			fetch('/auth/login', {
				method: 'POST',
				credentials: cred
			}).then((result) => {
				if (result.ok) {
					window.location = '/main/index';
				} else {
					alert('Ocorreu um erro!')
				}
			}).catch((e) => {
				console.error(e);
			});
		};

		form.addEventListener('submit', function() {
			let cred = new PasswordCredential({
				id: form.elements[0].value,
				password: form.elements[1].value
			});

			navigator.credentials.store(cred).then(() => {
				console.log('Dados salvos');
			}).catch(() => {
				console.log('Não foi possível salvar os dados');
			});
		});

		document.querySelector('.login').addEventListener('click', (evt) => {
			navigator.credentials.get({
				password: true,
				unmediated: true
			}).then((cred) => {
				if (cred) {
					login(cred);
				} else {
					navigator.credentials.get({
						password: true,
						unmediated: false
					}).then((cred) => {
						if(cred) {
							login(cred);
						}
					}).catch((e) => { console.error(e) });
				}
			}).catch((e) => console.error(e));

			evt.preventDefault();
		});
	}
})()
```

Passamos para a função `login` o objeto `cred` que será usado no nosso back-end para autenticar os dados do usuário. Fazemos uma requisição AJAX usando a [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch)).

Agora que sabemos como salvar e obter os dados salvos com a Credentinal Management API e integrar com um sistema próprio de autenticação, também podemos garantir o *logout* do usuário em nosso sistema. Para isso, vamos usar o metódo `navigator.credentials.requireUserMediation()`. Leia mais [sobre aqui](https://developers.google.com/web/fundamentals/security/credential-management/retrieve-credentials#sign-out).

```javascript

document.querySelector('.logout').addEventListener('click', (evt) => {

	if ('credentials' in navigator) {
		navigator.credentials.requireUserMediation();
	} else {
		window.location = '/auth/logout';
	}

	evt.preventDefault();
});
```

Como isso, garantimos que o usuário não irá mais logar novamente automaticamente quando acessar novamente o seu sistema.

## Conclusão

Por sem bem simples de implementar, a Credentinal Management API é uma solução bastante útil quando usada para melhorar o processo de login dos usuários em nossos sistemas, agilizando bastante esse processo e mantendo de forma segura essas informações. Claro que será muito mais interessante quando os outros navegadores implementeram a API.

## Refêrencias

* [A Credential Management API - Google Developer](https://developers.google.com/web/fundamentals/security/credential-management/)
* [Credential Management API - Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/API/Credential_Management_API)