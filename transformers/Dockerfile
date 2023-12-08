FROM fj0rd/io:latest
ARG PIP_FLAGS="--break-system-packages"

ENV LANG=zh_CN.UTF-8
ENV HOME=/root
ENV PATH=${HOME}/.local/bin:$PATH

WORKDIR ${HOME}

RUN set -ex \
  ; pip install --no-cache-dir ${PIP_FLAGS} \
        ipython torch transformers \
  ; printf "from transformers import pipeline\npipeline('feature-extraction')" \
    | python3 -
