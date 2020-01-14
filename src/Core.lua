local addonName, addon = ...

local playerGUID = UnitGUID("player")

local EVENTS_LIST = {
  -- "UNIT_ABSORB_AMOUNT_CHANGED",
  -- "UNIT_ATTACK",
  -- "UNIT_ATTACK_POWER",
  -- "UNIT_ATTACK_SPEED",
  -- "UNIT_AURA",
  -- "UNIT_CHEAT_TOGGLE_EVENT",
  -- "UNIT_CLASSIFICATION_CHANGED",
  -- "UNIT_COMBAT",
  -- "UNIT_CONNECTION",
  -- "UNIT_DAMAGE",
  -- "UNIT_DEFENSE",
  -- "UNIT_DISPLAYPOWER",
  -- "UNIT_FACTION",
  -- "UNIT_FLAGS",
  -- -- "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
  -- -- "UNIT_HEAL_PREDICTION",
  -- "UNIT_HEALTH",
  -- "UNIT_HEALTH_FREQUENT",
  -- "UNIT_INVENTORY_CHANGED",
  -- "UNIT_LEVEL",
  -- "UNIT_MANA",
  -- "UNIT_MAXHEALTH",
  -- "UNIT_MAXPOWER",
  -- "UNIT_MODEL_CHANGED",
  -- "UNIT_NAME_UPDATE",
  -- "UNIT_OTHER_PARTY_CHANGED",
  -- "UNIT_PET",
  -- "UNIT_PET_EXPERIENCE",
  -- "UNIT_PHASE",
  -- "UNIT_PORTRAIT_UPDATE",
  -- "UNIT_POWER_BAR_HIDE",
  -- "UNIT_POWER_BAR_SHOW",
  -- "UNIT_POWER_BAR_TIMER_UPDATE",
  -- "UNIT_POWER_FREQUENT",
  -- "UNIT_POWER_UPDATE",
  -- "UNIT_QUEST_LOG_CHANGED",
  -- "UNIT_RANGED_ATTACK_POWER",
  -- "UNIT_RANGEDDAMAGE",
  -- "UNIT_RESISTANCES",
  -- "UNIT_SPELL_HASTE",
  -- "UNIT_SPELLCAST_CHANNEL_START",
  -- "UNIT_SPELLCAST_CHANNEL_STOP",
  -- "UNIT_SPELLCAST_CHANNEL_UPDATE",
  -- "UNIT_SPELLCAST_DELAYED",
  -- "UNIT_SPELLCAST_FAILED",
  -- "UNIT_SPELLCAST_FAILED_QUIET",
  -- "UNIT_SPELLCAST_INTERRUPTED",
  -- -- "UNIT_SPELLCAST_INTERRUPTIBLE",
  -- -- "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
  -- "UNIT_SPELLCAST_START",
  -- "UNIT_SPELLCAST_STOP",
  -- "UNIT_SPELLCAST_SUCCEEDED",
  -- "UNIT_STATS",
  -- "UNIT_TARGET",
  -- "UNIT_TARGETABLE_CHANGED",
  -- "SPELL_UPDATE_USABLE",
  "CHAT_MSG_SAY",
  "CHAT_MSG_YELL",
  "CHAT_MSG_TEXT_EMOTE",
  "CHAT_MSG_ADDON"
  -- "VEHICLE_ANGLE_UPDATE",
  -- "UNIT_THREAT_LIST_UPDATE",
  -- "UNIT_THREAT_SITUATION_UPDATE",
  --
  -- "FORBIDDEN_NAME_PLATE_CREATED",
  -- "FORBIDDEN_NAME_PLATE_UNIT_ADDED",
  -- "NAME_PLATE_CREATED",
  -- "NAME_PLATE_UNIT_ADDED",
}

function addon:OnInitialize()
  addon.Settings:OnLoad()
  addon.Options:OnLoad()

  self:CreateEvents()
  self.list = self.ListFrame:New(UIParent)
end

function addon:CreateEvents()
  local f = CreateFrame("Frame")
  -- for i, event in ipairs(EVENTS_LIST) do
  --   f:RegisterEvent(event)
  -- end
  -- f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
  -- f:RegisterEvent("UNIT_FACTION")
  f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  f:SetScript("OnEvent", function(self, event, ...)
    -- if event == "CHAT_MSG_SAY" then
    --   addon:Print("CHAT_MSG_SAY", ...)
    --   return
    -- elseif event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
    --   return addon:Print("event[" .. event .. "]", ...)
    -- end
    self:OnEvent(event, CombatLogGetCurrentEventInfo())
  end)

  function f:OnEvent(event, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

    if sourceGUID ~= playerGUID then
      addon:CheckUnit(sourceGUID, timestamp)
    end

    if destGUID ~= playerGUID then
      addon:CheckUnit(destGUID, timestamp)
    end

  end

  f.TimeSinceLastUpdate = 0
  f:SetScript("OnUpdate", function(this, elapsed)
    -- addon:Print(this.TimeSinceLastUpdate))
    this.TimeSinceLastUpdate = this.TimeSinceLastUpdate + elapsed
    if (this.TimeSinceLastUpdate < 0.3) then return end
    this.TimeSinceLastUpdate = 0
    self.list:Redraw()
  end)
end

function addon:CheckUnit(guid, timestamp)
  if (guid == "") then return end
  local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid)
  local isAlliance = addon:UnitIsAlliance(race)
  local isHorde = addon:UnitIsHorde(race)

  --------------------------------------------------------------------------------
  --@TODO: make showing alliance/horde a db value
  if (isAlliance and addon.Settings.db.profile.showAlliance) or isHorde then
    addon.list:UpdateOrCreate({
      name = name,
      guid = guid,
      class = class,
      race = race,
      sex = sex,
      alliance = isAlliance,
      horde = isHorde,
      lastSeen = timestamp,
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