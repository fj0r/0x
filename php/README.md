```bash
podman run --rm --name=test-php -p 8080:80 -e PHP_DEBUG=1 fj0rd/0x:php8
```

```
http://localhost:8080/?XDEBUG_SESSION_START=xdebug
```