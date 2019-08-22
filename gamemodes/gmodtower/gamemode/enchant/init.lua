
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_base.lua")
AddCSLuaFile("sh_hook.lua")
AddCSLuaFile("sh_load.lua")

include('shared.lua')
include('base.lua')
include("hook.lua")
include("sh_base.lua")
include("sh_hook.lua")
include("sh_load.lua")

module("enchant", package.seeall )

AllSharedItems = {}

function New( Name, ply )

	local NewItem = _New( Name, ply )
	
	SafeCall( NewItem.Init, NewItem )
	
	return NewItem
	
end

function _Removed( item )

	local Shared = item:IsShared()
	
	if Shared then
		umsg.Start("enchant", item:GetRP() ) 
			umsg.Char( 2 )
			umsg.Short( item._Id )	
	end
	
	SafeCall( item.OnRemove, item )
	
	if Shared then
		umsg.End()
	end

end

hook.Add("PlayerDisconnected", "RemovePlayerEnchments", function( ply )
	
	if !ply._Enchantments then
		return
	end
	
	CallPlayerDeath( ply )
	
	for _, v in pairs( ply._Enchantments ) do
		if v:IsValid() then
			v:Destroy()
		end
	end
	
	for _, enchant in pairs( AllSharedItems ) do
		
		for k, v in pairs( enchant._PlayersToSend ) do
			
			if enchant == ply then
				enchant._PlayersToSend[ k ] = nil
			end
			
		end

	end
	
end )

local function SendSharedToPlayer( ply )
	
	for _, v in pairs( AllSharedItems ) do
		
		if !table.HasValue( v._PlayersToSend, ply ) then
			
			table.insert( v._PlayersToSend, ply )
			v:_SendToPlayer( ply )
			
			return true, 0.1
		end

	end
	
end

hook.Add("PlayerInitialSpawn", "SendEnchentments", function( ply )
	
	ClientNetwork.AddPacket( ply, "SendEnchentments", SendSharedToPlayer )
	
end )