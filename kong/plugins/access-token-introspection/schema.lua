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
    fields = {
        introspection_endpoint = { type = "string", required = true},
        token_header = { type = "string", required = true, default = { "Authorization" } },
        token_cache_time = { type = "number", required = true, default = 0 },
        scope = { type = "string", default = "" }
    }
}