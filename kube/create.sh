#!/bin/bash

#
set -e

# cd to script folder
cd $( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )

#
NAME=$(cat ../NAME)

#
dg() {
  docker run --rm -it -w /current \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $HOME/.ssh:/.ssh \
    -v $(pwd):/current \
    -v gcloud-data:/.config \
    -v gcloud-data:/.kube \
    -v gcloud-data:/.kubecfg \
    yurifl/gcloud $@
}

# Build
docker-compose run --rm web npm run build --production

#
docker-compose -f ./production.yml build

#
docker tag $NAME gcr.io/yebo-project/$NAME:\latest

#
dg gcloud docker push gcr.io/yebo-project/$NAME:\latest

#
echo "dg kubectl create secret generic tls-$NAME-certs --from-file=./certs"
echo "dg kubectl get secrets tls-$NAME-certs -o yaml >> secrets.yml"
echo "dg kubectl apply -f ./config/"
