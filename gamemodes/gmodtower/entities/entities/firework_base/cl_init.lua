
include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.SpriteMat = Material( "sprites/powerup_effects" )
gmt_fireworkdlight = CreateClientConVar( "gmt_fireworkdlight", 0, true, false )

function ENT:Initialize()

	self:UpdateSkin()

	self.Emitter = ParticleEmitter( self:GetPos() )

	self.Used = false
	self.Color = Color( math.random( 100, 255 ), math.random( 100, 255 ), math.random( 100, 255 ) )

	self.Yaw = 0
	self.NextParticle = CurTime()
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

	if !self.Used then return end

	if self.Emitter && CurTime() >= self.NextPartThink then

		if self.TypeTrail == 1 then

			self.LastParticlePos = self.LastParticlePos or self:GetPos()
			local vDist = self:GetPos() - self.LastParticlePos
			local Length = vDist:Length()
			local vNorm = vDist:GetNormalized()

			for i = 0, Length, 8 do

				self.LastParticlePos = self.LastParticlePos + vNorm * 8

				if math.random( 3 ) > 1 then

					local particle = self.Emitter:Add( "particles/smokey", self.LastParticlePos )
					particle:SetVelocity( VectorRand() * 40 )
					particle:SetLifeTime( 0 )
					particle:SetDieTime( math.Rand( 1.0, 1.5 ) )
					particle:SetStartAlpha( math.Rand( 100, 150 ) )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( math.random( 5, 10 ) )
					particle:SetEndSize( math.random( 20, 35 ) )

					local dark = math.Rand( 100, 200 )
					particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
					particle:SetAirResistance( 50 )
					particle:SetGravity( Vector( 0, 0, math.random( -50, 50 ) ) )
					particle:SetCollide( true )
					particle:SetBounce( 0.2 )

				end

				if math.random( 3 ) == 3 then

					local particle = self.Emitter:Add( "effects/muzzleflash" .. math.random( 1, 4 ), self.LastParticlePos )
					particle:SetVelocity( VectorRand() * 30 + Vector( 0, 0, 20 ) )
					particle:SetLifeTime( 0 )
					particle:SetDieTime( math.Rand( 0.1, 0.2 ) )
					particle:SetStartAlpha( 255 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( math.random( 6, 12 ) )
					particle:SetEndSize( 1 )
					particle:SetColor( math.Rand( 150, 255 ), math.Rand( 100, 150 ), 100 )
					particle:SetAirResistance( 50 )

				end

			end

			self.Emitter:SetPos( self.Entity:GetPos() )

		elseif self.TypeTrail == 2 then

			for i = 1, 8 do

				local particle = self.Emitter:Add( "effects/spark" , self:GetPos() )
				particle:SetVelocity( VectorRand() * 10 + Vector( 0, 0, 50 ) )
				particle:SetDieTime( math.random( 5, 20 ) * 0.1 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 6 )
				particle:SetEndSize( 0 )
				//particle:SetColor( math.random( 100, 255 ), math.random( 100, 255 ), math.random( 100, 255 ) )
				particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
				particle:SetStartLength( 10 )
				particle:SetEndLength( 0 )
				particle:SetRoll( math.random( 0, 360 ) )
				particle:SetGravity( Vector( 0, 0, -200 ) )
				particle:SetCollide( true )
				particle:SetBounce( 0.5 )

			end

		elseif self.TypeTrail == 3 then

			for i = 1, 20 do

				self.Yaw = self.Yaw + 2
				if self.Yaw > 360 then self.Yaw = 0 end

				local yaw = self.Yaw
				if i == 1 then yaw = yaw + 180 end
				if yaw > 360 then yaw = yaw - 360 end

				local particle = self.Emitter:Add( "particles/smokey", self:GetPos( ) )
				particle:SetVelocity( Angle( -45, yaw, 1 ):Forward( ) * 20 )
				particle:SetDieTime( math.random( 1, 2 ) )
				particle:SetStartAlpha( 100 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 8 )
				particle:SetEndSize( 0 )
				//local dark = math.Rand( 200, 255 )
				particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
				particle:SetStartLength( 8 )
				particle:SetEndLength( 8 )
				particle:SetRoll( math.random( 0, 360 ) )
				particle:SetGravity( Vector( 0, 0, -10 ) )

			end

		elseif self.TypeTrail == 4 then

			local angle = Angle( 0, 0, 0 )
			local pitch = angle.p
			local yaw = angle.y

			for i = 1, 12 do

				local rot = math.rad( math.random( 0, 360 ) )

				local dir = Vector(
					math.cos( rot ),
					math.sin( rot ),
					0
				):Angle()

				dir:RotateAroundAxis( Vector( 0 , 1 , 0 ), pitch )
				dir:RotateAroundAxis( Vector( 0 , 0 , 1 ), yaw )

				dir = dir:Forward()

				local particle = self.Emitter:Add( "effects/spark", self:GetPos() + Vector( 0, 0, 10 ) )
				particle:SetVelocity( ( dir * 50 ) + Vector( 0, 0, math.random( 200, 300 ) ) )
				particle:SetDieTime( math.random( 1, 2 ) )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 8 )
				particle:SetEndSize( 0 )

				if math.random( 1, 2 ) == 1 then
					particle:SetColor( math.random( 150, 255 ), math.random( 150, 255 ), math.random( 150, 255 ) )
				else
					particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
				end

				particle:SetStartLength( 15 )
				particle:SetEndLength( 30 )
				particle:SetAirResistance( 50 )
				--particle:VelocityDecay( false )
				particle:SetGravity( Vector( 0, 0, -math.random( 200, 300 ) ) )
				//particle:SetCollide( true )
				//particle:SetBounce( .25 )

			end

		elseif self.TypeTrail == 5 then

			local vel = VectorRand() * math.random( 6, 8 )
			vel.z = vel.z * ( vel.z > 0 && -6 or 6 )

			for i=1, 16 do

				local particle = self.Emitter:Add( "sprites/powerup_effects", self:GetPos() + ( VectorRand() * ( self:BoundingRadius() * 0.35 ) ) )

				if particle then

					particle:SetVelocity( vel )
					particle:SetDieTime( math.Rand( 4, 6 ) )
					particle:SetStartAlpha( 100 )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( math.random( 8, 16 ) )
					particle:SetEndSize( 0 )
					particle:SetRoll( math.Rand( 0, 360 ) )
					particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
					particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
					particle:SetCollide( true )
					particle:SetBounce( 0.25 )
					particle:SetAirResistance( 50 )

				end

			end

		elseif self.TypeTrail == 6 then

			if CurTime() > self.NextParticle then

				local angle = Angle( 0, 0, 0 )
				local pitch = angle.p
				local yaw = angle.y

				local rot = math.rad( math.random( 0, 360 ) )

				local dir = Vector(
					math.cos( rot ),
					math.sin( rot ),
					0
				):Angle()

				dir:RotateAroundAxis( Vector( 0 , 1 , 0 ), pitch )
				dir:RotateAroundAxis( Vector( 0 , 0 , 1 ), yaw )

				dir = dir:Forward()

				for i=1, 6 do

					local particle = self.Emitter:Add( "sprites/powerup_effects", self:GetPos() + Vector( 0, 0, 10 ) + ( VectorRand() * ( self:BoundingRadius() * 0.35 ) ) )

					if particle then

						local vel = ( dir * 50 ) + Vector( 0, 0, math.random( 100, 175 ) )
						if i == 1 then
							particle:SetVelocity( vel )
							particle:SetDieTime( math.Rand( 8, 18 ) )
							particle:SetStartSize( math.random( 18, 32 ) )
							particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
							particle:SetGravity( Vector( 0, 0, -10 ) )
						else
							particle:SetVelocity( vel * .95 )
							particle:SetDieTime( math.Rand( 16, 20 ) )
							particle:SetStartSize( math.random( 2, 5 ) )

							local function ColorMultiplied( color )
								return math.Clamp( color * math.Rand( .85, 2.15 ), 0, 255 )
							end

							particle:SetColor( ColorMultiplied( self.Color.r ), ColorMultiplied( self.Color.g ), ColorMultiplied( self.Color.b ) )
							particle:SetGravity( Vector( math.random( -10, 10 ), math.random( -10, 10 ), -5 ) )
						end

						particle:SetStartAlpha( 255 )
						particle:SetEndAlpha( 0 )
						particle:SetEndSize( 0 )
						particle:SetRoll( math.Rand( 0, 360 ) )
						particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
						particle:SetCollide( true )
						particle:SetBounce( 1 )
						particle:SetAirResistance( 85 )

					end

				end

				self:EmitSound( Sound("gmodtower/lobby/firework/firework_ufolaunch.wav"), math.random( 35, 50 ), 255 )
				self.NextParticle = CurTime() + math.Rand( .25, .65 )

			end

		end

		self.NextPartThink = CurTime() + 0.05

	end

	if self.IsRocket then return end

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

end

function ENT:OnRemove()

	if self.Emitter then

		self.Emitter:Finish()
		self.Emitter = nil

	end

	if self.Used && self.IsRocket && gmt_fireworkdlight:GetBool() == true then

		local dlight = DynamicLight( self:EntIndex() )
		if dlight then

			dlight.Pos = self:GetPos()
			dlight.r = self.Color.r
			dlight.g = self.Color.g
			dlight.b = self.Color.b
			dlight.Brightness = 1
			dlight.Size = 4096 * 2
			dlight.Decay = 4096 * 4
			dlight.DieTime = CurTime() + 1

		end

	end

end

usermessage.Hook( "FireworkUsed", function( um )

	local ent = um:ReadEntity()
	if !IsValid( ent ) then return end

	ent.Used = true

end	)

usermessage.Hook( "FireworkColor", function( um )

	local ent = um:ReadEntity()
	if !IsValid( ent ) then return end

	local r = um:ReadShort()
	local g = um:ReadShort()
	local b = um:ReadShort()

	ent.Color = Color( r, g, b )

end	)
