FROM ollama/ollama

RUN set -eux \
  ; ollama serve & sleep 5 \
  ; ollama pull llama3:8b

# ollama run llama2-chinese
