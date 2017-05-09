---
title: $category.title
description: $category.description
layout: page-amp
---
{{#each (getCollection "$category.category")}}
	<article class='post-card card-{{category}}'>
		<h2 class='title'>
			<a href='{{../site.baseUrl}}/amp{{url}}' class='link'>
			   {{title}}
			</a>
		</h2>
		<p class='author'>
			by
			<a href='https://github.com/{{author}}' target='_blank'>
				@{{author}}
			</a>
			&middot;
			<time datetime='{{dateAsText date}}'>{{dateAsText date}}</time>
		</p>
		<p class='description'>{{description}}</p>
		<a href='/amp/{{category}}' class='category {{category}}'>{{category}}</a>
		<a href='{{../site.baseUrl}}/amp{{url}}' class='link post-link'>Continue lendo</a>
	</article>
{{/each}}
