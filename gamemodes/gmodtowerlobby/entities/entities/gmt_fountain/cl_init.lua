include('shared.lua')

function ENT:Initialize()
    self.NextParticle = CurTime()
end

function ENT:Think()

if !self.Emitter then
  self.Emitter = ParticleEmitter( self:GetPos() )
end

if CurTime() < self.NextParticle then return end

for i=0, 1 do

  local offset = Vector(0,0,10)

  local part = self.Emitter:Add( "effects/splashwake3", self:GetPos() - offset )

  if part then

    part:SetVelocity(Vector(math.random(-180, 180), math.random(-180, 180), 90):GetNormal() * 80)
    part:SetStartAlpha(100)
    part:SetEndAlpha(100)
    part:SetDieTime(15)
    part:SetLifeTime(0)
    part:SetStartSize(1)
    part:SetEndSize(1)
    part:SetRoll(math.random(0, 360))
    part:SetRollDelta(math.random(-10, 10))
    part:SetAirResistance( 100 )
    part:SetGravity(Vector(0, 0, -10))

  end
end
self.NextParticle = CurTime() + 0.05
end
