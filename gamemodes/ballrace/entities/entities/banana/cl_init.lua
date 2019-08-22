include('shared.lua')

ENT.Size		= 2.5
ENT.BananaMat 	= Material( "sprites/banana" )

function ENT:Initialize()

	timer.Simple( .1, function()

		if IsValid( self ) then

			self:SetModelScale( self.Size, 0 )

			self.OriginPos = self:GetPos()
			self.TimeOffset = math.Rand( 0, 3.14 )

			self.NextParticle = CurTime()
			self.Emitter = ParticleEmitter( self:GetPos() )

			self.Radius = 24
			self.EmitOffset = 0
			self.EPos = self:GetPos() + Vector( 0, 0, 40 )

		end

	end )

end

function ENT:Draw()

	if !self.OriginPos || !self.TimeOffset then return end

	local rot = self:GetAngles()
	rot.y = rot.y + 90 * FrameTime()
	self:SetAngles(rot)

	local SinTime = math.sin( CurTime() + self.TimeOffset )
	self:SetPos( self.OriginPos + Vector(0,0, 40 + SinTime * 4 ) )

	self:SetModelScale( self.Size, 0 )

	self:ParticleThink()
	self:DrawModel()

end

function ENT:OnRemove()
	if IsValid( self.Emitter ) then
		self.Emitter:Finish()
	end
end

// they seem to think outside the PVS
function ENT:ParticleThink()

	if CurTime() > self.NextParticle then
		local rad = math.rad(self.EmitOffset)
		local coord = self.EPos + (self.Radius * Vector(math.cos(rad), math.sin(rad), 0))

		if !IsValid(self.Emitter) then
			self.Emitter = ParticleEmitter( self:GetPos() )
		end

		local particle = self.Emitter:Add( "sprites/banana", coord )
		if ( particle ) then

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 1 )
		
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 5 )
			particle:SetEndSize( 5 )

			particle:SetColor( 255, 230, 25 )

			particle:SetAirResistance( 100 )

			local inward = (self.EPos - coord):GetNormal() * 40 + Vector(0,0,60 + self.EmitOffset/15)
			particle:SetGravity( inward )
			
			particle:SetVelocity( (inward:Angle()):Right() * 20 + Vector(0,0,10) )

			particle:SetAngleVelocity( Angle( math.Rand( -2, 2 ), math.Rand( -2, 2 ), math.Rand( -2, 2 ) ) ) 
		end

		self.EmitOffset = self.EmitOffset + 60
		if self.EmitOffset == 360 then
			self.EmitOffset = 0
		end


		self.NextParticle = CurTime() + 0.1
	end

end