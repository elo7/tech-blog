---
layout: page-amp
---
<article itemprop='blogPost' itemscope itemtype='http://schema.org/BlogPosting' class='post-card post-content'>
	<h1 itemprop='name' class='title'>{{document.title}}</h1>
	<div class='post-meta'>
		<p class='date'>
			Publicado em: <time datetime='{{dateAsText document.date}}' itemprop='datePublished'>{{dateAsText document.date}}</time>
			<meta itemprop='dateModified' content='{{dateAsText document.date}}'>
		</p>

		<article>
			{{#each document.authors}}
				<a data-author='{{this}}' itemprop='author' itemscope itemtype='http://schema.org/Person' rel='author' href='/amp/publishers/{{this}}' class='author'>
					<meta itemprop='url' content='/amp/publishers/{{this}}'>
					<span itemprop='name' class='publisher' data-author='{{this}}'>@{{this}}</span>
					<meta itemprop='worksFor' content='Elo7 Serviços de Informática SA'>
				</a>
			{{/each}}
		</article>
	</div>
	<div class='content' itemprop='articleBody'>
		{{{content}}}
		<section class='share'>
			<a href='https://www.facebook.com/dialog/share?app_id=644444999041914&href={{site.url}}{{document.url}}&display=popup' rel='noopener' target='_blank' class='link-share facebook' title='Clique para compartilhar no Facebook'>
				Compartilhar no facebook
			</a>
			<a href='https://twitter.com/intent/tweet?text={{document.title}}&url={{site.url}}{{document.url}}&hashtags=elo7tech' rel='noopener' target='_blank' class='link-share twitter' title='Clique para compartilhar no Twitter'>
				Compartilhar no twitter
			</a>
		</section>
	</div>
	<span itemprop="image" itemscope itemtype="http://schema.org/ImageObject"> <!--Change for a post image-->
		<link href="{{../site.baseUrl}}/images/ico/elo7.png" itemprop="url"/>
		<meta itemprop='width' content='100px'/>
		<meta itemprop='height' content='100px'/>
	</span>

	<meta itemprop='headline' content='{{document.description}}'/>
	<span itemprop='publisher' itemscope itemtype="http://schema.org/Organization">
		<meta itemprop='name' content='Elo7 Tech'/>
		<meta itemprop="url" content='{{site.url}}'/>
		<span itemprop="logo" itemscope itemtype="http://schema.org/ImageObject">
			<link href="https://images.elo7.com.br/assets/v3/desktop/png/logo-elo7.png" itemprop="url"/>
			<meta itemprop='width' content='100px'/>
			<meta itemprop='height' content='100px'/>
		</span>
	</span>
	<meta itemprop='mainEntityOfPage' content='Elo7 Serviços de Informática SA'/>
</article>
