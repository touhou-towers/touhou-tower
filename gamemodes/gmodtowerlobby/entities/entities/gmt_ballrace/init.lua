AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_choose.lua" )

include("cl_choose.lua")
include("shared.lua")

function ENT:SphereInit( r )

	self:PhysicsInitSphere( r )

	local phys = self:GetPhysicsObjectNum( 0 )
	phys:SetMass( 50 )
	phys:SetDamping( 0.05, 1 )
	phys:SetBuoyancyRatio( 0.5 )

	self:StartMotionController()

end

function ENT:Initialize()

	self.radius = 38.5
	self:SphereInit( self.radius )
	self:SetModel( self.Model )
	self:SetSkin( math.random( 1, 6 ) )


	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	local eff = EffectData()
	eff:SetOrigin( self:GetPos() )
	util.Effect( "confetti", eff )

	timer.Simple( 0.1, self.SetupBall, self )

	self.ResetPlayer = CurTime()
	self.CheckResetTime = 0.25

end

function ENT:SetupBall()

	if !IsValid( self ) then return end

	local owner = self:GetOwner()

	if IsValid( owner.Shield ) then

		owner.Shield:Remove()
		owner.Shield = nil

		owner:EmitSound( "ambient/energy/powerdown2.wav", 80, 100 )

	end

	if IsValid( owner.StealthBox ) then

		owner.StealthBox:Remove()
		owner.StealthBox = nil

	end

	if IsValid( owner ) then

		owner.BallRaceBall = self

		owner:SendLua([[RunConsoleCommand('gmt_setball',']] .. (owner._PlyChoosenBall or 1) ..[[')]])

		/*umsg.Start( "GTThird", owner )
			umsg.Bool( true )
		umsg.End()*/

		local BallRacerBalls = {}
		BallRacerBalls[1] = "models/gmod_tower/ball.mdl"
		BallRacerBalls[2] = "models/gmod_tower/cubeball.mdl"
		BallRacerBalls[3] = "models/gmod_tower/icosahedron.mdl"
		BallRacerBalls[4] = "models/gmod_tower/catball.mdl"
		BallRacerBalls[8] = "models/gmod_tower/ball_soccer.mdl"
		BallRacerBalls[7] = "models/gmod_tower/ball_geo.mdl"
		BallRacerBalls[6] = "models/gmod_tower/ball_bomb.mdl"
		BallRacerBalls[9] = "models/gmod_tower/ball_spiked.mdl"
		BallRacerBalls[5] = "models/gmod_tower/ballion.mdl"

		if owner._PlyChoosenBall then
			print(owner._PlyChoosenBall)
			self:SetModel(BallRacerBalls[owner._PlyChoosenBall])
		end

	end

end

function ENT:Think()

	self:GetPhysicsObject():Wake()

	local owner = self:GetOwner()

	if !IsValid( owner ) || !owner:Alive() then
		self:Remove()
		return
	else
		if CurTime() > self.ResetPlayer then

			owner:SetColor( Color(0,0,0,0) )
			owner:SetNoDraw(true)
			owner:SetNotSolid( true )
			owner:SetMoveType( MOVETYPE_NOCLIP )

			local wep = owner:GetActiveWeapon()
			if IsValid( wep ) then
				owner:StripWeapon( wep:GetClass() )
			end

			self.ResetPlayer = CurTime() + self.CheckResetTime
		end
	end

	if !IsValid( owner.BallRaceBall ) then
		self:SetupBall( owner )
	end

end

function ENT:PhysicsCollide( data, physobj )

	if data.Speed > 100 && data.DeltaTime >= 1 then
		local edata = EffectData()
		edata:SetOrigin(data.HitPos)
		edata:SetNormal(data.HitNormal * -1)
		util.Effect("ball_hit", edata)
	end

end

