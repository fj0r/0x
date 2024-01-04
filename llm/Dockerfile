ARG BASEIMAGE=fj0rd/io:latest
FROM ${BASEIMAGE}

ARG PIP_FLAGS="--break-system-packages"
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        vllm "fschat[model_worker,webui]"
