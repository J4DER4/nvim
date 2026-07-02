-- Machine-local overrides (lua/core/local.lua, gitignored — see local.lua.example)
pcall(require, "core.local")

require("core.lazy")
require("core.keymaps")
require("core.settings")
require("core.extras")
