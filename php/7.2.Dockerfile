ARG BASEIMAGE=fj0rd/0x:openresty
FROM ${BASEIMAGE}

ARG php_version=7.2
ENV PHP_VERSION=${php_version}
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
  ; add-apt-repository ppa:ondrej/php --yes \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends $PHP_PKGS \
  ; apt-get remove -y gnupg software-properties-common \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

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
  ; webgrind_ver=$(curl -sSL https://api.github.com/repos/jokkedk/webgrind/releases/latest | jq -r '.tag_name') \
  ; webgrind_url="https://github.com/jokkedk/webgrind/archive/refs/tags/${webgrind_ver}.tar.gz" \
  ; curl -sSL ${webgrind_url} | tar -zxf - -C /webgrind --strip-components=1 \
  ;

COPY docker-nginx-conf /etc/openresty/nginx.conf
COPY setup-php /setup-php
COPY entrypoint.sh /entrypoint/init.sh

RUN set -ex \
  ; curl -sSL https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

ENV PHP_DEBUG=
ENV PHP_PROFILE=
ENV PHP_FPM_SERVERS=
ENV UPLOAD_MAX_FILESIZE=
