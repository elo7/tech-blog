---
layout: page-amp
---
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
	{{#document.description}}
		<p class='publisher-description'>{{.}}</p>
		<meta itemprop='description' content='{{ellipsis . 110}}' >
	{{/document.description}}
</article>

<section class='posts-container' itemscope itemtype='http://schema.org/Blog'>
	{{#each (getCollection 'posts')}}
		{{#contain authors ../document.github}}
			<article itemprop='blogPost' itemscope itemtype='http://schema.org/BlogPosting' class='post-card card-{{category}}'>
				<section>
						<a href='{{../site.baseUrl}}/amp{{url}}' class='link'>
							<h2 itemprop='name' class='title'>{{title}}</h2>
						</a>
				</section>
				<div class='post-meta'>
					{{#each authors}}
						<a href='/amp/publishers/{{this}}' class='author' itemprop='author' itemscope itemtype='http://schema.org/Person'>
							<span itemprop='name'>@{{this}}</span>
						</a> ·
					{{/each}}
					<time datetime='{{dateAsText this.date}}' class='date'>
						{{dateAsText this.date}}
						<meta itemprop='datePublished' content='{{dateAsText this.date}}'/>
					</time>
				</div>

				{{#description}}
					<p class='description' itemprop='description'>
						{{.}}
					</p>
					<meta itemprop='headline' content='{{ellipsis . 110}}' >
				{{/description}}

				<a href='/amp/{{category}}' class='category {{category}}'>{{category}}</a>
				<a href='{{../site.baseUrl}}/amp{{url}}' class='link post-link'>Continue lendo</a>

				<span itemprop='image' itemscope itemtype='http://schema.org/ImageObject'> <!--Change for a post image-->
					<link href='{{../site.baseUrl}}/images/ico/elo7.png' itemprop='url'/>
					<meta itemprop='width' content='100px'/>
					<meta itemprop='height' content='100px'/>
				</span>
				<meta itemprop='mainEntityOfPage' content='Elo7 Serviços de Informática SA'/>
				<span itemprop='publisher' itemscope itemtype='http://schema.org/Organization'>
					<meta itemprop='name' content='Elo7 Tech'/>
					<span itemprop='logo' itemscope itemtype='http://schema.org/ImageObject'>
						<link href='{{../site.baseUrl}}/images/ico/logo-elo7.png' itemprop='url'/>
						<meta itemprop='width' content='100px'/>
						<meta itemprop='height' content='100px'/>
					</span>
				</span>

			</article>
		{{/contain}}
	{{/each}}
</section>
