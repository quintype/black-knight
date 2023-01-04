#!/bin/bash -e

# local files come from stdin

echo "Black-Knight: This build is running on "
hostname -f

publisher_name="$1"
repo="$2"
old_tag="$3"
new_tag="$4"
target_platform="$5"

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
RUN mkdir -p /app/public/$publisher_name
RUN echo "Deployment: $BLACK_KNIGHT_DEPLOYMENT" >> /app/public/round-table.txt
RUN tar xvf /tmp/config.tar -C /
EOF

echo "Black-Knight: I am Upgraded To Support Buiding Multi-Arch Docker Images"
export DOCKER_CLI_EXPERIMENTAL=enabled
echo "Black-Knight: I am creating binaries for multi-arch support"
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
echo "Black-Knight: Done Creating binaries for multi-arch support"
echo "Black-Knight: I am building Docker Image for platform $target_platform"
docker buildx build --platform=$target_platform --progress=plain -t "$repo:$new_tag" --push .

echo Copying assets from /app/public/$publisher_name
mkdir toupload
container_id=`docker create $repo:$new_tag`
docker cp "$container_id:/app/public/$publisher_name" "toupload/$publisher_name"

# Removing statically gzipped files
find toupload -exec rm -f {}.gz \;

echo Uploading to S3

aws s3 sync "toupload/$publisher_name/" "s3://quintype-frontend-assets/$QT_ENV/$publisher_name/" --cache-control max-age=31536000,public,s-maxage=31104000 --profile prod-bot

echo S3 upload has been completed

rm -rf toupload

docker rm "$container_id"
docker rmi "$repo:$new_tag"

echo "Black-Knight: Goodbye!"
