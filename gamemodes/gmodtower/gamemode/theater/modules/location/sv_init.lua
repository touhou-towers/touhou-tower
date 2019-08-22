
module( "Location", package.seeall )

-- Prevent sending clients a theater video too early
local DelayThinkSeconds = 3

hook.Add( "PlayerThink", "LocationThink", function( ply )
	if not ply:IsConnected() or (ply:TimeConnected() < DelayThinkSeconds) then return end

	local oldloc = ply:GetRTLocation()
	local loc = Find( ply )
	if oldloc == loc then return end
	
	ply:SetRTLocation(loc)

	-- Player, New Location, Old Location
	hook.Call( "PlayerChangeLocation", GAMEMODE, ply, loc, oldloc )
end )

-- Lua refresh theater fix (used in development)
hook.Add("OnReloaded", "ResetPlayerLocations", function()
	timer.Simple( 0.1, function()
		for _, ply in pairs(player.GetAll()) do
			ply:SetInTheater(false)
			hook.Call( "PlayerChangeLocation", GAMEMODE, ply, ply:GetRTLocation(), 0 )
		end
	end)
end)