## Register machine using a pre authenticated key
```
headscale --namespace myfirstnamespace preauthkeys create --reusable --expiration 24h
```
```
tailscale up --login-server <YOUR_HEADSCALE_URL> --authkey <YOUR_AUTH_KEY>
```

## Register machine
```
headscale namespaces create myfirstnamespace
```
```
tailscale up --login-server YOUR_HEADSCALE_URL
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
