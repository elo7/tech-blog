define(['doc', 'ajax'], function($, ajax) {
    var urlQueryValue = window.location.search,
        searchParams = new URLSearchParams(urlQueryValue);
    var url = 'http://blog-api-dev.kube.aws.elo7.io/api/v1/search';
    var $postContainer = $('.search');
    ajax.get(url, {
        q: searchParams.get('query'),
        pg: 1,
        rows: 5
    }, {
        success: function(response, xhr) {
            var posts = response.docs;

            posts.forEach(p => {
                var postTitle = p.title.replace("Elo7 Tech - ", ""),
                    postUrl = p.url;
                var article = document.createElement('article'),
                    a = document.createElement('a');
                
                $(a).addClass('link-search').html(postTitle);
                a.href = postUrl;
                article.append(a);
                $postContainer.append(article);
            });
        }
    });
});
