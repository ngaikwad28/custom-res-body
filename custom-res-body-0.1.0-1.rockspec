package = "custom-res-body"
version = "0.1.0-1"
rockspec_format = "1.0"
source = {
  url = "git://your-repo-url.git",
  tag = "v1.0.0"
}

dependencies = {
  "kong",
  "lua-cjson"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.custom-res-body"] = "handler.lua",
    ["kong.plugins.custom-res-body.schema"] = "schema.lua"
  }
}
