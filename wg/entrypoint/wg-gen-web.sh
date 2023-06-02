cd /app
./wg-gen-web-linux 2>&1 &
echo -n "$! " >> /var/run/services
