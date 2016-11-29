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

# 4. Bump version
/usr/bin/vim ../VERSION
VERSION=$(cat ../VERSION)

# 4. Build process
docker-compose run --rm web npm run build --production

# 5. Creates the image
docker-compose -f ../production.yml build

# 6. Tag the docker image
docker tag work-setup "gcr.io/yebo-project/work-setup:$VERSION"
docker tag work-setup "gcr.io/yebo-project/work-setup:latest"

# 7. Pushes to kubernetes
dg gcloud docker push "gcr.io/yebo-project/work-setup:$VERSION"
dg gcloud docker push "gcr.io/yebo-project/work-setup:latest"

# 8. Prints the run command
echo "docker run --rm -ti -p 80:80 -p 443:443 gcr.io/yebo-project/work-setup:v$VERSION"

# 9. Prints rolling update command
echo "dg kubectl rolling-update work-setup --image=gcr.io/yebo-project/work-setup:$VERSION"

