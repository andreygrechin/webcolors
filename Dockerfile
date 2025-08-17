ARG UV_IMAGE=ghcr.io/astral-sh/uv:0.8.11
ARG BASE_IMAGE=python:3.13.7-alpine3.22

# hadolint ignore=DL3006
FROM $UV_IMAGE AS uv

# hadolint ignore=DL3006
FROM $BASE_IMAGE AS builder

COPY --from=uv /uv /uvx /bin/
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev
COPY ./src/ src/
COPY ./LICENSE .
COPY ./pyproject.toml .
COPY ./uv.lock .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# ARG BASE_IMAGE=python:3.13.7-alpine3.22
# hadolint ignore=DL3006
FROM $BASE_IMAGE

ARG APP_NAME=jobot
ARG VERSION_TAG
ARG GITHUB_ACTIONS
ARG GITHUB_SHA
ARG GITHUB_REF
ARG RUNNER_ARCH
ARG RUNNER_OS
ARG WEBCOLORS_HOST
ARG WEBCOLORS_PORT

ENV VERSION_TAG=${VERSION_TAG:-N/A}
ENV GITHUB_ACTIONS=${GITHUB_ACTIONS:-N/A}
ENV GITHUB_SHA=${GITHUB_SHA:-N/A}
ENV GITHUB_REF=${GITHUB_REF:-N/A}
ENV RUNNER_ARCH=${RUNNER_ARCH:-N/A}
ENV RUNNER_OS=${RUNNER_OS:-N/A}
ENV APP_NAME=webcolors
ENV WEBCOLORS_HOST=${WEBCOLORS_HOST:-0.0.0.0}
ENV WEBCOLORS_PORT=${WEBCOLORS_PORT:-8080}
ENV PYTHONPATH=/app/src

EXPOSE 8080
WORKDIR /app

COPY --from=builder /app /app

RUN adduser -D -u 1000 -s /sbin/nologin "$APP_NAME"
USER "$APP_NAME"
CMD ["/app/.venv/bin/python3", "/app/src/webcolors/app.py"]
