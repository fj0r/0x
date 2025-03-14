FROM ollama/ollama

RUN set -eux \
  ; ollama serve & sleep 5 \
  ; ollama pull llava-phi3:3.8b

