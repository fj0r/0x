ARG BASEIMAGE=ghcr.io/fj0r/io:nu
FROM ${BASEIMAGE}

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; sur_ver=$(curl https://api.github.com/repos/surrealdb/surrealdb/releases/latest | jq -r '.tag_name') \
  ; sur_url="https://github.com/surrealdb/surrealdb/releases/download/${sur_ver}/surreal-${sur_ver}.linux-amd64.tgz" \
  ; curl --retry 3 -sSL ${sur_url} | tar zxf - -C /usr/local/bin \
  ;

VOLUME ["/var/lib/surrealdb"]
ENV SURREAL_USER=foo
ENV SURREAL_PASS=foo
ENV SURREAL_BIND='0.0.0.0:8000'
EXPOSE 8000
COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint/init.sh"]
CMD ["srv"]

STOPSIGNAL SIGQUIT
