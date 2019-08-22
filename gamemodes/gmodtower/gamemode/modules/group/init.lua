
include('shared.lua')
include('network.lua')
include('player.lua')
include('group.lua')
include('concommand.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_gui.lua')
AddCSLuaFile('cl_group.lua')
AddCSLuaFile('cl_guiitem.lua')

//GTowerGroup.Groups = {}

GROUPDEBUG = false

GTowerGroup.Groups = {}
GTowerGroup.MaxPlayers = 6


hook.Add("PlayerCanHearPlayersVoice", "GMTGroupTalk", function(listener, talker)

	local group = listener:GetGroup()
	
	if group and table.HasValue(group:GetPlayers(), talker) then
		return true
	end
	
end)


hook.Add( "PlayerDisconnected", "RemoveFromGroup", function(ply)
	
	local Group = ply:GetGroup()
	
	if Group then
		Group:RemovePlayer( ply )
	end
	
end )

function GTowerGroup:Get( id )
	return self.Groups[ id ]
end