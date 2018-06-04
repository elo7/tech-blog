---
title: Palestras
description: Confira todas as palestras do time de Engenharia do Elo7!
layout: page
---
<link rel="stylesheet" href="/talks.css">

<section class="posts-container" itemscope itemtype="http://schema.org/Blog">
	<h1 class='title'>Palestras</h1>
    {{#each (getCollection "talks")}}
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
	{{/each}}
</section>
