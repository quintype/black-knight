#!/bin/bash -e
username="$1"
repo="$2"
tag="$3"
app_name="$4"
if [ -z "$KUBE_MASTER" ]; then
  echo Please provide a deploy server
  exit 1
fi

kubectl rolling-update "$app_name" "--image=$repo:$tag" "--server=$KUBE_MASTER" "--namespace=$username"

while read; do
  curl -X POST https://hooks.slack.com/services/your/hook/here" --data-binary @- <<-EOF
  {"channel": "#deploys", "username": "Black Knight", "text": "Deployed $app_name with tag $tag", "icon_emoji": ":wrench:"}
EOF
done
