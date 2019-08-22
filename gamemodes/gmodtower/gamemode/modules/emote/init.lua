
include( "shared.lua" )

AddCSLuaFile( "cl_init.lua")
AddCSLuaFile( "cl_emotes.lua")
AddCSLuaFile( "shared.lua" )

util.AddNetworkString( "EmoteAct" )

--concommand.Add("gmt_endemote", function(ply, cmd, args)
	--idk
--end)

local Grammar = {
	["agree"] = "agrees.",
	["beckon"] = "beckons.",
	["bow"] = "bows.",
	["disagree"] = "disagrees.",
	["group"] = "signals to group.",
	["no"] = "signals to halt.",
	["dance"] = "dances.",
	["sexydance"] = "dances sexily.",
	["sit"] = "sits.",
	["wave"] = "waves.",
	["yes"] = "signals to go forwards.",
	["taunt"] = "taunts.",
	["cheer"] = "cheers.",
	["flail"] = "flails.",
	["laugh"] = "laughs.",
	["suicide"] = "couldn't handle life anymore.",
	["lay"] = "lays down.",
	["robot"] = "does the robot.",
}

function GetGrammar( name )
	return Grammar[name]
end

Commands = {
	[1] = {"agree", "agree", 3},
	[2] = {"beckon", "becon", 4},
	[3] = {"bow", "bow", 3},
	[4] = {"disagree", "disagree", 3},
	[5] = {"group", "group", 1},
	[6] = {"no", "halt", 1},
	[7] = {"dance", "dance", 9},
	[8] = {"sexydance", "muscle", 13},
	[9] = {"sit", "", 0},
	[10] = {"wave", "wave", 3},
	[11] = {"yes", "forward", 1},
	[12] = {"taunt", "pers", 2},
	[13] = {"cheer", "cheer", 2.5},
	[14] = {"flail", "zombie", 2.5},
	[15] = {"laugh", "laugh", 6},
	[16] = {"suicide", "", 0},
	[17] = {"lay", "", 0},
	[18] = {"robot", "robot", 11},
}

concommand.Add("gmt_emoteend", function(ply)
		ply:SetNWBool("Emoting",false)
		ply:SetNWBool("Sitting",false)
		ply:SetNWBool("Laying",false)
end)

for _, emote in pairs(Commands) do
	local emoteName = emote[1]
	local Action 	= emote[2]
	local Duration	= emote[3]
	
	if emoteName == "sit" then
		ChatCommands.Register( "/" .. emoteName, 5, function( ply )
		if !ply:OnGround() then return end
		ply:SetNWBool("Emoting",true)
		ply:SetNWBool("Sitting",true)
		
		for k,v in pairs(player.GetAll()) do
			if ply.GLocation != v.GLocation then continue end
			v:SendLua([[GTowerChat.Chat:AddText("]]..ply:Name()..[[ ]]..GetGrammar(emoteName)..[[", Color(150, 150, 150, 255))]])
		end
		
		return ""
		end )
	elseif emoteName == "lay" then
		ChatCommands.Register( "/" .. emoteName, 5, function( ply )
		if !ply:OnGround() then return end
		ply:SetNWBool("Emoting",true)
		ply:SetNWBool("Laying",true)
		
		for k,v in pairs(player.GetAll()) do
			if ply.GLocation != v.GLocation then continue end
			v:SendLua([[GTowerChat.Chat:AddText("]]..ply:Name()..[[ ]]..GetGrammar(emoteName)..[[", Color(150, 150, 150, 255))]])
		end
		
		return ""
		end )
	elseif emoteName == "suicide" then
		ChatCommands.Register( "/" .. emoteName, 5, function( ply )
		ply:Kill()
		
		for k,v in pairs(player.GetAll()) do
			if ply.GLocation != v.GLocation then continue end
			v:SendLua([[GTowerChat.Chat:AddText("]]..ply:Name()..[[ ]]..GetGrammar(emoteName)..[[", Color(150, 150, 150, 255))]])
		end
		
		return ""
		end )
	else
		ChatCommands.Register( "/" .. emoteName, 5, function( ply )
		if !ply:OnGround() then return end
		ply:SetNWBool("Emoting",true)
		
		net.Start("EmoteAct")
			net.WriteString(Action)
		net.Send(ply)
		
		timer.Simple(Duration, function()
			if IsValid(ply) then ply:SetNWBool("Emoting",false) end
		end)
		
		for k,v in pairs(player.GetAll()) do
			if ply.GLocation != v.GLocation then continue end
			v:SendLua([[GTowerChat.Chat:AddText("]]..ply:Name()..[[ ]]..GetGrammar(emoteName)..[[", Color(150, 150, 150, 255))]])
		end
		
		return ""
		end )
	end

end