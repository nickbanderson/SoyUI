local _, SoyUI = ...

-- aliases
local print = SoyUI.util.print
local UnitClass = SoyUI.util.UnitClass
local C = SoyUI.util.COLORS

local function createBar(name, size, color, parent)
  local f = CreateFrame("Frame", name, parent)
  f:SetFrameStrata("LOW")
  f:SetWidth(size[1])
  f:SetHeight(size[2])
  
  local t = f:CreateTexture(nil, "BACKGROUND")
  t:SetTexture(unpack(color))
  t:SetAllPoints(f)
  f.texture = t

  -- frames can't be zero width, but this works
  function f:SetZeroableWidth(width)
    self:SetWidth(width > 0 and width or .001)
  end
 
  return f
end

local function calcHpHeight(total_height)
  return total_height * (SoyUI_DB.SoyFrames.hp_height__pct / 100)
end

local function calcPowHeight(total_height)
  return total_height * (1 - SoyUI_DB.SoyFrames.hp_height__pct / 100)
end

-- meta class
SoyUI.UnitFrame = {
  unit = nil,
  hp = nil,
  power = nil,
  width = 140,
  height = 35,
  padding = 2,
  frames = {},
}
SoyUI.UnitFrame.__index = SoyUI.UnitFrame

function SoyUI.UnitFrame:SetUpdateScripts()
  self.frames.hp:RegisterEvent("UNIT_HEALTH")
  self.frames.hp:RegisterEvent("UNIT_MAXHEALTH")
  self.frames.hp:SetScript("OnEvent",
    function(f, event, ...)
      local u = ...
      if u == self.unit then self:updateHp() end
    end
  )

  self.frames.power:RegisterEvent("UNIT_MANA")
  self.frames.power:RegisterEvent("UNIT_RAGE")
  self.frames.power:RegisterEvent("UNIT_ENERGY")
  self.frames.power:RegisterEvent("UNIT_FOCUS")
  self.frames.power:RegisterEvent("UNIT_RUNIC_POWER")
  self.frames.power:RegisterEvent("UNIT_DISPLAYPOWER") -- eg, shapeshift
  self.frames.power:RegisterEvent("UNIT_MAXMANA")
  self.frames.power:RegisterEvent("UNIT_MAXRAGE")
  self.frames.power:RegisterEvent("UNIT_MAXENERGY")
  self.frames.power:RegisterEvent("UNIT_MAXFOCUS")
  self.frames.power:RegisterEvent("UNIT_MAXRUNIC_POWER")
  self.frames.power:SetScript("OnEvent",
    function(f, event, ...)
      local u = ...
      if u == self.unit then self:updatePower() end
    end
  )
end

