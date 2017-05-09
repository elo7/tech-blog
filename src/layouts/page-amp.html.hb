<!doctype html>
<html amp lang='pt-br'>
<head>
	<meta charset='utf-8'>
	<script async src='https://cdn.ampproject.org/v0.js'></script>
	<script async custom-element='amp-sidebar' src='https://cdn.ampproject.org/v0/amp-sidebar-0.1.js'></script>
	<title>Elo7 Tech - {{document.title}}</title>
	<meta name='description' content='{{document.description}}'>
	<link rel='canonical' href='{{site.url}}/{{document.slug}}/' />
	<meta name='viewport' content='width=device-width,minimum-scale=1,initial-scale=1'>
	<script type='application/ld+json'>
		{
			'@context': 'http://schema.org',
			'@type': 'WebPage',
			'url': [
				'http://engenharia.elo7.com.br/',
				'https://github.com/elo7/tech-blog'
			],
			'image': [
				'//images.elo7.com.br/assets/v3/desktop/svg/logo-elo7.svg'
			],
			'blog': {
				'@type': 'Blog',
				'blogPost': {
					'@type': 'BlogPosting',
					'name': '{{document.title}}',
					'headline': '{{document.title}}',
					'datePublished': {{dateAsText document.date}},
					'articleBody': '{{content}}',
					'author': {
						'@type': 'Person',
						'name': '{{document.author}}',
						'url': 'https://github.com/{{document.author}}'
					},
					'worksFor': {
						'@type': 'Organization',
						'name': 'Elo7 Serviços de Informática SA'
					}
				}
			}
		}
	</script>
	<style amp-boilerplate>body{-webkit-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-moz-animation:-amp-start 8s steps(1,end) 0s 1 normal both;-ms-animation:-amp-start 8s steps(1,end) 0s 1 normal both;animation:-amp-start 8s steps(1,end) 0s 1 normal both}@-webkit-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-moz-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-ms-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@-o-keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}@keyframes -amp-start{from{visibility:hidden}to{visibility:visible}}</style><noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript>
	<link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet'>
	<style amp-custom>
		body {
			background-color: white;
			font-family: 'Open Sans', sans-serif;
			color: #666;
		}

		h1 {
			color: #333;
			font-size: 1.5em;
			margin-bottom: 0;
		}

		h2, h3 {
			color: #444;
			font-size: 1.2em;
		}

		h3 {
			font-weight: 300;
		}

		a {
			text-decoration: none;
		}

		p, li {
			font-size: 0.9em;
		}

		ul {
			padding-left: 1.5em;
		}

		article {
			line-height: 1.8;
			text-align: justify;
		}

		header {
			height: 60px;
			box-sizing: border-box;
			background-color: #FDC24F;
			text-align: center;
			padding-top: 0.8em;
			padding-bottom: 0.8em;
			position: sticky;
			top: 0;
			z-index: 10;
		}

		header a {
			background: url('//images.elo7.com.br/assets/v3/desktop/svg/logo-elo7.svg') no-repeat;
			background-size: 90px 35px;
			width: 90px;
			height: 35px;
			display: inline-block;
			filter: brightness(100);
		}

		.post-content, footer {
			padding-left: 5%;
			padding-right: 5%;
		}

		.post-content a, .post-content a:visited, .post-content a:hover {
			cursor: pointer;
			color: #000;
			font-weight: 500;
			text-decoration: underline;
			word-break: break-word;
		}

		.post-content p:last-of-type {
			margin-bottom: 0;
		}

		main {
			background-color: #ecebeb;
			padding-top: 1em;
			padding-bottom: 1em;
		}

		.post-card, .post-content {
			background: white;
			margin-left: 2%;
			padding: 1em;
			margin-right: 3%;
			box-shadow: rgba(72, 72, 72, 0.23) 0 0 5px;
		}

		.card-devops {
			border-left: 5px solid #7d7873;
		}

		.card-eventos {
			border-left: 5px solid #fdb933;
		}

		.card-front-end {
			border-left: 5px solid #c15eb4;
		}

		.card-back-end {
			border-left: 5px solid #359c9c;
		}

		.card-mobile {
			border-left: 5px solid #fa9c5e;
		}

		.card-vagas {
			border-left: 5px solid #99c799;
		}

		.card-design {
			border-left: 5px solid #7c9ec4;
		}

		.post-card:not(:last-of-type) {
			margin-bottom: 1em;
		}

		.post-card .title {
			margin-top: 0;
			margin-bottom: 0.5em;
		}

		.post-card .title a {
			color: inherit;
		}

		.author {
			color: #888;
			margin-bottom: 0;
			margin-top: 0;
			font-size: 0.9em;
		}

		.author a {
			color: inherit;
			margin-bottom: 1.5em;
		}

		#sidebar {
			width: 60vw;
			background-color: #FDC24F;
			color: #fff;
			padding-right: 1em;
			padding-left: 1em;
		}

		#sidebar li {
			margin-bottom: 0.5em;
		}

		#sidebar ul {
			margin-bottom: 1.5em;
			list-style: none;
			padding: 0;
		}

		#sidebar h2 {
			margin-bottom: 0;
		}

		#sidebar a {
			text-decoration: none;
			font-weight: 500;
		}

		#sidebar a, #sidebar h2 {
			color: inherit;
		}

		.sidebar-trigger {
			position: absolute;
			left: 5%;
			background-color: transparent;
			border: none;
			color: #fff;
			font-size: 1.8em;
			padding: 0;
		}

		.category {
			background-color: #73bebe;
			color: #ffffff;
			text-decoration: none;
			font-size: 0.8em;
			padding: .5em;
			border-radius: 3px;
			display: inline-block;
			margin-top: 2.3em;
			cursor: pointer;
			transition: background-color 0.3s;
			font-weight: 300;
		}

		.category:hover {
			background-color: #73bebe;
		}

		.post-link {
			border: 1px solid #fba702;
			border-radius: 3px;
			color: #fba702;
			display: inline-block;
			float: right;
			margin-top: 1em;
			padding: 0.8em;
			text-align: center;
			text-decoration: none;
			transition: background-color 0.3s, color 0.3s;
			font-size: 0.9em;
		}

		.post-link:hover {
			background-color: #fba702;
			color: #ffffff;
		}

		footer {
			background-color: #dedede;
			padding-top: 0.5em;
			padding-bottom: 0.5em;
			text-align: center;
		}

		footer a {
			color: #666;
			text-decoration: none;
			font-size: 0.8em;
		}

		code {
			background-color: #ececec;
			padding: 0.1em 0.2em;
		}

		.highlight code {
			overflow: auto;
		}

		.hljs {
			display: block;
			padding: 0.5em 1em;
			background: #23241f;
		}

		.hljs,
		.hljs-tag,
		.css .hljs-rules,
		.css .hljs-value,
		.css .hljs-function
		.hljs-preprocessor,
		.hljs-pragma {
			color: #f8f8f2;
		}

		.hljs-strongemphasis,
		.hljs-strong,
		.hljs-emphasis {
			color: #a8a8a2;
		}

		.hljs-bullet,
		.hljs-blockquote,
		.hljs-horizontal_rule,
		.hljs-number,
		.hljs-regexp,
		.alias .hljs-keyword,
		.hljs-literal,
		.hljs-hexcolor {
			color: #ae81ff;
		}

		.hljs-tag .hljs-value,
		.hljs-code,
		.hljs-title,
		.css .hljs-class,
		.hljs-class .hljs-title:last-child {
			color: #a6e22e;
		}

		.hljs-link_url {
			font-size: 80%;
		}

		.hljs-strong,
		.hljs-strongemphasis {
			font-weight: bold;
		}

		.hljs-emphasis,
		.hljs-strongemphasis,
		.hljs-class .hljs-title:last-child {
			font-style: italic;
		}

		.hljs-keyword,
		.hljs-function,
		.hljs-change,
		.hljs-winutils,
		.hljs-flow,
		.lisp .hljs-title,
		.clojure .hljs-built_in,
		.nginx .hljs-title,
		.tex .hljs-special,
		.hljs-header,
		.hljs-attribute,
		.hljs-symbol,
		.hljs-symbol .hljs-string,
		.hljs-tag .hljs-title,
		.hljs-value,
		.alias .hljs-keyword:first-child,
		.css .hljs-tag,
		.css .unit,
		.css .hljs-important {
			color: #F92672;
		}

		.hljs-function .hljs-keyword,
		.hljs-class .hljs-keyword:first-child,
		.hljs-constant,
		.css .hljs-attribute {
			color: #66d9ef;
		}

		.hljs-variable,
		.hljs-params,
		.hljs-class .hljs-title {
			color: #f8f8f2;
		}

		.hljs-string,
		.css .hljs-id,
		.hljs-subst,
		.haskell .hljs-type,
		.ruby .hljs-class .hljs-parent,
		.hljs-built_in,
		.sql .hljs-aggregate,
		.django .hljs-template_tag,
		.django .hljs-variable,
		.smalltalk .hljs-class,
		.django .hljs-filter .hljs-argument,
		.smalltalk .hljs-localvars,
		.smalltalk .hljs-array,
		.hljs-attr_selector,
		.hljs-pseudo,
		.hljs-addition,
		.hljs-stream,
		.hljs-envvar,
		.apache .hljs-tag,
		.apache .hljs-cbracket,
		.tex .hljs-command,
		.hljs-prompt,
		.hljs-link_label,
		.hljs-link_url {
			color: #e6db74;
		}

		.hljs-comment,
		.hljs-javadoc,
		.java .hljs-annotation,
		.python .hljs-decorator,
		.hljs-template_comment,
		.hljs-pi,
		.hljs-doctype,
		.hljs-deletion,
		.hljs-shebang,
		.apache .hljs-sqbracket,
		.tex .hljs-formula {
			color: #75715e;
		}

		.coffeescript .javascript,
		.javascript .xml,
		.tex .hljs-formula,
		.xml .javascript,
		.xml .vbscript,
		.xml .css,
		.xml .hljs-cdata,
		.xml .php,
		.php .xml {
			opacity: 0.5;
		}
	</style>
</head>
<body>
	<amp-sidebar id='sidebar' layout='nodisplay'>
		<h2>Categorias</h2>
		<ul>
			{{#each (getCategories)}}
				<li><a href='/amp/{{category}}'>{{category}}</a></li>
			{{/each}}
		</ul>
		<h2>Veja também</h2>
		<ul>
			<li><a href='http://carreira.elo7.com.br/engenharia/' target='_blank'>A engenharia</a></li>
			<li><a href='http://carreira.elo7.com.br/' target='_blank'>Carreiras</a></li>
			<li><a href='http://eventos.elo7.com.br/' target='_blank'>Nossos eventos</a></li>
			<li><a href='https://www.elo7.com.br/' target='_blank'>Elo7</a></li>
			</ul>
		</ul>
	</amp-sidebar>
	<header><button class='sidebar-trigger' on='tap:sidebar'>☰</button><a href='/amp/home/' class='logo'>{{site.title}}</a></header>

	<main>
		{{{ampContent content}}}
	</main>
	<footer>
		<a href='http://engenharia.elo7.com.br/'>engenharia.elo7.com.br © 2017</a>
	</footer>
</body>
</html>