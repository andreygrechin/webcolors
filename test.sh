#!/bin/bash
set -u # fail if reference a variable that hasn’t been set
set -e # exit if a command fails
set -o pipefail # fail a pipeline if any command of pipeline failed

image_name=$APP_NAME
version="$(cat VERSION)"
image_tag=${version//+/-}
echo Image name: "${image_name}:${image_tag}"

python3 scripts/update_requirements.py

docker run --rm --interactive --pull always hadolint/hadolint < Dockerfile

docker build --build-arg VERSION_TAG="${image_tag}" --tag "${image_name}:${image_tag}" .
echo docker build --build-arg VERSION_TAG="${image_tag}" --tag "${image_name}:${image_tag}" .
docker run --detach --publish 8080:8080 --name "${image_name}" "${image_name}:${image_tag}"
echo docker run --detach --publish 8080:8080 --name "${image_name}" "${image_name}:${image_tag}"
open http://localhost:8080/
docker exec -it "${image_name}" sh
docker rm --force "${image_name}"
docker rmi "${image_name}:${image_tag}"
