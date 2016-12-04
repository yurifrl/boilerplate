#!/bin/bash

# 1. Halt on any error
set -e

# 2. Use deploy directory as working directory
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd $parent_path

# 3. Kubernetes in container
dg() {
  docker run --rm -it -w /current \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):/current \
    --volumes-from gcloud-config yurifl/gcloud $@
}

# 4. Bump version
/usr/bin/vim ../VERSION
VERSION=$(cat ../VERSION)

# 5. Build process
docker-compose run --rm web npm run build --production

# 6. Creates the image
docker-compose -f ../production.yml build

# 7. Tag the docker image
docker tag boilerplate "gcr.io/yebo-project/boilerplate:$VERSION"
docker tag boilerplate "gcr.io/yebo-project/boilerplate:latest"

# 8. Pushes to kubernetes
dg gcloud docker push "gcr.io/yebo-project/boilerplate:$VERSION"
dg gcloud docker push "gcr.io/yebo-project/boilerplate:latest"

# 9. Prints the run command
echo "docker run --rm -ti -p 80:80 -p 443:443 gcr.io/yebo-project/boilerplate:v$VERSION"

# 10. Prints rolling update command
echo "dg kubectl rolling-update boilerplate --image=gcr.io/yebo-project/boilerplate:$VERSION"

