cat <<- EOF > /cloudflare.cron
# *    *    *    *    *
# -    -    -    -    -
# |    |    |    |    |
# |    |    |    |    +----- 星期中星期几 (0 - 6) (星期天 为0)
# |    |    |    +---------- 月份 (1 - 12)
# |    |    +--------------- 一个月中的第几天 (1 - 31)
# |    +-------------------- 小时 (0 - 23)
# +------------------------- 分钟 (0 - 59)

$(($RANDOM % 60)) 12 * * * bash /cloudflare.sh 2>&1
EOF

#crontab /cloudflare.cron
#cron
