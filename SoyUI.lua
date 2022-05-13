local myAddonName, SoyUI = ...
SoyUI.modules = {}
SoyUI.COLORS = {
  POWER = {
    [0] = { -- mana
      main = {0, 0, 1},    
      lighter = {.678, .847, .902},
    },
    [1] = { -- rage
      main = {1, 0, 0},    
      lighter = {1, .6, .597},
    },
    [2] = { -- focus
      main = {1, .502, .251},    
      lighter = {.996, .847, .694},
    },
    [3] = { -- energy
      main = {1, 1, 0},    
      lighter = {1, 1, .878},
    },
    [6] = { -- runic power
      main = {0, .820, 1},    
      lighter = {.635, .777, .828},
    },
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
  red = {.8, .1, .2},
  yellow = {1, .9, .4},
  green = {0, .9, 0},
  white = {1, 1, 1},
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
  SoyUI.configPanel = CreateFrame("Frame", "SoyUI_configPanel", UIParent)
  SoyUI.configPanel.name = myAddonName
  SoyUI.configPanel:Hide()

  local function makeSlider(label, initial_val, pos, range, size, setter)
    size = size or {100, 15}
    local frame_name = "SoyUI_configPanel" .. string.gsub(label, "%s+", "")
                        .."Slider"

    local slider = CreateFrame("Slider", frame_name, SoyUI.configPanel, 
                               "OptionsSliderTemplate")
    slider:SetWidth(size[1])
    slider:SetHeight(size[2])
    slider:SetMinMaxValues(range[1], range[2])
    slider:SetValueStep(range[3])
    slider:SetValue(initial_val)
    slider:SetPoint("TOPLEFT", pos[1], pos[2])

    getglobal(frame_name.."Low"):SetText(range[1])
    getglobal(frame_name.."High"):SetText(range[2])
    getglobal(frame_name.."Text"):SetText(label)

    local box = CreateFrame("EditBox", frame_name.."EditBox", slider, 
                            "InputBoxTemplate")
    box:SetWidth(30)
    box:SetHeight(15)
    box:SetPoint("TOP", slider, "BOTTOM", 0, 0)
    box:EnableMouse(true)
    box:SetAutoFocus(false)
    box:SetText(initial_val)

    local function hookedSetter(val)
      val = SoyUI.util.constrainValue(val, {range[1], range[2]})
      setter(val)
      slider:SetValue(val)
      box:SetText(val)
      box:ClearFocus()
    end

    slider:SetScript("OnValueChanged", 
                     function(self, val) hookedSetter(val) end)
    box:SetScript("OnEnterPressed", 
                  function(self) hookedSetter(self:GetText()) end)
  end

  makeSlider(
    "Hp Height (%)", SoyUI_DB.SoyFrames.hp_height__pct,
    {30, -30}, {0, 100, 1}, nil,
    function(value)
      SoyUI_DB.SoyFrames.hp_height__pct = value
      for _, uf in pairs(SoyUI.modules.SoyFrames.uf) do
        uf:reload()
      end
    end)

  -- local testButton = CreateFrame(
  --   "Button", "testButton",
  --   SoyUI.configPanel, "UIPanelButtonTemplate")
  -- testButton:SetWidth(80)
  -- testButton:SetHeight(22)
  -- testButton:SetText("Test Button")

  InterfaceOptions_AddCategory(SoyUI.configPanel)
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