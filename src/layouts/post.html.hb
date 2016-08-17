---
layout: page
---
<article itemprop="blogPost" itemscope itemtype="http://schema.org/BlogPosting" class="post-content">
  <h1 itemprop="name headline" class="title">{{document.title}}</h1>
  <p class="date">
    <time datetime="{{dateAsText document.date}}" itemprop="datePublished">{{dateAsText document.date}}</time>
  </p>
  <span itemprop="author" itemscope itemtype="http://schema.org/Person">
    <a rel="author" itemprop="url" href="https://github.com/{{documet.author}}" target="_blank" class="author">
      <p itemprop="publisher">@{{document.author}}</p>
    </a>
  	<meta itemprop="worksFor" content="Elo7 Serviços de Informática SA">
  </span>
  <div itemprop="articleBody">
    {{{content}}}
  </div>
</article>
