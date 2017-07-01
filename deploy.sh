git checkout master && git fetch origin && git pull origin master
npm i && npm run clean
./node_modules/.bin/docpad deploy-ghpages --env static
