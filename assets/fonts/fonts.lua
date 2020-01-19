local LSM = LibStub("LibSharedMedia-3.0")
if not LSM then return end -- Oh No Mr. Nil!

local folder = [[VikingSpy\assets\fonts\]]

local FONTS = {
  { name = "Staatliches", path = [[Interface\Addons\]] .. folder .. [[Staatliches-Regular.ttf]] },
}

for _, font in ipairs(FONTS) do
  LSM:Register("font", font.name, font.path)
end
