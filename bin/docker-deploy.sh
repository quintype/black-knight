#!/bin/bash -e
app_name="$1"
repo="$2"
tag="$3"

if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

kubectl rolling-update "$app_name" "--image=$repo:$tag" "--server=$KUBE_MASTER" --rollback
