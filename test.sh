#!/bin/bash
set -u # fail if reference a variable that hasn’t been set
set -e # exit if a command fails
set -o pipefail # fail a pipeline if any command of pipeline failed

image_name=webcolors
image_version=temp

echo Image name: ${image_name}:${image_version}

docker run --rm -i hadolint/hadolint < Dockerfile

docker build --build-arg VERSION_TAG="local-build" --tag ${image_name}:${image_version} .
docker run --detach --publish 8080:8080 --name ${image_name} ${image_name}:${image_version}
open http://localhost:8080/
docker exec -it ${image_name} sh
docker rm --force ${image_name}
docker rmi ${image_name}:${image_version}
