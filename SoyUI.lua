local myAddonName, SoyUI = ...
SoyUI.modules = {}

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
  for moduleName, module in pairs(SoyUI.modules) do
    if moduleName ~= "SoyConfig" then
      module.init()
    end
  end
  SoyUI.modules.SoyConfig.init()
end

SLASH_SOY1 = "/soy"
SlashCmdList["SOY"] = function(msg)
  if msg == '' or msg == nil then
    InterfaceOptionsFrame_Show()
    InterfaceOptionsFrame_OpenToCategory(myAddonName)
    return
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