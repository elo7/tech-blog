define(['doc', 'ajax'], function($, ajax) {
    var url = 'http://blog-api-dev.kube.aws.elo7.io/api/v1/search';
    var $postContainer = $('.search');
    ajax.get(url, {
        q: 'teste',
        pg: 1,
        rows: 5
    }, {
        success: function(response, xhr) {
            var posts = response.docs;
            posts.forEach(p => {
                var postTitle = p.title,
                    postUrl = p.url;
                var article = document.createElement('article'),
                    pTitle = document.createElement('p');
                
                $(pTitle).text(postTitle);
                article.append(pTitle);
                $postContainer.append(article);
            });
        }
    });
});
