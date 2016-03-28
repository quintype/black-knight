#/bin/sh -e

repo="$1"
publisher_name="$2"
local_files="$3"
old_tag="$4"
new_tag="$5"

rm -rf toupload && mkdir toupload

docker pull "$repo:$old_tag"
container_id=`docker create -v /bin:/safebin "$repo:$old_tag" /safebin/tar -C / xvf - < "$local_files"`
echo created container $container_id

docker cp "$container_id:/app/public/$publisher_name" "toupload/$publisher_name"
s3cmd sync "toupload/$publisher_name/" "s3://quintype-frontend-assets/staging/$publisher_name/"
rm -rf toupload

docker commit "$container_id" "$repo:$new_tag"
docker push "$repo:$new_tag"

docker rm "$container_id"
docker rmi "$repo:$new_tag" "$repo:$old_tag"
