local _, SoyUI = ...
SoyUI.modules.SoyTweaks = {
  init = nil,
  defaults = {
    showArenaNumberOnNameplate = true,
  },
}
local m = SoyUI.modules.SoyTweaks

local function registerSlashReload()
  SLASH_SOYUI_RELOAD1 = "/rl"
  SlashCmdList["SOYUI_RELOAD"] = function()
    DEFAULT_CHAT_FRAME.editBox:SetText("/reload") 
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
  end
end

local function setCVars()
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

function m.init()
  registerSlashReload()
  setCVars()
  if SoyUI_DB.SoyTweaks.showArenaNumberOnNameplate then
    -- enableArenaNumberOnNameplate()
  end
end