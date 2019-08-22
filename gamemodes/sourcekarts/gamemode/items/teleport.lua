
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Teleport"
ITEM.Model = "models/gmod_tower/sourcekarts/booster.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/teleport" )
ITEM.Entity = nil
ITEM.MaxUses = 1

ITEM.Battle = false
ITEM.Chance = items.RARE
ITEM.MaxPos = 4

if SERVER then
	util.AddNetworkString( "SKTeleport" )
end

function ITEM:Start( ply, kart )

	local point = checkpoints.Points[ math.Clamp( ply:GetCheckpoint() + 4, 1, #checkpoints.Points ) ]
	if !point then return end

	for i=point.id-4, point.id do
		ply.PassedPoints[i] = true
	end

	local ang = point.ang
	local pos = point.pos + ( ang:Up() * -120 )

	kart:EmitSound( "ambient/levels/labs/teleport_mechanism_windup1.wav" )
	ply:EmitSound( SOUND_TELEPORT )

	net.Start("SKTeleport")
		net.WriteInt( 1, 2 )
	net.Send( ply )

	// Fade out...
	PostEvent( ply, "teleon" )
	kart:Boost( 2, 2 )
	local ForwardVel = 0 -- Used to save our velocity

	timer.Simple( .85, function()
		if IsValid( ply ) && IsValid( kart ) then
			local KartPhys = kart:GetPhysicsObject()
			ForwardVel = KartPhys:GetAngles():Forward():Dot( KartPhys:GetVelocity() ) -- Store our vel

			ply:SpawnKart( pos, ang, true )
			PostEvent( ply, "teleoff" )

			net.Start("SKTeleport")
				net.WriteInt( 0, 2 )
			net.Send( ply )
		end
	end )

	// Boost!!!
	timer.Simple( 1, function()
		if IsValid( ply ) then
			local kart = ply:GetKart()
			if IsValid( kart ) then
				local KartPhys = kart:GetPhysicsObject()
				KartPhys:SetVelocity( KartPhys:GetAngles():Forward() * ForwardVel ) -- PUUUSH
			end
			ply:AddAchivement( ACHIVEMENTS.SKTELEPORT, 1 )
		end
	end )

end

if CLIENT then

	net.Receive( "SKTeleport", function(len)
		LocalPlayer().IsTeleporting = net.ReadInt(2) == 1
	end )

end

items.Register( ITEM )
