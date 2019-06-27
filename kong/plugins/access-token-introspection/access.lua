local _M = { conf = {} }
local http = require "resty.http"
local pl_stringx = require "pl.stringx"
local cjson = require "cjson.safe"


_M.conf.introspection_endpoint = ''
_M.conf.token_cache_time = 60
_M.conf.scope = nil
_M.conf.token_header = 'Authorization'

function _M.error_response(message, status)
    local jsonStr = '{"data":[],"error":{"code":' .. status .. ',"message":"' .. message .. '"}}'
    ngx.header['Content-Type'] = 'application/json'
    ngx.status = status
    ngx.say(jsonStr)
    ngx.exit(status)
end



function _M.introspect_access_token_req(access_token)
    local httpc = http:new()
    local res, err = httpc:request_uri(_M.conf.introspection_endpoint, {
        method = "POST",
        ssl_verify = false,
        body = "token_type_hint=access_token&token=" .. access_token,
        headers = { ["Content-Type"] = "application/x-www-form-urlencoded", }
    })

    if not res then
        return { status = 0 }
    end
    if res.status ~= 200 then
        return { status = res.status }
    end
    return { status = res.status, body = res.body }
end

function _M.introspect_access_token(access_token)
    if _M.conf.token_cache_time > 0 then
        local cache_id = "at:" .. access_token
        local res, err = kong.cache:get(cache_id, { ttl = _M.conf.token_cache_time },
                _M.introspect_access_token_req, access_token)
        if err then
            _M.error_response("Unexpected error: " .. err, ngx.HTTP_INTERNAL_SERVER_ERROR)
        end
        -- not 200 response status isn't valid for normal caching
        -- TODO:optimisation
        if res.status ~= 200 then
            kong.cache:invalidate(cache_id)
        end

        return res
    end

    return _M.introspect_access_token_req(access_token)
end

function _M.is_scope_authorized(scope)
    if _M.conf.scope == nil then
        return true
    end
    local needed_scope = pl_stringx.strip(_M.conf.scope)
    if string.len(needed_scope) == 0 then
        return true
    end
    scope = pl_stringx.strip(scope)
    if string.find(scope, '*', 1, true) or string.find(scope, needed_scope, 1, true) then
        return true
    end

    return false
end

 -- TODO: plugin config that will allow not authorized queries
function _M.run(conf)
    _M.conf = conf
    local access_token = ngx.req.get_headers()[_M.conf.token_header]
    if not access_token then
        _M.error_response("Unauthenticated.", ngx.HTTP_UNAUTHORIZED)
    end
    -- replace Bearer prefix
    access_token = pl_stringx.replace(access_token, "Bearer ", "", 1)

    local res = _M.introspect_access_token(access_token)
    if not res then
        _M.error_response("Authorization server error.", ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    if res.status ~= 200 then
        _M.error_response("The resource owner or authorization server denied the request.", ngx.HTTP_UNAUTHORIZED)
    end
    local data = cjson.decode(res.body)
    if data["active"] ~= true then
        _M.error_response("The resource owner or authorization server denied the request.", ngx.HTTP_UNAUTHORIZED)
    end
    if not _M.is_scope_authorized(data["scope"]) then
        _M.error_response("Forbidden", ngx.HTTP_FORBIDDEN)
    end

    ngx.req.set_header("X-Credential-Sub", data["sub"])
    ngx.req.set_header("X-Credential-Scope", data["scope"])
    -- clear token header from req
    ngx.req.clear_header(_M.conf.token_header)
end

return _M
