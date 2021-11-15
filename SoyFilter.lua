local _, SoyUI = ...
SoyUI.modules.SoyFilter = {
	init = nil,
	defaults = {
		matchThreshold = 1,
		filterWords = {},
	},
	ef = nil,
}
local m = SoyUI.modules.SoyFilter

SLASH_SOYFILTER1 = "/sf"
SlashCmdList["SOYFILTER"] = function(msg)

	if msg == "toggle" then
		filterSPAM = not filterSPAM
		if (filterSPAM == false) then
			SoyUI.print("Spam filter enabled")
		else
			SoyUI.print("Spam filter disabled until reload")
		end

	elseif msg == "verbose" then
		verbose = not verbose
		if (verbose == true) then
		  SoyUI.print("Verbose filtering enabled until reload")
		else
		  SoyUI.print("Verbose filtering disabled")
		end

	elseif msg == "words" then
		-- build a string using the words array
		result = ""
		for i = 1, #SoyUI_DB.SoyFilter.filterWords do
			if (result.length ~= 0) then
				result = result .. ", "
			end
			result = result .. SoyUI_DB.SoyFilter.filterWords[i]
		end
		SoyUI.print(result)

	elseif msg == "reset" then
		SoyUI_DB.SoyFilter.filterWords = {}

	elseif msg:find("add", 0, true) then
		-- get words to add
		msg = string.gsub(msg, "add", "") -- remove the word add
		msg = string.gsub(msg, "%s$", "") -- remove any spaces from the end
		msg = string.gsub(msg, "^%s", "") -- remove any spaces from the start
		msg = string.lower(msg)
		-- If there is not an array, we will have to create it.
		if SoyUI_DB.SoyFilter.filterWords then
			table.insert(SoyUI_DB.SoyFilter.filterWords,string.lower(msg))
		  SoyUI.print("Added " .. msg)
		else
			SoyUI_DB.SoyFilter.filterWords = {msg}
		  SoyUI.print("Added " .. msg)
		end 

	elseif msg:find("remove", 0, true) then
		-- get words to remove
		msg = string.gsub(msg, "remove", "") -- remove the word remove
		msg = string.gsub(msg, "%s$", "") -- remove any spaces from the end
		msg = string.gsub(msg, "^%s", "") -- remove any spaces from the end
		if SoyUI_DB.SoyFilter.filterWords then
			for i = 1, #SoyUI_DB.SoyFilter.filterWords do
				if (SoyUI_DB.SoyFilter.filterWords[i] == msg) then
					table.remove(SoyUI_DB.SoyFilter.filterWords,i)
				end
			end
		  SoyUI.print("Removed " .. msg)
		else
		  SoyUI.print("No custom user words found")
		end 	

  elseif msg:find("threshold", 0, true) then
		-- get threshold
		msg = string.gsub(msg, "threshold", "") -- remove the t
		msg = string.gsub(msg, "%s$", "") -- remove any spaces from the end
		msg = string.gsub(msg, "^%s", "") -- remove any spaces from the end
		if msg == "" then 
			SoyUI.print("Current threshold is " .. SoyUI_DB.SoyFilter.matchThreshold)
	  elseif tonumber(msg) > 0 and tonumber(msg) < 100 then
			SoyUI_DB.SoyFilter.matchThreshold = tonumber(msg)
			SoyUI.print("New threshold of " .. SoyUI_DB.SoyFilter.matchThreshold)
		else
			SoyUI.print("Bad argument.")
		end

	else
		SoyUI.print("List of commands")
		SoyUI.print("/sf toggle")
		SoyUI.print("/sf words     lists spam words")
		SoyUI.print("/sf add WORD     add one word")
		SoyUI.print("/sf remove WORD     remove one word")
		SoyUI.print("/sf verbose     show filtered msgs")
		SoyUI.print("/sf reset     remove all saved words.")
		SoyUI.print("/sf threshold     view match threshold for filter")
		SoyUI.print("/sf threshold NUMBER     change match threshold")

	end
end

local function filter(frame, event, message, sender, ...)
	-- filter from horde (not working :( )
	-- englishFaction, _ = UnitFactionGroup(sender)
	-- if englishFaction ~= nil then
	-- 	SoyUI.print(englishFaction)
	-- end

	-- check matched keywords
	if SoyUI_DB.SoyFilter.filterWords == {} then return false end
  message = string.lower(message)
  local matchCount = 0

	for i, word in ipairs(SoyUI_DB.SoyFilter.filterWords) do
			if message:find(word, 0, true) then
					matchCount = matchCount + 1
			end
	end

	if matchCount >= SoyUI_DB.SoyFilter.matchThreshold then
		if verbose then SoyUI.print("Filtered: " .. message) end
		return true -- hide this message
  end
end

-- add filters
function m.init()
	local ef = CreateFrame("Frame")

	local tbl = {
		"CHAT_MSG_CHANNEL",
		"CHAT_MSG_YELL",
		"CHAT_MSG_SAY",
	}
	for i = 1, #tbl do
		local event = tbl[i]
		local frames = {GetFramesRegisteredForEvent(event)}
		for i = 1, #frames do
			local frame = frames[i]
			frame:UnregisterEvent(event)
		end
		ef:RegisterEvent(event)
		ChatFrame_AddMessageEventFilter(event, filter)
		for i = 1, #frames do
			local frame = frames[i]
			frame:RegisterEvent(event)
		end
	end
end