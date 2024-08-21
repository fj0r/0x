const modules = {
    base: {
        global(o, _, $) {
            _`daemon off;`
            _`user ${o.run_as};`
            if (o.worker.processes) {
                _`worker_processes ${o.worker.processes};`
            } else {
                _`worker_processes auto;`
            }
            $(`events`
                , `worker_connections  ${o.worker.connections};`)

        },
        http(o, _, $) {
            _`include            mime.types;`
            _`sendfile           on;`
            _`keepalive_timeout  0;`
            _`gzip               on;`
            if (o.log_format == 'json') {
                _`log_format json escape=json '{'`
                _`    '"source":"openresty",'}`
                _`    '"time":"$time_iso8601",'`
                _`    '"resp_body_size":$body_bytes_sent,'`
                _`    '"host":"$http_host",'`
                _`    '"address":"$remote_addr",'`
                _`    '"request_length":$request_length,'`
                _`    '"proto":"$server_protocol",'`
                _`    '"method":"$request_method",'`
                _`    '"uri":"$request_uri",'`
                _`    '"status":$status,'`
                _`    '"referer":"$http_referer",'`
                _`    '"user_agent":"$http_user_agent",'`
                _`    '"resp_time":$request_time,'`
                _`    '"upstream":{'`
                _`        '"addr":"$upstream_addr",'`
                _`        '"status":"$upstream_status",'`
                _`        '"resp_time":"$upstream_response_time",'`
                _`        '"conn_time":"$upstream_connect_time",'`
                _`        '"header_time":"$upstream_header_time"'`
                _`    '}'`
                _`'}';`
            }
            if (o.log_format == 'logfmt') {

                _`log_format logfmt  'time=$time_iso8601 client=$remote_addr '`
                _`                   'method=$request_method uri=$request_uri proto=$server_protocol '`
                _`                   'req_len=$request_length '`
                _`                   'req_time=$request_time '`
                _`                   'stat=$status sent=$bytes_sent '`
                _`                   'body_sent=$body_bytes_sent '`
                _`                   'referer=$http_referer '`
                _`                   'ua="$http_user_agent" '`
                _`                   'us_addr=$upstream_addr '`
                _`                   'us_status=$upstream_status '`
                _`                   'ust_res=$upstream_response_time '`
                _`                   'ust_conn=$upstream_connect_time '`
                _`                   'ust_header=$upstream_header_time';`
            }
            if (o.map_vars.length > 0) {
                /*
                {
                    "src": "upstream_http_docker_distribution_api_version",
                    "dest": "docker_distribution_api_version",
                    "value": {
                        "": "registry/2.0"
                    }
                }
                */
                for (let m of o.map_vars) {
                    $(`map \$${m.src} \$${m.dest}`
                        , ...Object.keys(m.value).map(x => `'${x}' '${m.value[x]}';`)
                    )
                }
            }
        },
        server(o, _, $) {
            _`server_name           ${o.server.name};`
            _`set $root             '${o.server.root}';`
            _`listen                ${o.server.port};`
            _`root                  $root;`
            _`charset               utf-8;`
            _`default_type          application/${o.default_type};`
            _`proxy_http_version    1.1;`
            _`proxy_set_header      Host              $host;`
            _`proxy_set_header      X-Real-IP         $remote_addr;`
            _`proxy_set_header      X-Forwarded-For   $proxy_add_x_forwarded_for;`
            _`proxy_set_header      X-Forwarded-Proto $scheme;`
            _`proxy_set_header      X-Original-URI    $request_uri;`
            _`proxy_set_header      Connection        "upgrade";`
            _`proxy_set_header      Upgrade           $http_upgrade;`
            _`proxy_connect_timeout ${o.timeout};`
            _`proxy_read_timeout    ${o.timeout};`
            _`proxy_send_timeout    ${o.timeout};`
            _`client_max_body_size  ${o.maxbody};`
            _`chunked_transfer_encoding on;`
            if (o.resolver) {
                _`resolver ${o.resolver};`
            }
            if (o.log_format) {
                _`access_log  /var/log/openresty/access.log   ${o.log_format};`
            }
            if (!o.fastcgi.type) {
                $('location /'
                    , `autoindex on;`
                    , `autoindex_format json;`
                )

            }
        }
    },
    fastcgi: {
        server(o, _) {
            if (o.fastcgi.type) {
                _`fastcgi_connect_timeout   ${o.timeout};`
                _`fastcgi_send_timeout      ${o.timeout};`
                _`fastcgi_read_timeout      ${o.timeout};`
            }
        },
        location(o, _, $) {
            if (o.fastcgi.type == 'php') {
                $('location /'
                    , `index index.php index.html index.htm;`
                    , ...(
                        cond(o.fastcgi.ignore_index)
                        && [`try_files $uri $uri/ /index.php?$args;`]
                        || [`if (!-e $request_filename) {`
                            , INDENT + `rewrite ^(.*)$ /index.php?s=$1 last;`
                            , INDENT + `break;`
                            , `}`
                        ]
                    )
                )
                $(`location ~ \\.${o.fastcgi.type}$`
                    , `include fastcgi_params;`
                    , `fastcgi_index index.php;`
                    , `fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;`
                    , ...(
                        cond(o.fastcgi.pathinfo)
                        && [`fastcgi_split_path_info ^((?U).+\.php)(/?.+)$;`
                            , `fastcgi_param PATH_INFO $fastcgi_path_info;`
                            , `fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;`
                        ]
                        || []
                    )
                    , `fastcgi_pass ${o.fastcgi.pass};`
                )
                $(`location = /favicon.ico`
                    , `log_not_found off;`
                    , `access_log off;`
                )
                $(`location = /robots.txt`
                    , `allow all;`
                    , `log_not_found off;`
                    , `access_log off;`
                )
                _`error_page      500 502 503 504 / 50x.html;`
                $(`location = /50x.html`
                    , `root   /usr/share/nginx/html;`
                )
            }
        }
    },
    real_remote: {
        location(o, _, $) {
            if (o.real_remote) {
                $(`set_by_lua_block $real_remote`
                    , `if ngx.var.http_x_forwarded_for then`
                    , `${INDENT}for r in ngx.var.http_x_forwarded_for:gmatch('([^,]+)') do`
                    , `${INDENT}${INDENT}return r`
                    , `${INDENT}end`
                    , `end`
                    , `return ngx.var.remote_addr`
                )
            }

        }
    },
    about: {
        global(o, _, $, s) {
            if (o.about.enable || any(s, ['about', 'enable'])) {
                _`env TIMEZONE;`
                _`env HOSTNAME;`
                for (let i of o.about.env) {
                    _`env ${i};`
                }
            }
        },
        location(o, _, $) {
            if (o.about.enable) {
                $(`location = /about`
                    , `default_type application/json;`
                    , `content_by_lua_block {`
                    , `    local json = require('cjson')`
                    , `    local data = {}`
                    , `    local file = io.open('/about.json', 'r')`
                    , `    if file ~= nil then`
                    , `        local txt = file:read('*all')`
                    , `        data = json.decode(txt)`
                    , `        io.close(file)`
                    , `    end`
                    , `    data.host = ngx.var.http_host`
                    , `    data.useraddr = ngx.var.real_remote`
                    , `    data.timezone = os.getenv("TIMEZONE")`
                    , `    data.hostname = os.getenv("HOSTNAME")`
                    , `    data.useragent = ngx.req.get_headers()['user-agent']`
                    , ...(cond(o.about.env) && [
                        , `    data.env = {}`
                        , ...(o.about.env.map(i => `    data.env.${i} = os.getenv("${i}")`))
                    ] || [])
                    , `    ngx.say(json.encode(data))`
                    , `    ngx.exit(200)`
                    , `}`
                )
            }
        }

    },
    upload: {
        global(o, _, $, s) {
            if (o.upload.prefix || any(s, ['upload', 'prefix'])) {
                _`env UPLOAD_ROOT;`
            }
        },
        location(o, _, $) {
            if (o.upload.prefix) {
                $(`location ~ /${o.upload.prefix}/(.*)`
                    , ...(cond(o.htpassword.enable)
                        && [`auth_basic "Please enter your username and password";`
                            , `auth_basic_user_file ${o.htpassword.user_file};`]
                        || []
                    )
                    , `set $path $1;`
                    , `content_by_lua_block {`
                    , `    local function file_exists(path)`
                    , `        local file = io.open(path, "rb")`
                    , `        if file then file:close() end`
                    , `        return file ~= nil`
                    , `    end`
                    , ``
                    , `    function dirname (path)`
                    , `        local f = io.popen('dirname '..path)`
                    , `        if f == nil then return end`
                    , `        local r = f:read()`
                    , `        f:close()`
                    , `        return r`
                    , `    end`
                    , ``
                    , `    local root_path = ngx.var.document_root .. '/' .. os.getenv('UPLOAD_ROOT')`
                    , `    local target = root_path .. '/' .. ngx.var.path`
                    , `    local target_dir = dirname(target)`
                    , ``
                    , `    if file_exists(target_dir) ~= true then`
                    , `        ngx.say('mkdir -p '..target_dir)`
                    , `        local status = os.execute('mkdir -p '..target_dir)`
                    , `        if status ~= true then`
                    , `            return nil, '创建目录失败'`
                    , `        end`
                    , `    end`
                    , ``
                    , `    ngx.req.read_body()`
                    , `    local data = ngx.req.get_body_data()`
                    , ``
                    , `    if nil == data then`
                    , `        local file_name = ngx.req.get_body_file()`
                    , `        os.execute('mv '..file_name..' '..target)`
                    , `    else`
                    , `        local file = io.open(target, "w+")`
                    , `        if file then`
                    , `            file:write(data)`
                    , `            file:close()`
                    , `        else`
                    , `            ngx.say('打开文件失败')`
                    , `        end`
                    , `    end`
                    , `}`
                )
            }
        }
    },
    http_bin: {
        location(o, _, $) {
            let prefix = o.http_bin.prefix
            if (prefix) {
                $(`location = /${prefix}/ip`
                    , `default_type 'text';`
                    , `content_by_lua_block {`
                    , `    ngx.print(ngx.var.real_remote)`
                    , `    ngx.exit(200)`
                    , `}`
                )
                $(`location = /${prefix}/ua`
                    , `default_type 'text';`
                    , `content_by_lua_block {`
                    , `    ngx.print(ngx.req.get_headers()['user-agent'])`
                    , `    ngx.exit(200)`
                    , `}`
                )
                $(`location = /${prefix}/redirect`
                    , `default_type 'text';`
                    , `content_by_lua_block {`
                    , `    -- ngx.header.content_type = 'text'`
                    , `    ngx.redirect(ngx.req.get_uri_args()['url'], 302)`
                    , `}`
                )
                $(`location = /${prefix}/headers`
                    , `default_type 'text';`
                    , `content_by_lua_block {`
                    , `    ngx.say(ngx.req.raw_header())`
                    , `    ngx.exit(200)`
                    , `}`
                )
                $(`location = /${prefix}/body`
                    , `lua_need_request_body on;`
                    , `content_by_lua_block {`
                    , `    ngx.print(ngx.req.get_body_data())`
                    , `    ngx.exit(200)`
                    , `}`
                )
                $(`location ~ /${prefix}/exec/(.*)`
                    , ...(cond(o.htpassword.enable) && [
                        `auth_basic "Please enter your username and password";`
                        , `auth_basic_user_file ${o.htpassword.user_file};`
                    ] || [])
                    , `default_type 'text';`
                    , `content_by_lua_block {`
                    , `    local shell = require "resty.shell"`
                    , `    local key = ngx.var[1]`
                    , `    local arg = ngx.req.get_uri_args()`
                    , `    local cmd = {`
                    , `        du = [[du -hd 1 /srv]],`
                    , `        pwd = [[pwd]],`
                    , `        ls  = [[ls]],`
                    , `    }`
                    , `    local ok, stdout, stderr, reason, status = shell.run(cmd[key], nil, 3000, 409600)`
                    , `    ngx.say(stdout)`
                    , `    ngx.say(stderr)`
                    , `    ngx.exit(200)`
                    , `}`
                )
            }
        }
    },
    short_url: {
        http(o, _, $) {
            if (o.short_url.jsonfile) {
                _`lua_shared_dict short_url 10m;`
                $(`init_by_lua_block`
                    , `local cjson = require('cjson')`
                    , `-- /srv/short-url.json`
                    , `local f = io.open('${o.short_url.jsonfile}', 'r')`
                    , `local data = f:read("*a")`
                    , `f:close()`
                    , `local url = ngx.shared.short_url`
                    , `for k, v in pairs(cjson.decode(data)) do`
                    , `${INDENT}url:set(k, v)`
                    , `end`
                )
            }
        },
        location(o, _, $) {
            if (o.short_url.jsonfile) {
                $(`location ~ ^/${o.short_url.prefix}(.+)`
                    , `content_by_lua_block {`
                    , `    ngx.redirect(ngx.shared.short_url:get(ngx.var[1]))`
                    , `}`
                )
            }
        }
    },
    replace_host: {
        location(o, _, $) {
            if (o.replace_host.length > 0) {
                _`### replace_host`
                for (let i of o.replace_host) {
                    $(`location = ${i}`
                        , `try_files $uri =404;`
                        , `header_filter_by_lua_block {`
                        , `    ngx.header.content_length = nil`
                        , `}`
                        , `body_filter_by_lua_block {`
                        , `    host = ngx.var.scheme.."://".. ngx.var.http_host`
                        , `    ngx.arg[1] = ngx.arg[1]:gsub('\${HTTP_HOST}', host)`
                        , `    --ngx.arg[1] = ngx.re.sub(ngx.arg[1], '\\\\\${HOST}', host)`
                        , `}`
                    )
                }
            }

        }
    },
    wstunnel: {
        location(o, _, $) {
            if (o.wstunnel.prefix) {
                $(`location /${o.wstunnel.prefix}`
                    , `proxy_pass http://127.0.0.1:${o.wstunnel.port || 9000};`
                    , `proxy_http_version 1.1;`
                    , `proxy_read_timeout 1800s;`
                    , `proxy_set_header Upgrade $http_upgrade;`
                    , `proxy_set_header Connection "upgrade";`
                    , `proxy_set_header Host            $host;`
                    , `proxy_set_header X-Real-IP       $remote_addr;`
                    , `proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;`
                    , `proxy_set_header X-Forwarded-Proto $scheme;`
                )

            }

        }
    },
    nchan: {
        global(o, _, $, s) {
            if (o.nchan.enable || any(s, ['nchan', 'enable'])) {
                _`load_module modules/ngx_nchan_module.so;`
            }
        },
        http(o, _, $) {
            if (o.nchan.enable) {
                _`variables_hash_max_size 4096;`
                _`variables_hash_bucket_size 256;`
            }
        },
        location(o, _, $) {
            if (o.nchan.enable) {
                _`## subscribe`
                $(`location ~ /sub/(.*)$`
                    , `nchan_subscriber;`
                    , `nchan_channel_id "$1";`
                    , `nchan_channel_id_split_delimiter ",";`
                    , `nchan_subscriber_first_message 0;`
                    , `nchan_authorize_request /auth;`
                    , `nchan_subscribe_request /upstream_sub;`
                    , `nchan_unsubscribe_request /upstream_unsub;`
                    , ...(cond(o.nchan.redis) && [
                        , `nchan_use_redis on;`
                        , `nchan_redis_pass ${o.nchan.redis};`
                    ] || [])
                )
                _`## publish`
                $(`location ~ /pub/(.*)$`
                    , `nchan_publisher;`
                    , `nchan_channel_id "$1";`
                    , cond(o.nchan.redis) && `nchan_redis_pass ${o.nchan.redis};`
                    , `nchan_authorize_request /auth;`
                    , `nchan_publisher_upstream_request /upstream_pub;`
                    , `nchan_message_timeout 5m;`
                    , `# deny all;`
                )
                _`## Message forwarding`
                $(`location = /upstream_pub`
                    , `proxy_pass http://127.0.0.1/nchan/pub;`
                    , `proxy_pass_request_body on;`
                    , `proxy_set_header X-Publisher-Type $nchan_publisher_type ;`
                    , `proxy_set_header X-Prev-Message-Id $nchan_prev_message_id ;`
                    , `proxy_set_header X-Channel-Id $nchan_channel_id ;`
                    , `proxy_set_header X-Original-URI $request_uri ;`
                    , `proxy_set_header X-Access-Token $http_access_token ;`
                    , `# deny all;`
                )
                _`## cancel subscribe Message forwarding`
                $(`location = /upstream_unsub`
                    , `proxy_pass http://127.0.0.1/nchan/unsub;`
                    , `proxy_ignore_client_abort on; #!!!important!!!!`
                    , `proxy_set_header X-Subscriber-Type $nchan_subscriber_type;`
                    , `proxy_set_header X-Channel-Id $nchan_channel_id;`
                    , `proxy_set_header X-Original-URI $request_uri;`
                    , `# deny all;`
                )
                _`## subscribe Message forwarding`
                $(`location = /upstream_sub`
                    , `proxy_pass http://127.0.0.1/nchan/sub;`
                    , `proxy_set_header X-Subscriber-Type $nchan_subscriber_type;`
                    , `proxy_set_header X-Message-Id $nchan_message_id;`
                    , `proxy_set_header X-Channel-Id $nchan_channel_id;`
                    , `proxy_set_header X-Original-URI $request_uri;`
                    , `proxy_set_header X-Access-Token $http_access_token ;`
                    , `# deny all;`
                )

                _`## nchan authentication`
                $(`location = /auth`
                    , ` proxy_pass http://127.0.0.1/nchan/auth;`
                    , ` proxy_pass_request_body off;`
                    , ` proxy_set_header Content-Length "";`
                    , ` proxy_set_header X-Subscriber-Type $nchan_subscriber_type;`
                    , ` proxy_set_header X-Publisher-Type $nchan_publisher_type;`
                    , ` proxy_set_header X-Prev-Message-Id $nchan_prev_message_id;`
                    , ` proxy_set_header X-Channel-Id $nchan_channel_id;`
                    , ` proxy_set_header X-Original-URI $request_uri;`
                    , ` proxy_set_header X-Forwarded-For $remote_addr;`
                    , ` # deny all;`
                )
                _`## nchan status`
                $(`location = /private/status`
                    , `nchan_stub_status;`
                    , `deny all;`
                )
            }

        }
    },
    ext: {
        location(o, _, $) {
            _`include ./ext/*.conf;`
        }
    }
}

