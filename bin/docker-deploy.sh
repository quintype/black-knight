#!/bin/bash -e
username="$1"
repo="$2"
tag="$3"
app_name="$4"
multi_container_pod="$5"

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

ready=$(kubectl get rc $next_deployment_id --namespace=$username --server=$KUBE_MASTER | tail -n+2 | awk '{print $4}')

TIMEOUT=600
age=$(kubectl get rc $next_deployment_id --namespace=$username --server=$KUBE_MASTER | tail -n+2 | awk '{print $5}')
age_in_second=$(convert_time_in_second $age)

if ([ $replicas -gt 1 ] && [ $ready -eq 1] && [ $age_in_second -lt $TIMEOUT ]);then
   echo -e "Aborting: Some existing deployment is in progress.\n Time remaining for TIMEOUT is: $(( $TIMEOUT - $age_in_second))"
   exit 1
fi

echo "Rolling back the failed RC: $next_deployment_id"
rollback_deployment
echo "Rolled Back"
return 0

}

start_deploy(){
 if "$multi_container_pod" == "true";then
 	echo "Deploying container $app_name in multi container pod"
  kubectl rolling-update "$app_name" "--image=$repo:$tag" "--container=$app_name" "--server=$KUBE_MASTER" "--namespace=$username" "--image-pull-policy=IfNotPresent"
 else
  kubectl rolling-update "$app_name" "--image=$repo:$tag" "--server=$KUBE_MASTER" "--namespace=$username" "--image-pull-policy=IfNotPresent"	
 fi  
}

if  kubectl get rc --namespace=$username -o go-template='{{index .metadata.annotations "kubectl.kubernetes.io/next-controller-id"}}' --server=$KUBE_MASTER $app_name 2>/dev/null 1>/dev/null;then
next_deployment_id=$(kubectl get rc --namespace=$username  -o go-template='{{index .metadata.annotations "kubectl.kubernetes.io/next-controller-id"}}' --server=$KUBE_MASTER $app_name)
if checks; then start_deploy ;exit 0; fi
else
start_deploy
exit 0
fi
