#!/bin/bash -e
username="$1"
repo="$2"
tag="$3"
app_name="$4"
shift 4

if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

kubectl run -i ${app_name}-migrate-$tag --image=${repo}:${tag} --restart=Never --namespace=$username --server=$KUBE_MASTER --command "$@"
kubectl delete pod ${app_name}-migrate-$tag --namespace=$username
