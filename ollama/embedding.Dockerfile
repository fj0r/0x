FROM ollama/ollama

RUN set -eux \
  ; ollama serve & sleep 5 \
  ; ollama pull mxbai-embed-large
