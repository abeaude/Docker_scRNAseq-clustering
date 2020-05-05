#!/bin/bash

tags=$(printf '%s\n' "$@"|sort)

for tag in $tags
do
#     echo $tag
    sed "s/{{ver}}/${tag}/" Dockerfile.template > Dockerfile
    git add Dockerfile
    git commit -m "R ${tag}" Dockerfile
    git tag ${tag}
done
git push --tags

last_git_tag=$(git tag -l | sort | tail -n 1)
last_input_tag=$(printf '%s\t' "$tags"|tail -n 1)

# If newer version push to master branch to be tagged as latest
dpkg --compare-versions ${last_input_tag} "ge" ${last_git_tag}
if [ $? -eq "0" ]
then
    git push
fi 


