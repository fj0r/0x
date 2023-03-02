env | grep -E '_|HOME|ROOT|PATH|TIMEZONE|HOSTNAME|DIR|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER|LS_COLORS)=' \
   >> /etc/environment
