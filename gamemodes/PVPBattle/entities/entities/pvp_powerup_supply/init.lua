AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.ActiveTime = 1

function ENT:PowerUpOn( ply )
	ply:GiveAmmo( 54, "SMG1", true )
	ply:GiveAmmo( 24, "357", true )
	ply:GiveAmmo( 28, "Pistol", true )
	ply:GiveAmmo( 18, "Buckshot", true )
	ply:GiveAmmo( 12, "SniperRound", true )
	ply:GiveAmmo( 50, "AR2", true )
	ply:GiveAmmo( 4, "RPG_Round", true )
	ply:GiveAmmo( 1, "SMG1_Grenade", true )
	ply:GiveAmmo( 2, "slam", true )

	if ply:Health() < 100 then
		if ply:Health() < 10 then
			ply:SetAchivement( ACHIVEMENTS.PVPONTHEBRINK, 1 )
		end

		ply:SetHealth( math.min( ply:Health() + 50, 100 ) )
	end

	PostEvent( ply, "pheal" )
end

function ENT:PowerUpOff( ply )
end
