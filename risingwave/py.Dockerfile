FROM python:3.11-bookworm

RUN set -eux \
  ; pip install --no-cache-dir --break-system-packages \
    risingwave requests
