git checkout master && git fetch origin && git pull origin master
git checkout -

src_post=$(git diff --summary master | grep create | grep html.md | awk '{print $4}')
post_name=$(echo $src_post | sed -E "s/.*\/(.*).html.md/\1/")
today=$(date +"%Y-%m-%d")

sed -i.tmp -E "s/(date: *).+/\1$today/" $src_post

rm $src_post.tmp

git add $src_post
git commit -m "Publicando post $post_name"
git push
