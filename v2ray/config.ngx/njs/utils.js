const fs = require('fs').promises

function main(r) {
    var f = METHODS[r.variables[1]]
    f ? f(r) : r.return(200, JSON.stringify({avaiables: Object.keys(METHODS)}))
}

const METHODS = {
    headers : r => r.return(200, JSON.stringify(r.headersIn)),
    ip      : r => r.return(200, r.headersIn['X-Real-IP']),
    rdr     : r => r.return(301, r.args.url),
    ua      : r => r.return(200, r.headersIn['User-Agent']),
    body    : r => r.return(200, r.requestBuffer),
    version : r => r.return(200, JSON.stringify({ngx: r.variables.nginx_version, njs: njs.version, tz: process.env.TIMEZONE})),
    errorLog: r => fs.readFile('/opt/nginx/logs/error.log').then(data=>r.return(200, data)),
    r       : r => r.return(200, JSON.stringify(r)),
    v       : r => r.return(200, JSON.stringify(r.variables[r.args.v])),
}

export default { main }
