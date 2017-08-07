const shelljs = require('shelljs');

const ampTask = (categories) => {
	console.info('\nAMP Task');
	console.info('Copying posts folder...');
	shelljs.mkdir('./src/documents/amp');
	shelljs.cp('-rf', './src/posts/*.html.md', './src/documents/amp');
	shelljs.cp('-rf', './src/documents/*.hb', './src/documents/amp');
	shelljs.mkdir('./src/documents/amp/publishers');
	shelljs.cp('-rf', './src/publishers/*.md', './src/documents/amp/publishers');
	console.info('Copying images folder...');
	shelljs.mkdir('./src/documents/amp/images');
	shelljs.cp('-rf', './src/assets/images/*', './src/documents/amp/images');
	console.info('Replacing post default values...');
	shelljs.ls('./src/documents/amp/**/*.md').forEach(function (file) {
		shelljs.sed('-i', /^layout: (.*)$/, 'layout: $1-amp\nstandalone: true', file);
	});
	console.info('\nGenerating amp dynamic categories...');
	categories.forEach(category => {
		let filename = `./src/documents/amp/${category.category}.html.hb`;
		shelljs.cp('./src/layouts/category-template-amp.html.hb', filename);
		for (key in category) {
			let regexp = new RegExp(`\\$category\\.${key}`, 'g');
			shelljs.sed('-i', regexp, category[key], filename);
		}
		console.info('Created category', filename);
	});
	console.info('Finished dynamic categories task.');
	console.info('AMP Task complete!');
};

module.exports = ampTask;
