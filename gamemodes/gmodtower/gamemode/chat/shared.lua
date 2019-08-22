

-----------------------------------------------------

GTowerChat.Bubble = "models/extras/info_speech.mdl"

GTowerChat.TypeBits = 6
GTowerChat.ChatGroups = {
	[1] = "Server",
	[2] = "Group",
	[3] = "Local",
	[4] = "Theater",
	[5] = "Join/Leave",
	[6] = "Emotes",
	[7] = "Duels",
}

function GTowerChat.GetChatEnum( typestr )

	if not GTowerChat.ChatGroups then return end

	for k,v in ipairs( GTowerChat.ChatGroups ) do
		if v == typestr then
			return k
		end
	end

end

net.Receive("ChatBubble",function ()

	local pl = net.ReadEntity()
	local new = net.ReadBool()

	if !IsValid(pl) then return end

	if new then
		pl:StartChatBubble()
	else
		pl:EndChatBubble()
	end

end)

RegisterNWTablePlayer( {
	{ "Chatting", false, NWTYPE_BOOLEAN, REPL_EVERYONE, PlayerBubble },
	{ "HideRedir", false, NWTYPE_BOOLEAN, REPL_PLAYERONLY }
})
