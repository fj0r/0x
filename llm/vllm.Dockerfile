ARG BASEIMAGE=ghcr.io/fj0r/io:latest
FROM ${BASEIMAGE}

ARG PIP_FLAGS="--break-system-packages"
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        vllm

ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
