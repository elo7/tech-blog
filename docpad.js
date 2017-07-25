var moment = require('moment');

docpadConfig = function() {
	return {
		documentsPaths: ['documents', 'posts', 'assets', 'publishers'],

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
						return [
							{ category: "front-end" },
							{ category: "back-end" },
							{ category: "devops" },
							{ category: "vagas" },
							{ category: "mobile" },
							{ category: "eventos" }
						];
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
				}
			},
			cleanurls: {
				static: true,
				trailingSlashes: true
			},
			markit: {
				html: true
			},
			rss: {
				default: {
					collection: 'posts',
					title: 'Elo7 Tech Blog'
				}
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

		collections: function() {
			var collections = {
				posts : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
								.setComparator(function(postA, postB) {
									var dateA = postA.toJSON().date;
									var dateB = postB.toJSON().date;
									return moment(dateB).unix() - moment(dateA).unix();
								});
				},
				frontend : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
								.setFilter('isCategory', function(model) {
									return model.attributes.category == "front-end";
								})
								.setComparator(function(postA, postB) {
									var dateA = postA.toJSON().date;
									var dateB = postB.toJSON().date;
									return moment(dateB).unix() - moment(dateA).unix();
								});
				},
				backend : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
								.setFilter('isCategory', function(model) {
									return model.attributes.category == "back-end";
								})
								.setComparator(function(postA, postB) {
									var dateA = postA.toJSON().date;
									var dateB = postB.toJSON().date;
									return moment(dateB).unix() - moment(dateA).unix();
								});
				},
				devops : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
								.setFilter('isCategory', function(model) {
									return model.attributes.category == "devops";
								})
								.setComparator(function(postA, postB) {
									var dateA = postA.toJSON().date;
									var dateB = postB.toJSON().date;
									return moment(dateB).unix() - moment(dateA).unix();
								});
				},
				design : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
								.setFilter('isCategory', function(model) {
									return model.attributes.category == "design";
								})
								.setComparator(function(postA, postB) {
									var dateA = postA.toJSON().date;
									var dateB = postB.toJSON().date;
									return moment(dateB).unix() - moment(dateA).unix();
								});
				},
				vagas : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
								.setFilter('isCategory', function(model) {
									return model.attributes.category == "vagas";
								})
								.setComparator(function(postA, postB) {
									var dateA = postA.toJSON().date;
									var dateB = postB.toJSON().date;
									return moment(dateB).unix() - moment(dateA).unix();
								});
				},
				mobile : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
								.setFilter('isCategory', function(model) {
									return model.attributes.category == "mobile";
								})
								.setComparator(function(postA, postB) {
									var dateA = postA.toJSON().date;
									var dateB = postB.toJSON().date;
									return moment(dateB).unix() - moment(dateA).unix();
								});
				},
				eventos : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
								.setFilter('isCategory', function(model) {
									return model.attributes.category == "eventos";
								})
								.setComparator(function(postA, postB) {
									var dateA = postA.toJSON().date;
									var dateB = postB.toJSON().date;
									return moment(dateB).unix() - moment(dateA).unix();
								});
				}
			};
			return collections;
		}()
	}
}();

module.exports = docpadConfig;
