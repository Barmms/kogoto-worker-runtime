# Runtime shell for the KOGOTO social worker. Contains NO application code and
# NO secrets: at start the container clones the private kogoto-content-engine
# repo with a repo-scoped deploy key supplied as a host env var.
FROM python:3.11-slim
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends \
        ffmpeg git openssh-client ca-certificates fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
