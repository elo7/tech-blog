<!doctype html>
<html lang="pt-br">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="{{document.description}}">
	<meta name="google-site-verification" content="NqCILBTY8B8P-r_KF8BSZKH9kUQgQOEbXJvEMaB33vw">
	<meta name="theme-color" content="#FDC24F">
	<meta name="keywords" content="Elo7,tecnologia,post,desenvolvimento,blog,{{document.tags}}">
	<meta name="language" content="pt-br">
	<meta name="title" content="Elo7 Tech - {{document.title}}">
	<meta name="apple-mobile-web-app-title" content="Elo7 Tech - {{document.title}}">
	<meta name="mobile-web-app-capable" content="yes">

	<meta property="fb:app_id" content="644444999041914">
	<meta property="fb:admins" content="100003324447975">

	<meta property="og:site_name" content="Elo7 Tech">
	<meta property="og:image" content="{{site.url}}/images/ico/elo7.png">
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

    <link rel="canonical" href="{{site.url}}">
    <link rel='amphtml' href='{{site.url}}/amp/{{document.slug}}/' />

	<title>Elo7 Tech - {{document.title}}</title>
	<link rel="stylesheet" href="/reset.css">
	<link rel="stylesheet" href="/main.css">
	<link rel="stylesheet" href="/posts.css">
	<link rel="stylesheet" href="/post.css">
	<link rel="icon" type="image/png" href="/images/favicon.ico">
	<script>window.addEventListener('error', window.__e=function f(e){f.q=f.q||[];f.q.push(e)});</script>
	<script src="/js/vendor/async-define.js"></script>
</head>
<body itemscope itemtype="http://schema.org/WebPage" data-env="{{getEnvironment}}">
	<header class="left-pane">
		<div class="logo-container">
			<a rel="home" itemprop="url" href="/" class="logo">{{site.title}}</a>
		</div>
		<nav aria-label="Navigation" itemscope itemtype="http://schema.org/SiteNavigationElement" class="navigation">
			<input id="categories-switch" type="checkbox" class="categories-switch">
			<label for="categories-switch" class="selectable">
				<h2 class="nav-title">Categorias</h2>
			</label>
			<ul class="nav-list nav-category">
				{{#each (getCategories)}}
					<li itemscope itemtype="http://schema.org/SiteNavigationElement">
						<a itemprop="url" href="/{{category}}">
							<span itemprop='name'>{{category}}</span>
						</a>
					</li>
				{{/each}}
			</ul>
			<input id="more-switch" type="checkbox" class="more-switch">
			<label for="more-switch" class="selectable">
				<h2 class="nav-title">Veja também</h2>
			</label>
			<ul class="nav-list nav-more">
				<li itemscope itemtype="http://schema.org/SiteNavigationElement">
					<a itemprop='url' href="http://carreira.elo7.com.br/engenharia/" target="_blank">
						<span itemprop='name'>A engenharia</span>
					</a>
				</li>
				<li itemscope itemtype="http://schema.org/SiteNavigationElement">
					<a itemprop="url" href="http://carreira.elo7.com.br/" target="_blank">
						<span itemprop='name'>Carreiras</span>
					</a>
				</li>
				<li itemscope itemtype="http://schema.org/SiteNavigationElement">
					<a itemprop="url" href="http://eventos.elo7.com.br/" target="_blank">
						<span itemprop='name'>Nossos eventos</span>
					</a>
				</li>
				<li itemscope itemtype="http://schema.org/SiteNavigationElement">
					<a itemprop="url" href="http://elo7.com.br/" target="_blank">
						<span itemprop='name'>Elo7</span>
					</a>
				</li>
			</ul>
		</nav>
		<a rel="external" itemprop="url" href="https://github.com/elo7/tech-blog" class="social github"></a>
	</header>
	<main aria-label="Main content" itemscope itemtype="http://schema.org/Blog">
		{{{content}}}
	</main>
	<footer itemscope itemtype="http://schema.org/Organization">
		<a rel="home" itemprop="url" href="http://engenharia.elo7.com.br/" >
			engenharia.elo7.com.br © 2017
		</a>
		<meta itemprop="name" content='Elo7 Serviços de Informática SA'/>
	</footer>
	<script async src="https://www.google-analytics.com/analytics.js"></script>
	<script async src="/js/analytics.js"></script>
	<script async src="/js/github.js"></script>
	<script async src="/js/vendor/events-amd.js"></script>
	<script async src="/js/vendor/ajax.js"></script>
	<script async src="/js/vendor/doc.js"></script>
</body>
</html>
