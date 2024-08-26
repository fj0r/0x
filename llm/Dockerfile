FROM ollama/ollama

RUN set -eux \
  ; ollama serve & sleep 5 \
  ; for o in \
        mxbai-embed-large \
        #llama3.1:8b \
        phi3.5:3.8b \
        qwen2:1.5b \
        qwen2:7b \
  ; do \
        ollama pull ${o}; \
    done \
  ;
