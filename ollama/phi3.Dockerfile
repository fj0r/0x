FROM ollama/ollama

RUN set -eux \
  ; ollama serve & sleep 5 \
  ; ollama pull phi3.5:3.8b

