---
layout: page
---
<link rel="stylesheet" href="/publisher.css">

<article class='publisher-info' itemscope itemtype='http://schema.org/Person'>
	<section class='info'>
		<h1 class='name' itemprop='name' data-author='{{document.publisher}}' class='publisher'>{{document.publisher}}</h1>
		<a itemprop='url' href='https://github.com/{{document.github}}' class='social github' target='_blank' title='Conheça meu github'>{{document.github}}</a>
		{{#document.twitter}}
			<a itemprop='url' href='https://twitter.com/{{.}}' class='social twitter' target='_blank' title='Conheça meu twitter'>{{.}}</a>
		{{/document.twitter}}
		{{#document.linkedin}}
			<a itemprop='url' href='https://www.linkedin.com/in/{{.}}' class='social linkedin' target='_blank' title='Conheça meu linkedin'>{{.}}</a>
		{{/document.linkedin}}
	</section>
	<figure class='hide avatar' itemprop='image' itemscope itemtype="http://schema.org/ImageObject">
		<img itemprop='contentUrl' width='100px' height='100px'/>
	</figure>
	{{#document.description}}
		<p class='publisher-description'>{{.}}</p>
		<meta itemprop='description' content='{{ellipsis . 110}}' >
	{{/document.description}}
</article>

<section class="container posts-container publisher-container" itemscope itemtype="http://schema.org/Blog">
	<h2 class="title">Posts</h2>

	{{#each (getCollection "posts")}}
		{{#contain authors ../document.github}}
			<article itemprop="blogPost" itemscope itemtype="http://schema.org/BlogPosting" class="post-card card-{{category}}">
				<div class="post-meta">
					<a href="{{../site.baseUrl}}{{url}}" class="link">
						<h2 itemprop='name' class="title">{{title}}</h2>
					</a>
					{{#each authors}}
						<a href="/{{this}}/" class="author" itemprop='author' itemscope itemtype="http://schema.org/Person">
							<p itemprop='name'>@{{this}}</p>
						</a>
					{{/each}}
					<time datetime="{{dateAsText this.date}}" class="date">
						{{dateAsText this.date}}
						<meta itemprop="datePublished" content='{{dateAsText this.date}}'/>
					</time>
				</div>

				{{#description}}
					<p class="description" itemprop="description">
						{{.}}
					</p>
					<meta itemprop='headline' content='{{ellipsis . 110}}' >
				{{/description}}

				<a href="/{{category}}/" class="category {{category}}">{{category}}</a>
				<a href="{{../site.baseUrl}}{{url}}" class="link post-link">Continue lendo</a>

				<span itemprop="image" itemscope itemtype="http://schema.org/ImageObject"> <!--Change for a post image-->
					<link href="{{../site.baseUrl}}/images/ico/elo7.png" itemprop="url"/>
					<meta itemprop='width' content='100px'/>
					<meta itemprop='height' content='100px'/>
				</span>
				<meta itemprop='mainEntityOfPage' content='Elo7 Serviços de Informática SA'/>
				<span itemprop='publisher' itemscope itemtype="http://schema.org/Organization">
					<meta itemprop='name' content='Elo7 Tech'/>
					<span itemprop="logo" itemscope itemtype="http://schema.org/ImageObject">
						<link href="{{../site.baseUrl}}/images/ico/logo-elo7.png" itemprop="url"/>
						<meta itemprop='width' content='100px'/>
						<meta itemprop='height' content='100px'/>
					</span>
				</span>

			</article>
		{{/contain}}
	{{/each}}
</section>

<section class="container posts-container publisher-container">
	<h2 class="title">Palestras</h2>
	{{#each (getCollection "talks")}}
		{{#contain speakers ../document.github}}
			<article itemprop="blogPost" itemscope itemtype="http://schema.org/BlogPosting" class="post-card card-{{category}}">
				<header>
					<a href="{{../site.baseUrl}}{{url}}" class="link">
						<h2 itemprop='name' class="title">{{title}}</h2>
					</a>
				</header>
				<div class="post-meta">
					{{#each speakers}}
						<a href="/{{this}}/" class="author" itemprop='author' itemscope itemtype="http://schema.org/Person">
							<p itemprop='name'>@{{this}}</p>
						</a>
					{{/each}}
					<time datetime="{{formatDate this.date ''}}" class="date" aria-label="{{formatDate this.date 'LL'}}">
						{{dateAsText this.date}}
						<meta itemprop="datePublished" content='{{this.date}}'/>
					</time>
				</div>

				{{#description}}
					<p class="description" itemprop="description">
						{{.}}
					</p>
					<meta itemprop='headline' content='{{ellipsis . 110}}' >
				{{/description}}
				<a href="{{../site.baseUrl}}{{url}}" class="link post-link">Veja essa talk</a>
			</article>
		{{/contain}}
	{{/each}}
</section>

<script async src="/js/publisher.js"></script>
