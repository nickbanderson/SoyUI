local _, SoyUI = ...

local function hookCRFM()
  LoadAddOn("Blizzard_CompactRaidFrameManager")
  local f = CompactRaidFrameManager

  local function moveCRFM(self, ...)
    local point, relativeTo, relativePoint, xOff, yOff = f:GetPoint(n)
    f:ClearAllPoints()
    f:SetPoint(point, relativeTo, relativePoint, xOff, 
      SoyUI_DB.SoyLayout.CRFM_yOffset) 
  end

  f:HookScript('OnShow', moveCRFM)
  f:HookScript('OnHide', moveCRFM)
  f.displayFrame:HookScript('OnShow', moveCRFM)
  f.displayFrame:HookScript('OnHide', moveCRFM)
end

local function init()
  hookCRFM()
end

SoyUI.modules.SoyLayout = {
  init = init,
  defaults = {
    CRFM_yOffset = -10
  },
}