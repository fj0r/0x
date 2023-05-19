crontab /app/daily-job
crond

echo "[$(date -Is)] starting docker registry"

/usr/local/bin/registry serve /etc/docker/registry/config.yml 2>&1 &
echo -n "$! " >> /var/run/services
