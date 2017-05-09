---
layout: page-amp
---
<article class='post-card post-content'>
	<h1 class='title'>{{document.title}}</h1>
	<p class='author'>
		by
		<a href='https://github.com/{{document.author}}' target='_blank'>
		 	@{{document.author}}
		</a>
		&middot;
		<time datetime='{{dateAsText document.date}}'>{{dateAsText document.date}}</time>
	</p>
	{{{content}}}
</article>
