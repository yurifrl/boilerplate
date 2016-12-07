#!/bin/bash
dg () {
  docker run --rm -it -w /current \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $HOME/.ssh:/.ssh \
    -v $(pwd):/current \
    -v gcloud-data:/.config \
    -v gcloud-data:/.kube \
    -v gcloud-data:/.kubecfg \
    --name dg \
    yurifl/gcloud $@
}

# Log in to gcloud
docker volume create --name=gcloud-data
dg gcloud init
dg gcloud beta auth application-default login
dg gcloud container clusters get-credentials cluster-1 --zone=us-east1-d
dg kubectl cluster-info
