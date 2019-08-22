
EFFECT.SplashMat = Material("effects/splash4")

local SPREAD = 14
local POWER = 3


/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
local function randomAngleAmt(ang,amt)
local arc = ang
arc:RotateAroundAxis(arc:Up(),math.random(-amt,amt))
arc:RotateAroundAxis(arc:Forward(),math.random(-amt,amt))
arc:RotateAroundAxis(arc:Right(),math.random(-amt,amt))
return arc
end

function EFFECT:Init( data )

self.Normal = data:GetNormal()
self.Delay = .5
self.RunTime = CurTime() + .8
self.Spread = data:GetRadius()
self.Power= data:GetScale()

// Keep the start and end pos - we're going to interpolate between them
local Pos = data:GetOrigin()
local Dist = Pos:Distance( EyePos() )

local SizeMul = Dist / 1024

local NumParticles = 0

local emitter = ParticleEmitter( Pos )
for i=0, 12 do
self:DoParticle(emitter,Pos)
self:DoParticle2(emitter,Pos)
end

emitter:Finish()


end

function EFFECT:DoParticle2(emitter, Pos)
local vPos = Pos
local particle = emitter:Add( "effects/splash4", vPos )
if (particle) then

particle.vPos = vPos
particle.vOffset = vOffset
particle.Player = Player
particle:SetVelocity(randomAngleAmt(self.Normal:Angle(),self.Spread):Forward()*(math.Rand(120,500)*(self.Power/1.3)))
particle:SetLifeTime( 0 )
particle:SetDieTime( math.Rand( 0.2, 0.6 ) )
particle:SetStartAlpha( math.Rand( 180, 255 ) )
particle:SetEndAlpha( 0 )

particle:SetStartLength(110)
particle:SetEndLength(150)

particle.sizage = math.random(8,10)/1.5
particle:SetStartSize( particle.sizage )
particle:SetEndSize( 70 )
particle:SetRoll( math.Rand(0, 360) )
particle:SetRollDelta( math.Rand(-10,10) )
particle.lastPos = particle:GetPos()
particle:SetColor(255,255,255)

end

end

function EFFECT:DoParticle(emitter, Pos)
local vPos = Pos
local particle = emitter:Add( "effects/splash4", vPos )
if (particle) then

particle.vPos = vPos
particle.vOffset = vOffset
particle.Player = Player
particle:SetVelocity(randomAngleAmt(self.Normal:Angle(),self.Spread):Forward()*(math.Rand(120,500)*self.Power))
particle:SetLifeTime( 0 )
particle:SetDieTime( math.Rand( 5.2, 8.0 )/1.8 )
particle:SetStartAlpha( math.Rand( 80, 155 ) )
particle:SetEndAlpha( 0 )
particle.sizage = math.random(8,10)*2
particle:SetStartSize( particle.sizage )
particle:SetEndSize( 70 )
particle:SetRoll( math.Rand(0, 360) )
particle:SetRollDelta( math.Rand(-10,10) )
particle.lastPos = particle:GetPos()
particle:SetColor(255,255,255)
particle.sTime = CurTime()

local function collided( particle, HitPos, Normal )
particle:SetAngleVelocity(Angle(0, 0, 0))
particle:SetRollDelta( 0 )

local Ang = Normal:Angle()
Ang:RotateAroundAxis(Normal, particle:GetAngles().y)
particle:SetAngles(Ang)
particle:SetLifeTime(0)
particle:SetDieTime(0.7)
particle:SetVelocity(Vector(0, 0, 0))
particle:SetGravity(Vector(0, 0, 0))
end

particle:SetCollideCallback( collided )
particle:SetAirResistance( math.Rand( 6, 18 ) )
particle:SetGravity( Vector( 0, 0, math.random(-400,-300) ) )
particle:SetCollide( true )
particle:SetBounce( 0 )

end

end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

// Die instantly
return false

end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

// Do nothing - this effect is only used to spawn the particles in Init

end