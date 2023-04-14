FROM fj0rd/scratch:dropbear-alpine as dropbear

FROM openresty/openresty:alpine-amd64


ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

COPY --from=dropbear / /

RUN ln -fs /usr/local/openresty/nginx/conf /etc/openresty
COPY config /etc/openresty
COPY setup.sh /srv
WORKDIR /srv

VOLUME [ "/srv" ]
EXPOSE 80 443
ENV PREBOOT=
ENV POSTBOOT=
ENV HTPASSWD=
ENV UPLOAD_ROOT=

COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint/init.sh"]

STOPSIGNAL SIGQUIT

