local myAddonName, SoyUI = ...
SoyUI.modules = {}

function SoyUI.print(msg)
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
    module.init()
  end
end

SLASH_SOYUI1 = "/soyui"
SlashCmdList["SOYUI"] = function()
  initDatabaseWithDefaults()
end

-- -- toy function: PoC for switch pattern
-- function f:prant(arg)
--   ({
--     ["a"] = function() 
--       SoyPrint("a pranted lol")
--     end,
--     ["b"] = function() 
--       SoyPrint("b pranted lol")
--     end
--   })[arg]() -- if {}[arg] doesnt exist, it returns nil; can i use this to define an inline default case?
-- end