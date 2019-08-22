
-----------------------------------------------------
include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Particles = {
	rate = .1,
	amount = 1,
	material = "sprites/strider_blackball",
}

local function GetCenterPos( ent )

	if !IsValid( ent ) then return end

	if ent:IsPlayer() && !ent:Alive() && IsValid( ent:GetRagdollEntity() ) then
		ent = ent:GetRagdollEntity()
	end

	if ent:IsPlayer() and isfunction( ent.GetClientPlayerModel ) and IsValid( ent:GetClientPlayerModel() ) then
		ent = ent:GetClientPlayerModel():Get()
	end

	local Torso = ent:LookupBone( "ValveBiped.Bip01_Spine2" )

	if !Torso then return ent:GetPos() end

	local pos, ang = ent:GetBonePosition( Torso )

	if !ent:IsPlayer() then return pos end

	return pos

end

local function Fit( val, valMin, valMax, outMin, outMax )
	return ( val - valMin ) * ( outMax - outMin ) / ( valMax - valMin ) + outMin
end

function ENT:DrawParticles()

	local owner = self:GetOwner()

	local pos = GetCenterPos( owner ) + Vector( 0, 0, -5 )

	local angle = Angle( 0, SinBetween( -240, -120, CurTime() * 2 ), 0 )

	local pitch = angle.p
	local yaw = angle.y

	local color = Color(225,225,0,100)

	for i=1, self.Particles.amount do

		//local flare = Vector( 0, math.random( -10, 10 ), 0 )
		//local flare = Vector( 0, 0, math.random( -25, 25 ) )
		local flare = Vector( CosBetween( -16, 16, CurTime() * 16 ), SinBetween( -16, 16, CurTime() * 16 ), 0 )

		local particle = self.Emitter:Add( self.Particles.material, pos + flare )
		if particle then

			local rad = math.rad(0)
			--local coord = self.EPos + (self.Radius * Vector(math.cos(rad), math.sin(rad), 0))

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 1 )

			particle:SetStartAlpha( 25 )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( 8 )
			particle:SetEndSize( 0 )

			particle:SetColor( math.random(1,255), math.random(1,255), math.random(1,255) )

			particle:SetAirResistance( 100 )

			self.EPos = self:GetPos() + Vector( 0, 0, 40 )

			--local inward = (self.EPos - coord):GetNormal() * 40 + Vector(0,0,60 + self.EmitOffset/15)
			particle:SetGravity( Vector(math.random(-5,25),math.random(-5,25),25) )

			particle:SetVelocity(  Vector(math.random(-5,25),math.random(-5,25),25) )

			particle:SetAngleVelocity( Angle( math.Rand( -12, 12 ), math.Rand( -12, 12 ), math.Rand( -12, 12 ) ) )

		end

	end

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
