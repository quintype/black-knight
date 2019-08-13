#!/bin/bash -e
username="$1"
repo="$2"
tag="$3"
app_name="$4"
KUBECTL="/usr/local/bin/kubectl"
DEPLOYMENT="true"

if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

is_exist(){
    resource=$1
    resource_name=$2
    if $KUBECTL get $resource  $resource_name --namespace=$username --server=$KUBE_MASTER 2>/dev/null 1>/dev/null ;then return 0; else return 1; fi
}

convert_time_in_second(){
    time=$1
    suffix=${time:((-1))}
    d="24 * 60 *60"
    h="60 * 60"
    m="60"
    s="1"
    prefix=${time/[a-z]}
    echo $(( $prefix * ${!suffix} ))
}

rollback_rc(){
    $KUBECTL rolling-update $app_name --rollback  --namespace=$username --server=$KUBE_MASTER
}

rollback_deployments(){
    $KUBECTL rollout undo deployments/$app_name  --namespace=$username --server=$KUBE_MASTER
}

checks(){
    if ! is_exist "rc" "$next_deployment_id" ;then
     return 0
    fi

    replicas=$($KUBECTL get rc $next_deployment_id  -o go-template='{{.spec.replicas}}' --namespace=$username --server=$KUBE_MASTER)

    ready=$($KUBECTL get rc $next_deployment_id --namespace=$username --server=$KUBE_MASTER | tail -n+2 | awk '{print $4}')

    TIMEOUT=600
    age=$($KUBECTL get rc $next_deployment_id --namespace=$username --server=$KUBE_MASTER | tail -n+2 | awk '{print $5}')
    age_in_second=$(convert_time_in_second $age)

    if ([ $replicas -gt 1 ] && [ $ready -eq 1] && [ $age_in_second -lt $TIMEOUT ]);then
       echo -e "Aborting: Some existing deployment is in progress.\n Time remaining for TIMEOUT is: $(( $TIMEOUT - $age_in_second))"
       exit 1
    fi

    echo "Rolling back the failed RC: $next_deployment_id"
    rollback_rc
    echo "Rolled Back"
    return 0
}


checks_deployments(){
    if ! is_exist "deployments" "$next_deployment_id" ;then
     return 0
    fi

    replicas=$($KUBECTL get deployments $next_deployment_id  -o go-template='{{.spec.replicas}}' --namespace=$username --server=$KUBE_MASTER)

    ready=$($KUBECTL get deployments $next_deployment_id --namespace=$username --server=$KUBE_MASTER | tail -n+2 | awk '{print $4}')

    TIMEOUT=600
    age=$($KUBECTL get deployments $next_deployment_id --namespace=$username --server=$KUBE_MASTER | tail -n+2 | awk '{print $5}')
    age_in_second=$(convert_time_in_second $age)

    if ([ $replicas -gt 1 ] && [ $ready -eq 1] && [ $age_in_second -lt $TIMEOUT ]);then
       echo -e "Aborting: Some existing deployment is in progress.\n Time remaining for TIMEOUT is: $(( $TIMEOUT - $age_in_second))"
       exit 1
    fi

    echo "Rolling back the failed DEPLOYMENT: $next_deployment_id"
    rollback_deployments
    echo "Rolled Back"
    return 0

}

start_deploy_rc(){
    KUBE_OPTS=""

    if [ "$MULTIPLE_CONTAINER_PODS" == "true" ]; then
    KUBE_OPTS="$KUBE_OPTS --container=$app_name"
    fi

    $KUBECTL rolling-update "$app_name" "--image=$repo:$tag" $KUBE_OPTS "--server=$KUBE_MASTER" "--namespace=$username" "--image-pull-policy=IfNotPresent"

    IFS=', ' read -r -a containers <<< "$DEPLOYABLE_CONTAINERS"
    for container in "${containers[@]}"
    do
        $KUBECTL rolling-update "$app_name" "--image=$repo:$tag" "--server=$KUBE_MASTER" "--namespace=$username" "--image-pull-policy=IfNotPresent" "--container=$container"
    done
}


start_deploy_deployments(){
    all_containers="$app_name=$repo:$tag"
    IFS=', ' read -r -a containers <<< "$DEPLOYABLE_CONTAINERS"
    for container in "${containers[@]}"
      do
          all_containers="$all_containers $container=$repo:$tag"
    done
    $KUBECTL  set image  "deployments/$app_name" $all_containers "--server=$KUBE_MASTER" "--namespace=$username"
    $KUBECTL rollout status  "deployments/$app_name" "--server=$KUBE_MASTER" "--namespace=$username"
}

redeploy_deployments(){
    echo "Redeploying ...."
    all_containers="$app_name=$repo:$tag"
    IFS=', ' read -r -a containers <<< "$DEPLOYABLE_CONTAINERS"
    for container in "${containers[@]}"
      do
          all_containers="$all_containers $container=$repo:$tag"
    done
    $KUBECTL patch "deployments/$app_name" -p "{\"spec\": {\"template\": {\"metadata\": { \"labels\": {  \"redeploy\": \"$(date +%s)\"}}}}}" "--server=$KUBE_MASTER" "--namespace=$username"
    $KUBECTL rollout status  "deployments/$app_name" "--server=$KUBE_MASTER" "--namespace=$username"
}

if [ $DEPLOYMENT == "true" ]; then
    if  $KUBECTL get deployments --namespace=$username -o go-template='{{index .metadata.annotations "$KUBECTL.kubernetes.io/next-controller-id"}}' --server=$KUBE_MASTER $app_name 2>/dev/null 1>/dev/null;then
        next_deployment_id=$($KUBECTL get deployments --namespace=$username  -o go-template='{{index .metadata.annotations "$KUBECTL.kubernetes.io/next-controller-id"}}' --server=$KUBE_MASTER $app_name)
        if checks_deployments; then
           redeploy_deployments ;exit 0;
        fi
    else
        start_deploy_deployments
        exit 0
    fi
else
    if  $KUBECTL get rc --namespace=$username -o go-template='{{index .metadata.annotations "$KUBECTL.kubernetes.io/next-controller-id"}}' --server=$KUBE_MASTER $app_name 2>/dev/null 1>/dev/null;then
        next_deployment_id=$($KUBECTL get rc --namespace=$username  -o go-template='{{index .metadata.annotations "$KUBECTL.kubernetes.io/next-controller-id"}}' --server=$KUBE_MASTER $app_name)
        if checks; then
           start_deploy_rc ;exit 0;
        fi
    else
        start_deploy_rc
        exit 0
   fi
fi
