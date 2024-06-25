FROM fj0rd/0x:fonts
ARG PIP_FLAGS="--break-system-packages"

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        #python3 python3-pip python3-setuptools \
        libnss3 libnspr4 libgbm1 libx11-xcb-dev libdbus-glib-1-2 \
        libgles2 gstreamer1.0-libav \
        libglib2.0-0 libatk1.0-0 libatk-bridge2.0-0 libxcb1 \
        libcups2 libdbus-1-3 libxkbcommon0 libgtk-3-0 libxt6 \
        libpango-1.0-0 libcairo2 libgdk-pixbuf2.0-0 libasound2 libatspi2.0-0 \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ; pip3 install --default-timeout=100 --no-cache-dir ${PIP_FLAGS} \
        playwright html5lib \
        httpx aiofile aiostream fastapi uvicorn \
        debugpy pytest pydantic PyParsing \
        ipython typer pydantic-settings pyyaml \
        boltons decorator deepmerge \
        structlog python-json-logger \
        #pyiceberg[s3fs,hive,pyarrow,pandas] \
  ; python3 -m playwright install \
  \
  ; pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

ENV DEBUG=pw:api
# python3 -m playwright codegen

