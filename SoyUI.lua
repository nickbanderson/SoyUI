SLASH_SOYUI_RELOAD1 = "/rl"
SlashCmdList["SOYUI_RELOAD"] = function()
  DEFAULT_CHAT_FRAME.editBox:SetText("/reload") 
  ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end

SLASH_SOYUI1 = "/soyui"
SlashCmdList["SOYUI"] = function()
  -- launch gui
end