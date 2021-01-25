local url = require "socket.url"
local typedefs = require "kong.db.schema.typedefs"

local function validate_url(value)
    local parsed_url = url.parse(value)
    if parsed_url.scheme == nil or parsed_url.host == nil then
        return nil, "Invalid URL"
    end

    if not (parsed_url.scheme:lower() == "http" or parsed_url.scheme:lower() ==
        "https") then return nil, "Supported protocols are HTTP and HTTPS" end

    return true
end

local string_map = {
    type = "map",
    keys = {type = "string"},
    values = {type = "string"},
    default = {},
    required = false
}

return {
    name = "access-token-introspection",
    fields = {
        {consumer = typedefs.no_consumer}, {
            config = {
                type = "record",
                fields = {
                    {
                        introspection_endpoint = {
                            type = "string",
                            required = true,
                            custom_validator = validate_url
                        }
                    },
                    {
                        client_id = {
                            type = "string",
                            required = true,
                        }
                    },
                    {
                        client_secret = {
                            type = "string",
                            required = true,
                        }
                    },
                    {
                        token_header = {
                            type = "string",
                            required = true,
                            default = "Authorization"
                        }
                    },
                    {
                        token_query = {
                            type = "string",
                            required = true,
                            default = "token"
                        }
                    },
                    {
                        require_success = {
                            type = "boolean",
                            required = false,
                            default = true
                        }
                    },
                    {
                        token_cache_time = {
                            type = "number",
                            required = true,
                            default = 0
                        }
                    }, {
                        introspection_map = {
                            type = "record",
                            required = false,
                            fields = {
                                {body = string_map},
                                {headers = string_map},
                                {static = string_map},
                            }
                        }
                    }
                }
            }
        }
    }
}
