const fs = require('fs').promises

function run(r) {
    let inspect = parseInt(process.env.INSPECT_REQUEST)
    if (inspect > 0) {
        let dump = {
            req: r,
            body: r.requestBuffer && r.requestBuffer.toString(),
        }
        if (inspect > 1) {
            dump.env = process.env
        }
        r.error(JSON.stringify(dump, null, 4))
    }
    var f = METHODS[r.variables.op]
    f ? f(r) : r.return(200, JSON.stringify({avaiables: Object.keys(METHODS)}))
}

const METHODS = {
    ok      : r => r.return(200, "OK"),
    headers : r => r.return(200, JSON.stringify(r.headersIn)),
    ip      : r => r.return(200, r.headersIn['X-Real-IP'] || r.remoteAddress),
    rdr     : r => r.return(301, r.args.url),
    ua      : r => r.return(200, r.headersIn['User-Agent']),
    body    : r => r.return(200, r.requestBuffer),
    version : r => r.return(200, JSON.stringify({ngx: r.variables.nginx_version, njs: njs.version, tz: process.env.TIMEZONE})),
    errorLog: r => fs.readFile('/opt/nginx/logs/error.log').then(data=>r.return(200, data)),
    r       : r => r.return(200, JSON.stringify(r)),
    v       : r => r.return(200, JSON.stringify(r.variables[r.args.v])),
}

export default { run }
