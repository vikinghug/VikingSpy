local addonName, addon = ...

local Settings = {}; addon.Settings = Settings

local defaults = {
  profile = {
    showFriendly = true,
    displayTime = 10,
    barHeight = 20,
    barWidth = 140,
    alertSound = [[Interface\Addons\VikingSpy\assets\sounds\enemy-spotted.mp3]],
  }
}

function Settings:OnLoad()
  self.db = LibStub("AceDB-3.0"):New("VikinghugDB", defaults, true)
end