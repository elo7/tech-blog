const shelljs = require('shelljs');

const ampTask = (categories) => {
	console.log('\nAMP Task');
	console.log('Copying posts folder...');
	shelljs.mkdir('./src/documents/amp');
	shelljs.cp('-rf', './src/posts/*', './src/documents/amp');
	shelljs.cp('-rf', './src/documents/*.hb', './src/documents/amp');
	console.log('Copying images folder...');
	shelljs.mkdir('./src/documents/amp/images');
	shelljs.cp('-rf', './src/assets/images/*', './src/documents/amp/images');
	console.log('Replacing post default values...');
	shelljs.ls('./src/documents/amp/*.md').forEach(function (file) {
		shelljs.sed('-i', /^layout: (.*)$/, 'layout: $1-amp\nstandalone: true', file);
	});
	console.log('\nGenerating amp dynamic categories...');
	categories.forEach(category => {
		let filename = `./src/documents/amp/${category.category}.html.hb`;
		shelljs.cp('./src/layouts/category-template-amp.html.hb', filename);
		for (key in category) {
			let regexp = new RegExp(`\\$category\\.${key}`, 'g');
			shelljs.sed('-i', regexp, category[key], filename);
		}
		console.log('Created category', filename);
	});
	console.log('Finished dynamic categories task.');
	console.log('AMP Task complete!');
};

module.exports = ampTask;
