include( "shared.lua" )
ENT.Color = Color( 255, 255, 255, 200 )
ENT.SpriteMat = Material( "sprites/powerup_effects" )
ENT.SpriteSize = 50
ENT.SpriteOffset = Vector( 0, 0, 0 )
ENT.ProgressCircleOffset = 10
ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:Initialize()
	timer.Simple( .1, function()
		if IsValid( self ) then
			self.Pos = self:GetPos() - Vector( 0, 0, 38 )
			// Offset the spawn down
			self.Offset = 150
			self:SetPos( self.Pos - Vector( 0, 0, self.Offset ) )
			// Store this position and calculate how much to move it up
			self.MoveUnits = self.Offset * .25
			self.EndPos = self.Pos.z + self.MoveUnits
			self.Emitter = ParticleEmitter( self.Pos )
			self.RemoveTime = CurTime() + self.RemoveDelay
		end
	end )
end
function ENT:Draw()
	self:DrawModel()
	if !self.Pos then return end
	if self.SpriteSize > 0 then
		render.SetMaterial( self.SpriteMat )
		render.DrawSprite( self:GetPos() + self.SpriteOffset, self.SpriteSize, self.SpriteSize, self.Color )
	end
	GAMEMODE:DrawWorldPowerup( self, self.RemoveTime, self.RemoveDelay, self.ProgressCircleOffset )
end
function ENT:OnRemove()
	if IsValid( self.Emitter ) then
	
		self.Emitter:Finish()
		self.Emitter = nil
	end
end
function ENT:Think()
	if !self.Pos then return end
	//Move it up until the end.
	if self.Pos.z < self.EndPos then
		self.Pos.z = self.Pos.z + self.MoveUnits * FrameTime()
		self:ParticleThink()
	else
		self.Emitter = nil // no smoke when it's up
	end
	self:SetPos( self.Pos )
end
function ENT:ParticleThink()
	if not self.Emitter then return end
	for i=0, 15 do
		if math.random(3) > 1 then
			local particle = self.Emitter:Add( "particles/smokey", self:GetPos() )
			if particle then
				particle:SetVelocity( VectorRand() * 40 ) 
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 1.0, 1.5 ) )
				particle:SetStartAlpha( math.Rand( 5, 80 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 5, 10) )
				particle:SetEndSize( math.random( 8, 30 ) )
				local dark = math.Rand( 100, 200 )
				particle:SetColor( dark, dark, dark )
				particle:SetAirResistance( 50 )
				particle:SetGravity( Vector( 0, 0, math.random( -50, 50 ) ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.2 )
				
			end
		end
	end
end