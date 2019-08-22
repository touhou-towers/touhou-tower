

-----------------------------------------------------
GTowerChat.AutoCompleteEnabled = true
GTowerChat.AutoCompleteChanged = {"", ""}
GTowerChat.AutoCompleteFileRead = string.Explode("\n", file.Read("GTowerChat/WordList.txt", "DATA") or "")

function GTowerChat.AutoComplete(Text)
	if(!GTowerChat.AutoCompleteEnabled) then
		return false
	end
	local Explode = string.Explode(" ", Text)
	if(!Explode) then
		return false
	end
	
	local CurrentWord = Explode[table.Count(Explode)]
	if(!CurrentWord or CurrentWord == "") then
		return false
	end
	
	local Ex = false
	local AfterK = false
	local LenFix = CurrentWord
	local Changed = GTowerChat.AutoCompleteChanged
	local LastCurrentWord = Changed[1]
	local LastBestWord = Changed[2]
	
	if(LastCurrentWord != "") then
		if(!LastBestWord or (LastBestWord and string.lower(CurrentWord) == string.lower(LastBestWord))) then
			Ex = true
			CurrentWord = LastCurrentWord
			AfterK = GTowerChat.AutoCompleteGetK(LastBestWord)
		end
	end
	
	local Best = 0
	local BestWord = ""
	for k,v in pairs(GTowerChat.AutoCompleteTable()) do
		local Match = GTowerChat.AutoCompleteMatch(CurrentWord, v)
		if(Match and ((!AfterK and Match > Best) or (AfterK and AfterK < k))) then
			Best = Match
			BestWord = v
			if(AfterK) then
				break
			end
		end
	end
	
	if(CurrentWord == LastCurrentWord and Best == 0 and BestWord == "") then
		GTowerChat.AutoCompleteChanged = {CurrentWord, false}
		return GTowerChat.AutoComplete(Text)
	end
	
	if(BestWord != "") then
		GTowerChat.AutoCompleteChanged = {CurrentWord, BestWord}
		return string.sub(Text, 0, string.len(Text) - string.len(LenFix))..BestWord, Ex
	end
	return false
end

function GTowerChat.AutoCompleteTable()
	local Table = GTowerChat.AutoCompleteFileRead
	for k,v in pairs(player.GetAll()) do
		if(v and v:IsValid()) then
			table.insert(Table, v:Nick())
		end
	end
	return Table
end

function GTowerChat.AutoCompleteGetK(Word)
	if(Word) then
		for k,v in pairs(GTowerChat.AutoCompleteTable()) do
			if(v == Word) then
				return k
			end
		end
	end
	return 0
end

function GTowerChat.AutoCompleteMatch(CurrentWord, TableWord)
	local Match = 0
	
	local Len1 = string.len(CurrentWord)
	local Lower1 = string.lower(CurrentWord)
	
	local Len2 = string.len(TableWord)
	local Lower2 = string.lower(TableWord)
	
	if(Lower1 == Lower2) then
		return Match
	end
	
	local Match = false
	for i=0, Len2 do
		if(string.sub(Lower2, 0, i) == string.lower(Lower1)) then 
			Match = i
		end
	end
	
	return Match
end
