local PLUGIN_NAME = "access-token-introspection"
local helpers = require "spec.helpers"

for _, strategy in helpers.each_strategy() do
    describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
        local client

        lazy_setup(function()

            local bp = helpers.get_db_utils(strategy, nil, {PLUGIN_NAME})

            -- Inject a test route. No need to create a service, there is a default
            -- service which will echo the request.
            local route1 = bp.routes:insert({hosts = {"test1.com"}})
            local route2 = bp.routes:insert({hosts = {"test2.com"}})
            -- add the plugin to test to the route we created
            bp.plugins:insert{
                name = PLUGIN_NAME,
                route = {id = route1.id},
                config = {
                    client_id = "CLIENT_ID",
                    client_secret = "CLIENT_SECRET",
                    introspection_endpoint = "http://auth.com",
                }
            }

            bp.plugins:insert{
                name = PLUGIN_NAME,
                route = {id = route2.id},
                config = {
                    client_id = "CLIENT_ID",
                    client_secret = "CLIENT_SECRET",
                    introspection_endpoint = "http://auth.com",
                    require_success = false
                }
            }

            -- start kong
            assert(helpers.start_kong({
                -- set the strategy
                database = strategy,
                -- use the custom test template to create a local mock server
                nginx_conf = "spec/fixtures/custom_nginx.template",
                -- make sure our plugin gets loaded
                plugins = "bundled," .. PLUGIN_NAME
            }))
        end)

        lazy_teardown(function() helpers.stop_kong(nil, true) end)

        before_each(function() client = helpers.proxy_client() end)

        after_each(function() if client then client:close() end end)

        describe("with default config", function()
            it("responds with unauthorized", function()
                local r = client:get("/request",
                                     {headers = {host = "test1.com"}})
                -- validate that the request fails, response status 401
                assert.response(r).has.status(401)
            end)
        end)

        describe("with require_success = false", function()
            it("responds with ok", function()
                local r = client:get("/request",
                                     {headers = {host = "test2.com"}})
                -- validate that the request succeeded, response status 200
                assert.response(r).has.status(200)
            end)
        end)

    end)
end
