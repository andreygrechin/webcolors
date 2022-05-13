FROM python:3.10-alpine3.15
ARG VERSION_TAG
ARG GITHUB_ACTIONS
ARG GITHUB_SHA
ARG GITHUB_REF
ARG RUNNER_ARCH
ARG RUNNER_OS

ENV VERSION_TAG=${VERSION_TAG:-N/A}
ENV GITHUB_ACTIONS=${GITHUB_ACTIONS:-N/A}
ENV GITHUB_SHA=${GITHUB_SHA:-N/A}
ENV GITHUB_REF=${GITHUB_REF:-N/A}
ENV RUNNER_ARCH=${RUNNER_ARCH:-N/A}
ENV RUNNER_OS=${RUNNER_OS:-N/A}

LABEL env=test \
    os=alpine \
    app=webcolors
EXPOSE 8080
WORKDIR /app
COPY ./requirements.txt ./
RUN /usr/local/bin/python -m pip install --upgrade pip --no-cache-dir \
    && pip install --no-cache-dir -r /app/requirements.txt \
    && mkdir /app/logs \
    && chown 1000:2000 /app/logs
COPY ./src/ ./src/
USER 1000:2000
ENTRYPOINT ["python", "/app/src/webcolors.py"]
CMD ["--color", "green"]

# different ways to provide environment variables and arguments
# ENTRYPOINT ["python", "/app/src/webcolors.py", "--color", "green"]
# ENV COLOR=red
