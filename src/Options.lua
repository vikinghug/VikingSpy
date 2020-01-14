local AceConfig = LibStub("AceConfig-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local addonName, addon = ...

local Options = {}; addon.Options = Options

Options.primary = {
  name = addonName,
  type = 'group',
  args = {
  	showAlliance = {
  		name = 'Show Alliance',
  		type = 'toggle',
  		order = 1,
  		desc = 'Show or Hide Alliance display',
  		set = function(info, val) addon.Settings.db.profile.showAlliance = val end,
  		get = function(info) return addon.Settings.db.profile.showAlliance end,
    },

    displayTime = {
  		name = 'Display Time',
  		type = 'range',
      order = 2,
      min = 5,
      softMax = 60,
  		desc = 'How long before fading out detected players (in seconds)',
  		set = function(info, val) addon.Settings.db.profile.displayTime = val end,
  		get = function(info) return addon.Settings.db.profile.displayTime end,
    },


    barWidth = {
  		name = 'Addon Width',
  		type = 'range',
      order = 3,
      min = 40,
      softMax = 500,
  		desc = 'How wide do you want this dang thing?',
      set = function(info, val)
        addon.Settings.db.profile.barWidth = val
        addon.list:Update()
      end,
  		get = function(info) return addon.Settings.db.profile.barWidth end,
    },

    barHeight = {
  		name = 'Bar Height',
  		type = 'range',
      order = 4,
      min = 5,
      softMax = 200,
  		desc = 'How tall do you want these dang bars?',
      set = function(info, val)
        addon.Settings.db.profile.barHeight = val
        addon.list:Update()
      end,
  		get = function(info) return addon.Settings.db.profile.barHeight end,
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