const INDENT = '  '

const default_config = {
    run_as: 'www-data',
    about: {
        enable: 1,
        env: [
            "CI_COMMIT_TITLE",
            "CI_COMMIT_SHA",
            "CI_PIPELINE_BEGIN",
            "CI_PIPELINE_ID"
        ]
    },
    real_remote: 1,
    nchan: {
        enable: 0
    },
    http_bin: {
        prefix: null
    },
    path_to_ip: 0,
    fastcgi: {
        type: null,
        pathinfo: true,
        pass: "unix:/var/run/php/php-fpm.sock",
        ignore_index: false,
    },
    upload: {
        prefix: null,
    },
    htpassword: {
        enable: 0,
        user_file: "/etc/openresty/htpasswd"
    },
    worker: {
        processes: null,
        connections: 1024,
    },
    server: {
        root: "/srv",
        name: "_",
        port: 80,
    },
    default_type: "json",
    log_format: null,
    timeout: "1800s",
    maxbody: "0",
    resolver: null,
    replace_host: [],
    map_vars: [],
    short_url: {
        jsonfile: null,
        prefix: "-"
    },
    wstunnel: {
        prefix: null,
    },
    location: [],
}

const cond = c => !!c && c !== '0' || undefined

const any = (o, path) => {
    for (let i of o) {
        let v = i
        for (let j of path) {
            v = v[j]
        }
        if (cond(v)) {
            return true
        }
    }
    return false
}

