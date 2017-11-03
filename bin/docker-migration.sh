#!/bin/bash -e
username="$1"
repo="$2"
tag="$3"
app_name="$4"
ABORT="${ABORT:-0}"
shift 4

if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

kubecmd="kubectl --namespace=${username} --server=${KUBE_MASTER} --kubeconfig=../config/kubeconfig"

if [ "$ABORT" -eq 1 ]; then
  $kubecmd delete pod ${tag}
else
  $kubecmd run -i ${tag} --image=${repo}:${tag} --restart=Never  --overrides='{"spec":{"imagePullSecrets":[{"name":"myregistrykey"}]}}' --quiet=true --command -- $@
  $kubecmd delete pod ${tag}
fi
