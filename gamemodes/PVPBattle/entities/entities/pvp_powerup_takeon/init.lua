AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.ActiveTime = 22

function ENT:PowerUpOn( ply )
	ply:SetMaterial( "gmod_tower/pvpbattle/aha_skin" )
	ply:SetWalkSpeed( 650 )
	ply:SetRunSpeed( 550 )
	PostEvent( ply, "putakeon_on" )

	ply.IsTakeOn = true
end

function ENT:PowerUpOff( ply )
	ply:SetMaterial( "" )
	ply:SetWalkSpeed( 450 )
	ply:SetRunSpeed( 450 )
	PostEvent( ply, "putakeon_off" )

	ply.IsTakeOn = false
end
