# DNS settings
## MX
> {{ MADDY_DOMAIN }}. A {{ MADDY_HOSTIP }}

{{ MADDY_DOMAIN }}. MX {{ MADDY_HOSTNAME }}
{{ MADDY_HOSTNAME }}. A {{ MADDY_HOSTIP }}


## SPF
> {{ MADDY_DOMAIN }}. TXT "v=spf1 mx ~all"

{{ MADDY_DOMAIN }}. TXT "v=spf1 include:{{ MADDY_HOSTNAME }} ~all"
{{ MADDY_HOSTNAME }}. TXT "v=spf1 include:{{ MADDY_HOSTNAME }} ~all"

## DMARC
_dmarc.{{ MADDY_DOMAIN }}. TXT "v=DMARC1;p=reject;rua=postmaster@{{ MADDY_DOMAIN }}"

## MTA-STS
_mta-sts.{{ MADDY_DOMAIN }}.   TXT "v=STSv1; id=1"
_smtp._tls.{{ MADDY_DOMAIN }}. TXT "v=TLSRPTv1;rua=mailto:postmaster@{{ MADDY_DOMAIN }}"

{% if DKIM_KEY -%}
## DKIM
default._domainkey.{{ MADDY_DOMAIN }}. TXT "{{ DKIM_KEY }}"
{%- endif %}

# user settings
```
maddy --config /var/lib/maddy/maddy.conf creds create ${user}@{{ MADDY_DOMAIN }}
maddy --config /var/lib/maddy/maddy.conf imap-acct create ${user}@{{ MADDY_DOMAIN }}
```