function ENT:PhysicsSimulate( phys, deltatime )

	local ply = self:GetOwner()

	if !IsValid(ply) then return SIM_NOTHING end

	local vMove = Vector(0,0,0)
	local vAngle = Vector(0,0,0)
	local aEyes = ply:EyeAngles()

	aEyes.p = 0

	local mass = phys:GetMass()
	local velocity = phys:GetVelocity()
	local anglevel = phys:GetAngleVelocity()

	if ( ply:KeyDown( IN_FORWARD ) ) then vMove = vMove + aEyes:Forward() end
	if ( ply:KeyDown( IN_BACK) ) then vMove = vMove - aEyes:Forward() end
	if ( ply:KeyDown( IN_MOVELEFT ) ) then vMove = vMove - aEyes:Right() end
	if ( ply:KeyDown( IN_MOVERIGHT ) ) then vMove = vMove + aEyes:Right() end

	local traceData = {
			start = self:GetPos(),
			endpos = self:GetPos() + Vector( 0, 0, -500 ),
			filter = { self, ply },
			mask = MASK_NPCWORLDSTATIC,
	}

	local trace = util.TraceLine( traceData )

	if ( ply:KeyDown( IN_JUMP ) && !self.IsJumping  ) then

		if ( trace.HitWorld ) then

			local length =  self:GetPos().z - trace.HitPos.z

			if ( length < 39.5 ) then
				local ballVel = phys:GetVelocity()
				ballVel:Add( Vector( 0, 0, 250 ) )
				phys:SetVelocity( ballVel )

				self.IsJumping = true
			end

		end

	else
		self.IsJumping = false
	end


	if vMove:Length() > 0 then
		local dir = vMove:GetNormal()

		local dot = 1 - dir:Dot(velocity:GetNormal())
		local speed = 30000
		if IsValid( ply.TakeOn ) then
			speed = speed * 1.75
		end

		vMove = dir * mass * speed * deltatime

		vMove = vMove + (vMove * dot)

	elseif math.abs(velocity.z) <= 10 then

		velocity.z = 0

		local length = velocity:Length()
		velocity:Normalize()

		vMove = velocity * -length * 200 * (1 - deltatime)
	end

	return vAngle, vMove, SIM_GLOBAL_FORCE

end

function ENT:OnRemove()

	local owner = self:GetOwner()

	if IsValid( owner ) then

		owner:SetColor( Color(255, 255, 255, 255) )
		owner:SetNoDraw(false)
		owner:SetNotSolid( false )
		owner:SetMoveType( MOVETYPE_WALK )

		owner.BallRaceBall = nil


	end

end

hook.Add("GTowerPhysgunPickup", "DisableBallPickupPhys", function(pl, ent)

	if pl:IsAdmin() then return true end // because admins are badasses

	if IsValid( ent ) && ent:GetClass() == "gmt_ballrace" then return false end

	return true
end )

hook.Add("GravGunPickupAllowed", "DisableBallPickupGrav", function( pl, ent )

	if pl:IsAdmin() then return true end

	if IsValid( ent ) && ent:GetClass() == "gmt_ballrace" then return false end

	return true

end )

hook.Add("GravGunPunt", "DisableBallGravPunt", function( pl, ent )

	if pl:IsAdmin() then return true end

	if IsValid( ent ) && ent:GetClass() == "gmt_ballrace" then return false end

	return true
end )

/*
hook.Add("Think", "DisableBallGravPull", function( ply )

	for _, ply in ipairs( player.GetAll() ) do

		if !IsValid( ply ) || !ply:Alive() then return end

		local wep = ply:GetActiveWeapon()
		if !IsValid( wep ) || wep:GetClass() != "weapon_physcannon" then return end

		//if ply:KeyPressed( IN_ATTACK2 ) || ply:KeyDown( IN_ATTACK2 ) || ply:KeyReleased( IN_ATTACK2 ) then

			local tr = ply:GetEyeTrace()
			if IsValid( tr.Entity ) && tr.Entity:GetClass() == "gmt_ballrace" then

				ply:StripWeapon( wep:GetClass() )

			end

		//end

	end

end )*/