const type = o => {
    let to = typeof o
    if (to === 'object') {
        if (o instanceof Array) {
            return 'array'
        } else if (o === null) {
            return 'null'
        } else {
            return 'object'
        }
    } else {
        return to
    }
}

const log = data => {
    print(type(data))
    print(JSON.stringify(data, null, 2))
    return data
}

const array_collect = () => {
    const v = []
    const l = (s, ...t) => {
        let r = s[0]
        for (let i = 1; i <= t.length; i++) {
            r += t[i - 1]
            r += s[i]
        }
        v.push(r)
    }
    const w = (loc, ...lns) => {
        l`${loc} {`
        for (let i of lns) {
            if (typeof i !== 'undefined') {
                l`${INDENT}${i}`
            }
        }
        l`}`
    }
    return [v, l, w]
}

const clone = (o = {}, a) => {
    for (let i of Object.keys(a)) {
        if (type(a[i]) === 'object') {
            o[i] = clone(o[i], a[i])
        } else {
            o[i] = a[i]
        }
    }
    return o
}

const merge = (a, b) => {
    return clone(clone({}, a), b)
}

const path = (o, p = []) => {
    let r = []
    for (let i of Object.keys(o)) {
        if (type(o[i]) === 'object') {
            r = r.concat(path(o[i], [i]))
        } else {
            r.push([...p, i])
        }
    }
    return r
}

