FROM fj0rd/io:base

RUN set -eux \
  ; reg_url=$(curl -sSL https://api.github.com/repos/distribution/distribution/releases -H 'Accept: application/vnd.github.v3+json' \
              | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' \
              | grep -v sha256 \
              | grep linux_amd64) \
  ; curl -sSL ${reg_url} | tar zxvf - -C /usr/local/bin registry


COPY ./config.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 80 5000

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
