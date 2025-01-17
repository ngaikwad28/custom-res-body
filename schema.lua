local typedefs = require("kong.db.schema.typedefs")

return {
  name = "custom-res-body",
  fields = {
    { config = {
        type = "record",
        fields = {
          { sensitive_fields = {
              type = "array",
              elements = { type = "string" },
              default = {}
            }
          },
          { replacement_text = {
              type = "string",
              default = "[REMOVE]"
            }
          },
        }
      }
    }
  }
}
