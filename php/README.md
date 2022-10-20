- 服务端口: 80
- 调试端口: 22
- 应用目录: /srv

构建镜像时拷贝公钥
```bash
COPY id_ecdsa.php.pub /root/.ssh/authorized_keys
```

本地 `~/.ssh/config` 添加
```bash
Host dev:xxx
    HostName localhost
    User root
    IdentitiesOnly yes
    IdentityFile ~/.ssh/id_ecdsa.php
    Port 8022
```

运行容器
``` bash
    docker run \
        --rm \
        --name test \
        -v vscode-server-php:/root/.vscode-server \
        -v $(pwd)/log:/var/log/nginx \
        -p 8022:22 \
        -p 8082:80 \
        phpf:7.2
```

使用 vscode remote \[ssh\] 模式登录即可, 打开 `/srv` 目录

添加调试配置
``` json
{
    "name": "Listen for XDebug",
    "type": "php",
    "request": "launch",
    "port": 9001
}
```

使用 websocat 连接
```sh
websocat -E -b tcp-l:127.0.0.1:2288 ws://{{url}}/websocat-{{token}}
```