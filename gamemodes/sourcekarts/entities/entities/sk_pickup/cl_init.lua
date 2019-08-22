
-----------------------------------------------------
include( "shared.lua" )

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT
ENT.SpriteMat 		= Material( "sprites/powerup_effects" )
ENT.BoxColor  		= Material( "color.vmt" )
ENT.MaxDist 		= 4096 * 2
ENT.MaxPartDist 	= 2048
surface.CreateFont( "PickupFont", { font = "Days", size = 64, weight = 500 } )

function ENT:Initialize()

	timer.Simple( .1, function()

		if IsValid( self ) then
			self.OriginPos = self:GetPos()
			self.NextParticle = CurTime()

			self.Emitter = ParticleEmitter( self:GetPos() )
		end

	end )

end

function ENT:DrawTranslucent()

	if GAMEMODE:GetState() == STATE_WAITING || LocalPlayer():Team() == TEAM_FINISHED then return end

	//self:DrawModel()
	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + Vector( 0, 0, 16 + SinBetween( 24, 32, RealTime() * 2 )  )

	local dist = LocalPlayer():GetPos():Distance( pos )
	if ( dist >= self.MaxDist ) then return end

	local color = colorutil.Rainbow( 150 )

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	local rot = Angle( 0, ang.y, 90 )
	rot.p = rot.p + 90 * ( RealTime() )

	cam.Start3D2D( pos, rot, .4 )

		if !self.NextItem || self.NextItem < RealTime() then
			self._Item = math.random( 1, #items.List )
			self.NextItem = RealTime() + .25
		end

		local item = items.Get( self._Item )
		local scale = .18
		local w, h = 256 * scale, 512 * scale

		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( item.Material )
		surface.DrawTexturedRect( -w/2, -h/2, w, h )

		//draw.SimpleShadowText( "?", "PickupFont", 0, 0, Color( 255, 255, 255, 255 ), Color( 0, 0, 0, 255 ) )

	cam.End3D2D()


	render.SetMaterial( self.SpriteMat )
	render.DrawSprite( self:GetPos(), 50, 50, color )

	render.SetMaterial( self.BoxColor )

	local rot = self:GetAngles()
	rot.y = rot.y + 90 * ( RealTime() )
	rot.p = rot.p + 90 * ( RealTime() )

	local size = 14
	render.DrawBox( pos, rot, Vector( -size, -size, -size ), Vector( size, size, size ), Color( color.r, color.g, color.b, 50 ) )
	render.DrawWireframeBox( pos, rot, Vector( -size, -size, -size ), Vector( size, size, size ), Color( color.r, color.g, color.b, 80 ), true )

	//surface.DrawCircle( pos.x, pos.y, 24, Color( color.r, color.g, color.b, 80 ) )

end

function ENT:OnRemove()

	if IsValid( self.Emitter ) then
		self.Emitter:Finish()
	end

end

function ENT:Think()

	if GAMEMODE:GetState() == STATE_WAITING || LocalPlayer():Team() == TEAM_FINISHED then return end

	if not IsValid( LocalPlayer() ) or not IsValid( self ) or not LocalPlayer().GetPos or not self.GetPos then return end

	local dist = LocalPlayer():GetPos():Distance( self:GetPos() )
	if not dist or not self.MaxDist then return end
	if ( dist >= self.MaxDist ) then return end

	if !self.OriginPos then return end

	local rot = self:GetAngles()
	rot.y = rot.y + 90 * FrameTime()
	rot.p = rot.p + 90 * FrameTime()

	self:SetAngles(rot)
	self:SetRenderAngles(rot)

	if !self.TimeOffset then self.TimeOffset = math.Rand( 0, 3.14 ) end
	local SinTime = math.sin( CurTime() + self.TimeOffset )

	self:SetRenderOrigin( self.OriginPos + Vector(0,0, 35 +  SinTime * 4 ) )

	if ( dist >= self.MaxPartDist ) then return end

	local emitter = self.Emitter

	local pos = self:GetPos() + ( VectorRand():GetNormal() * ( self:BoundingRadius() * 0.75 ) )
	local vel = VectorRand() * 3 + Vector( 0, 0, -100 )

	if !IsValid(emitter) then
		self.Emitter = ParticleEmitter( self:GetPos() )
		return
	end

	local particle = emitter:Add( "sprites/powerup_effects", pos )
	if particle then
		particle:SetVelocity( vel )
		particle:SetDieTime( math.Rand( 1, 3 ) )
		particle:SetStartAlpha( 100 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( math.random( 10, 18 ) )
		particle:SetEndSize( 0 )
		particle:SetRoll( math.Rand( 0, 360 ) )
		particle:SetRollDelta( math.Rand( -5.5, 5.5 ) )
		particle:SetCollide( true )
		particle:SetBounce( .2 )

		local color = colorutil.Rainbow( 150 )
		particle:SetColor( color.r, color.g, color.b )
	end

end
