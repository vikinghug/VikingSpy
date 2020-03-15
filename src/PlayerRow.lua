local VSL = LibStub("VikingSharedLib")
local LSM = LibStub("LibSharedMedia-3.0")

local addonName, addon = ...

local PlayerRow = {}
addon.PlayerRow = PlayerRow

local function new(parent, data)
  local frame = CreateFrame("Button", addonName .. "_PlayerRowFrame", parent, "SecureActionButtonTemplate")
  frame.inactive = false

  local barWidth = addon.Settings.db.profile.barWidth
  local barHeight = addon.Settings.db.profile.barHeight

  frame:EnableMouse(true)
  frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  frame:SetAttribute("type1", "target")

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
  -- frame:SetBackdrop({
  --   bgFile = LSM:Fetch("background", "Solid"),
  --   insets = { left = 0, right = 0, top = 0, bottom = 0}
  -- })
  if (frame.leftText) then
    frame.leftText:Show()
  else
    frame.leftText = frame:CreateFontString(nil, "Artwork")
    frame.leftText:SetJustifyH("LEFT")
    frame.leftText:SetFont(addon.Settings.db.profile.font, addon.Settings.db.profile.fontSize)
    frame.leftText:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.leftText:SetShadowColor(VSL.Colors.BG:ToList())
    frame.leftText:SetShadowOffset(1, -1)
  end

  if (frame.timeIndicator) then
    frame.timeIndicator:Show()
  else
    frame.timeIndicator = CreateFrame("StatusBar", nil, frame)
    frame.timeIndicator:SetSize(barWidth, 2)
    frame.timeIndicator:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    frame.timeIndicator:SetStatusBarTexture(LSM:Fetch("background", "Solid"), 'ARTWORK')

    frame.timeIndicator:SetBackdrop({
      bgFile = LSM:Fetch("background", "Solid"),
      insets = { left = 0, right = 0, top = 0, bottom = 0}
    })

    frame.timeIndicator:SetMinMaxValues(0, barWidth)
  end

  if frame.lock then
  else
    frame.lock = frame:CreateTexture(nil, "ARTWORK")
    frame.lock:SetSize(14, 14)
    frame.lock:SetPoint("RIGHT", frame, "RIGHT", 2, 0)
    VSL.Sprites:SetSprite(frame.lock, "sprites.tga", "unlock")
    frame.lock:SetAlpha(0)
  end

  frame:SetScript("OnEnter", function(this)
    this.lock:SetAlpha(1)
  end)
  frame:SetScript("OnLeave", function(this)
    if (this.locked ~= true) then
      this.lock:SetAlpha(0)
    else
      this.lock:SetAlpha(0.5)
    end
  end)
  frame:SetScript("PostClick", function(this, btn)
    if (btn == "RightButton") then
      if (this.locked == true) then
        VSL.Sprites:SetSprite(this.lock, "sprites.tga", "unlock")
        this:Update(this.data)
        this.data.lastSeen = time()
        this:CreateTimeIndicator(frame.data)
      else
        VSL.Sprites:SetSprite(this.lock, "sprites.tga", "lock")
        this.timeIndicator:SetValue(addon.Settings.db.profile.barWidth)
        this.timeIndicator:SetScript("OnUpdate", nil)
      end

      this.locked = not this.locked
      this.lock:SetAlpha(1)
    elseif btn == "LeftButton" then

    end
  end)

  return frame
end

local PlayerRowBase = {}
function PlayerRowBase:CreateTimeIndicator(data)
  local accumulator = time() - data.lastSeen
  local duration = addon.Settings.db.profile.displayTime
  local startValue = addon.Settings.db.profile.barWidth
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
  end

function PlayerRowBase:Update(data)
  self.inactive = false
  local barWidth = addon.Settings.db.profile.barWidth
  local barHeight = addon.Settings.db.profile.barHeight

  self:SetSize(barWidth, barHeight)
  self.timeIndicator:SetSize(barWidth, 2)

  local color
  if data.class == "DRUID" then
    color = VSL.Colors.ORANGE
  elseif data.class == "HUNTER" then
    color = VSL.Colors.GREEN
  elseif data.class == "MAGE" then
    color = VSL.Colors.BLUE
  elseif data.class == "PALADIN" then
    color = VSL.Colors.PINK
  elseif data.class == "PRIEST" then
    color = VSL.Colors.WHITE
  elseif data.class == "ROGUE" then
    color = VSL.Colors.YELLOW
  elseif data.class == "SHAMAN" then
    color = VSL.Colors.BLUE
  elseif data.class == "WARLOCK" then
    color = VSL.Colors.PURPLE
  elseif data.class == "WARRIOR" then
    color = VSL.Colors.LIGHT_BROWN
  end

  local level = self:GetDisplayLevel(data)

  self.leftText:SetText(color:ToText() .. level.."|r "..data.name)

  if self.locked ~= true then
    self:CreateTimeIndicator(data)
  end

  if data.isHorde then
    self.timeIndicator:SetStatusBarColor(0.94, 0.2, 0.31, 1)
    self.timeIndicator:SetBackdropColor(0.94, 0.2, 0.31, 0.5)

  elseif data.isAlliance then
    self.timeIndicator:SetStatusBarColor(0.18, 0.59, 0.97, 1)
    self.timeIndicator:SetBackdropColor(0.18, 0.59, 0.97, 0.5)
  end

  self:SetAttribute("macrotext1", "/target "..data.name)



  self.data = data
  return self
end

function PlayerRowBase:GetDisplayLevel(data)
  data.level = max(self.data.level, data.level)
  local levelDisplay = data.level == -1 and "??" or data.level

  return levelDisplay
end

function PlayerRowBase:SetPosition(parent)
  self:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -3)
end

function PlayerRowBase:Release()
  self.inactive = true
  self.data.level = -1
  self:Hide()
end

function PlayerRow:New(parent, data)
  local frame = new(parent, data)
  VSL:ApplyMixin(frame, PlayerRowBase)
  frame:Update(data)

  return frame
end