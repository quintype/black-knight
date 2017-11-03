#!/bin/bash -e
username="$1"
repo="$2"
size="$3"
app_name="$4"
if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

kubectl scale "rc/$app_name" --replicas="$size" --server="$KUBE_MASTER" --namespace="$username" --kubeconfig=../config/kubeconfig
