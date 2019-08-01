#!/bin/bash -e
username="$1"
repo="$2"
size="$3"
app_name="$4"
DEPLOYMENT="true"

if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

if [ $DEPLOYMENT == "true" ]; then
  $KUBECTL scale "deployments/$app_name" --replicas="$size" --server="$KUBE_MASTER" --namespace="$username"
else
  $KUBECTL scale "rc/$app_name" --replicas="$size" --server="$KUBE_MASTER" --namespace="$username"
fi
