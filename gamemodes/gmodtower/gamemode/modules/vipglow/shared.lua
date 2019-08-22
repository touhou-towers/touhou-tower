
-----------------------------------------------------
Vip = {}

include( "sh_player.lua" )

hook.Add( "PlayerThink", "VIPHaloColorCheck", function( ply )

	if !IsValid(ply) || CLIENT then return end

	local color = Vector( ply:GetInfo( "cl_playerglowcolor" ) ) * 255
	ply:SetNWVector( "GlowColor", color )

end)

/*plynet.Register( "Bool", "VIP" )

if IsLobby then
	plynet.Register( "Vector", "GlowColor" )
end*/
