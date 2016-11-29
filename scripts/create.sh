#!/bin/bash

# 1. Use deploy directory as working directory
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

#
dg gcloud compute disks create --size=200GB --zone=<your-cluster-zone> boilerplate-disk
dg gcloud compute disks list

# 4. Build process
docker-compose run --rm web npm run build --production

# 5. Creates the image
docker-compose -f ../production.yml build

# 6. Tag the docker image
docker tag boilerplate "gcr.io/yebo-project/boilerplate:latest"

# 7. Pushes to kubernetes
dg gcloud docker push "gcr.io/yebo-project/boilerplate:latest"

# 8. Prints the posible comands
dg kubectl create -f ../kube/rc.yml
dg kubectl create -f ../kube/svc.yml

# 9. Prints the actual state of the cluster
dg kubectl get svc
dg kubectl get rc
dg kubectl get po

