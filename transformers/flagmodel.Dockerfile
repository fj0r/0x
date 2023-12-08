FROM fj0rd/io:latest
ARG PIP_FLAGS="--break-system-packages"

ENV LANG=zh_CN.UTF-8
ENV HOME=/root
ENV PATH=${HOME}/.local/bin:$PATH

WORKDIR ${HOME}

RUN set -ex \
  ; pip install --no-cache-dir ${PIP_FLAGS} \
        ipython FlagEmbedding \
  ; printf "from FlagEmbedding import FlagModel\nmodel = FlagModel('BAAI/bge-large-zh-v1.5', query_instruction_for_retrieval='为这个句子生成表示以用于检索相关文章：', use_fp16=True)" \
    | python3 -
    
