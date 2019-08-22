ENT.Type 			= "anim"
ENT.Base			= "base_anim"

ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

ENT.Model				= Model("models/gmod_tower/BALL.mdl")
ENT.RollSound			= Sound("GModTower/balls/BallRoll.wav")

local novel = Vector(0,0,0)

function ENT:Initialize()
    self:SetCustomCollisionCheck( true )
end

RegisterNWTablePlayer({
	{ "BallRaceBall", Entity( 0 ), NWTYPE_ENTITY, REPL_EVERYONE },
})

hook.Add( "Move", "MoveBall", function( ply, movedata )

	if !IsValid( ply.BallRaceBall ) then return end

	movedata:SetForwardSpeed( 0 )
	movedata:SetSideSpeed( 0 )
	movedata:SetVelocity( novel )
	if SERVER then ply:SetGroundEntity( NULL ) end

	local ball = ply.BallRaceBall
	if IsValid( ball ) then
		movedata:SetOrigin( ball:GetPos() )
	end

	return true

end )

hook.Add( "PlayerFootstep", "PlayerFootstepBall", function( ply, pos, foot, sound, volume, rf )

	if IsValid( ply.BallRaceBall ) then

		return true

	end

end )

/*hook.Add( "ShouldCollide", "ShouldCollideBall", function( ent1, ent2 )

	if ent1:GetClass() == "gmt_ballrace" && string.sub( ent2:GetClass(), 1, 9 ) == "func_door" then
		return false
	end

	if ent1:GetClass() == "gmt_ballrace" && ent2:GetClass() == "gmt_teleporter" then return false end

	return true

end )*/
