FROM ghcr.io/fj0r/io:__dropbear__ AS dropbear

FROM openresty/openresty:alpine-amd64


ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

COPY --from=dropbear / /

RUN set -eux \
  ; apk add --no-cache \
        pcre \
        zlib \
        bash \
        curl \
        jq \
        zstd \
        patch \
        shadow \
        sudo \
        openssl \
        quickjs \
  ; adduser -SDH www-data -G www-data -h /srv \
  ; ln -fs /usr/local/openresty/nginx/conf /etc/openresty

COPY config /etc/openresty
COPY setup.sh /srv
WORKDIR /srv

VOLUME [ "/srv" ]
EXPOSE 80 443
ENV PREBOOT=
ENV POSTBOOT=

COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint/init.sh"]
CMD ["srv"]

STOPSIGNAL SIGQUIT

