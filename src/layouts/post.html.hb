---
layout: page
---
<article itemprop='blogPost' itemscope itemtype='http://schema.org/BlogPosting' class='post-content'>
	<figure class='cover-image'>
		<img src='{{site.url}}/{{getCoverUri cover}}' alt='{{title}}'>
	</figure>
	<h1 itemprop='name' class='title'>{{document.title}}</h1>
	<div class='post-meta'>
		<p class='date'>
			Publicado em: <time datetime='{{dateAsText document.date}}' itemprop='datePublished'>{{dateAsText document.date}}</time>
			<meta itemprop='dateModified' content='{{dateAsText document.date}}'>
		</p>

		<article>
			{{#each document.authors}}
				<a data-author='{{this}}' itemprop='author' itemscope itemtype='http://schema.org/Person' rel='author' href='/{{this}}/' class='author'>
					<meta itemprop='url' content='/{{this}}'>
					<img class='hide avatar' width='50px' height='50px' itemprop='image'>
					<p itemprop='name' class='publisher' data-author='{{this}}'>@{{this}}</p>
				</a>
			{{/each}}

			<meta itemprop='worksFor' content='Elo7 Serviços de Informática SA'>
		</article>
	</div>
	<div itemprop='articleBody'>
		{{{content}}}

		<ul class='tag-list'>
		{{#each document.tags}}
			<li>
				<a href='/tags/{{getSlug . }}/'>{{toLowerCase . }}</a>
			</li>
		{{/each}}
		</ul>
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

	<div id='disqus_thread'></div>

	<script>
		var disqus_shortname = 'engenhariaelo7';
		var disqus_identifier = '{{dateAsText document.date}}:{{document.url}}';
		var disqus_url = '{{site.url}}{{document.url}}';

		(function() {
			var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
			dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
			(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
		})();
	</script>
	<noscript>Habilite o JavaScript para ver os comentários</noscript>
</article>
<script async src="/js/post.js"></script>
