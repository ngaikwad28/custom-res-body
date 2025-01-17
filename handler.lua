local kong = kong
local cjson = require("cjson")

local CustomResponsePlugin = {}

-- Constructor
function CustomResponsePlugin:new()
  local obj = {}
  setmetatable(obj, self)
  self.__index = self
  return obj
end

-- Header filter phase
function CustomResponsePlugin:header_filter(conf)
  -- Set the Content-Length header to nil, as we will modify the body
  kong.response.set_header("Content-Length", nil)
end

-- Body filter phase: modify the response body
function CustomResponsePlugin:body_filter(conf)
  local chunk = kong.response.get_raw_body()
  local eof = ngx.arg[2]

  -- Collect the body content and process when it's complete
  if not ngx.ctx.buffer then
    ngx.ctx.buffer = ""
  end

  if chunk then
    ngx.ctx.buffer = ngx.ctx.buffer .. chunk
    ngx.arg[1] = nil -- Clear the chunk to avoid outputting unmodified data
  end

  if eof then
    -- Parse the JSON response body
    local response_body, err = cjson.decode(ngx.ctx.buffer)
    if not response_body then
      kong.log.err("Failed to decode response body: ", err)
      ngx.arg[1] = ngx.ctx.buffer -- Send the original response if decoding fails
      return
    end

    -- Remove or mask sensitive fields
    for _, field in ipairs(conf.sensitive_fields) do
      if response_body[field] then
        if conf.replacement_text == "[REMOVE]" then
          response_body[field] = nil -- Remove the field
        else
          response_body[field] = conf.replacement_text -- Mask the field
        end
      end
    end

    -- Encode the modified response body back to JSON
    ngx.arg[1] = cjson.encode(response_body)
  end
end

-- Define the plugin priority and version
CustomResponsePlugin.PRIORITY = 10
CustomResponsePlugin.VERSION = "1.0.0"

return CustomResponsePlugin
