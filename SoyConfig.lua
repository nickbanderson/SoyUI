local myAddonName, SoyUI = ...
SoyUI.modules.SoyConfig = {
  init = nil,
  defaults = {},
}

-- aliases
local print = SoyUI.util.print
local m = SoyUI.modules.SoyConfig
local C = SoyUI.util.COLORS

local function addModuleTabs()
  local tabs = {}

  local tab_i = 0
  local anchor = m.configPanel -- first, anchor tab to panel, then to prev tab
  for name, _ in pairs(SoyUI.modules) do
    tabs[name] = CreateFrame('Button', "SoyConfigPanel"..name.."Tab",
                             m.configPanel, "OptionsFrameTabButtonTemplate")
    tabs[name]:SetID(tab_i + 1)
    tabs[name]:SetText(name)
    -- if i want to edit this text: tabs[name]:GetFontString()
    -- https://wowwiki-archive.fandom.com/wiki/Widget_API#Button

    if tab_i == 0 then
      tabs[name]:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 0)
    else
      tabs[name]:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", 0, 0)
    end

    tab_i = tab_i + 1
    anchor = tabs[name]
  end

  return tabs
end

local function makeSlider(label, initial_val, pos, range, size, setter)
  size = size or {100, 15}
  local frame_name = "SoyConfigPanel" .. string.gsub(label, "%s+", "") .. "Slider"

  local slider = CreateFrame("Slider", frame_name, m.configPanel, 
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

function m.init()
  m.configPanel = CreateFrame("Frame", "SoyConfigPanel", UIParent)
  m.configPanel.name = myAddonName
  m.configPanel:Hide()

  local tabs = addModuleTabs()

  makeSlider(
    "Hp Height (%)", SoyUI_DB.SoyFrames.hp_height__pct,
    {30, -30}, {0, 100, 1}, nil,
    function(value)
      SoyUI_DB.SoyFrames.hp_height__pct = value
      for _, uf in pairs(SoyUI.modules.SoyFrames.uf) do
        uf:reload()
      end
    end)

  InterfaceOptions_AddCategory(m.configPanel)
end
