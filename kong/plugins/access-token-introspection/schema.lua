local url = require "socket.url"
local function validate_url(value)
    local parsed_url = url.parse(value)
    if parsed_url.scheme and parsed_url.host then
        parsed_url.scheme = parsed_url.scheme:lower()
        if not (parsed_url.scheme == "http" or parsed_url.scheme == "https") then
            return false, "Supported protocols are HTTP and HTTPS"
        end
    end

    return true
end

return {
    no_consumer = true, -- this plugin will only be API-wide
    fields = {
        -- introspection_endpoint = { type = "url", required = true, func = validate_url },
        -- token_header = { type = "string", required = true, default = { "Authorization" } },
        -- token_cache_time = { type = "number", required = true, default = 0 },
        -- scope = { type = "string", default = "" }
    },
    self_check = function(schema, plugin_t, dao, is_updating)
      -- perform any custom verification
      return true
    end
}