---
layout: page
---

<link rel="stylesheet" href="/talks.css">

<section class="talk-container">
	<h1 class="title">{{document.title}}</h1>
	<div>
		{{#each document.speakers}}
			<a data-author='{{this}}' itemprop='author' itemscope itemtype='http://schema.org/Person' rel='author' href='/{{this}}/' class='author'>
				<meta itemprop='url' content='/{{this}}'>
				<img class='hide avatar' width='50px' height='50px' itemprop='image'>
				<p itemprop='name' class='publisher' data-author='{{this}}'>@{{this}}</p>
			</a>
		{{/each}}
		<time datetime="{{formatDate document.date ''}}" class="date" aria-label="{{formatDate document.date 'LL'}}">
			{{dateAsText this.date}}
			<meta itemprop="datePublished" content='{{document.date}}'/>
		</time>
	</div>

	<p class="description">{{document.description}}</p>

	<div class="slides">
		{{{document.embeded_slides}}}
	</div>

	<section class='share'>
		<a href='#share' class='share-post hide' title='Clique aqui para compartilhar esse post'>Compartilhe</a>
		<div class='social-share'>
			<a href='https://www.facebook.com/dialog/share?app_id=644444999041914&href={{site.url}}{{document.url}}&display=popup' rel='noopener' target='_blank' class='link-share facebook' title='Clique para compartilhar no Facebook'>
				Compartilhar no facebook
			</a>
			<a href='https://twitter.com/intent/tweet?text={{document.title}}&url={{site.url}}{{document.url}}&hashtags=elo7tech' rel='noopener' target='_blank' class='link-share twitter' title='Clique para compartilhar no Twitter'>
				Compartilhar no twitter
			</a>
			<a href='{{site.url}}{{document.url}}?utm_source=share&utm_medium=copy' class='link-share hide copy' title='Clique para copiar a url'>
				Copiar URL
			</a>
			<span class='copy-success'>Link copiado</span>
			<input type='url' value='{{site.url}}{{document.url}}?utm_source=share&utm_medium=copy' class='link-input'>
		</div>
	</section>
</section>
<script async src="/js/post.js"></script>