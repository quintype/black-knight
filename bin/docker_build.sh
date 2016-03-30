#/bin/bash -e

publisher_name="$1"
repo="$2"
local_files="$3"
old_tag="$4"
new_tag="$5"

if [ -z "$QT_ENV" ]; then
  echo Please provide an environment
  exit 1
fi

TEMPORARY_DIR=`mktemp -d -t docker_compile`
mkdir -p $TEMPORARY_DIR
cp $local_files $TEMPORARY_DIR/config.tar
pushd $TEMPORARY_DIR

cat > Dockerfile <<EOF
FROM $repo:$old_tag

COPY config.tar /tmp/config.tar
RUN tar xvf /tmp/config.tar -C /
EOF

docker build -t "$repo:$new_tag" .
docker push "$repo:$new_tag"

mkdir toupload
container_id=`docker create $repo:$new_tag`
docker cp "$container_id:/app/public/$publisher_name" "toupload/$publisher_name"
s3cmd sync "toupload/$publisher_name/" "s3://quintype-frontend-assets/$QT_ENV/$publisher_name/"
rm -rf toupload

docker rm "$container_id"
docker rmi "$repo:$new_tag" "$repo:$old_tag"
