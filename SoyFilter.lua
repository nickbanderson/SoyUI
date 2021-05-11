SoyFilterDB_DEFAULTS = {
	matchThreshold = 2,
	filterWords = {}
}

local function InformPlayer(msg) 
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SoyFilter:|r " .. msg)	
end

SLASH_SOYFILTER1 = "/sf"
SlashCmdList["SOYFILTER"] = function(msg)

	if msg == "toggle" then
		filterSPAM = not filterSPAM
		if (filterSPAM == false) then
			InformPlayer("Spam filter enabled")
		else
			InformPlayer("Spam filter disabled until reload")
		end

	elseif msg == "verbose" then
		verbose = not verbose
		if (verbose == true) then
		  InformPlayer("Verbose filtering enabled until reload")
		else
		  InformPlayer("Verbose filtering disabled")
		end

	elseif msg == "words" then
		-- build a string using the words array
		result = ""
		for i = 1, #SoyFilterDB.filterWords do
			if (result.length ~= 0) then
				result = result .. ", "
			end
			result = result .. SoyFilterDB.filterWords[i]
		end
		InformPlayer(result)

	elseif msg == "reset" then
		SoyFilterDB.filterWords = {}

	elseif msg:find("add") then
		-- get words to add
		msg = string.gsub(msg, "add", "") -- remove the word add
		msg = string.gsub(msg, "%s$", "") -- remove any spaces from the end
		msg = string.gsub(msg, "^%s", "") -- remove any spaces from the end
		msg = string.lower(msg)
		-- If there is not an array, we will have to create it.
		if SoyFilterDB.filterWords then
			table.insert(SoyFilterDB.filterWords,string.lower(msg))
		  InformPlayer("Added " .. msg)
		else
			SoyFilterDB.filterWords = {msg}
		  InformPlayer("Added " .. msg)
		end 

	elseif msg:find("remove") then
		-- get words to remove
		msg = string.gsub(msg, "remove", "") -- remove the word remove
		msg = string.gsub(msg, "%s$", "") -- remove any spaces from the end
		msg = string.gsub(msg, "^%s", "") -- remove any spaces from the end
		if SoyFilterDB.filterWords then
			for i = 1, #SoyFilterDB.filterWords do
				if (SoyFilterDB.filterWords[i] == msg) then
					table.remove(SoyFilterDB.filterWords,i)
				end
			end
		  InformPlayer("Removed " .. msg)
		else
		  InformPlayer("No custom user words found")
		end 	

  elseif msg:find("threshold") then
		-- get threshold
		msg = string.gsub(msg, "threshold", "") -- remove the t
		msg = string.gsub(msg, "%s$", "") -- remove any spaces from the end
		msg = string.gsub(msg, "^%s", "") -- remove any spaces from the end
		if msg == "" then 
			InformPlayer("Current threshold is " .. SoyFilterDB.matchThreshold)
	  elseif tonumber(msg) > 0 and tonumber(msg) < 100 then
			SoyFilterDB.matchThreshold = tonumber(msg)
			InformPlayer("New threshold of " .. SoyFilterDB.matchThreshold)
		else
			InformPlayer("Bad argument.")
		end

	else
		InformPlayer("List of commands")
		InformPlayer("/sf toggle")
		InformPlayer("/sf words     lists spam words")
		InformPlayer("/sf add WORD     add one word")
		InformPlayer("/sf remove WORD     remove one word")
		InformPlayer("/sf verbose     show filtered msgs")
		InformPlayer("/sf reset     remove all saved words.")
		InformPlayer("/sf threshold     view match threshold for filter")
		InformPlayer("/sf threshold NUMBER     change match threshold")

	end
end

local function filter(frame, event, message, sender, ...)
	if SoyFilterDB.filterWords == {} then return false end
  message = string.lower(message)
  local matchCount = 0

	for i, word in ipairs(SoyFilterDB.filterWords) do
			if message:find(word) then
					matchCount = matchCount + 1
			end
	end

	if matchCount >= SoyFilterDB.matchThreshold then
		if verbose then InformPlayer("Filtered: " .. message) end
		return true -- hide this message
  end
end


local f = CreateFrame("Frame")

-- load DB
f:RegisterEvent("ADDON_LOADED")
function f:OnEvent(event, addonName)
	if event == "ADDON_LOADED" and addonName == "SoyUI" then
		if SoyFilterDB == nil then SoyFilterDB = SoyFilterDB_DEFAULTS end
	end
end
f:SetScript("OnEvent", f.OnEvent)

-- add filters
local tbl = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_YELL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_DND",
	"CHAT_MSG_AFK",
}
for i = 1, #tbl do
	local event = tbl[i]
	local frames = {GetFramesRegisteredForEvent(event)}
	for i = 1, #frames do
		local frame = frames[i]
		frame:UnregisterEvent(event)
	end
	f:RegisterEvent(event)
	ChatFrame_AddMessageEventFilter(event, filter)
	for i = 1, #frames do
		local frame = frames[i]
		frame:RegisterEvent(event)
	end
end