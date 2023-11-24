FROM libretranslate/libretranslate:latest
ARG MODELS="en,zh"

USER libretranslate

WORKDIR /app

RUN set -eux \
  ; ./venv/bin/python scripts/install_models.py --load_only_lang_codes "$MODELS" \
  ; rm -rf /tmp/prometheus_data \
  ; mkdir -p /tmp/prometheus_data

ENV LT_HOST=0.0.0.0
ENV PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus_data
ENTRYPOINT [ "./venv/bin/libretranslate"]

