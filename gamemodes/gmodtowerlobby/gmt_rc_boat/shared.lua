
-----------------------------------------------------
ENT.Type 				= "anim"
ENT.Base 				= "base_anim"

ENT.PrintName			= "RC Boat"

ENT.Spawnable			= true
ENT.AdminSpawnable		= true
ENT.RenderGroup 		= RENDERGROUP_OPAQUE

ENT.Model				= Model( "models/gmod_tower/rcboat.mdl")

hook.Add( "Move", "MoveBoat", function( ply, movedata )

  local novel = Vector(0,0,0)

	if ply:GetNWBool("DrivingBoat") then

		movedata:SetForwardSpeed( 0 )
		movedata:SetSideSpeed( 0 )
		movedata:SetVelocity( novel )
		if SERVER then ply:SetGroundEntity( NULL )

		local boat = ply:GetRCBoat()

		local offset = Vector(0,0,25)
		local current = LerpVector( 0.05, ply:GetPos(), boat:GetPos() - offset + (ply:EyeAngles():Forward() * -100) )

		if IsValid( boat ) then
			movedata:SetOrigin( current )
		end

		return true
    end

	end

end )
