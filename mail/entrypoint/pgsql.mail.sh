
# postfix conf

# dovecot conf

touch /etc/postfix/transport
postmap /etc/postfix/transport


# ssl certificate
cd /etc/ssl/private/
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out server.key
chmod 400 server.key

openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
chmod 444 server.crt