const detected = (() => {
    if (typeof process === 'undefined') {
        if (typeof document === 'undefined') {
            // quickjs
            return {
                env(n) { return std.getenv(n) },
                load(f) { return std.loadFile(f) }
            }
        } else {
            // browser
            return {
                env(n) { },
                load(f) { }
            }
        }
    } else {
        // nodejs
        return {
            env(n) { return process.env[n] },
            load(f) { return fs.readFileSync(f) }
        }
    }
})()

const conf_env = (prefix, stub) => {
    const env = detected.env
    let c = {}
    for (let i of path(default_config)) {
        let e = env(`${prefix}${i.join('_').toUpperCase()}`)
        if (typeof e !== 'undefined' || stub) {
            let cur = c
            for (let j of i.slice(0, -1)) {
                if (type(cur[j]) == 'undefined') {
                    cur[j] = {}
                }
                cur = cur[j]
            }
            cur[i.slice(-1)[0]] = e && JSON.parse(e)
        }
    }
    // HACK:
    return JSON.parse(JSON.stringify(c))
}

const conf_file = (prefix) => {
    var conf = JSON.parse(std.loadFile(std.getenv(`${prefix}CONFIG`) || 'config.json'))
    conf = conf instanceof Array && conf || [conf]
    if (conf.length == 0) {
        conf = [{}]
    }
    return conf
}

