const moment = require('moment'),
	categories = require('./src/json/categories.json'),
	categoriesTask = require('./src/tasks/categories'),
	ampTask = require('./src/tasks/amp');

const orderByDate = (postA, postB) => {
	let dateA = postA.toJSON().date,
		dateB = postB.toJSON().date;
	return moment(dateB).unix() - moment(dateA).unix();
};

const docpadConfig = function() {
	return {
		documentsPaths: ['documents', 'posts', 'assets', 'publishers', 'amp'],

		plugins: {
			handlebars: {
				helpers: {
					getCollection(name) {
						return this.getCollection(name).toJSON();
					},
					dateAsText(date) {
						return moment(date).utc().format('DD/MM/YYYY');
					},
					getCategories() {
						return categories;
					},
					getEnvironment() {
						return this.getEnvironment() === 'static' ? 'production' : 'development';
					},
					contain(lvalue, rvalue, options) {
						if (arguments.length < 3) {
							throw new Error('Handlebars Helper equal needs 2 parameters');
						}

						if( lvalue.indexOf(rvalue) == -1 ) {
							return options.inverse(this);
						} else {
							return options.fn(this);
						}
					},
					ellipsis(str, len) {
						if (len > 0 && str.length > len) {
							return str.substring(0, (len - 3)) + '...';
						}
						return str;
					},
					replaceForAmpTags(content) {
						return content.replace(/<img\s/g, '<amp-img layout=\'fixed\' height=\'150\' width=\'auto\'');
					},
					getCanonicalURI(uri) {
						if (uri === 'amp-home') {
							return '';
						}

						let normalizedUri = `${uri.replace('amp-', '')}/`;
						if (normalizedUri.indexOf() === 0) {
							return normalizedUri.replace('publishers-', 'publishers/');
						}
						return normalizedUri;
					},
					getAmpURI(uri) {
						if (uri === 'index') {
							return 'amp/home/';
						}
						return `amp/${uri}/`;
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
				url: 'http://localhost:9778'
			}
		},

		environments: {
			static: {
				templateData: {
					site: {
						url: 'http://engenharia.elo7.com.br'
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
				posts() {
					return this.getCollection('html')
								.findAll({
									layout: 'post'
								})
								.setComparator(orderByDate);
				},

				postsAmp() {
					return this.getCollection('html')
								.findAll({
									relativeOutDirPath: 'amp',
									layout: 'post-amp'
								})
								.setComparator(orderByDate);
				}
			};

			categories.forEach(category => {
				collections[category.category] = function() {
					return this.getCollection('html')
						.findAll({layout: 'post'})
						.setFilter('isCategory', function(model) {
							return model.attributes.category === category.category;
						})
						.setComparator(orderByDate);
				};
			});
			return collections;
		}()
	}
}();

module.exports = docpadConfig;
