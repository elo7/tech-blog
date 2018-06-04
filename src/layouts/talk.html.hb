---
layout: page
---

<link rel="stylesheet" href="/talks.css">

<section class="talks-container">
	<h1 class="title">{{document.title}}</h1>
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

	<p class="description">{{document.description}}</p>

	<div class="slides">
		{{{document.embeded_slides}}}
	</div>
</section>
