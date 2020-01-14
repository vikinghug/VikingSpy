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
    row.inactive = false
  else
    local inactiveRow = self:GetInactiveRow()
    if inactiveRow then
      inactiveRow:Update(data)
    else
      self:Create(data)
    end
  end
  self:Redraw()
end

function ListFrame:Create(data)
  local newRow = addon.PlayerRow:New(self, data)
  newRow.inactive = false
  table.insert(self.pool, 1, newRow)
end

function ListFrame:Prune()
  local now = time()
  for i, row in ipairs(self.pool) do
    local elapsed = now - row.data.lastSeen
    if (elapsed > addon.Settings.db.profile.displayTime) then
      row:Hide()
      row.inactive = true
    end
  end
end

function ListFrame:Delete(data)
end

function ListFrame:Redraw()
  self:Prune()
  --------------------------------------------------------------------------------
  --@TODO: Sort by configurable field

  -- table.sort(self.pool, function(a, b)
  --   return a.data.lastSeen > b.data.lastSeen
  -- end)
  local parent = self
  for i, row in ipairs(self.pool) do
    if (row.inactive == false) then
      row:SetPosition(parent)
      parent = row
    end
  end
end

function ListFrame:GetRowByGUID(guid)
  for i, row in ipairs(self.pool) do
    -- addon:Print(i, guid)
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