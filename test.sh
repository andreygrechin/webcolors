#!/bin/bash
set -u # fail if reference a variable that hasn’t been set
set -e # exit if a command fails
set -o pipefail # fail a pipeline if any command of pipeline failed

image_name=$APP_NAME
version="$(cat src/"${APP_NAME}"/VERSION)"
image_tag="${version//+/-}"
BASE_PYTHON_IMAGE_TAG="3.13.7-alpine3.22"
timestamped_image="${image_name}:${image_tag}-$(date -u '+%Y%m%dT%H%M%SZ')"
echo "Image name: ${timestamped_image}"


docker run --rm --interactive --pull always hadolint/hadolint < Dockerfile

docker build \
    --build-arg VERSION_TAG="${image_tag}" \
    --build-arg BASE_PYTHON_IMAGE_TAG="${BASE_PYTHON_IMAGE_TAG}" \
    --tag "${timestamped_image}" \
    --platform linux/amd64,linux/arm64 \
    --annotation "org.opencontainers.image.created=$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    --annotation "org.opencontainers.image.url=https://github.com/andreygrechin/webcolors" \
    --annotation "org.opencontainers.image.documentation=https://github.com/andreygrechin/webcolors/blob/main/README.md" \
    --annotation "org.opencontainers.image.version=$(git describe --tags --always --dirty)" \
    --annotation "org.opencontainers.image.revision=$(git rev-parse --short HEAD)" \
    --annotation "org.opencontainers.image.source=$(git config --get remote.origin.url)" \
    --annotation "org.opencontainers.image.title=${APP_NAME}" \
    --annotation "org.opencontainers.image.description='An example of a containerized Flask app to play with K8s and Docker'" \
    --annotation "org.opencontainers.image.authors=$(git config --get user.email)" \
    --annotation "org.opencontainers.image.licenses=MIT" \
    --annotation "org.opencontainers.image.base.name=docker.io/python:${BASE_PYTHON_IMAGE_TAG}" \
    .
container_id=$(docker run --detach --publish 8080:8080 "${timestamped_image}")
echo "Container ID: ${container_id}"
open http://localhost:8080/
docker exec -it "${container_id}" sh
docker rm --force "${container_id}"
echo "Deleted container ${container_id}"
docker rmi "${timestamped_image}"
echo "Deleted image ${timestamped_image}"
