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

KUBECTL="/usr/local/bin/kubectl"

if [[ $KUBE_MASTER =~ "eks" ]]
then
  KUBECTL="/opt/bin/kubectl"
fi

kubecmd="${KUBECTL} --namespace=${username} --server=${KUBE_MASTER}"

kube_secrets=$($kubecmd get secrets  -o json | jq '.items[].data' | jq -r 'to_entries[] | "\(.key)::\(.value )"') # using :: just as separator
kube_secrets_arr=$(echo $kube_secrets | tr " " "\n")
secrets_string=""
for kv in $kube_secrets_arr
do
    IFS='::' read -r -a secret_kv <<< "$kv"
    secret_key=${secret_kv[0]}
    if [[ "$secret_key" =~ "namespace" ]] || [[ "$secret_key" =~ "ca.crt" ]] || [[ "$secret_key" =~ "token" ]] || [[ "$secret_key" =~ ".dockerconfigjson" ]]; then
      echo "ignoring certs secret. ${secret_kv[0]}"
    else
      base64_decode_value=$(echo ${secret_kv[2]} | base64 --decode)
      updated_base64_value=${base64_decode_value// /} # remove blank spaces
      secrets_string="$secrets_string --env=$secret_key=$updated_base64_value"
    fi
done


#Running migration pods in different namespace
NAMESPACES=$(${KUBECTL} get ns)
if [[ ${NAMESPACES} == *"quintype-all-migrations"* ]]; then
    echo "******************************"
    echo "Namespace exists"
else
    echo "quintype-all-migrations namespace does not exist,please create it to continue "
    exit 1
fi


kubecmd="${KUBECTL} --namespace=quintype-all-migrations --server=${KUBE_MASTER}"

if [ "$ABORT" -eq 1 ]; then
  $kubecmd delete pod ${tag}
else
  $kubecmd run -i ${tag} --image=${repo}:${tag} --labels app=${app_name}-migrate --restart=Never $secrets_string --overrides='{"spec":{"imagePullSecrets":[{"name":"myregistrykey"}]}}' --command -- $@
  $kubecmd delete pod ${tag}
fi

