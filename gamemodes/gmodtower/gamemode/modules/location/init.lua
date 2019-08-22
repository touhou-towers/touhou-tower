
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("teleport.lua")


module("Location", package.seeall )

hook.Add("PlayerThink", "GTowerLocation", function(ply)

	local PlyPlace = GTowerLocation:FindPlacePos( ply:GetPos() )
	
	if PlyPlace != ply.GLocation then
		
		ply.GLastLocation = ply.GLocation
		ply.GLocation = PlyPlace
		hook.Call("Location", GAMEMODE, ply, ply.GLocation )
		
	end
	
end)

--[[ We'll fix later since there's no players anyway lol ]]

--hook.Add("PlayerCanHearPlayersVoice", "GMTBarTalk", function(listener, talker) 
--	local group = talker:GetGroup() --Maybe i should add some check if groups module turned on?
--	if group then return end
--	if (listener:Location() == 39 and talker:Location() == 39) or (listener:Location() == 40 and talker:Location() == 40) then
--		return true
--	end
--end)

function LocationRP( pos )

	local rp = RecipientFilter()
	
	for _, v in pairs( player.GetAll() ) do
	
		if v:Location() == pos then
			rp:AddPlayer( v )
		end
		
	end
	
	return rp
	
end
RP = LocationRP //Alias to get RP

local Player = FindMetaTable("Player")

if Player then
	function Player:LastLocation()
		return self._GLastLocation
	end
end