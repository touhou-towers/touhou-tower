
include('shared.lua')

local matLight 		= Material( "sprites/light_ignorez" )

function ENT:Initialize()
	self.Color = Color( 255, 255, 255, 255 )
	
	self.Emitter = ParticleEmitter( self.Entity:GetPos() )
	self.PixVis = util.GetPixelVisibleHandle()

	self.Red = 0
	self.Green = 0
	self.Blue = 0

	local dice = math.random(1,3)

	if dice == 1 then
		self.Red = 255
	elseif dice == 2 then
		self.Blue = 255
	else
		self.Red = 255
		self.Green = 255
		self.Blue = 255
	end	
end

function ENT:OnRemove()
	if ( self.Emitter ) then
		self.Emitter = nil
	end
end

function ENT:Think()
	local Gravity = Vector( 0, 0, -10 )
	local Velocity = self:GetVelocity()
		
	if ( self.Emitter ) then
			self.LastParticlePos = self.LastParticlePos or self:GetPos()
			local vDist = self:GetPos() - self.LastParticlePos
			local Length = vDist:Length()
			local vNorm = vDist:GetNormalized()
			
			for i=0, Length, 8 do
				self.LastParticlePos = self.LastParticlePos + vNorm * 8
				self.ParticlesSpawned = self.ParticlesSpawned or 1
				self.ParticlesSpawned = self.ParticlesSpawned + 1
				
				if math.random(3) > 1 then
					local particle = self.Emitter:Add( "particles/smokey", self.LastParticlePos ) 
					particle:SetVelocity( VectorRand() * 40 ) 
					particle:SetLifeTime( 0 ) 
					particle:SetDieTime( math.Rand(1.0,1.5) ) 
					particle:SetStartAlpha( math.Rand(150,200) ) 
					particle:SetEndAlpha( 0 ) 
					particle:SetStartSize( math.random(5,10) ) 
					particle:SetEndSize( math.random(20,50) ) 
					particle:SetColor( self.Red,self.Green,self.Blue ) 
					particle:SetAirResistance( 50 )
					particle:SetGravity( Vector( 0, 0, math.random(-50,50) ) )
					particle:SetCollide( true )
					particle:SetBounce( 0.2 )
				end
					
				if math.random(3) == 3 then
					local particle = self.Emitter:Add( "effects/muzzleflash"..math.random(1,4), self.LastParticlePos )
					particle:SetVelocity( VectorRand() * 30 + Vector(0,0,20) ) 
					particle:SetLifeTime( 0 ) 
					particle:SetDieTime( math.Rand(0.1,0.2) ) 
					particle:SetStartAlpha( 255 ) 
					particle:SetEndAlpha( 0 ) 
					particle:SetStartSize( math.random(6,12) ) 
					particle:SetEndSize( 1 )
					particle:SetColor( math.Rand( 150, 255 ), math.Rand( 100, 150 ), 100 )
			
					particle:SetAirResistance( 50 )
				end 
				if ( self.ParticlesSpawned > 8 ) then
					self.Emitter:Finish()
					self.Emitter = ParticleEmitter( self.Entity:GetPos() )
					self.ParticlesSpawned = 0
				end
			end
	end
end

g_RPGGlares = {}
function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:DrawTranslucent()
	local Pos = self.Entity:GetPos()
	
	local Visibile	= util.PixelVisible( Pos, 8, self.PixVis )
	if ( !Visibile ) then return end
	if ( Visibile == 0 ) then return end
	
	local Visibile = 1
	
	self.Visibility = Visibile
	table.insert( g_RPGGlares, self )
end

function ENT:RenderGlare()
	local Pos = self.Entity:GetPos()
	local Dist = math.Clamp( Pos:Distance( EyePos() ) / 2048, 0, 1 )
	local Visibile	= self.Visibility
	
	local Col = Color( 0, 155, 255, Visibile * 255 )
	
	local Size = 1024 * Dist
	
		Col.r = 255
		Col.g = 100 + math.Rand( 0, 100 )
		Col.b = 0
	
	render.SetMaterial( matLight )
	
	render.DrawSprite( Pos, Size, Size, Col, math.Rand( 0, 360 ) )
	render.DrawSprite( Pos, 16, 16, Color(255, 255, 255, Visibile*255) )
	render.DrawSprite( Pos, 64, 64, Color(255, 255, 255, Visibile*255))
end

local function RenderGrenadeGlares()
	for k, v in ipairs( g_RPGGlares ) do
		v:RenderGlare()
	end

	g_RPGGlares = {}
end

hook.Add( "PostDrawTranslucent", "RenderRPGGlares", RenderGrenadeGlares )