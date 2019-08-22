function EFFECT:Init( data )
	local low = data:GetOrigin()
	local high = data:GetOrigin() + Vector( 25, 25, 25 )
	local num = 50
		
	local emitter = ParticleEmitter( low )
	for i = 0, num do
		local pos = Vector( math.Rand( low.x, high.x ), math.Rand( low.y, high.y ), math.Rand( low.z, high.z ) )

		local particle = emitter:Add( "effects/yellowflare", pos )
		if particle then
			particle:SetVelocity( Vector(0,0,0) )
			particle:SetColor( 150, 0, 255 )
			particle:SetDieTime( math.Rand( 2.0, 4.0 ) )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand( 3, 6 ) )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand( -360, 360 ) )
			particle:SetRollDelta( math.Rand( -50, 50 ) )
		
			particle:SetAirResistance( math.random( 50, 100 ) )
			particle:SetGravity( Vector( 0, 0, math.random( -100, -50 ) ) )
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )
		end
	end
	emitter:Finish()

	local emitter2 = ParticleEmitter( self:GetPos() )
	local particle = emitter2:Add( "effects/strider_muzzle", self:GetPos() )
	if particle then
		particle:SetVelocity( Vector( 0, 0, 0 ) )
		particle:SetDieTime( 1.5 )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 100 )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.random( -360, 360 ) )
		particle:SetRollDelta( math.random( -200, 200 ) )
		particle:SetColor( 200, 200, 255 )
	end	
	emitter2:Finish()
	
	local dlight = DynamicLight( self.Entity:EntIndex() )
	if dlight then
		dlight.Pos = self.Entity:GetPos()
		dlight.r = 50
		dlight.g = 50
		dlight.b = 255
		dlight.Brightness = 4
		dlight.Decay = 2048
		dlight.size = 1024
		dlight.DieTime = CurTime() + 2
	end
end

function EFFECT:Think( ) return false end
function EFFECT:Render() end