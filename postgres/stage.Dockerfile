FROM fj0rd/pg

ENV BUILD_DEPS \
	git \
	cmake \
	curl \
	build-essential \
	ca-certificates \
	libpq-dev \
	postgresql-server-dev-13

RUN set -eux \
    ; apt-get update \
	; apt-get install -y --no-install-recommends \
		${BUILD_DEPS:-} \
    ; cd /root \
    ; git clone https://github.com/jaiminpan/pg_jieba \
    ; cd pg_jieba \
    ; git submodule update --init --recursive

WORKDIR /root/pg_jieba

