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

  local function createTab(mod_name, tab_i, anchor)
    tabs[mod_name] = CreateFrame('Button', "SoyConfigPanel"..mod_name.."Tab",
                            m.configPanel, "OptionsFrameTabButtonTemplate")
    tabs[mod_name]:SetPoint("BOTTOMLEFT", anchor[1], anchor[2], 0, 0)
    tabs[mod_name]:SetID(tab_i + 1) -- 1-base indexing
    tabs[mod_name]:SetText(mod_name)
    -- if i want to edit this text: tabs[mod_name]:GetFontString()
    -- https://wowwiki-archive.fandom.com/wiki/Widget_API#Button

    tabs[mod_name]:SetScript("OnClick", function (self, button)
      for _, tab in pairs(tabs) do
        if (tab.widgets) then
          for _, widget in pairs(tab.widgets) do
            widget:Hide()
          end
        end
      end

      if (self.widgets) then
        for _, widget in pairs(self.widgets) do
          widget:Show()
        end
      end
    end)
  end

  local tab_i = 0
  createTab("SoyConfig", tab_i, {m.configPanel, "TOPLEFT"})
  local anchor = tabs["SoyConfig"]
  for mod_name, _ in pairs(SoyUI.modules) do
    if mod_name ~= "SoyConfig" then
      tab_i = tab_i + 1
      createTab(mod_name, tab_i, {anchor, "BOTTOMRIGHT"})
      anchor = tabs[mod_name]
    end
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

  return slider
end

function m.init()
  m.configPanel = CreateFrame("Frame", "SoyConfigPanel", UIParent)
  m.configPanel.name = myAddonName
  m.configPanel:Hide()

  local tabs = addModuleTabs()

  tabs.SoyFrames.widgets = {
    makeSlider(
      "Hp Height (%)", SoyUI_DB.SoyFrames.hp_height__pct,
      {30, -30}, {0, 100, 1}, nil,
      function(value)
        SoyUI_DB.SoyFrames.hp_height__pct = value
        for _, uf in pairs(SoyUI.modules.SoyFrames.uf) do
          uf:reload()
        end
      end),
  }

  InterfaceOptions_AddCategory(m.configPanel)
end
