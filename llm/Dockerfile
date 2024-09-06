FROM ollama/ollama

RUN set -eux \
  ; ollama serve & sleep 5 \
  ; for o in \
        #llama3.1:8b \
        #phi3.5:3.8b \
        roger/minicpm \
        qwen2:1.5b \
  ; do \
        ollama pull ${o}; \
    done \
  ;

RUN set -eux \
  ; ollama serve & sleep 5 \
  ; ollama pull qwen2:7b
