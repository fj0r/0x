FROM ollama/ollama

RUN set -eux \
  ; ollama serve & sleep 5 \
  ; ollama pull llama3.1:8b

