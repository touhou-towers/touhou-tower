
-----------------------------------------------------

include("sh_player.lua")

include('shared.lua')
include("waterslide_curve.lua")
include("sh_tube_manager.lua")

// thirdperson support
if ThirdPerson then
	ThirdPerson.ExcludeEnt( "gmt_pooltube" )
	ThirdPerson.ExcludeEnt( "gmt_beachball" )
end

function ENT:Enter( ply )

	self.PlayerModel = ClientsidePlayer( ply )

	local seq = UCHAnim.GetIdleSequence( ply ) or "zombie_slump_idle_02"
	self.PlayerModel:SetSequence( seq )

	self.PlayerModel:ForceThirdPerson( true )

	ply.PoolTube = self

end

function ENT:Exit( ply )

	if IsValid( self.PlayerModel ) then
		self.PlayerModel:Remove()
		self.PlayerModel = nil
	end

	if IsValid( ply ) then
		ply.PoolTube = nil
	end

	-- Also remove the stored passenger player just in case
	if IsValid(self.Passenger) then
		self.Passenger.PoolTube = nil 
		self.Passenger = nil 
	end

end

function ENT:Draw()
	self:DrawModel()
end
function ENT:DrawTranslucent()
	local ply = self:GetOwner()

	if !IsValid(ply) then return end

	if ply == LocalPlayer() then return end

	local ang = LocalPlayer():EyeAngles()

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	pos = self:GetPos() + self:GetUp() * 80 + ang:Up() * ( math.sin( CurTime() ) * 2 )

	local dist = LocalPlayer():GetPos():Distance( self:GetPos() )
	if ( dist >= 800 ) then return end

	local opacity = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 150 )
	local name = ply:GetName()

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .5 )

		draw.DrawText( name, "ClPlayerName", 2, 2, Color( 0, 0, 0, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.DrawText( name, "ClPlayerName", 0, 0, Color( 255, 255, 255, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	cam.End3D2D()
end

function ENT:Think()

	local ply = self:GetOwner()

	if not IsValid( ply ) or not ply:Alive() then 
		self:Exit()
		return
	end

	-- Store the owner for now
	self.Passenger = ply 

	-- If we never recieved the usermessage somehow, join up anyway
	if not IsValid(ply.PoolTube) or ply.PoolTube ~= self then
		if IsValid(ply.PoolTube) then
			ply.PoolTube:Exit(ply)
		end

		self:Enter(ply)
	end

	self.IsOn = ( self:GetVelocity():Length() > 80 )
	self:DrawParticles()

	-- Since the clientmodel only sets the position, set it in think here
	if IsValid( self.PlayerModel ) then
		self.PlayerModel:Draw( self:GetPos() + self:GetUp() * 16, self:GetAngles() + Angle( -20, 0, -10 ) )
		self.PlayerModel:DrawPlayerName( self:GetPos() )
	end

end

function ENT:OnRemove()
	self:Exit(self:GetOwner())
end

function ENT:DrawParticles()

	if self.IsOn then
		if !self.Emitter then
			self.Emitter = ParticleEmitter( self:GetPos() )
		end
	else
		if IsValid( self.Emitter ) then
			self.Emitter:Finish()
			self.Emitter = nil
		end
		return
	end

	if !self.NextParticle then
		self.NextParticle = RealTime()
	end

	if RealTime() < self.NextParticle then
		return
	end

	local velocity = self:GetVelocity():Length()
	local factor = self:GetVelocity():Length() * .0025
	local vel = ( self:GetVelocity() * -1 ) / 2
	local volume = velocity * 0.0015

	// Large
	local particle = self.Emitter:Add( "effects/splash4", self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * volume ) ) + Vector( 0, 0, -10 ) )
	if particle then
		particle:SetVelocity( vel )
		particle:SetLifeTime( 0 )
		particle:SetDieTime( math.Rand( 0.2, 0.6 ) )
		particle:SetStartAlpha( math.Rand( 180, 255 ) )
		particle:SetEndAlpha( 0 )

		particle:SetStartLength( 110 * factor )
		particle:SetEndLength( 150 * factor)

		particle:SetStartSize( math.random( 8, 10 ) / 1.5  * factor )
		particle:SetEndSize( 70 * factor )
		particle:SetRoll( math.Rand( 0, 360 ) )
		particle:SetRollDelta( math.Rand( -10, 10 ) )
		particle:SetColor( 255, 255, 255 )
	end

	// Splashes
	local particle = self.Emitter:Add( "effects/splash4", self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * volume ) ) )
	if particle then
		particle:SetVelocity( vel + Vector( 0, 0, 160 * factor ) )
		particle:SetLifeTime( 0 )
		particle:SetDieTime( math.Rand( 5.2, 8.0 ) / 1.8 )
		particle:SetStartAlpha( math.Rand( 80, 155 ) )
		particle:SetEndAlpha( 0 )

		particle:SetStartSize( math.random( 8, 10 ) * 2 * factor )
		particle:SetEndSize( 70 * factor )
		particle:SetRoll( math.Rand( 0, 360 ) )
		particle:SetRollDelta( math.Rand( -10, 10 ) )
		particle:SetColor(255,255,255)

		local function collided( particle, HitPos, Normal )

			particle:SetAngleVelocity( Angle( 0, 0, 0 ) )
			particle:SetRollDelta( 0 )

			local Ang = self:GetUp():Angle()
			Ang:RotateAroundAxis( self:GetUp(), particle:GetAngles().y )
	
			particle:SetAngles( Ang )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 0.7 )
			particle:SetVelocity( Vector( 0, 0, 0 ) )
			particle:SetGravity( Vector( 0, 0, 0 ) )

		end

		particle:SetCollideCallback( collided )
		particle:SetAirResistance( math.Rand( 6, 18 ) )
		particle:SetGravity( Vector( 0, 0, math.random(-400,-300) ) )
		particle:SetCollide( true )
		particle:SetBounce( 0 )

	end

	self.NextParticle = RealTime() + 0.025

end
hook.Add("CalcView","PoolTubeCalc", function( ply, pos, angles, fov )
	if ply.PoolTube == nil then return end
	local view = {}
	
	view.origin = ply.PoolTube:GetPos() - ( angles:Forward()*100 ) + Vector(0,0,50)
	view.angles = angles
	view.fov = fov
	view.drawviewer = false
	
	return view
	
end)
usermessage.Hook( "PoolTube", function( um )

	local ent = um:ReadEntity()
	if !IsValid( ent ) then return end

	local ply = um:ReadEntity()
	if !IsValid( ply ) then return end

	local bool = um:ReadBool()

	if bool then
		ent:Enter( ply )
	else
		ent:Exit( ply )
	end

end )