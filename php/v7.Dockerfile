ARG PHP_VERSION=7.4
FROM ghcr.io/fj0r/io:__dropbear__ AS dropbear
FROM ghcr.io/fj0r/io:base
COPY --from=dropbear / /

EXPOSE 8080

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; ferron_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/ferronweb/ferron/releases | jq -r '.[0].name') \
  ; ferron_url="https://github.com/ferronweb/ferron/releases/download/${ferron_ver}/ferron-${ferron_ver}-x86_64-unknown-linux-musl.zip" \
  ; mkdir -p /opt/ferron \
  ; cd /opt/ferron \
  ; curl --retry 3 -fsSL ${ferron_url} -o ferron.zip \
  ; unzip ferron.zip \
  ; rm -f ferron.zip

ARG PHP_VERSION
ARG DEBIAN_SOURCE=trixie
ENV PHP_VERSION=${PHP_VERSION}
ENV PHP_PKGS \
        php${PHP_VERSION} \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-json \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mcrypt \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-redis \
        php${PHP_VERSION}-ast \
        php${PHP_VERSION}-xdebug

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends gnupg software-properties-common \
  ; curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
  ; echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ ${DEBIAN_SOURCE} main" \
    | tee /etc/apt/sources.list.d/php.list \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends $PHP_PKGS \
  ; apt-get remove -y gnupg software-properties-common \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm \
  ; sed -e 's!^.*\(date.timezone =\).*$!\1 Asia/Shanghai!' \
        -e 's!^.*\(track_errors =\).*$!\1 Off!' \
        -e 's!^\(error_reporting =.*\)$!\1 \& ~E_NOTICE \& ~E_WARNING!' \
        -i /etc/php/${PHP_VERSION}/fpm/php.ini \
  ; sed -e 's!.*\(daemonize =\).*!\1 no!' \
        -e 's!.*\(error_log =\).*!\1 /var/log/php-fpm/fpm.log!' \
        -i /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
  ; mkdir -p /var/log/php-fpm \
  ; sed -e 's!\(listen =\).*!\1 /var/run/php/php-fpm.sock!' \
        -e 's!.*\(slowlog =\).*$!\1 /var/log/php-fpm/fpm.log.slow!' \
        -e 's!.*\(clear_env =\).*$!\1 no!' \
        -e 's!.*\(pm.start_servers =\).*$!\1 6!' \
        -e 's!.*\(pm.min_spare_servers =\).*$!\1 5!' \
        -e 's!.*\(pm.max_spare_servers =\).*$!\1 10!' \
        -e 's!.*\(pm.max_children =\).*$!\1 10!' \
        -i /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
  ; mkdir -p /var/run/php

RUN set -eux \
  ; mkdir /webgrind \
  ; webgrind_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/jokkedk/webgrind/releases/latest | jq -r '.tag_name') \
  ; webgrind_url="https://github.com/jokkedk/webgrind/archive/refs/tags/${webgrind_ver}.tar.gz" \
  ; curl --retry 3 -fsSL ${webgrind_url} | tar -zxf - -C /webgrind --strip-components=1 \
  ;

COPY setup-php /setup-php
COPY entrypoint /entrypoint/
COPY ferron.kdl /opt/ferron/ferron.kdl
COPY index.php /srv/
CMD ["srv"]
WORKDIR /srv

RUN set -ex \
  ; curl --retry 3 -fsSL https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

ENV PHP_DEBUG=
ENV PHP_PROFILE=
ENV PHP_FPM_SERVERS=
ENV UPLOAD_MAX_FILESIZE=
