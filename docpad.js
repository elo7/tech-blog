moment = require('moment');

docpadConfig = function() {
    var categories = [
        "front-end",
        "back-end",
        "design",
        "devops",
        "busca"
    ];

    return {
        documentsPaths: ['documents', 'posts'],

        plugins: {
            handlebars: {
                helpers: {
                    getCollection: function(name) {
                        return this.getCollection(name).toJSON();
                    },

                    dateAsText: function(date) {
                        return moment(date).utcOffset("00:00").format('DD MMM YYYY');
                    }
                }
            }
        },

        templateData: {
            site: {
                title: "Elo7 Tech",
                url: "http://localhost:9778"
            }
        },

        environments: {
            static: {
                templateData: {
                    site: {
                        url: "https://elo7.github.io/tech-blog",
                        baseUrl: "/tech-blog"
                    }
                }
            }
        },

        collections: function() {
            var collections = {
                posts : function() {
                    return this.getCollection("documents")
                                .setFilter('isPost', function(model) {
                                    var isIn = model.attributes.fullPath.substr((__dirname+'/src/').length);
                                    return isIn.indexOf('posts') == 0;
                                })
                                .on("add", function(model) {
                                    model.setMetaDefaults({
                                        layout: 'post'
                                    });
                                })
                                .setComparator(function(postA, postB) {
                                    var dateA = postA.toJSON().date;
                                    var dateB = postB.toJSON().date;
                                    return moment(dateB).unix() - moment(dateA).unix();
                                })
                                .live();
                }
            }
            return collections;
        }()
    }
}();

module.exports = docpadConfig;
