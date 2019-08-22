ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:StartTouch( ply )
	if !ply:IsPlayer() || !IsValid(ply) then return end

  local kart = ply:GetKart()

  if !IsValid(kart) then return end

	local point = checkpoints.Points[ math.Clamp( ply:GetCheckpoint(), 1, #checkpoints.Points ) ]
	if !point then return end

	for i=point.id-4, point.id do
		ply.PassedPoints[i] = true
	end

	local ang = point.ang
	local pos = point.pos + ( ang:Up() * -120 )

	// Fade out...
	PostEvent( ply, "fadeon" )
	local ForwardVel = 0 -- Used to save our velocity

	timer.Simple( .85, function()
		if IsValid( ply ) && IsValid( kart ) then
			local KartPhys = kart:GetPhysicsObject()
			ForwardVel = KartPhys:GetAngles():Forward():Dot( KartPhys:GetVelocity() ) -- Store our vel

			ply:SpawnKart( pos, ang, true )
			PostEvent( ply, "fadeoff" )

		end
	end )

	// Boost!!!
	timer.Simple( 1, function()
		if IsValid( ply ) then
			local kart = ply:GetKart()
			if IsValid( kart ) then
			   kart:Boost(2,0.5)
			end
		end
	end )
end
