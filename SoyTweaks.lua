local _, SoyUI = ...

local function registerSlashReload()
  SLASH_SOYUI_RELOAD1 = "/rl"
  SlashCmdList["SOYUI_RELOAD"] = function()
    DEFAULT_CHAT_FRAME.editBox:SetText("/reload") 
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  end
end

local function setCVars()
  SetCVar('nameplateMaxDistance', SoyUI_DB.SoyTweaks.nameplateMaxDistance)
end

local function enableArenaNumberOnNameplate()
  hooksecurefunc("CompactUnitFrame_UpdateName", function(nameplate)
    if IsActiveBattlefieldArena() and nameplate.unit:find("nameplate", 0, true) then 
      for i=1,5 do 
        if UnitIsUnit( nameplate.unit ,"arena"..i) then 
          nameplate.name:SetText(i)
          nameplate.name:SetTextColor(1,1,0)
          break 
        end 
      end 
    end 
  end)
end

local function ensurePlayerOnTopOfRaidFrames()
  LoadAddOn("Blizzard_CompactRaidFrames") 
  local CRFSort_Group = function(t1, t2) 
		if UnitIsUnit(t1, "player") then return true
		elseif UnitIsUnit(t2, "player") then return false
    else return t1 < t2
    end
  end 
  CompactRaidFrameContainer.flowSortFunc = CRFSort_Group
  CompactRaidFrameContainer_SetFlowSortFunction(
    CompactRaidFrameContainer, CRFSort_Group)
end

local function init()
  registerSlashReload()
  setCVars()
  -- ensurePlayerOnTopOfRaidFrames()
  if SoyUI_DB.SoyTweaks.showArenaNumberOnNameplate then
    enableArenaNumberOnNameplate()
  end
end

SoyUI.modules.SoyTweaks = {
  init = init,
  defaults = {
    nameplateMaxDistance = 41, -- [?,41]
    showArenaNumberOnNameplate = true,
  },
}