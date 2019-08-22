
-----------------------------------------------------
include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.CenterSprite = {
	enabled = true,
	material = Material( "sprites/powerup_effects" ),
	offsetX = 0,
	offsetY = 0,
	offsetZ = 0,
	color = Color( 255, 255, 255, 255 ),
	size = 64
}

ENT.Particles = {
	rate = .005,
	amount = 10,
	material = "sprites/powerup_effects",
}

ENT.Colors = {
	Color( 255, 0, 0 ),
	Color( 0, 255, 0 ),
	Color( 0, 0, 255 ),
	Color( 0, 255, 255 ),
	Color( 255, 0, 255 ),
	Color( 255, 255, 0 ),
}

ENT.CurrentColor = Color( 0, 0, 0 )
ENT.CurColorID = 1

function ENT:DrawParticles()

	local owner = self:GetOwner()

	local pos = self:ParticlePosition( owner ) + Vector( 0, 0, -32 )

	//local angle = Angle( SinBetween( -240, -190, CurTime() * 2 ), 0, 0 )
	local angle = Angle( 0, SinBetween( -240, -120, CurTime() * 2 ), 0 )
	//local angle = Angle( 0, SinBetween( -360, 360, CurTime() * 2 ), 0 )
	//local angle = Angle( 0, 0, SinBetween( -360, 360, CurTime() * 2 ) )

	local pitch = angle.p
	local yaw = angle.y

	local color = colorutil.Smooth( .5 )

	for i=1, self.Particles.amount do

		//local flare = Vector( 0, math.random( -10, 10 ), 0 )
		//local flare = Vector( 0, 0, math.random( -25, 25 ) )
		local flare = Vector( CosBetween( -16, 16, CurTime() * 16 ), SinBetween( -16, 16, CurTime() * 16 ), 0 )

		local particle = self.Emitter:Add( self.Particles.material, pos + flare )
		if particle then

			//particle:SetVelocity( ( angle:Forward() * 50 ) )
			particle:SetVelocity( ( angle:Up() * 50 ) )
			//particle:SetDieTime( math.Rand( 2, 6 ) )
			particle:SetDieTime( math.Rand( .75, 2 ) )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )

			particle:SetStartSize( math.random( 2, 16 ) )
			particle:SetEndSize( 0 )

			particle:SetStartLength( 0 )
			particle:SetEndLength( 60 )

			//particle:SetGravity( ( angle:Forward() * 50 * -1 ) /*- ( flare / 3 )*/ )
			particle:SetGravity( ( angle:Up() * 25 * -1 ) - ( flare / 3 ) )

			particle:SetColor( color.r, color.g, color.b, 255 )

			//particle:SetCollide( true )
			//particle:SetBounce( 1 )

		end

	end

	/*local vel = VectorRand() * math.random( 4, 6 )
	particle:SetVelocity( vel )

	particle:SetDieTime( math.Rand( .75, 2 ) )

	particle:SetStartAlpha( 100 )
	particle:SetEndAlpha( 0 )

	particle:SetStartSize( math.random( 8, 16 ) )
	particle:SetEndSize( 0 )

	particle:SetRoll( math.Rand( 0, 360 ) )
	particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )

	particle:SetColor( 255, 255, 255 )
	particle:SetCollide( true )*/

end

function ENT:ParticlePosition( owner, bound )

	local pos = owner:GetPos() + Vector(0,0,50)
	if bound then
		pos = pos + ( VectorRand() * ( self:BoundingRadius() * ( bound or .35 ) ) )
	end

	return pos

end

function ENT:GetNextColorID()

	if self.CurColorID > ( #self.Colors - 1 ) then
		self.CurcolorID = 1
		return self.CurcolorID
	end

	return self.CurColorID + 1

end

function ENT:GetTimedColor()

	local nextColor = self.Colors[ self:GetNextColorID() ]

	if !( math.abs( self.CurrentColor.r ) >= math.abs( nextColor.r ) &&
	   math.abs( self.CurrentColor.g ) >= math.abs( nextColor.g ) &&
	   math.abs( self.CurrentColor.b ) >= math.abs( nextColor.b ) ) then

		self.CurrentColor.r = math.Approach( self.CurrentColor.r, nextColor.r, FrameTime() * 30 )
		self.CurrentColor.g = math.Approach( self.CurrentColor.g, nextColor.g, FrameTime() * 30 )
		self.CurrentColor.b = math.Approach( self.CurrentColor.b, nextColor.b, FrameTime() * 30 )

	else
		self.CurColorID = self:GetNextColorID()
	end

	return self.CurrentColor

end

function ENT:Initialize()

	self.NextParticle = CurTime()
	self.Emitter = ParticleEmitter( self:GetPos() )

end

function ENT:TranslateOffset( vec )
	return ( self:GetForward() * vec.x ) + ( self:GetRight() * -vec.y ) + ( self:GetUp() * vec.z )
end

function ENT:Draw()

	--if !EnableParticles:GetBool() then return end

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	if self.CenterSprite.enabled then

		local pos = owner:GetPos() + Vector(0,0,50) + self:TranslateOffset( Vector( offsetX, offsetY, offsetZ ) )
		local color = self.CenterSprite.color
		local size = self.CenterSprite.size

		render.SetMaterial( self.CenterSprite.material )
		render.DrawSprite( pos, size, size, Color( color.r, color.g, color.b, color.a ) )

	end

end

function ENT:Think()

	if !EnableParticles:GetBool() then
		self:RemoveEmitter()
		return
	end

	local owner = self:GetOwner()
	if !IsValid( owner ) || self:GetColor().a == 0 then return end

	if LocalPlayer() == owner && !LocalPlayer().ThirdPerson then return end

	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	if CurTime() > self.NextParticle then

		self.NextParticle = CurTime() + self.Particles.rate

		self:DrawParticles()

	end

end

function ENT:OnRemove()

	self:RemoveEmitter()

end

function ENT:RemoveEmitter()

	if IsValid( self.Emitter ) then
		self.Emitter:Finish()
		self.Emitter = nil
	end

end
