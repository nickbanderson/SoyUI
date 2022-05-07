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
    ROGUE  = {1, .96, .408},
    SHAMAN  = {0, .478, .867},
    WARLOCK  = {.529, .533, .933},
    WARRIOR = {.776, .608, .427},
  },
}

-- alias
local print = SoyUI.util.print

local function initDatabaseWithDefaults()
  print('initializing SoyUI_DB with defaults')
  SoyUI_DB = {}
  for moduleName, module in pairs(SoyUI.modules) do
    SoyUI_DB[moduleName] = { enabled = true }
    for key, default_value in pairs(module.defaults) do
      SoyUI_DB[moduleName][key] = default_value
    end
  end
end

local function initGUI()
  -- print("init gui")
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
    -- print('initting module ' .. moduleName)
    module.init()
  end
end

SLASH_SOY1 = "/soy"
SlashCmdList["SOY"] = function(msg)
  if msg == '' or msg == nil then
    msg = "help"
  end

  msg = SoyUI.util.split(msg, " ") 

  if msg[1] == "help" then
    print("lol this retard needs help")
  elseif msg[1] == "reset" then
    initDatabaseWithDefaults()
    print("database reset to defaults")
  elseif msg[1] == "unlock" then
    for unit_name, unit_frame in pairs(SoyUI.modules.SoyFrames.uf) do
      unit_frame:unlock()
    end
    print("frames unlocked")
  elseif msg[1] == "lock" then
    for unit_name, unit_frame in pairs(SoyUI.modules.SoyFrames.uf) do
      unit_frame:lock()
    end
    print("frames locked")
  elseif msg[1] == "db" then
    print(SoyUI_DB)
  end
end