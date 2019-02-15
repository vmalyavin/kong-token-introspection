local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.access-token-introspection.access"

local TokenHandler = BasePlugin:extend()

function TokenHandler:new()
    TokenHandler.super.new(self, "access-token-introspection")
end

function TokenHandler:access(conf)
    TokenHandler.super.access(self)
    access.run(conf)
end

return TokenHandler