const moment = require('moment'),
    categories = require('./src/json/categories.json'),
    categoriesTask = require('./src/tasks/categories'),
    ampTask = require('./src/tasks/amp');

docpadConfig = function() {
	return {
		documentsPaths: ['documents', 'posts', 'assets', 'publishers', 'amp'],

		plugins: {
			handlebars: {
				helpers: {
					getCollection: function(name) {
						return this.getCollection(name).toJSON();
					},
					dateAsText: function(date) {
						return moment(date).utc().format('DD/MM/YYYY');
					},
					getCategories: function() {
                        return categories;
                    },
					getEnvironment: function() {
						return this.getEnvironment() === "static" ? "production" : "development";
					},
					contain: function(lvalue, rvalue, options) {
						if (arguments.length < 3) {
							throw new Error("Handlebars Helper equal needs 2 parameters");
						}

						if( lvalue.indexOf(rvalue) == -1 ) {
							return options.inverse(this);
						} else {
							return options.fn(this);
						}
					},
					ellipsis: function (str, len) {
						if (len > 0 && str.length > len) {
							return str.substring(0, (len - 3)) + '...';
						}
						return str;
					},
                    ampContent: function(content) {
                        return content
                                    .replace(/<img\s/g, '<amp-img layout=\'fixed\' height=\'150\' width=\'auto\'')
                    }
                }
            },
            cleanurls: {
                static: true,
                trailingSlashes: true
            },
            markit: {
                html: true
            }
        },

		templateData: {
			site: {
				url: "http://localhost:9778"
			}
		},

		environments: {
			static: {
				templateData: {
					site: {
						url: "http://engenharia.elo7.com.br"
					}
				}
			}
		},

        events: {
            populateCollectionsBefore: () => {
                categoriesTask(categories);
                ampTask(categories);
            }
        },

        collections: function() {
            var collections = {
                posts : function() {
                    return this.getCollection('html')
                                .findAll({
                                    layout: 'post'
                                })
                                .setComparator(function(postA, postB) {
                                    var dateA = postA.toJSON().date;
                                    var dateB = postB.toJSON().date;
                                    return moment(dateB).unix() - moment(dateA).unix();
                                });
                },

                postsAmp : function() {
                    return this.getCollection('html')
                                .findAll({
                                    relativeOutDirPath: 'amp',
                                    layout: 'post-amp'
                                })
                                .setComparator(function(postA, postB) {
                                    var dateA = postA.toJSON().date;
                                    var dateB = postB.toJSON().date;
                                    return moment(dateB).unix() - moment(dateA).unix();
                                });
                }
            };

            categories.forEach(category => {
                collections[category.category] = function() {
                    return this.getCollection('html')
                        .findAll({layout: 'post'})
                        .setFilter('isCategory', function(model) {
                            return model.attributes.category === category.category;
                        })
                        .setComparator(function(postA, postB) {
                            var dateA = postA.toJSON().date;
                            var dateB = postB.toJSON().date;
                            return moment(dateB).unix() - moment(dateA).unix();
                        });
                };
            });
            return collections;
        }()
    }
}();

module.exports = docpadConfig;