function SoyUI.UnitFrame:new(unit, x, y)
  local uf = {}
  setmetatable(uf, SoyUI.UnitFrame)

  uf.name = "SoyFrames_" .. unit
  uf.unit = unit

  local background = createBar(
    uf.name .. "_background", 
    {uf.width + 2 * uf.padding, uf.height + 3 * uf.padding},
    {0, 0, 0},
    UIParent
  )
  background.unit = unit
  background:SetPoint("CENTER", x, y)
  background.text = background:CreateFontString(uf.name .. "_bgText", "MEDIUM",
                                                "GameTooltipText")
  background.text:SetPoint("BOTTOMLEFT", background, "TOPLEFT", 0, 0)
  local default_font_path, font_size, _ = background.text:GetFont()
  background.text:SetFont(default_font_path, font_size, "OUTLINE")

  background:EnableMouse(true)
  background:SetClampedToScreen(true) -- keep frame on screen (while dragging)
  background:RegisterForDrag("LeftButton")
  background:SetScript("OnDragStart", function(self)
    if background:IsMovable() then
      self:StartMoving()
    end
  end)
  background:SetScript("OnDragStop", function(self)
    if background:IsMovable() then
      self:StopMovingOrSizing()
      SoyUI_DB.SoyFrames[self.unit].x = self:GetLeft()
      SoyUI_DB.SoyFrames[self.unit].y = self:GetBottom()
    end
  end)

  local function handleKeybind(self, type, ...)
    if type == "LeftButton" then
      -- print('target kek')
      -- TargetUnit(self.unit) -- cant do this so easily bc its protected
    elseif type == "RightButton" then
      local background = "SoyFrames_"..self.unit.."_background"
      if self.unit == 'player' then
        ToggleDropDownMenu(1, nil, PlayerFrameDropDown, background, 0, 0)
      elseif self.unit == 'target' then
        ToggleDropDownMenu(1, nil, TargetFrameDropDown, background, 0, 0)
      elseif self.unit == 'focus' then
        ToggleDropDownMenu(1, nil, FocusFrameDropDown, background, 0, 0)
      end
    elseif type == "MiddleButton" then
        print(type)
    elseif type == "Button4" then
        print(type)
    elseif type == "Button5" then
        print(type)
    elseif type == 1 then -- scroll up
        print('scroll up')
    elseif type == -1 then -- scroll down
        print('scroll down')
    else
      print("UNMATCHED EVENT: "..type)
    end
  end
  background:SetScript("OnMouseDown", handleKeybind)
  background:SetScript("OnKeyDown", handleKeybind)
  background:SetScript("OnMouseWheel", handleKeybind)
  background:EnableMouseWheel(true)
  local hp = createBar(
    uf.name .. "_hp",
    {uf.width, calcHpHeight(self.height)},
    {0, 120, 0},
    background
  )
  hp:SetPoint("TOPLEFT", uf.name .. "_background", "TOPLEFT",
              uf.padding, -1 * uf.padding)
  hp.text = hp:CreateFontString(uf.name .. "_hpText", "MEDIUM", 
                                "GameTooltipText")
  hp.text:SetFont(default_font_path, font_size, "OUTLINE")
  hp.text:SetPoint("CENTER", uf.name .. "_hp" , "LEFT",
                   uf.width / 2 + uf.padding, 0)

  local power = createBar(
    uf.name .. "_power",
    {uf.width, calcPowHeight(self.height)},
    {0, 0, 120},
    background
  )
  power:SetPoint("BOTTOMLEFT", uf.name .. "_background",
                 "BOTTOMLEFT", uf.padding, uf.padding)
  power.text = power:CreateFontString(uf.name .. "_powerText", "MEDIUM", 
                                      "GameTooltipText")
  power.text:SetFont(default_font_path, font_size, "OUTLINE")
  power.text:SetPoint("CENTER", uf.name .. "_power" , "LEFT", 
                      uf.width / 2 + uf.padding, 0)

  uf.frames = {
    background = background,
    hp = hp,
    power = power,
  }
  uf:SetUpdateScripts()
  return uf
end

function SoyUI.UnitFrame:updateHp()
  local proportion = UnitHealth(self.unit) / UnitHealthMax(self.unit)
  self.frames.hp:SetZeroableWidth(proportion * self.width)
  self.frames.hp.text:SetText(SoyUI.util.fmtNum(UnitHealth(self.unit)))

  self.frames.hp.text:SetTextColor(unpack(proportion > .7 and C.green or
                                          proportion > .2 and C.yellow or
                                          C.red))
end

function SoyUI.UnitFrame:updatePower()
  local proportion = UnitPower(self.unit) / UnitPowerMax(self.unit)
  self.frames.power:SetZeroableWidth(proportion * self.width)
  self.frames.power.text:SetText(SoyUI.util.fmtNum(UnitPower(self.unit)))
end

function SoyUI.UnitFrame:updateMeta()
  self.frames.background.text:SetText(GetUnitName(self.unit))

  local power_type = UnitPowerType(self.unit) 
  self.frames.power.texture:SetTexture(unpack(C.POWER[power_type].main))
  self.frames.power.text:SetTextColor(unpack(C.POWER[power_type].lighter))

  self.frames.hp.texture:SetTexture(unpack(C.CLASS[UnitClass(self.unit)]))
end

function SoyUI.UnitFrame:updatePosition()
  self.frames.background:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT",
                                  SoyUI_DB.SoyFrames[self.unit].x, 
                                  SoyUI_DB.SoyFrames[self.unit].y)
end

function SoyUI.UnitFrame:show()
  self:updateMeta()
  self:updateHp()
  self:updatePower()
  self:updatePosition()
  self.frames.background:Show()
end

function SoyUI.UnitFrame:hide()
  self.frames.background:Hide()
end

function SoyUI.UnitFrame:unlock()
  self.frames.background:SetMovable(true)
end

function SoyUI.UnitFrame:lock()
  self.frames.background:SetMovable(false)
end

function SoyUI.UnitFrame:reload()
  self.frames.hp:SetHeight(calcHpHeight(self.height))
  self.frames.power:SetHeight(calcPowHeight(self.height))
end
