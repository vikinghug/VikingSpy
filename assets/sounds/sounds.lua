local addonName, addon = ...
local LSM = LibStub("LibSharedMedia-3.0")

if not LSM then return end -- Oh No Mr. Nil!

local folder = [[VikingSpy\assets\sounds\]]

local SOUNDS = {
  SOLID = {
    name = "Enemy Spotted",
    path = [[Interface\Addons\]] .. folder .. [[enemy-spotted.mp3]],
  },
}

for key, data in pairs(SOUNDS) do
  LSM:Register("sound", data.name, data.path)
end

addon.SOUNDS = SOUNDS