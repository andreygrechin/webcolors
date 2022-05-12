# An example of a containerized Flask app to play with k8s and Docker

The app shows one page with information about the server inside a container and
a client who requests this page. By default **gray** background is used for the
page. You may redefine the background color by specifying the environment
variable `COLOR` or providing an additional argument `--color`.

Images published in Docker Hub and GitHub Container Registry for easy
consumption:

1. [Docker Hub](https://hub.docker.com/r/andreygrechin/webcolors)
2. [GitHub Container Registry](https://github.com/andreygrechin/webcolors/pkgs/container/webcolors)

For example, to pull and run:

## Docker

```sh
docker run --rm --detach --publish 8081:8080 andreygrechin/webcolors:latest
open http://localhost:8081/

docker run --rm --detach --publish 8082:8080 --env COLOR=gold andreygrechin/webcolors:latest
open http://localhost:8082/

docker run --rm --detach --publish 8083:8080 --env COLOR=blue andreygrechin/webcolors:0.1.3
open http://localhost:8083/

docker run --rm --detach --publish 8084:8080 andreygrechin/webcolors:0.1.3 --color red
open http://localhost:8084/
```

## GitHub

```sh
docker run --rm --detach --publish 8085:8080 ghcr.io/andreygrechin/webcolors:latest
open http://localhost:8085/

docker run --rm --detach --publish 8086:8080 --env COLOR=gold ghcr.io/andreygrechin/webcolors:latest
open http://localhost:8086/

docker run --rm --detach --publish 8087:8080 --env COLOR=blue ghcr.io/andreygrechin/webcolors:0.1.3
open http://localhost:8087/

docker run --rm --detach --publish 8088:8080 ghcr.io/andreygrechin/webcolors:0.1.3 --color red
open http://localhost:8088/
```
