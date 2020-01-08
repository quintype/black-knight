#!/bin/bash -e
username="$1"
repo="$2"
size="$3"
app_name="$4"
DEPLOYMENT="true"
KUBECTL="/usr/local/bin/kubectl"

if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

if [[ $KUBE_MASTER =~ "eks" ]]
then
  KUBECTL="/opt/bin/kubectl"
fi


KUBECTL="$KUBECTL --server=$KUBE_MASTER"

if [ $DEPLOYMENT == "true" ]; then
  $KUBECTL scale "deployments/$app_name" --replicas="$size" --namespace="$username"
else
  $KUBECTL scale "rc/$app_name" --replicas="$size" --namespace="$username"
fi
