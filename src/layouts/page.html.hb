<!doctype html>
<html lang="pt-br">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="{{document.description}}">
	<meta name="google-site-verification" content="NqCILBTY8B8P-r_KF8BSZKH9kUQgQOEbXJvEMaB33vw">
	<meta name="google-site-verification" content="cKh-stJM3_ENNfMjaBIIyYiDgMXZFpRkoH8eQTcPwhM" />
	<meta name="google-site-verification" content="6Er6NBhORIKrEwdS46h772O_7LTE9vWgZjwtzuZ5gpQ" />
	<meta name="theme-color" content="#FDC24F">
	<meta name="keywords" content="Elo7,tecnologia,post,desenvolvimento,blog,{{toLowerCase document.tags}}">
	<meta name="language" content="pt-br">
	<meta name="title" content="Elo7 Tech - {{document.title}}">
	<meta name="apple-mobile-web-app-title" content="Elo7 Tech - {{document.title}}">
	<meta name="mobile-web-app-capable" content="yes">

	<meta property="fb:app_id" content="644444999041914">
	<meta property="fb:admins" content="100003324447975">

	<meta property="og:site_name" content="Elo7 Tech">
	<meta property="og:image" content="{{site.url}}/{{getCoverUri document.cover}}">
	<meta property="og:type" content="website">
	<meta property="og:title" content="Elo7 Tech - {{document.title}}">
	<meta property="og:url" content="{{site.url}}{{document.url}}">
	<meta property="og:description" content="{{document.description}}">

	<meta name="twitter:widgets:csp" content="on">
	<meta name="twitter:card" content="summary_large_image">

	<meta property="twitter:title" content="Elo7 Tech - {{document.title}}">
	<meta property="twitter:domain" content="{{site.url}}">
	<meta property="twitter:url" content="{{site.url}}{{document.url}}">
	<meta property="twitter:description" content="{{document.description}}">
	<meta property="twitter:image" content="{{site.url}}/images/ico/elo7.png">

	<link rel="canonical" href="{{site.url}}{{document.url}}">
	{{#hasAmpPage document.slug}}
		<link rel='amphtml' href='{{site.url}}/{{getAmpURI document.slug}}' />
	{{/hasAmpPage}}

	<title>Elo7 Tech - {{document.title}}</title>
	<link rel="stylesheet" href="/reset.css">
	<link rel="stylesheet" href="/main.css">
	<link rel="stylesheet" href="/posts.css">
	<link rel="stylesheet" href="/post.css">
	<link rel="icon" href="/images/favicon/favicon-16.png" sizes="16x16">
	<link rel="icon" href="/images/favicon/favicon-32.png" sizes="32x32">
	<link rel="icon" href="/images/favicon/favicon-48.png" sizes="48x48">
	<link rel="icon" href="/images/favicon/favicon-64.png" sizes="64x64">
	<link rel="icon" href="/images/favicon/favicon-96.png" sizes="96x96">
	<link rel="icon" href="/images/favicon/favicon-128.png" sizes="128x128">
	<link rel="icon" href="/images/favicon/favicon-160.png" sizes="160x160">
	<link rel="icon" href="/images/favicon/favicon-192.png" sizes="192x192">
	<link rel="apple-touch-icon-precomposed" sizes="180x180" href="/images/favicon/favicon-180.png">
	<link rel="apple-touch-icon-precomposed" sizes="152x152" href="/images/favicon/favicon-152.png">
	<link rel="apple-touch-icon-precomposed" sizes="144x144" href="/images/favicon/favicon-144.png">
	<link rel="apple-touch-icon-precomposed" sizes="120x120" href="/images/favicon/favicon-120.png">
	<link rel="apple-touch-icon-precomposed" sizes="114x114" href="/images/favicon/favicon-114.png">
	<link rel="apple-touch-icon-precomposed" sizes="76x76" href="/images/favicon/favicon-76.png">
	<link rel="apple-touch-icon-precomposed" sizes="72x72" href="/images/favicon/favicon-72.png">
	<link rel="apple-touch-icon-precomposed" sizes="60x60" href="/images/favicon/favicon-60.png">
	<link rel="apple-touch-icon-precomposed" sizes="57x57" href="/images/favicon/favicon-57.png">
	<link rel="apple-touch-icon-precomposed" href="/images/favicon/favicon-precomposed.png">
	<script>window.addEventListener("error", window.__e=function f(e){f.q=f.q||[];f.q.push(e)});</script>
	<script src="/js/vendor/async-define.js"></script>
</head>
<body itemscope itemtype="http://schema.org/WebPage" data-env="{{getEnvironment}}" data-ga-code="{{getGaCode}}" class="{{document.bodyClassName}}">
	<header class="left-pane">
		<div class="logo-container">
			<a rel="home" itemprop="url" href="/" class="logo">Tech Blog Elo7</a>
		</div>
		<div itemscope itemtype="http://schema.org/SiteNavigationElement" class="navigation">
			<input id="categories-switch" type="checkbox" class="categories-switch">
			<label for="categories-switch" class="selectable">
				<h2 class="nav-title">Categorias</h2>
			</label>
			<nav aria-label="Navegue pelas categorias do nosso blog" class="nav-list nav-category">
				{{#each (getCategories)}}
					<a itemprop="url" href="/{{category}}/" itemscope itemtype="http://schema.org/SiteNavigationElement">
						<span itemprop="name">{{title}}</span>
					</a>
				{{/each}}
			</nav>
		</div>
		<div class="navigation">
			<input id="more-switch" type="checkbox" class="more-switch">
			<label for="more-switch" class="selectable">
				<h2 class="nav-title">Veja também</h2>
			</label>
			<nav class="nav-list nav-more" aria-label="Navegue pelos links relacionados ao Elo7">
				<a itemscope itemtype="http://schema.org/SiteNavigationElement" itemprop="url" href="http://carreira.elo7.com.br/engenharia/" target="_blank">
					<span itemprop="name">A engenharia</span>
				</a>
				<a itemscope itemtype="http://schema.org/SiteNavigationElement" itemprop="url" href="http://carreira.elo7.com.br/" target="_blank">
					<span itemprop="name">Carreiras</span>
				</a>
				<a itemscope itemtype="http://schema.org/SiteNavigationElement" itemprop="url" href="http://eventos.elo7.com.br/" target="_blank">
					<span itemprop="name">Nossos eventos</span>
				</a>
				<a itemscope itemtype="http://schema.org/SiteNavigationElement" itemprop="url" href="http://elo7.com.br/" target="_blank">
					<span itemprop="name">Elo7</span>
				</a>
			</nav>
		</div>
		<div class='social'>
			<a title="Github do Elo7" rel="external" itemprop="url" href="https://github.com/elo7" target="_blank" class="github">Github do Elo7</a>
			<a title="Twitter do Elo7" rel="external" itemprop="url" href="https://twitter.com/elo7tech" target="_blank" class="twitter">Twitter do Elo7</a>
			<a title='RSS do Elo7' rel="external" itemprop="url" href="{{site.url}}/rss.xml" target="_blank" class="rss">RSS do Elo7</a>
			<a title='Newsletter do Elo7' rel="external" itemprop="url" href="http://eepurl.com/cVUwvH" target="_blank" class="email">Newsletter do Elo7</a>
		</div>
	</header>
	<main aria-label="Main content" itemscope itemtype="http://schema.org/Blog">
		{{{content}}}

		{{#if document.isPaged}}
			{{#over document.page.count 1}}
				<nav class="container pagination" role="navigation" itemscope itemtype="http://schema.org/SiteNavigationElement">
					{{#if hasPrevPage}}
						<a class="back btn" href="{{site.baseUrl}}{{../getPrevPage}}">anterior</a>
					{{else}}
						<span class="back disabled">anterior</span>
					{{/if}}

					<span>
						Página {{sum document.page.number 1}} de {{document.page.count}}
					</span>

					{{#if hasNextPage}}
						<a class="next btn" href="{{site.baseUrl}}{{../getNextPage}}">próximo</a>
					{{else}}
						<span class="next disabled">próximo</span>
					{{/if}}
				</nav>
			{{/over}}
		{{/if}}
	</main>
	<footer itemscope itemtype="http://schema.org/Organization">
		<a rel="home" itemprop="url" href="https://engenharia.elo7.com.br/" >
			engenharia.elo7.com.br © 2017
		</a>
		<meta itemprop="name" content="Elo7 Serviços de Informática SA"/>
		<section class='footer-social'>
			<a title='Github do Elo7' rel='external' itemprop='url' href='https://github.com/elo7' target='_blank' class='github'>Github do Elo7</a>
			<a title='Twitter do Elo7' rel='external' itemprop='url' href='https://twitter.com/elo7tech' target='_blank' class='twitter'>Twitter do Elo7</a>
			<a title='RSS do Elo7' rel='external' itemprop='url' href='{{site.url}}/rss.xml' target='_blank' class='rss'>RSS do Elo7</a>
			<a title='Newsletter do Elo7' rel='external' itemprop='url' href='http://eepurl.com/cVUwvH' target='_blank' class='email'>Newsletter do Elo7</a>
		</section>
	</footer>
	<script async src="https://www.google-analytics.com/analytics.js"></script>
	<script async src="/js/analytics.js"></script>
	<script async src="/js/github.js"></script>
	<script async src="/js/vendor/events-amd.js"></script>
	<script async src="/js/vendor/ajax.js"></script>
	<script async src="/js/vendor/doc.js"></script>
	<script async type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
</body>
</html>
