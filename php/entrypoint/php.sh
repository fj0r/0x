if [ -f /setup-php ]; then
  bash /setup-php
  touch /setup-php.$(date -Is)
fi

/usr/sbin/php-fpm 2>&1 &
echo -n "$! " >> /var/run/services
