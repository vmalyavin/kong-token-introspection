local _M = {}
local http = require "resty.http"
local pl_stringx = require "pl.stringx"
local cjson = require "cjson.safe"

function _M.errorResponse(message, status)
    local jsonStr = '{"data":[],"error":{"code":' .. status .. ',"message":"' .. message .. '"}}'
    ngx.header['Content-Type'] = 'application/json'
    ngx.status = status
    ngx.say(jsonStr)
    ngx.exit(status)
end

function _M.introspectAccessToken(conf, access_token)
    local httpc = http:new()
    local res, err = httpc:request_uri(conf.introspection_endpoint, {
        method = "POST",
        ssl_verify = false,
        body = "token_type_hint=access_token&token=" .. access_token,
        headers = { ["Content-Type"] = "application/x-www-form-urlencoded", }
    })

    return res
end

-- TODO: cache
-- TODO: scope-controll
function _M.run(conf)
    local access_token = ngx.req.get_headers()[conf.token_header]
    if not access_token then
        _M.errorResponse("Unauthenticated.", ngx.HTTP_UNAUTHORIZED)
    end
    -- replace Bearer prefix
    access_token = pl_stringx.replace(access_token, "Bearer ", "", 1)

    local res = _M.introspectAccessToken(conf, access_token)
    if not res then
        _M.errorResponse("Authorization server error.", ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    if res.status ~= 200 then
        _M.errorResponse("The resource owner or authorization server denied the request.", ngx.HTTP_UNAUTHORIZED)
    end

    local data = cjson.decode(res.body)
    ngx.req.set_header("X-Credential-User-Id", data["sub"])
    ngx.req.set_header("X-Credential-Scope", data["scope"])
    -- clear token header from req
    ngx.req.clear_header(conf.token_header)
end

return _M