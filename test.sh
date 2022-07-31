#!/bin/bash
set -u # fail if reference a variable that hasn’t been set
set -e # exit if a command fails
set -o pipefail # fail a pipeline if any command of pipeline failed

image_name=$APP_NAME
old_image_version="$(cat VERSION)"
image_version=$(scripts/semver bump patch "$old_image_version")
echo "$image_version" > VERSION

echo Image name: "${image_name}:${image_version}"

docker run --rm --interactive --pull always hadolint/hadolint < Dockerfile

docker build --build-arg VERSION_TAG="${image_version}" --tag "${image_name}:${image_version}" .
echo docker build --build-arg VERSION_TAG="${image_version}" --tag "${image_name}:${image_version}" .
docker run --detach --publish 8080:8080 --name "${image_name}" "${image_name}:${image_version}"
echo docker run --detach --publish 8080:8080 --name "${image_name}" "${image_name}:${image_version}"
open http://localhost:8080/
docker exec -it "${image_name}" sh
docker rm --force "${image_name}"
docker rmi "${image_name}:${image_version}"
