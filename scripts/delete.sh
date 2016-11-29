#!/bin/bash

# Use deploy directory as working directory
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

# 2. Halt on any error
set -e

# 3. Kubernetes in container
dg() {
  docker run --rm -it -w /current \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):/current \
    --volumes-from gcloud-config yurifl/gcloud $@
}

dg gcloud compute disks delete --zone=<your-cluster-zone> work-setup-disk
dg gcloud compute disks list

dg kubectl delete -f ../kube/svc.yml
dg kubectl delete -f ../kube/rc.yml

dg kubectl get svc
dg kubectl get rc
dg kubectl get po

