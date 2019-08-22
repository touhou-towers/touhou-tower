

-----------------------------------------------------
include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.SpriteMat = Material( "sprites/powerup_effects" )

function ENT:Initialize()

	self.Emitter = ParticleEmitter( self:GetPos() )
	self.Color = Color( math.random( 100, 255 ), math.random( 100, 255 ), math.random( 100, 255 ) )
	self.WooshSound = CreateSound(self, self.SoundLiftOff)
	self.WooshSound:PlayEx(0.30, math.random( 90, 110 ))
	self.WooshSound:SetSoundLevel(170)

	self.Yaw = 0
	self.GlowSize = 15
	self.MaxGlowSize = 80
	self.NextGlowIncrease = 0

	self.NextPartThink = CurTime()

end

function ENT:Draw()

	self:DrawModel()
	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self:GetPos(), self.GlowSize, self.GlowSize, self.Color )

end

function ENT:Think()

	if CurTime() >= self.NextGlowIncrease then

		self.GlowSize = self.GlowSize + 1
		self.NextGlowIncrease = CurTime() + 0.075

	end

	if self.GlowSize > self.MaxGlowSize then

		self.GlowSize = 15

	end

	if IsValid( self.Emitter ) then

		local vel = VectorRand() * math.random( 2, 3 )
		vel.z = vel.z * ( vel.z > 0 && -6 or 6 )

		for i=1, 8 do

			local particle = self.Emitter:Add( "sprites/powerup_effects", self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * 0.2 ) ) )

			if particle then

				particle:SetVelocity( vel )
				particle:SetDieTime( math.Rand( 3, 6 ) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 2, 5 ) )
				particle:SetEndSize( math.random( 10, 16 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
				particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
				particle:SetCollide( true )
				particle:SetBounce( 1 )
				particle:SetAirResistance( 50 )

			end

		end

	end

	if gmt_fireworkdlight:GetBool() == true then

		local dlight = DynamicLight( self:EntIndex() )
		if dlight then

			dlight.Pos = self:GetPos()
			dlight.r = math.random( 100, 255 )
			dlight.g = math.random( 100, 255 )
			dlight.b = math.random( 100, 255 )
			dlight.Brightness = 0.35
			dlight.Size = 512
			dlight.Decay = 512 * 2
			dlight.DieTime = CurTime() + 0.5

		end

	end

	self:NextThink( CurTime() )
	return true
end


function ENT:OnRemove()

	if IsValid( self.Emitter ) then

		self.Emitter:Finish()
		self.Emitter = nil

	end
	
	if gmt_fireworkdlight:GetBool() == true then

		local dlight = DynamicLight( self:EntIndex() )
		if dlight then

			dlight.Pos = self:GetPos()
			dlight.r = self.Color.r
			dlight.g = self.Color.g
			dlight.b = self.Color.b
			dlight.Brightness = 1
			dlight.Size = 512 * 2
			dlight.Decay = 512 * 4
			dlight.DieTime = CurTime() + 1

		end

	end

end

usermessage.Hook( "FireworkColor", function( um )

	local ent = um:ReadEntity()
	if !IsValid( ent ) then return end

	local r = um:ReadShort()
	local g = um:ReadShort()
	local b = um:ReadShort()

	ent.Color = Color( r, g, b )

end	)
