#!/bin/bash

# 1. Halt on any error
set -e

# 2. Set zone
ZONE=us-east1-d

# 3. Use deploy directory as working directory
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

# 4. Kubernetes in container
dg() {
  docker run --rm -it -w /current \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):/current \
    --volumes-from gcloud-config yurifl/gcloud $@
}

# 5. Delete Disk
dg gcloud compute disks delete --zone=$ZONE boilerplate-disk
dg gcloud compute disks list

# 6. Delete Service and Replication Controller
dg kubectl delete -f ../kube/svc.yml
dg kubectl delete -f ../kube/rc.yml

# 7. List
dg kubectl get svc
dg kubectl get rc
dg kubectl get po

