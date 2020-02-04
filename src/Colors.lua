local _, addon = ...
local defaultColors = {
  BLACK = { 10, 3, 8 },
  WHITE = { 255, 255, 255 },
  GREY = { 180, 161, 188 },
  DARK_GREY = { 120, 101, 128 },
  BROWN = { 99, 82, 34 },
  RED = { 242, 51, 80 },
  DARK_RED = { 173, 42, 62 },
  ORANGE = { 242, 115, 45 },
  BLUE = { 47, 151, 247 },
  PALE_BLUE = { 83, 154, 219 },
  GREEN = { 115, 222, 89 },
  DARK_GREEN = { 65, 172, 49 },
  PALE_GREEN = {130, 191, 115 },
  YELLOW = { 237, 197, 64 },
  PALE_YELLOW = { 235, 226, 152 },
  PINK = { 232, 125, 211 },
  DARK_PINK = { 161, 77, 144 },
  PURPLE = { 178, 108, 235 },
  CYAN = { 57, 231, 237 },
  BG = { 30, 11, 38 },
}

local Colors = {}; addon.Colors = Colors

-- local function setDefaultColor(t, d)
--   local mt = { __index = function() return d end }
--   setmetatable(t, mt)
-- end

-- setDefaultColor(VH_COLORS, VH_COLORS.WHITE)
-- setDefaultColor(VH_POWER_COLORS, VH_COLORS.WHITE)
-- setDefaultColor(VH_SPELL_SCHOOL_COLORS, VH_COLORS.WHITE)

local function ParseColor(color, alpha)
  local t = {}
  for index, value in ipairs(color) do
    t[index] = value / 255
  end
  t[#t+1] = alpha and alpha or 1
  return unpack(t)
end

function Colors:New(r, g, b, a)
  local color = {}
  setmetatable(color, {
    __index = Colors
  })

  color.r = r or 1.0
  color.g = g or 1.0
  color.b = b or 1.0
  color.a = a or 1.0

  return color
end

function Colors:NewRGBA(color, alpha)
  local r, g, b, a = ParseColor(color, alpha or 1.0)

  return Colors:New(r, g, b, a)
end

function Colors:ToList()
  return self.r, self.g, self.b, self.a
end

function Colors:ToHex()
  local r = 255 * (self.r+0.0001)
  local g = 255 * (self.g+0.0001)
  local b = 255 * (self.b+0.0001)
  local a = 255 * (self.a+0.0001)
  return string.format ( "%.2x%.2x%.2x%.2x", a, r, g, b )
end

function Colors:ToText()
  local color = self:ToHex()
  return "|c" .. color
end

-- Blizzard Colors
-- red      1,    0.1,    0.1
-- orange   1,    0.5,    0.25
-- yellow   1,    1,      0
-- green    0.25, 0.25,   0.75
-- white    1,    1,      1
-- grey     0.5,  0.5,    0.5
local function ConvertBlizzardToVHColor(color)
  local vhColor = {}
  if (color.r == 1 and color.g == 0.1 and color.b == 0.1) then
    vhColor = Colors.RED

  elseif (color.r == 1 and color.g == 0.5 and color.b == 0.5) then
    vhColor = Colors.ORANGE

  elseif (color.r == 1 and color.g == 1 and color.b == 0) then
    vhColor = Colors.YELLOW

  elseif (color.r == 0.25 and color.g == 0.25 and color.b == 0.75) then
    vhColor = Colors.GREEN

  else
    return color.r, color.g, color.b, 1.0
  end

  local r = vhColor[1] / 255
  local g = vhColor[2] / 255
  local b = vhColor[3] / 255
  local a = 1.0

  return r, g, b, a
end

function Colors:NewDifficultyColor(num)
  local blizzardColor = GetDifficultyColor(num)
  local r, g, b, a = ConvertBlizzardToVHColor(blizzardColor)

  local color = Colors:New(r, g, b, a)
  return color
end

for key, value in pairs(defaultColors) do
  addon.Colors[key] = Colors:NewRGBA(value, 1.0)
end