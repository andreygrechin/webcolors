#!/bin/bash
set -u          # fail if reference a variable that hasn't been set
set -e          # exit if a command fails
set -o pipefail # fail a pipeline if any command of pipeline failed

APP_NAME=webcolors

image_name=$APP_NAME
version="$(PYTHONPATH=src uv run python -c "import webcolors; print(webcolors.__version__)")"
image_tag="${version//+/-}"
timestamped_image="${image_name}:${image_tag}-$(date -u '+%Y%m%dT%H%M%SZ')"
echo "Image name: ${timestamped_image}"
BUILD_IMAGE=dhi.io/python:3.14.3-debian13-dev
RUNTIME_IMAGE=dhi.io/python:3.14.3-debian13-dev

docker run --rm --interactive --pull always hadolint/hadolint <Dockerfile

docker build \
    --build-arg VERSION_TAG="${image_tag}" \
    --build-arg BUILD_IMAGE="${BUILD_IMAGE}" \
    --build-arg RUNTIME_IMAGE="${RUNTIME_IMAGE}" \
    --tag "${timestamped_image}" \
    --file Dockerfile \
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
    --annotation "org.opencontainers.image.base.name=${RUNTIME_IMAGE}" \
    .
container_id=$(docker run --detach --publish 8080:8080 "${timestamped_image}")
echo "Container ID: ${container_id}"
sleep 3s
open http://localhost:8080/
docker exec -it "${container_id}" sh
docker rm --force "${container_id}"
echo "Deleted container ${container_id}"
docker rmi "${timestamped_image}"
echo "Deleted image ${timestamped_image}"