const s_indent = x => {
    if (/^\s*$/.test(x)) { return '' } else { return `${INDENT}${x}` }
}

const gen = (prefix = "QNG") => {
    let env = conf_env(`${prefix}_`, true)
    let site = conf_file(prefix)
    let mod = Object.keys(modules).reduce((a, i) => {
        for (let k of Object.keys(a)) {
            let f = modules[i][k]
            if (f) a[k].push(f)
        }
        return a
    }, { global: [], http: [], server: [], location: [] })
    let [r, _, w] = array_collect()
    let o = merge(default_config, env)
    let so = site.map(c => merge(c, env))
    for (let f of mod.global) {
        f(o, _, w, so)
    }
    _`http {`
    for (let f of mod.http) {
        f(o, x => _`${s_indent(x)}`, (...x) => w(...x.map(y => s_indent(y))))
    }
    _`${INDENT}server {`
    so.forEach(c => gen_site(c, mod).forEach(i => r.push(s_indent(s_indent(i)))))
    _`${INDENT}}`
    _`}`

    return r
}

const gen_site = (conf, mod) => {
    let o = merge(default_config, conf)
    let [head, h] = array_collect()
    let [loc, l, w] = array_collect()
    for (let f of mod.server) {
        f(o, h, w)
    }
    for (let f of mod.location) {
        f(o, l, w)
    }
    for (let i of o.location) {
        w(`location ${i.path}`
            , cond(i.rewrite) && `rewrite ${i.rewrite.from} ${i.rewrite.to} break;`
            , ...(cond(i.backend)
                && [`proxy_set_header Host $host;`
                    , `proxy_pass ${i.backend};`
                ]
                || [`root ${i.root};`
                    , cond(i.autoindex) && `autoindex on;`
                ])
        )

    }
    return [...head, ...loc]
}

    ;
(() => {
    switch (scriptArgs[1]) {
        case 'help':
            print(`help | config`)
            break;
        case 'config':
            print(JSON.stringify(default_config, null, 2))
            break;
        default:
            print(gen().join("\n"))
            break;
    }
})()
