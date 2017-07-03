git checkout master && git fetch origin && git pull origin master

commit_merge=$(git log | grep Merge | head -n 1 | awk '{print $3}')
src_post=$(git log --name-status $commit_merge | grep '^A.*\.html\.md$' | head -n 1 | awk '{print $2}')
post_name=$(echo $src_post | sed -E "s/.*\/(.*).html.md/\1/")
today=$(date +"%Y-%m-%d")

sed -i.tmp -E "s/(date: *).+/\1$today/" $src_post

rm $src_post.tmp

git diff

echo "Você tem certeza que quer fazer esse deploy? (y/N)"
read confirma

if [ "$confirma" = "y" ]; then
	git add $src_post
	git commit -m "Publicando post $post_name"
	git push origin HEAD

	./node_modules/.bin/docpad deploy-ghpages --env static
else
	git checkout $src_post
	echo "Deploy cancelado :("
fi
