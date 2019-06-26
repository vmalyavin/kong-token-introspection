package = "kong-token-introspection"
version = "1.0.0-0"
source = {
    url = "git@github.com:VentaApps/kong-token-introspection.git",
    tag = "v1.0.0",
    dir = "kong-token-introspection"
}
description = {
}
build = {
    type = "builtin",
    modules = {
    ["kong.plugins.token.introspection.access"] = "src/access.lua",
    ["kong.plugins.token.introspection.handler"] = "src/handler.lua",
    ["kong.plugins.token.introspection.schema"] = "src/schema.lua"
    }
}