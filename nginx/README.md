## ssh login

### download websocat client
https://github.com/vi/websocat/releases


### connect to websocket endpoint
``` bash
websocat -E -b tcp-l:127.0.0.1:2288 ws://example.com/websocat
```

### connect to localhost ssh tunnel
``` bash
ssh -i ~/.ssh/id_ecdsa -p 2288 -v -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
```

#### or add to ssh configuration file
```
Host websocat
    HostName localhost
    User root
    IdentitiesOnly yes
    IdentityFile ~/.ssh/id_ecdsa
    Port 2288
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

then just
```
ssh websocat
```


## k8s pod template
```yaml
    spec:
      containers:
      - name: download
        image: nnurphy/or
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        volumeMounts:
        - mountPath: /srv
          name: pub
        - mountPath: /root/.ssh/authorized_keys
          name: pubkey
          subPath: authorized_keys
        env:
        - name: WS_FIXED
          value: '1'
      volumes:
      - name: pub
        persistentVolumeClaim:
          claimName: pub-files
      - name: pubkey
        secret:
          secretName: pubkey
```

