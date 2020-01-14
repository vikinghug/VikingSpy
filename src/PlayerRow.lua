local Taka = LibStub("Taka-0.0")
local LSM = LibStub("LibSharedMedia-3.0")

local addonName, addon = ...

local PlayerRow = Taka:NewClass("Button", addonName .. "_PlayerRowFrame", "SecureActionButtonTemplate")
addon.PlayerRow = PlayerRow

function PlayerRow:New(parent, data)
  local frame = self:Super(PlayerRow):New(parent)

  local barWidth = addon.Settings.db.profile.barWidth
  local barHeight = addon.Settings.db.profile.barHeight

  frame:EnableMouse(true)
  frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  frame:SetAttribute("type", "macro")

  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(this)
    parent:StartMoving()
  end)
  frame:SetScript("OnDragStop", function(this)
    parent:StopMovingOrSizing()
  end)

  frame.parent = parent
  frame.data = data

  frame:SetSize(barWidth, barHeight)
  frame:SetBackdrop({
    bgFile = LSM:Fetch("background", "Solid"),
    insets = { left = 0, right = 0, top = 0, bottom = 0}
  })

  frame.leftText = frame.leftText or frame:CreateFontString(nil, "Artwork")
  frame.leftText:SetJustifyH("LEFT")
  frame.leftText:SetFont(LSM:Fetch("font", "Staatliches"), 14)
  frame.leftText:SetPoint("LEFT", frame, "LEFT", 8, 0)
  frame.leftText:SetText(data.name)

  frame.classIndicator = frame.classIndicator or frame:CreateTexture(nil, "ARTWORK")
  frame.classIndicator:SetSize(6, barHeight)
  frame.classIndicator:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

  frame.timeIndicator = frame.timeIndicator or CreateFrame("StatusBar", nil, frame)
  frame.timeIndicator:SetSize(barWidth - 6, 3)
  frame.timeIndicator:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 6, 0)
  frame.timeIndicator:SetStatusBarTexture(LSM:Fetch("background", "Solid"), 'ARTWORK')
  frame.timeIndicator:SetStatusBarColor(addon.Colors.YELLOW:ToList())
  frame.timeIndicator:SetAlpha(0.75)
  frame.timeIndicator:SetMinMaxValues(0, barWidth)

  frame:Update(data)

  return frame
end

function PlayerRow:Update(data)
  local barWidth = addon.Settings.db.profile.barWidth
  local barHeight = addon.Settings.db.profile.barHeight

  self:SetSize(barWidth, barHeight)
  self.classIndicator:SetSize(6, barHeight)
  self.timeIndicator:SetSize(barWidth - 6, 3)

  self.data = data
  if data.horde then
    self:SetBackdropColor(0.94, 0.2, 0.31, 0.8)
  elseif data.alliance then
    self:SetBackdropColor(0.18, 0.59, 0.97, 0.8)
  end

  local color
  if data.class == "DRUID" then
    color = addon.Colors.ORANGE
  elseif data.class == "HUNTER" then
    color = addon.Colors.GREEN
  elseif data.class == "MAGE" then
    color = addon.Colors.BLUE
  elseif data.class == "PALADIN" then
    color = addon.Colors.PINK
  elseif data.class == "PRIEST" then
    color = addon.Colors.WHITE
  elseif data.class == "ROGUE" then
    color = addon.Colors.YELLOW
  elseif data.class == "SHAMAN" then
    color = addon.Colors.BLUE
  elseif data.class == "WARLOCK" then
    color = addon.Colors.PURPLE
  elseif data.class == "WARRIOR" then
    color = addon.Colors.BROWN
  end

  self.classIndicator:SetColorTexture(color:ToList())

  self.leftText:SetText(data.name)

  self:SetAttribute("macrotext", "/target " .. data.name)

  local accumulator = 0
  local duration = addon.Settings.db.profile.displayTime
  local startValue = barWidth
  local endValue = 0
  local delta = endValue - startValue

  self.timeIndicator.TimeSinceLastUpdate = 0
  self.timeIndicator:SetScript("OnUpdate", function(this, elapsed)
    this.TimeSinceLastUpdate = this.TimeSinceLastUpdate + elapsed
    accumulator = accumulator + elapsed
    if (this.TimeSinceLastUpdate < 0.1) then return end
    this.TimeSinceLastUpdate = 0

    if elapsed > duration then
      this:SetScript("OnUpdate", nil)
    end
    local progress = min(accumulator / duration, 1)
    local latest = startValue + progress * delta
    this:SetValue(latest)
  end)

  return self
end

function PlayerRow:SetPosition(parent)
  self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -3)
end