
-----------------------------------------------------
include('shared.lua')

local model_offset = Vector(0,0,35)
surface.CreateFont( "BoatPlayerName", { font = "Oswald", size = 50, weight = 800 } )

function ENT:Think()

	self.IsOn = ( self:GetVelocity():Length() > 80 )
	self:DrawParticles()

end

function ENT:Initialize()
    self.csModel = ClientsideModel(self.Model)
end

function ENT:Draw()

	local ply = self:GetOwner()
	self.csModel:SetPos(self:GetPos())
	self.csModel:DrawModel()
	if !IsValid( ply ) then return end

	self.csModel:SetAngles(Angle( 0, ply:EyeAngles().y + 180 ,0 ))

	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + Vector( 0, 0, 35 ) + ang:Up() * ( math.sin( CurTime() ) * 2 )

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	local dist = LocalPlayer():GetPos():Distance( ply:GetPos() )
	if ( dist >= 800 ) then return end

	local opacity = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 150 )
	local name = ply:GetName()

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .5 )

		draw.DrawText( name, "BoatPlayerName", 2, 2, Color( 0, 0, 0, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.DrawText( name, "BoatPlayerName", 0, 0, Color( 255, 255, 255, opacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	cam.End3D2D()

end

function ENT:DrawParticles()

	if !IsValid(self) then return end

	if self.IsOn then
		if not self.Emitter then
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
		self.NextParticle = CurTime()
	end

	if CurTime() < self.NextParticle then
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
		particle:SetGravity( Vector( 0, 0, math.random(50,150) ) )
	end

	// Splashes
	local particle = self.Emitter:Add( "effects/splash4", self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * volume ) ) + Vector( 0, 0, -5 ) )
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
			particle:SetGravity( Vector( 0, 0, 50 ) )

		end

		particle:SetCollideCallback( collided )
		particle:SetAirResistance( math.Rand( 6, 18 ) )
		particle:SetGravity( Vector( 0, 0, math.random(-150,-300) ) )
		particle:SetCollide( true )
		particle:SetBounce( 0 )

	end

	self.NextParticle = CurTime() + 0.025

end

function ENT:OnRemove()
	self.csModel:Remove()
end
