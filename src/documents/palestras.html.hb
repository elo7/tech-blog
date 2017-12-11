---
title: Palestras
description: Confira todas as palestras do time de Engenharia do Elo7, o maior marketplace de produtos criativos da América Latina.
layout: page
---
<link rel="stylesheet" href="/talks.css">

<section class="talks-container" itemscope itemtype="http://schema.org/Blog">
	<h1 class='title'>Palestras</h1>
    {{#each (getCollection "talks")}}
		<article class="talk">
			<img src="{{../site.baseUrl}}/images/talks/{{this.image}}">
			<div class="talk-meta">
				{{#each this.speakers}}
					<a href="/{{this}}/" class="author" itemprop='author' itemscope itemtype="http://schema.org/Person">
						<p itemprop='name'>@{{this}}</p>
					</a>
				{{/each}}

				{{#description}}
					<p class="description" itemprop="description">
						{{.}}
					</p>
					<meta itemprop='headline' content='{{ellipsis . 110}}' >
				{{/description}}

				<time datetime="{{formatDate this.date ''}}" class="date" aria-label="{{formatDate this.date 'LL'}}">
					{{dateAsText this.date}}
					<meta itemprop="datePublished" content='{{this.date}}'/>
				</time>
			</div>

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
	{{/each}}
</section>
