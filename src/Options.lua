local AceConfig = LibStub("AceConfig-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local addonName, addon = ...

local Options = {}; addon.Options = Options

local function spairs(t, order)
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys
  if order then
      table.sort(keys, function(a,b) return order(t, a, b) end)
  else
      table.sort(keys)
  end

  -- return the iterator function
  local i = 0
  return function()
      i = i + 1
      if keys[i] then
          return keys[i], t[keys[i]]
      end
  end
end

Options.primary = {
  name = addonName,
  type = 'group',
  args = {
    fontFamily = {
      name = 'Font Family',
      type = 'select',
      order = 0.11,
      sorting = function(values, ...)
        local keys = {}
        for _, v in spairs(LSM:HashTable("font")) do table.insert(keys, v) end
        return keys
      end,
      values = function()
        local values = {}
        for k, v in pairs(LSM:HashTable("font")) do
          values[v] = k
        end
        return values
      end,
      set = function(info, val)
        addon.Settings.db.profile.font = val
        addon.list:Redraw()
      end,
      get = function(info) return addon.Settings.db.profile.font end,
    },

    fontSize = {
  		name = 'Font Size',
  		type = 'range',
      order = 0.12,
      softMin = 4,
      softMax = 46,
      set = function(info, val)
        addon.Settings.db.profile.fontSize = val
        addon.list:Redraw()
      end,
  		get = function(info) return addon.Settings.db.profile.fontSize end,
    },

    enableInBattlegrounds = {
  		name = 'Enable in Battlegrounds',
  		type = 'toggle',
  		order = 1,
  		desc = "Show or Hide in battlegrounds",
      set = function(info, val)
        addon.Settings.db.profile.enableInBattlegrounds = val
        addon:OnZoneChange()
      end,
  		get = function(info) return addon.Settings.db.profile.enableInBattlegrounds end,
    },

  	showFriendly = {
  		name = 'Show Friendly Players',
  		type = 'toggle',
  		order = 1,
  		desc = "Show or Hide your faction's Players",
      set = function(info, val)
        addon.Settings.db.profile.showFriendly = val
        addon.list:Redraw()
      end,
  		get = function(info) return addon.Settings.db.profile.showFriendly end,
    },

    displayTime = {
  		name = 'Display Time',
  		type = 'range',
      order = 2,
      min = 5,
      softMax = 60,
  		desc = 'How long before fading out detected players (in seconds)',
      set = function(info, val)
        addon.Settings.db.profile.displayTime = val
        addon.list:Redraw()
      end,
  		get = function(info) return addon.Settings.db.profile.displayTime end,
    },


    barWidth = {
  		name = 'Bar Width',
  		type = 'range',
      order = 3,
      min = 40,
      softMax = 500,
  		desc = 'How wide do you want this dang thing?',
      set = function(info, val)
        addon.Settings.db.profile.barWidth = val
        addon.list:Redraw()
      end,
  		get = function(info) return addon.Settings.db.profile.barWidth end,
    },

    barHeight = {
  		name = 'Row Height',
  		type = 'range',
      order = 4,
      min = 5,
      softMax = 200,
  		desc = 'How tall do you want these dang bars?',
      set = function(info, val)
        addon.Settings.db.profile.barHeight = val
        addon.list:Redraw()
      end,
  		get = function(info) return addon.Settings.db.profile.barHeight end,
    },

    timerHeight = {
  		name = 'Timer Height',
  		type = 'range',
      order = 4.1,
      min = 0,
      softMax = 15,
  		desc = 'How tall do you want these dang timers?',
      set = function(info, val)
        addon.Settings.db.profile.timerHeight = val
        addon.list:Redraw()
      end,
  		get = function(info) return addon.Settings.db.profile.timerHeight end,
    },

    alertSound = {
  		name = 'Alert Sound',
      type = 'select',
      order = 5,
      sorting = function(values, ...)
        local keys = {}
        for _, v in spairs(LSM:HashTable("sound")) do table.insert(keys, v) end
        return keys
      end,
      values = function()
        local values = {}
        for k, v in pairs(LSM:HashTable("sound")) do
          values[v] = k
        end
        return values
      end,
  		desc = 'How long before fading out detected players (in seconds)',
      set = function(info, val)
        PlaySoundFile(val, "Master")
        addon.Settings.db.profile.alertSound = val
      end,
  		get = function(info) return addon.Settings.db.profile.alertSound end,
    },
  },
}

function Options:OnLoad()
  AceConfig:RegisterOptionsTable(addonName, addon.Options.primary, { "vikingspy", "vs" })
  AceConfigDialog:AddToBlizOptions(addonName, addonName)
  local profiles = AceDBOptions:GetOptionsTable(addon.Settings.db)
  AceConfig:RegisterOptionsTable(addonName .. ".profiles", profiles)
  AceConfigDialog:AddToBlizOptions(addonName .. ".profiles", "Profiles", addonName)
end