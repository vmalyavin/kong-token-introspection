local PLUGIN_NAME = "access-token-introspection"

-- helper function to validate data against a schema
local validate
do
    local validate_entity =
        require("spec.helpers").validate_plugin_config_schema
    local plugin_schema = require("kong.plugins." .. PLUGIN_NAME .. ".schema")

    function validate(data) return validate_entity(data, plugin_schema) end
end

describe(PLUGIN_NAME .. ": (schema)", function()

    it("requires distinct client_id, client_secret, and introspection_endpoint",
       function()
        local ok, err = validate({
            client_id = "CLIENT_ID",
            client_secret = "CLIENT_SECRET",
            introspection_endpoint = "http://localhost:8080"
        })
        assert.is_nil(err)
        assert.is_truthy(ok)
    end)

    it("validates introspection_endpoint is a valid URL", function()
        local ok, err = validate({
            client_id = "CLIENT_ID",
            client_secret = "CLIENT_SECRET",
            introspection_endpoint = "xyz"
        })
        assert.falsy(ok)
        assert.same("Invalid URL", err.config.introspection_endpoint)
    end)

    it("validates token_cache_time is an integer", function()
        local ok, err = validate({
            client_id = "CLIENT_ID",
            client_secret = "CLIENT_SECRET",
            introspection_endpoint = "http://localhost:8080",
            token_cache_time = "60"
        })
        assert.falsy(ok)
        assert.same("expected a number", err.config.token_cache_time)
    end)

    it("validates introspection_map supports body, headers, and static",
       function()
        local ok, err = validate({
            client_id = "CLIENT_ID",
            client_secret = "CLIENT_SECRET",
            introspection_endpoint = "http://localhost:8080",
            introspection_map = {
                body = {Header1 = "index-1"},
                headers = {Header2 = "X-User"},
                static = {Header3 = "zyx"}
            }
        })
        assert.is_nil(err)
        assert.is_truthy(ok)
    end)

    it("validates introspection_map only supports body, headers, and static",
       function()
        local ok, err = validate({
            client_id = "CLIENT_ID",
            client_secret = "CLIENT_SECRET",
            introspection_endpoint = "http://localhost:8080",
            introspection_map = {xyz = "zyx"}
        })
        assert.falsy(ok)
        assert.same("unknown field", err.config.introspection_map.xyz)
    end)

end)
