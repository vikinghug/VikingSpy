local addonName, addon = ...
local LSM = LibStub("LibSharedMedia-3.0")

if not LSM then return end -- Oh No Mr. Nil!

local folder = [[VikingSpy\textures\]]

addon.TEXTURES = {
  -- Interface\Addons\Vikinghug\textures\
  -- DRUID_ICON = {
  --   type = "background",
  --   name = "Druid Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[druid.tga]],
  -- },
  -- HUNTER_ICON = {
  --   type = "background",
  --   name = "Hunter Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[hunter.tga]],
  -- },
  -- MAGE_ICON = {
  --   type = "background",
  --   name = "Mage Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[mage.tga]],
  -- },
  -- PALADIN_ICON = {
  --   type = "background",
  --   name = "Paladin Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[paladin.tga]],
  -- },
  -- PRIEST_ICON = {
  --   type = "background",
  --   name = "Priest Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[priest.tga]],
  -- },
  -- ROGUE_ICON = {
  --   type = "background",
  --   name = "Rogue Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[rogue.tga]],
  -- },
  -- SHAMAN_ICON = {
  --   type = "background",
  --   name = "Shaman Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[shaman.tga]],
  -- },
  -- WARLOCK_ICON = {
  --   type = "background",
  --   name = "Warlock Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[warlock.tga]],
  -- },
  -- WARRIOR_ICON = {
  --   type = "background",
  --   name = "Warrior Icon",
  --   path = [[Interface\Addons\]] .. folder .. [[warrior.tga]],
  -- },

  SOLID = {
    type = "background",
    name = "solid",
    path = [[Interface\Addons\]] .. folder .. [[solid.tga]],
  },
}

for key, data in pairs(addon.TEXTURES) do
  LSM:Register(data.type, data.name, data.path)
end