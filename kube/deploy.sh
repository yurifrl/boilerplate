#!/bin/bash

# 1. Halt on any error
set -e

# 3. Use deploy directory as working directory
cd $( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )

# 2. Set app name
NAME=$(cat ../NAME)

# 4. Kubernetes in container
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


# 5. Bump version
/usr/bin/vim ../VERSION
VERSION=$(cat ../VERSION)

# 6. Build process
docker-compose run --rm web npm run build --production

# 7. Creates the image
docker-compose -f ./production.yml build

# 8. Tag the docker image
docker tag $NAME gcr.io/yebo-project/$NAME:$VERSION
docker tag $NAME gcr.io/yebo-project/$NAME:\latest

# 9. Pushes to kubernetes
dg gcloud docker push gcr.io/yebo-project/$NAME:$VERSION
dg gcloud docker push gcr.io/yebo-project/$NAME:\latest

# 10. Prints the run command
echo "docker run --rm -ti -p 80:80 -p 443:443 gcr.io/yebo-project/$NAME:v$VERSION"
echo "dg kubectl set image deployment/$NAME $NAME=gcr.io/yebo-project/$NAME:$VERSION"
