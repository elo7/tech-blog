const moment = require('moment'),
	categories = require('./src/json/categories.json'),
	categoriesTask = require('./src/tasks/categories'),
	ampTask = require('./src/tasks/amp'),
	sizeOf = require('image-size');

const orderByDate = (postA, postB) => {
	let dateA = postA.toJSON().date,
		dateB = postB.toJSON().date;
	return moment(dateB).unix() - moment(dateA).unix();
};

const docpadConfig = function() {
	return {
		documentsPaths: ['documents', 'posts', 'assets', 'publishers', 'amp'],

		plugins: {
			tags: {
				injectDocumentHelper: function(document) {
					document.setMeta({
						layout: 'tags'
					})
				}
			},
			handlebars: {
				helpers: {
					getCollection(name) {
						return this.getCollection(name).toJSON();
					},
					getPagedCollection: function(name) {
						return this.getPageCollection(name).toJSON();
					},
					getPostsWithTag(tagName) {
						return this.getCollection('html')
							.setComparator(orderByDate)
							.findAll({
								layout: 'post',
								tags: {
									$has: tagName
								}
							})
							.toJSON();
					},
					toLowerCase(text) {
						return typeof text === 'string' ? text.toLowerCase() : text;
					},
					getSlug(text) {
						return text.toLowerCase().replace(/(\s|\.)/g, '-');
					},
					dateAsText(date) {
						return moment(date).locale('pt-BR').utc().format('DD/MM/YYYY');
					},
					formatDate: function(date, format) {
						return moment(date).locale('pt-BR').utc().format(format);
					},
					today() {
						return moment(new Date()).locale('en').utc().format('ddd, DD MMM YYYY HH:mm:ss ZZ');
					},
					dateAsRFC(date) {
						return moment(date).locale('en').utc().format('ddd, DD MMM YYYY HH:mm:ss ZZ');
					},
					getCategories() {
						return categories;
					},
					getEnvironment() {
						return this.getEnvironment() === 'static' ? 'production' : 'development';
					},
					getGaCode() {
						return this.getEnvironment() === 'static' ? 'UA-3692628-29' : 'UA-3692628-30';
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
					sum: function(number1, number2) {
						return number1 + number2;
					},
					over: function(lvalue, rvalue, options) {
					   if (arguments.length < 3) {
						   throw new Error("Handlebars Helper equal needs 2 parameters");
					   }
					   if(parseInt(lvalue) <= parseInt(rvalue)) {
						   return options.inverse(this);
					   } else {
						  return options.fn(this);
					   }
					},
					replaceImagesToAmpTags(content) {
						const matches = content.match(/<img[^>]+>/g),
							fixedWidthSize = 272;
							content = content.replace(/ style=['"][^"']+['"]/g, '');
						if(!matches) return content;

						let replacedContent = content;
						matches.forEach((imgTag, index) => {
							let imgSource = imgTag.match(/src=['"]([^'"]+)['"]/)[1],
								alt = imgTag.match(/alt=['"]([^'"]+)['"]/)[1],
								dimensions = sizeOf(`${__dirname}/src/assets/${imgSource.replace('../', '')}`),
								ratio = fixedWidthSize/dimensions.width,
								adjustedWidth = Math.round(dimensions.width * ratio),
								adjustedHeight = Math.round(dimensions.height * ratio),
								id = 'lightbox-' + index;
							let ampImg = `<div class='post-image'><amp-img on='tap:${id}' role='button' tabindex='0' src='../${imgSource}' layout='fixed' height='${adjustedHeight}' width='${adjustedWidth}' alt='${alt}'></amp-img><amp-image-lightbox id='${id}' layout='nodisplay'></amp-image-lightbox></div>`;
							replacedContent = replacedContent.replace(new RegExp(imgTag, 'g'), ampImg);
						});
						return replacedContent;
					},
					getCanonicalURI(uri) {
						if (uri === 'amp-home') {
							return '';
						}
						return uri.replace('amp-', '') + '/';
					},
					getAmpURI(uri) {
						if (uri === 'index') {
							return 'amp/home/';
						}
						return `amp/${uri}/`;
					},
					hasAmpPage(uri, options) {
						if (arguments.length < 2) {
							throw new Error('Handlebars Helper equal needs 1 parameters');
						}
						if(!uri.startsWith('tags-') && !uri.startsWith('page-')) {
							return options.fn(this);
						} else {
							return options.inverse(this);
						}
					},

					encodeURI(uri) {
						return encodeURI(uri);
					},

					getCoverUri(fileName) {
						if (fileName && fileName.length > 0) {
							return `images/cover/${fileName}`;
						}
						return 'images/ico/elo7.png';
					}
				}
			},
			cleanurls: {
				static: true,
				trailingSlashes: true
			},
			markit: {
				html: true
			},
			paged: {
				prefix: 'page'
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
						url: 'https://engenharia.elo7.com.br'
					}
				}
			}
		},

		events: {
			populateCollectionsBefore: () => {
				if(this.process.env.npm_package_config_amp === 'true') {
					categoriesTask(categories);
					ampTask(categories);
				}
			}
		},

		collections: function() {
			var collections = {
				posts : function() {
					return this.getCollection('html')
								.findAll({layout: 'post'})
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
