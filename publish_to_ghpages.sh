#!/bin/sh

echo "Npm install"
npm install

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git fetch origin
git worktree add -B test-pages public origin/test-pages

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
npm run build
hugo --config config.prod.toml

echo "Updating gh-pages branch"
cd public && git add --all && git commit -m "Publishing to gh-pages (publish.sh)"
git push origin test-pages
