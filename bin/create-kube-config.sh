#!/bin/bash -e

MEM=1500Mi
CPU=420m

if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

usage()
{
echo -e "Usage: $0 [create|delete|delete-all] args
         $0 create app_name repo publisher
         eg:-
         $0 create staging-thequint quintype/theuqint thequint
         define CLASS env variable to change the container class(possible values are: q.small,q.medium)"
exit
}


create_temp_directory()
{

TEMPORARY_DIR=`mktemp -d -t kube-configXXXXXXXX`
mkdir -p $TEMPORARY_DIR
cd $TEMPORARY_DIR
mkdir -p $app_name
cd $app_name

}

def_class()
{
case $1 in
   q.small)
       MEM="1500Mi"
       CPU="420m"
       ;;
   q.medium)
       MEM="3000Mi"
       CPU="840m"
       ;;
   q.micor)
       MEM="1500Mi"
       CPU="200m"
       ;;
   q.custome)
       MEM=$mem
       CPU=$cpu
       ;;
esac
}

get_server()
{
server="${KUBE_MASTER}"
echo $server
}

create_rc()
{
echo "in create_rc"
cat > rc.yml <<EOF
apiVersion: v1
kind: ReplicationController
metadata:
  name: $app_name
  namespace: $publisher
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: $app_name
        version: "1"
    spec:
      containers:
      - name: $app_name
        image: $repo_name
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /ping
            port: 3000
            scheme: HTTP
          initialDelaySeconds: 30
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 5
        resources:
          limits:
            memory: ${MEM}
          requests:
            cpu: ${CPU}
        ports:
        - containerPort: 3000
      imagePullSecrets:
        - name: myregistrykey
EOF
cat rc.yml
$kubectl create -f rc.yml
}

create_svc()
{
cat > svc.yml << EOF
apiVersion: v1
kind: Service
metadata:
  name: $app_name
  namespace: $publisher
spec:
  selector:
   app: $app_name
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
EOF

$kubectl create -f svc.yml
}

create_ns()
{
cat > $publisher.yml << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: $publisher
EOF

$kubectl create -f $publisher.yml
}

create_secret()
{
cat > image_pull_secret.yml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: myregistrykey
data:
  .dockerconfigjson: $secret
type: kubernetes.io/dockerconfigjson
EOF

$kubectl create -f image_pull_secret.yml --namespace=$publisher
}

check_exist()
{
$kubectl describe $1 $2  --namespace=$publisher > /dev/null 2>&1
exist=$?
if [ "$exist" -ne "0" ] ;then
  return "1"
else
  return "0"
fi
}

create()
{
if check_exist "$1" $2 ;then
  echo  " $2 $1 already exists. skipping..."
else
  create_$1
fi
}

create_config()
{
create_temp_directory
create ns $publisher
create secret $secret_name
if [ -n $CLASS ];then
    def_class $CLASS
fi
create rc $app_name
create svc $app_name
IP=$( $kubectl get svc $app_name --namespace=$publisher | grep -v CLUSTER-IP | awk '{print $2}')
proxy_config $IP
}


secret="${SECRET}"
secret_name='myregistrykey'

if [ "$#" -gt 1 ];then
  opt=$1
  shift 1
else
  usage
fi

case $opt in
   create)
      if [ $# -ne 3 ]; then
         usage
         exit 1
      fi
      app_name=$1
      repo_name=$2
      publisher=$3
      server=$(get_server)
      kubectl="kubectl --server=$server"
      create_config
   ;;
   *) usage
   ;;
esac
