FROM python:3.10-alpine3.15
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
