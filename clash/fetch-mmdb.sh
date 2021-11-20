CountryMmdbUrl=$(xh https://api.github.com/repos/alecthw/mmdb_china_ip_list/releases Accept:application/vnd.github.v3+json \
                | jq -r '.[0].assets[].browser_download_url' | grep mmdb | grep -v lite)
xh -F ${CountryMmdbUrl} -do Country.mmdb