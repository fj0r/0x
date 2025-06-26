if [ -f /setup-php ]; then
  sudo bash /setup-php
  sudo touch /setup-php.$(date -Is)
fi

sudo /usr/sbin/php-fpm 2>&1 &
echo -n "$! " | sudo tee -a /var/run/services > /dev/null
