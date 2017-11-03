#!/bin/bash -e
username="$1"
repo="$2"
tag="$3"
app_name="$4"
if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

is_exist(){
resource=$1
rc_name=$2
if kubectl get $resource  $rc_name --namespace=$username --server=$KUBE_MASTER 2>/dev/null 1>/dev/null ;then return 0; else return 1; fi
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

rollback_deployment(){
kubectl rolling-update $app_name --rollback  --namespace=$username --server=$KUBE_MASTER
}

checks(){
if ! is_exist "rc" "$next_deployment_id" ;then
 return 0
fi

replicas=$(kubectl get rc $next_deployment_id  -o go-template='{{.spec.replicas}}' --namespace=$username --server=$KUBE_MASTER)
if [ $replicas -gt 1 ];then
  echo "Aborting: Some existing deployment is in progress which has one or more pods in ready state."
  exit 1
fi

ready=$(kubectl get rc $next_deployment_id --namespace=$username --server=$KUBE_MASTER | tail -n+2 | awk '{print $4}')
if [ $ready -eq 1 ];then
  echo "Aborting: Some existing deployment is in progress which has pods in ready state"
  exit 1
fi

TIMEOUT=600
age=$(kubectl get rc $next_deployment_id --namespace=$username --server=$KUBE_MASTER | tail -n+2 | awk '{print $5}')
age_in_second=$(convert_time_in_second $age)
if [ $age_in_second -lt $TIMEOUT ];then
   echo -e "Aborting: Some existing deployment is in progress either wait for it to complete or for timeout\n Time remaining for TIMEOUT is: $(( $TIMEOUT - $age_in_second))"
   exit 1
fi

echo "Rolling back the older deployment  rc: $next_deployment_id"
rollback_deployment
return 0

}

start_deploy(){
  kubectl rolling-update "$app_name" "--image=$repo:$tag" "--server=$KUBE_MASTER" "--namespace=$username" "--image-pull-policy=IfNotPresent"
}

if  kubectl get rc --namespace=$username -o go-template='{{index .metadata.annotations "kubectl.kubernetes.io/next-controller-id"}}' --server=$KUBE_MASTER $app_name 2>/dev/null 1>/dev/null;then
next_deployment_id=$(kubectl get rc --namespace=$username  -o go-template='{{index .metadata.annotations "kubectl.kubernetes.io/next-controller-id"}}' --server=$KUBE_MASTER $app_name)
if checks; then start_deploy ;exit 0; fi
else
start_deploy
exit 0
fi
