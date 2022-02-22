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

