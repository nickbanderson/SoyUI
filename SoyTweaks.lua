local _, SoyUI = ...
SoyUI.modules.SoyTweaks = {
  init = nil,
  defaults = {
    showArenaNumberOnNameplate = true,
  },
  cd = {
    ef = nil,
    pf = nil,
    hidden = false,
    timer = -1,
  }
}
local m = SoyUI.modules.SoyTweaks

local pvp_timers = {
  fifteen = {
    "Fifteen seconds until the Arena battle begins!",
  },
  thirty = {
    "Thirty seconds until the Arena battle begins!",
    "The battle for Warsong Gulch begins in 30 seconds. Prepare yourselves!",
    "The battle for Arathi Basin begins in 30 seconds. Prepare yourselves!",
    "The battle for Strand of the Ancients begins in 30 seconds. Prepare yourselves!",
    "Round 2 begins in 30 seconds. Prepare yourselves!",
    "The battle will begin in 30 seconds!",
  },
  sixty = {
    "One minute until the Arena battle begins!",
    "The battle for Warsong Gulch begins in 1 minute.",
    "The battle for Arathi Basin begins in 1 minute.",
    "The battle for Strand of the Ancients begins in 1 minute.",
    "Round 2 of the Battle for the Strand of the Ancients begins in 1 minute.",
    "The battle will begin in 1 minute.",
  },
}

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

local function enablePvpCountdowns()
  m.cd.ef = CreateFrame("Frame")
  function m.cd.ef:OnEvent(event, ...)
    self[event](self, ...)
  end
  m.cd.ef:SetScript("OnEvent", m.cd.ef.OnEvent)

  m.cd.ef:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
  function m.cd.ef:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
    local function contains(tb, target)
      for i, v in ipairs(tb) do
          if v == target then return true end
      end
      return false 
    end

    if contains(pvp_timers["sixty"], msg) then
      m.cd.timer = 61
    elseif contains(pvp_timers["thirty"], msg)then
      m.cd.timer = 31
    elseif contains(pvp_timers["fifteen"], msg) then
      m.cd.timer = 16
    end
  end

  m.cd.pf = CreateFrame("Frame", "CountdownParent", UIParent)
  m.cd.pf:SetHeight(256)
  m.cd.pf:SetWidth(256)
  m.cd.pf:SetPoint("CENTER", 0, 128)

  local ones = m.cd.pf:CreateTexture("CountdownOnes", "HIGH")
  ones:SetHeight(128)
  ones:SetWidth(256)
  ones:SetPoint("CENTER", m.cd.pf, 48, 0)

  local tens = m.cd.pf:CreateTexture("CountdownTens", "HIGH")
  tens:SetHeight(128)
  tens:SetWidth(256)
  tens:SetPoint("CENTER", m.cd.pf, -48, 0)

  m.cd.ef:SetScript("OnUpdate", function(self, elapse)
    -- timer off or just expiring
    if m.cd.timer <= 0 then 
      if not hidden then
        m.cd.hidden = true
        ones:Hide()
        tens:Hide()
      end
      return 
    end

    local old_timer = m.cd.timer
    m.cd.timer = m.cd.timer - elapse

    -- skip graphics update if <1 second has passed
    if math.floor(m.cd.timer) == math.floor(old_timer) then return end

    m.cd.hidden = false

    local ones_digit = math.floor(m.cd.timer % 10)
    local tens_digit = math.floor(m.cd.timer / 10)

    -- SoyUI.print(tens_digit .. " and " .. ones_digit)

    ones:SetTexture("Interface\\Addons\\SoyUI\\assets\\" .. ones_digit)
    ones:Show()

    if tens_digit ~= 0 then
      tens:SetTexture("Interface\\Addons\\SoyUI\\assets\\" .. tens_digit)
      tens:Show()
      -- SoyUI.print("tens on")
      ones:SetPoint("CENTER", m.cd.pf, 48, 0)
    else
      tens:Hide()
      ones:SetPoint("CENTER", m.cd.pf, 0, 0)
      -- SoyUI.print("tens off")
    end
  end)
end

function m.init()
  registerSlashReload()
  setCVars()
  enablePvpCountdowns()
  if SoyUI_DB.SoyTweaks.showArenaNumberOnNameplate then
    -- enableArenaNumberOnNameplate()
  end
end