echo "{\"minute\": $(($RANDOM % 60))}" | tera -t /cloudflare.cron.tmpl -s -o /cloudflare.cron

crontab /cloudflare.cron
cron
