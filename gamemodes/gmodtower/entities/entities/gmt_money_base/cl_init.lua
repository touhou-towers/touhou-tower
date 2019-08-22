
include("shared.lua")

ENT.LightMat = Material("sprites/pickup_light")

function ENT:Draw()
	self:DrawModel()
end


function ENT:DrawTranslucent()	
	self:Draw()
end


function ENT:Initialize()	
	self.OriginPos = self:GetPos()
	self.OriginAngles = self:GetAngles()
	
	self.NextParticle = CurTime()
	
	self.TimeOffset = math.Rand( 0, 3.14 )

	self.Emitter = ParticleEmitter( self:GetPos() )
end


function ENT:Think()
    local SinTime = math.sin(CurTime() + self.TimeOffset)
    
    self:SetPos( self.OriginPos + Vector(0,0, 50 +  SinTime * 5 ) ) 
    self:SetAngles( self:GetAngles() + Angle( 0, 0.5 ,0 ) )
    
    if CurTime() > self.NextParticle then
        local emitter = self.Emitter

        local pos = self:GetPos() + ( VectorRand() * ( self.Entity:BoundingRadius( ) * 0.75 ) )
        local vel = VectorRand() * 3
			
        vel.z = vel.z * ( vel.z > 0 && -3 or 3 )
			
        local particle = emitter:Add( "sprites/pickup_light", pos )
        
        if particle then
            particle:SetVelocity( vel )
            particle:SetDieTime( math.Rand( 1, 3 ) )
            particle:SetStartAlpha( 100 )
            particle:SetEndAlpha( 0 )
            particle:SetStartSize( 12 )
            particle:SetEndSize( 0 )
            particle:SetRoll( math.Rand( 0, 360 ) )
            particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
            particle:SetColor( 255, 240, 70 )
	    end
    
        self.NextParticle = CurTime() + 0.1
    end
    
end

function ENT:OnRemove()
    
    local emitter = self.Emitter

	for i=1, 10 do
	   
        local pos = self:GetPos() + ( VectorRand() * ( self.Entity:BoundingRadius( ) * 0.75 ) )
	
        local particle = emitter:Add( "sprites/pickup_light", pos )
        
        if particle  then
            particle:SetVelocity( VectorRand() * 10 )
            particle:SetDieTime( math.Rand( 1, 3 ) )
            particle:SetStartAlpha( 255 )
            particle:SetEndAlpha( 200 )
            particle:SetStartSize( 12 )
            particle:SetEndSize( 0 )
            particle:SetRoll( math.Rand( 0, 360 ) )
            particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
            particle:SetColor( 255, 240, 70 )
        end
    	
    	
    end
    
    emitter:Finish()
end 
