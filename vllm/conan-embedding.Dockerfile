ARG BASEIMAGE=ghcr.io/fj0r/0x:sentence_transformers
FROM ${BASEIMAGE}

COPY conan-embedding.py /app/conan-embedding.py
RUN set -eux \
  ; python /app/conan-embedding.py


ENV HF_DATASETS_OFFLINE=1
ENV HF_HUB_OFFLINE=1
