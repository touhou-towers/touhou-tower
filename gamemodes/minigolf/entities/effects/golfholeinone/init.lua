
-----------------------------------------------------
local matLight 	= Material( "effects/select_ring" )
local matLight2 = Material( "sprites/powerup_effects" )

function EFFECT:Init( data )

	local ent = data:GetEntity()
	if !IsValid( ent ) then return end
	self.Color = ent:GetBallColor() * 255

	//Energy Orb Decay
	self.Resize = 0
	self.Size = 0
	self.MaxSpriteSize = 256
	self.Alpha = 255

	self.Entity:SetRenderBounds( Vector() * -( self.MaxSpriteSize * 2 ), Vector() * ( self.MaxSpriteSize * 2 ) )

	self.Pos = data:GetOrigin()
	self.Norm = data:GetNormal()

	local emitter = ParticleEmitter( self.Pos )

	//Energy Debris
	for i= 0, 60 do
		local particle = emitter:Add( "sprites/powerup_effects", self.Pos )
		if particle then

			particle:SetVelocity( VectorRand():GetNormal() * math.Rand( 35, 85 ) + Vector( 0, 0, 150 ) )
			particle:SetAngleVelocity( Angle( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) ) * 1200 )
			//particle:SetAngles( Angle( math.Rand( 0, 360 ), math.Rand( 0, 360 ), math.Rand( 0, 360 ) ) )
				
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 3 )
				
			particle:SetStartSize( 8 )
			particle:SetEndSize( 0 )

			particle:SetColor( math.random( 50, 255 ), math.random( 50, 255 ), math.random( 50, 255 ) )

			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -2, 2 ) )
				
			particle:SetAirResistance( 5 )

			particle:SetGravity( Vector( 0, 0, -800 ) )
			particle:SetBounce( 0.6 )
			particle:SetCollide( true )
			
		end
	end

	//Energy Sparks
	for i = 1, 35 do

		local particle = emitter:Add( "effects/spark", self.Pos )
		if particle then
			particle:SetVelocity( VectorRand():GetNormal() * math.Rand( 35, 85 ) + Vector( 0, 0, 50 ) )
			particle:SetDieTime( math.random( .25, .5 ) )
			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 50 )
			particle:SetEndSize( 15 )
			particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
			particle:SetStartLength( 10 )
			particle:SetEndLength( 80 )
		end

	end

	emitter:Finish()


	local dlight = DynamicLight( self:EntIndex() )
	if dlight then
		dlight.Pos = self.Pos
		dlight.r = self.Color.r
		dlight.g = self.Color.g
		dlight.b = self.Color.b
		dlight.Brightness = 5
		dlight.Decay = 256
		dlight.size = 128
		dlight.DieTime = CurTime() + 2
	end

end

function EFFECT:Think()

	self.Alpha = self.Alpha - FrameTime() * 150
	self.Resize = self.Resize + 1.5 * FrameTime()
	self.Size = self.MaxSpriteSize * self.Resize^( 0.15 )
	
	if self.Alpha <= 0 then return false end
	return true

end

function EFFECT:Render()

	local Pos = self.Entity:GetPos() + self.Norm * -5 * ( self.Resize^( 0.3 ) ) * 0.8

	render.SetMaterial( matLight )
	render.DrawQuadEasy( Pos, self.Norm, self.Size, self.Size, Color( math.random( 50, 255 ), math.random( 50, 255 ), math.random( 50, 255 ), self.Alpha ) )
	render.DrawQuadEasy( Pos, self.Norm, self.Size / 2, self.Size / 2, Color( math.random( 50, 255 ), math.random( 50, 255 ), math.random( 50, 255 ), self.Alpha ) )

	local Distance = EyePos():Distance( self.Entity:GetPos() )
	local Pos2 = self.Entity:GetPos() + ( EyePos()-self.Entity:GetPos() ):GetNormal() * Distance * ( self.Resize^( 0.3 ) ) * 0.8

	render.SetMaterial( matLight2 )
	render.DrawSprite( Pos2, self.Size / 4, self.Size / 4, Color( math.random( 50, 255 ), math.random( 50, 255 ), math.random( 50, 255 ), self.Alpha ) )

end