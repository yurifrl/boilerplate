#!/bin/bash

# 1. Create the initial config files
docker run -ti --name gcloud-config yurifl/gcloud gcloud init

# 2. Login process
docker run --rm -ti --volumes-from gcloud-config yurifl/gcloud gcloud beta auth application-default login

# 3. Cluster setup
docker run --rm -ti --volumes-from gcloud-config yurifl/gcloud gcloud container clusters get-credentials <your-cluster-name> --zone=<your-cluester-zone>

