#!/bin/bash

# 2. Use deploy directory as working directory
cd $( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )

# 5. Kubernetes in container
dg() {
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

dg kubectl delete -f ./config/

