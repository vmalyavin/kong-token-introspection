package = "access-token-introspection"
version = "1.2.1-0"

source = {
  url = "git+https://github.com/medwing/kong-token-introspection.git",
  tag = "v1.2.1"
}

description = {
  summary = "A Kong plugin, that let you use an external Oauth 2.0 provider to protect your API.",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1"
}

local pluginName = "access-token-introspection"
build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".access"] = "kong/plugins/"..pluginName.."/access.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua"
  }
}
