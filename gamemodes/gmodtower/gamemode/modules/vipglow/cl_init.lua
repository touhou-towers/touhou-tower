
-----------------------------------------------------
include( "shared.lua" )
include( "sh_player.lua" )

CreateConVar( "cl_playerglowcolor", "0.24 0.34 0.41", { FCVAR_ARCHIVE, FCVAR_USERINFO }, "The value is a Vector - so between 0-1 - not between 0-255" )

//local VIPColor = Color( 163, 73, 164 )
local haloVIP = CreateClientConVar( "gmt_vipglow", 1, true, false )
local VIPHalos = {}
net.Receive("CLPlayerThink", function()
	local ply = net.ReadEntity()
	CheckVIPHalos(ply)
end)
function CheckVIPHalos(ply)

	if !IsLobby then return end
	if !haloVIP:GetBool() then return end
	VIPHalos = {}

	--for _, ply2 in pairs( GTowerLocation.GetPlayersInLocation( ply.GLocation ) ) do
	for _, ply2 in pairs(player.GetAll()) do		if ply2 != LocalPlayer() then
			if LocalPlayer().GLocation != ply2.GLocation then continue end
		end

		if !ply2:IsPlayer() || !ply2:IsVIP() then continue end
		--if ply2:IsTransparent() or ply2:IsNoDrawAll() then continue end

		if IsValid( ply2 ) and ply2:Alive() and ply2:GetColor().a == 255 and ply2:GetGlowColor() then

			local color = ply2:GetGlowColor() * 255

			-- Update instantly for client
			if CLIENT and ply2 == LocalPlayer() then
				color = Vector( GetConVar("cl_playerglowcolor"):GetString() ) * 255
			end

			local objects = {}

			-- Support driving object glow
			local ent = ply2.PoolTube
			if IsValid( ent ) then
				table.insert( objects, ent )
			elseif IsValid( ply2.GolfBall ) then

				table.insert( objects, ply2.GolfBall )

			else
			

				-- Player is not using a drivable
				table.insert( objects, ply2 )

				// Gather their hats and stuff
				if ply2.CosmeticEquipment then
					table.Add( objects, ply2.CosmeticEquipment )
				end

			end

			local halodata = {
				color = color,
				objects = objects
			}
			table.insert( VIPHalos, halodata )

		end

	end

end

hook.Add( "PreDrawHalos", "VIPHalos", function()

	if !IsLobby then return end
	if !haloVIP:GetBool() then return end
	if !VIPHalos then return end

	for id, halodata in pairs( VIPHalos ) do

		local color = halodata.color
		halo.Add( halodata.objects, Color( color.r, color.g, color.b, 255 ), 10, 10, 1 )

	end

end )
