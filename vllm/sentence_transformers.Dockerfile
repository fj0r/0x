ARG BASEIMAGE=ghcr.io/fj0r/io:root
FROM ${BASEIMAGE}

ARG PIP_FLAGS="--break-system-packages"
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

ENV HF_DATASETS_OFFLINE=0
ENV HF_HUB_OFFLINE=0
RUN set -eux \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        sentence_transformers \
  ;
