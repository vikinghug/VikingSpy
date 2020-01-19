local addonName, addon = ...
local Helpers = {}; addon.Helpers = Helpers

function Helpers:ApplyMixin(base, mixin)
  for k, v in pairs(mixin) do
    base[k] = v
  end

  return base
end

function Helpers:StartsWith(str, start)
  return str:sub(1, #start) == start
end

function Helpers:EndsWith(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end