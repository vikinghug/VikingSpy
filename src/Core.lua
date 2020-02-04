local addonName, addon = ...

local playerGUID = UnitGUID("player")
local playerIsAlliance = UnitFactionGroup("player") == "Alliance"

function addon:OnInitialize()
  addon.Settings:OnLoad()
  addon.Options:OnLoad()

  self.list = self.ListFrame:New(UIParent)

  self.eventFrame = CreateFrame("Frame")
  self.zoneFrame = CreateFrame("Frame")
  self.zoneFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  self.zoneFrame:SetScript("OnEvent", addon.OnZoneChange)
end

function addon:OnZoneChange()
  local inInstance, instanceType = IsInInstance()
    if (instanceType == "pvp") then
      if (addon.Settings.db.profile.enableInBattlegrounds == true) then
        addon:Enable()
      else
        addon:Disable()
      end
    else
      addon:Enable()
    end
end

function addon:Enable()
  addon:CreateEvents()
  self.eventFrame:Show()
  self.list:Show()
end

function addon:Disable()
  self.eventFrame:SetScript("OnEvent", nil)
  self.eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self.eventFrame:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
  self.eventFrame:Hide()
  self.list:Hide()
end

function addon:CreateEvents()
  local f = self.eventFrame
  f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  f:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  f:SetScript("OnEvent", function(self, event, ...)
    if event == "UPDATE_MOUSEOVER_UNIT" then
      local guid = UnitGUID("mouseover")
      local level = UnitLevel("mouseover")
      return addon:MaybeAddUnit(guid, time(), level)
    end

    self:OnEvent(event, CombatLogGetCurrentEventInfo())
  end)

  function f:OnEvent(event, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

    addon:MaybeAddUnit(sourceGUID, timestamp)
    addon:MaybeAddUnit(destGUID, timestamp)
  end
end

function addon:MaybeAddUnit(guid, timestamp, level)
  if (guid == "" or guid == nil) then return end
  if (guid == playerGUID) then return end
  local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid)
  local isAlliance = addon:UnitIsAlliance(race)
  local isHorde = addon:UnitIsHorde(race)
  local isEnemy = (playerIsAlliance and isHorde) or (not playerIsAlliance and isAlliance)

  if isAlliance or isHorde then
    addon.list:UpdateOrCreate({
      name = name,
      guid = guid,
      class = class,
      race = race,
      sex = sex,
      level = level or -1,
      isAlliance = isAlliance,
      isHorde = isHorde,
      lastSeen = timestamp,
      isEnemy = isEnemy
    })
  end
end

function addon:UnitIsHorde(race)
  local RACES = { "Orc", "Tauren", "Scourge", "Troll" }
  for _, v in ipairs(RACES) do
    if race == v then return true end
  end

  return false
end

function addon:UnitIsAlliance(race)
  local RACES = { "Human", "Gnome", "NightElf", "Dwarf" }
  for _, v in ipairs(RACES) do
    if race == v then return true end
  end

  return false
end

--@debug helpers
function addon:Print(...)
  local color = "|cFFEDC540"
  print(color .. addonName .. ":|r", ...)
end

function addon:Debug(strName, tData)
  if ViragDevTool_AddData then
    ViragDevTool_AddData(tData, strName)
  end
end

local frame = CreateFrame("Frame", "VHSpyInitFrame")
frame:RegisterEvent("ADDON_LOADED")
local function eventHandler(self, event, ...)
  frame:SetScript("OnEvent", nil)
  frame:UnregisterAllEvents()
  frame:Hide()
  frame = nil
  addon:OnInitialize()
end
frame:SetScript("OnEvent", eventHandler)