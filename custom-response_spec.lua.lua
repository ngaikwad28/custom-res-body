local helpers = require "spec.helpers"
local cjson = require("cjson")

describe("Custom Response Plugin", function()
  local client

  setup(function()
    local bp = helpers.setup_server({
      plugins = {
        {
          name = "custom-res-body",
          config = {
            sensitive_fields = {"password", "token"},
            replacement_text = "[REDACTED]"
          }
        }
      }
    })

    client = helpers.proxy_client()
  end)

  it("should mask sensitive fields in response", function()
    local res = client:get("/some-endpoint")
    local body = assert.res_status(200, res)
    local json_body = cjson.decode(body)

    -- Assert that sensitive fields are masked
    assert.equal("[REDACTED]", json_body.password)
    assert.equal("[REDACTED]", json_body.token)
  end)

  it("should remove sensitive fields if configured", function()
    -- Configure the plugin to remove sensitive fields
    helpers.set_plugin_config({
      sensitive_fields = {"password", "token"},
      replacement_text = "[REMOVE]"
    })

    local res = client:get("/some-endpoint")
    local body = assert.res_status(200, res)
    local json_body = cjson.decode(body)

    -- Assert that sensitive fields are removed
    assert.is_nil(json_body.password)
    assert.is_nil(json_body.token)
  end)
end)
