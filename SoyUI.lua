local myAddonName, SoyUI = ...
SoyUI.modules = {}
SoyUI.COLORS = {
  POWER = {
    [0] = {0, 0, 1},    -- mana
    [1] = {1, 0, 0},    -- rage
    [2] = {1, .502, .251}, -- focus
    [3] = {1, 1, 0},  -- energy
    [6] = {0, .820, 1},  -- runic power
  },
  CLASS = {
    NPC = {0, 1, 0},
    DEATHKNIGHT  = {.773, .118, .227},
    DRUID  = {1, .486, .039},
    HUNTER  = {.667, .827, .447},
    MAGE  = {.247, .780, .922},
    PALADIN  = {.957, .549, .729},
    PRIEST  = {1, 1, 1},
    ROGUE  = {1, .565, .408},
    SHAMAN  = {0, .478, .867},
    WARLOCK  = {.529, .533, .933},
    WARRIOR = {.776, .608, .427},
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