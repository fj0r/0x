# SPF
@           IN      TXT ("v=spf1 include:{{ HOST }} ~all")

{%- if DKIM_KEY %}
# DKIM
{{ DKIM_KEY }}
{% endif %}

# DMARC
_dmarc      IN      TXT ("v=DMARC1;p=reject;rua={{ MASTER }}@{{ HOST }}")
