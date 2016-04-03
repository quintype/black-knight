#!/bin/bash -e

# local files come from stdin

publisher_name="$1"
repo="$2"
old_tag="$3"
new_tag="$4"

if [ -z "$QT_ENV" ]; then
  echo Please provide an environment
  exit 1
fi

TEMPORARY_DIR=`mktemp -d -t docker-compileXXXXXXXX`
mkdir -p $TEMPORARY_DIR
cat > $TEMPORARY_DIR/config.tar
cd $TEMPORARY_DIR

cat > Dockerfile <<EOF
FROM $repo:$old_tag

COPY config.tar /tmp/config.tar
RUN tar xvf /tmp/config.tar -C /
EOF

echo Building Container
docker build -t "$repo:$new_tag" .
docker push "$repo:$new_tag"

echo Uploading Assets to S3
mkdir toupload
container_id=`docker create $repo:$new_tag`
docker cp "$container_id:/app/public/$publisher_name" "toupload/$publisher_name"
s3cmd sync "toupload/$publisher_name/" "s3://quintype-frontend-assets/$QT_ENV/$publisher_name/"
rm -rf toupload

docker rm "$container_id"
docker rmi "$repo:$new_tag" "$repo:$old_tag"
