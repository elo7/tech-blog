---
layout: page
---

<h1>{{document.title}}</h1>
{{#each document.speakers}}
	<a data-author='{{this}}' itemprop='author' itemscope itemtype='http://schema.org/Person' rel='author' href='/{{this}}/' class='author'>
		<meta itemprop='url' content='/{{this}}'>
		<img class='hide avatar' width='50px' height='50px' itemprop='image'>
		<p itemprop='name' class='publisher' data-author='{{this}}'>@{{this}}</p>
	</a>
{{/each}}

<p>{{document.description}}</p>

{{#each document.links}}
	<a href='{{this}}'>{{this}}</a>
{{/each}}

<div>
	{{{document.slides}}}
</div>
