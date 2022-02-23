# RUN
## Register machine using a pre authenticated key
```
headscale --namespace myfirstnamespace preauthkeys create --reusable --expiration 24h
```
```
tailscale up --hostname <NAME> --login-server <YOUR_HEADSCALE_URL> --authkey <YOUR_AUTH_KEY>
```

## Register machine
```
headscale namespaces create myfirstnamespace
```
```
tailscale up --hostname <NAME> --login-server YOUR_HEADSCALE_URL
```
```
headscale --namespace myfirstnamespace nodes register --key <YOU_+MACHINE_KEY>
```

## systemd

```
cat << EOF | sudo tee /etc/systemd/system/tailscale.service
[Unit]
Description=tailscale
After=network.target

[Service]
ExecStart=/usr/local/bin/tailscaled
# Disable debug mode
Environment=GIN_MODE=release

[Install]
WantedBy=multi-user.target
EOF
```

# remote CLI
## Prerequisit
- headscale must be served over TLS/HTTPS
    - Remote access does not support unencrypted traffic.
- Port `50443 ` must be open in the firewall (or port overriden by `grpc_listen_addr` option)
## api key
```
headscale apikeys create --expiration 90d

headscale apikeys list
headscale apikeys expire --prefix "<PREFIX>"
```

## configure headscale
```
export HEADSCALE_CLI_ADDRESS="<HEADSCALE ADDRESS>:<PORT>"
export HEADSCALE_CLI_API_KEY="<API KEY FROM PREVIOUS STAGE>"
```



