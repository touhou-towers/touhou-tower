EFFECT.Mat = Material( "effects/tool_tracer" )
local matLight 	= Material( "effects/yellowflare" )

function EFFECT:Init( data )

	self.Position = data:GetStart()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	// Keep the start and end pos - we're going to interpolate between them
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self.EndPos = data:GetOrigin()
	
	local Weapon = data:GetEntity()
	if ( IsValid( Weapon ) ) then
	
		local Owner = Weapon:GetOwner()
		if ( IsValid( Owner ) ) then
			self.Color = Color( 225, 0, 255 )
		end
	
	end

	self.Alpha = 255
	
	//Blast of plasma at the end	
	local emitter = ParticleEmitter( self.EndPos )
	for i=1,5 do
		local particle = emitter:Add( "sprites/light_glow02_add", self.EndPos )
		if (particle) then

			particle:SetVelocity( ( VectorRand() * 1 ) * math.Rand( 25, 150 )  )
			particle:SetAngleVelocity( Angle( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 1200 )
			//particle:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
				
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 1 )
				
			particle:SetStartSize( 12 )
			particle:SetEndSize( 0 )

			particle:SetColor( 180, 0, 255, 200 )

			particle:SetRoll( math.Rand(0, 360) )
			particle:SetRollDelta( math.Rand(-2, 2) )
				
			particle:SetAirResistance( 5 )

			particle:SetGravity( Vector( 0, 0, -800 ) )
			particle:SetBounce( 0.2 )
			particle:SetCollide( true )
			
		end
	end
	emitter:Finish()
end

function EFFECT:Think( )

	self.Alpha = self.Alpha - FrameTime() * 2500
	
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	if (self.Alpha < 0) then return false end
	return true

end

function EFFECT:Render()

	if ( self.Alpha < 1 ) then return end

	self.Length = (self.StartPos - self.EndPos):Length()
	local texcoord = CurTime() * -0.2

	for i = 1, 10 do
		render.SetMaterial( self.Mat )
		texcoord = texcoord + i * 0.05 * texcoord
	
		render.DrawBeam( self.StartPos, 										// Start
						self.EndPos,											// End
						i * self.Alpha * 0.025,													// Width
						texcoord,														// Start tex coord
						texcoord + (self.Length / (128 + self.Alpha)),									// End tex coord
						self.Color )
						
		render.SetMaterial( matLight )

		render.DrawSprite( self.StartPos, i * 5, i * 5, Color( self.Color.r, self.Color.g, self.Color.b, self.Alpha ) )
		//render.DrawSprite( self.EndPos, i * 15, i * 15, Color( self.Color.r, self.Color.g, self.Color.b, self.Alpha ) )
	end
end