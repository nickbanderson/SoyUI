local myAddonName, SoyUI = ...
SoyUI.modules = {}
SoyUI.COLORS = {
  POWER = {
    [0] = {0, 0, 255},    -- mana
    [1] = {255, 0, 0},    -- rage
    [2] = {255, 128, 64}, -- focus
    [3] = {255, 255, 0},  -- energy
    [6] = {0, 209, 255},  -- runic power
  },
  CLASS = {
    NPC = {0, 255, 0},
    DEATHKNIGHT  = {197, 30, 58},
    DRUID  = {255, 124, 10},
    HUNTER  = {170, 211, 114},
    MAGE  = {63, 199, 235},
    PALADIN  = {244, 140, 186},
    PRIEST  = {255, 255, 255},
    ROGUE  = {255, 244, 104},
    SHAMAN  = {0, 112, 221},
    WARLOCK  = {135, 136, 238},
    WARRIOR = {198, 155, 109},
  },
}

local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function SoyUI.print(msg)
  if type(msg) == 'table' then
    msg = dump(msg)
  end

	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SoyUI:|r " .. msg)	
end

local function initDatabaseWithDefaults()
  SoyUI.print('initializing SoyUI_DB with defaults')
  SoyUI_DB = {}
  for moduleName, module in pairs(SoyUI.modules) do
    SoyUI_DB[moduleName] = { enabled = true }
    for key, default_value in pairs(module.defaults) do
      SoyUI_DB[moduleName][key] = default_value
    end
  end
end

local function initGUI()
  -- SoyUI.print("init gui")
  SoyUI.InterfaceOptionsPanel = CreateFrame(
    "Frame", "SoyUIInterfaceOptionsPanel", UIParent)
  SoyUI.InterfaceOptionsPanel.name = "SoyUI"

  local testButton = CreateFrame(
    "Button", "testButton",
    SoyUI.InterfaceOptionsPanel, "UIPanelButtonTemplate")
  testButton:SetWidth(80)
  testButton:SetHeight(22)
  testButton:SetText("Test Button")

  InterfaceOptions_AddCategory(SoyUI.InterfaceOptionsPanel)
end

SoyUI.F = CreateFrame("Frame", "SoyUIController") 
SoyUI.F:RegisterEvent("ADDON_LOADED")
SoyUI.F:SetScript("OnEvent", function(self, event, addonName) 
  if addonName == myAddonName then 
    SoyUI.F[event](self)
    SoyUI.F:UnregisterEvent(event)
  end
end)

function SoyUI.F:ADDON_LOADED()
  if SoyUI_DB == nil then initDatabaseWithDefaults() end
  initGUI()
  for moduleName, module in pairs(SoyUI.modules) do
    -- SoyUI.print('initting module ' .. moduleName)
    module.init()
  end
end

SLASH_SOYUI1 = "/soyui"
SlashCmdList["SOYUI"] = function()
  initDatabaseWithDefaults()
end