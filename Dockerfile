ARG BUILD_IMAGE=dhi.io/python:3.14.3-debian13-dev
ARG RUNTIME_IMAGE=dhi.io/python:3.14.3-debian13

FROM $BUILD_IMAGE AS builder

COPY --from=dhi.io/uv:0-debian13-dev /usr/local/bin/uv /usr/local/bin/uvx /usr/local/bin/
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev --no-editable

FROM $RUNTIME_IMAGE

ARG APP_NAME=webcolors
ARG VERSION_TAG
ARG GITHUB_ACTIONS
ARG GITHUB_SHA
ARG GITHUB_REF
ARG RUNNER_ARCH
ARG RUNNER_OS
ARG WEBCOLORS_HOST
ARG WEBCOLORS_PORT

ENV VERSION_TAG=${VERSION_TAG:-N/A} \
    GITHUB_ACTIONS=${GITHUB_ACTIONS:-N/A} \
    GITHUB_SHA=${GITHUB_SHA:-N/A} \
    GITHUB_REF=${GITHUB_REF:-N/A} \
    RUNNER_ARCH=${RUNNER_ARCH:-N/A} \
    RUNNER_OS=${RUNNER_OS:-N/A} \
    APP_NAME=${APP_NAME} \
    WEBCOLORS_HOST=${WEBCOLORS_HOST:-0.0.0.0} \
    WEBCOLORS_PORT=${WEBCOLORS_PORT:-8080} \
    PYTHONPATH=/app/src \
    PATH="/app/.venv/bin:${PATH}"

WORKDIR /app
COPY --from=builder /app/.venv /app/.venv
COPY ./src/ src/
COPY ./LICENSE .
COPY ./pyproject.toml .
COPY ./uv.lock .

EXPOSE 8080

CMD ["python3", "/app/src/webcolors/app.py"]
