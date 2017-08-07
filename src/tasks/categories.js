const shelljs = require('shelljs');

const categoriesTask = (categories) => {
	console.log('\nGenerating dynamic categories...');
	categories.forEach(category => {
		let filename = `./src/documents/${category.category}.html.hb`;
		shelljs.cp('./src/layouts/category-template.html.hb', filename);
		for (key in category) {
			let regexp = new RegExp(`\\$category\\.${key}`, 'g');
			shelljs.sed('-i', regexp, category[key], filename);
		}
		console.log('Created category', filename);
	});
	console.log('Finished dynamic categories task.');
}

module.exports = categoriesTask;
