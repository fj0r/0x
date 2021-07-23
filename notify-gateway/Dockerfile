ARG BASE_IMAGE=python:rc-alpine3.14
FROM ${BASE_IMAGE}

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk update && apk upgrade \
  ; rm -rf /var/cache/apk/* \
  ; apk add --no-cache tzdata \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone

RUN set -eux \
  ; pip3 --no-cache-dir install \
      fastapi uvicorn httpx aiofile \
      PyParsing decorator more-itertools \
      typer pyyaml cachetools chronyk

COPY src /app

WORKDIR /app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]

ARG CI_COMMIT_SHA
ARG CI_COMMIT_TITLE
ARG CI_PIPELINE_ID
ENV CI_COMMIT_SHA=${CI_COMMIT_SHA} \
    CI_COMMIT_TITLE=${CI_COMMIT_TITLE} \
    CI_PIPELINE_ID=${CI_PIPELINE_ID}


