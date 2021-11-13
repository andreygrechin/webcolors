# An example of a containerized Flask app to play with k8s and Docker

The app shows one page with information about the server inside a container and
a client who requests this page. By default gray background is used for the
page. You may redefine the background color by specifying the environment
variable `COLOR` or providing an additional argument `--color`.

Images published in Docker Hub and GitHub Container Registry for easy
consumption:

1. [Docker Hub](https://hub.docker.com/r/andreygrechin/webcolors)
2. [GitHub Container Registry](https://github.com/andreygrechin/webcolors/pkgs/container/webcolors)

For example, to pull and run:

## Docker

```sh
docker run --rm -p 8080:8080 andreygrechin/webcolors:latest
docker run --rm -p 8080:8080 -e COLOR=gold andreygrechin/webcolors:latest
docker run --rm -p 8080:8080 --pull always -e COLOR=blue andreygrechin/webcolors:0.1
docker run --rm -p 8080:8080 --pull always andreygrechin/webcolors:0.1 --color red

open http://localhost:8080/
```

## GitHub

```sh
docker run --rm -p 8080:8080 ghcr.io/andreygrechin/webcolors:latest
docker run --rm -p 8080:8080 -e COLOR=gold ghcr.io/andreygrechin/webcolors:latest
docker run --rm -p 8080:8080 --pull always -e COLOR=blue ghcr.io/andreygrechin/webcolors:0.1
docker run --rm -p 8080:8080 --pull always ghcr.io/andreygrechin/webcolors:0.1 --color red

open http://localhost:8080/
```
