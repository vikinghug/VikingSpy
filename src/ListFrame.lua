local Taka = LibStub("Taka-0.0")
local LSM = LibStub("LibSharedMedia-3.0")

local addonName, addon = ...

local ListFrame = Taka:NewClass("Frame", addonName .. "_Frame")
addon.ListFrame = ListFrame

function ListFrame:New(parent)
  local frame = self:Super(ListFrame):New(parent)
  frame.parent = parent
  frame.pool = {}

  local barWidth = addon.Settings.db.profile.barWidth
  local barHeight = addon.Settings.db.profile.barHeight

  frame:SetSize(barWidth, barHeight)
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -barHeight)

  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(this)
    this:StartMoving()
  end)
  frame:SetScript("OnDragStop", function(this)
    this:StopMovingOrSizing()
  end)

  frame.text = frame.text or frame:CreateFontString(nil, "Artwork")
  frame.text:SetJustifyH("LEFT")
  frame.text:SetFont(LSM:Fetch("font", "Staatliches"), 14)
  frame.text:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 2)
  frame.text:SetText("VikingSpy")

  frame.divider = CreateFrame("Frame", nil, frame)
  frame.divider:SetSize(barWidth, 2)
  frame.divider:SetBackdrop({
    bgFile = LSM:Fetch("background", "Solid"),
    insets = { left = 0, right = 0, top = 0, bottom = 0}
  })
  frame.divider:SetBackdropColor(1,1,1,1)
  frame.divider:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)

  frame.options = CreateFrame("Button", addonName .. "_OptionsButton", frame)
  frame.options:SetSize(14, 14)
  frame.options:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
  frame.options.texture = frame.options:CreateTexture(nil, "ARTWORK")
  addon.Sprites:SetSprite(frame.options.texture, "sprites.tga", "settings")
  frame.options.texture:SetAllPoints(frame.options)

  frame.options:RegisterForClicks("LeftButtonUp")

  frame.options:SetScript("PostClick", function(this, btn)
    InterfaceOptionsFrame_OpenToCategory(addonName)
    InterfaceOptionsFrame_OpenToCategory(addonName)
  end)

  frame.options:SetScript("OnLeave", function(this) this:Hide() end)
  frame:SetScript("OnLeave", function(this) this.options:Hide() end)

  frame.options:SetScript("OnEnter", function(this) this:Show() end)
  frame:SetScript("OnEnter", function(this) this.options:Show() end)
  frame.options:Hide()

  frame.TimeSinceLastUpdate = 0
  frame:SetScript("OnUpdate", function(this, elapsed)
    this.TimeSinceLastUpdate = this.TimeSinceLastUpdate + elapsed
    if (this.TimeSinceLastUpdate < 0.3) then return end

    this.TimeSinceLastUpdate = 0
    this:Redraw()
  end)

  return frame
end

function ListFrame:Update()
  self:SetSize(addon.Settings.db.profile.barWidth, addon.Settings.db.profile.barHeight)
  self.divider:SetSize(addon.Settings.db.profile.barWidth, 2)
end

function ListFrame:UpdateOrCreate(data)
  local row = self:GetRowByGUID(data.guid)
  if row then
    row:Update(data)
    row:Show()
  else
    local inactiveRow = self:GetInactiveRow()
    if inactiveRow then
    else
      inactiveRow = self:Create(data)
    end

    if (data.isEnemy) then
      PlaySoundFile(addon.Settings.db.profile.alertSound, "Master")
    end
    inactiveRow:Update(data)
    inactiveRow:Show()
  end
  self:Redraw()
end

function ListFrame:Create(data)
  local newRow = addon.PlayerRow:New(self, data)
  table.insert(self.pool, 1, newRow)
  return newRow
end

function ListFrame:Prune()
  local now = time()
  for i, row in ipairs(self.pool) do
    local elapsed = now - row.data.lastSeen
    if (elapsed > addon.Settings.db.profile.displayTime and row.locked ~= true) then
      row:Release()
    end
  end
end

function ListFrame:Delete(data)
end

function ListFrame:Redraw()
  if self.redrawing == true then return end
  self.redrawing = true
  if #self.pool > 0 then self:Prune() end
  --------------------------------------------------------------------------------
  --@TODO: Sort by configurable field

  -- table.sort(self.pool, function(a, b)
  --   return a.data.lastSeen > b.data.lastSeen
  -- end)
  local parent = self
  for i, row in ipairs(self.pool) do
    if (row.inactive == false) then
      if ((addon.Settings.db.profile.showFriendly == true and row.data.isEnemy == false) or row.data.isEnemy) then
        row:SetPosition(parent)
        parent = row
      else
        row:Release()
      end
    end
  end
  self.redrawing = false
end

function ListFrame:GetRowByGUID(guid)
  for i, row in ipairs(self.pool) do
    if row.data.guid == guid then
      return row
    end
  end
end

function ListFrame:GetInactiveRow()
  for i, row in ipairs(self.pool) do
    if row.inactive then
      return row
    end
  end
end