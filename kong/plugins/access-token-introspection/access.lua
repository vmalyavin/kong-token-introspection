local _M = { conf = {} }
local http = require "resty.http"
local pl_stringx = require "pl.stringx"
local cjson = require "cjson.safe"

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
        body = "token=" .. access_token .. "&client_id=" .. _M.conf.client_id .. "&client_secret=" .. _M.conf.client_secret,
        headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded"
        }
    })

    if not res then
        return { status = 0 }
    end

    return {
        status = res.status,
        body = cjson.decode(res.body),
        headers = res.headers
    }
end

function _M.introspect_access_token(access_token)
    if _M.conf.token_cache_time > 0 then
        local cache_id = "at:" .. access_token
        local res, err = kong.cache:get(cache_id,
                                        {ttl = _M.conf.token_cache_time},
                                        _M.introspect_access_token_req,
                                        access_token)
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

function _M.run(conf)
    _M.conf = conf

    -- access_token could be got from the Header or the query parameter
    local access_token = ngx.req.get_headers()[_M.conf.token_header]
    if not access_token then
        access_token = ngx.req.get_uri_args()[_M.conf.token_query]
    end

    if not _M.conf.require_success and access_token == nil then
        return
    end

    if not access_token then
        _M.error_response("Unauthenticated.", ngx.HTTP_UNAUTHORIZED)
    end

    -- replace Bearer prefix
    access_token = pl_stringx.replace(access_token, "Bearer ", "", 1)

    local res = _M.introspect_access_token(access_token)
    if not res then
        _M.error_response("Authorization server error.", ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    if _M.conf.require_success and res.status ~= 200 then
        _M.error_response("The resource owner or authorization server denied the request.", ngx.HTTP_UNAUTHORIZED)
    end

    for k, v in pairs(_M.conf.introspection_map.headers) do
        ngx.req.set_header(k, res.headers[v])
    end

    for k, v in pairs(_M.conf.introspection_map.body) do
        ngx.req.set_header(k, res.body[v])
    end

    for k, v in pairs(_M.conf.introspection_map.static) do
        ngx.req.set_header(k, v)
    end

    -- clear token header from req
    ngx.req.clear_header(_M.conf.token_header)
end

return _M
