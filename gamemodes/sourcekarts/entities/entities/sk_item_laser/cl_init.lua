
-----------------------------------------------------
include('shared.lua')

local matBeam 	= Material( "effects/laser1" )
local matLight	= Material( "sprites/powerup_effects" )

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()

	self:UpdateEndPos()

	self.StartPos = self:GetPos()

	if !self.HitPos then
		return
	end

	local min, max = self.StartPos * 1, self.HitPos * 1
	OrderVectors( min, max )
	self:SetRenderBoundsWS( min, max )

end

function ENT:DrawTranslucent()

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	local kart = owner:GetKart()
	if !IsValid( kart ) then return end
	if !IsValid( kart.ClientModel ) then return end

	// Offset
	local dir = self:GetDirection()

	self:DrawModel()
	self:SetPos( kart.ClientModel:GetPos() + kart:GetForward() * ( 32 * dir ) + kart:GetUp() * 8 )

	// Main beam
	render.SetMaterial( matBeam )
	render.DrawBeam( self.StartPos, self.HitPos, 150, 3, 0, Color( 255, 0, 0 ) )

	// Inner beam
	render.DrawBeam( self.StartPos, self.HitPos, 15, 3, 0, Color( 255, 150, 150 ) )

	// More beams
	local Dir = ( self.HitPos - self.StartPos )
	local Inc = Dir:Length() / 12
	local Dir = Dir:GetNormal()
	local color = Color( math.Rand( .5, 1 ), 255, 255 )
	local size = 50 //math.Clamp( Inc * 1.8, 6, 30 )

	// Inner Beam
	render.SetMaterial( matBeam )
	render.StartBeam( 12 )

		render.AddBeam( self.StartPos, size, RealTime(), color )

		for i = 1, 12 do
			local length = Dir:Length() or 1
			local rnd = math.Rand( 1, length * 2 )

			local Point = ( self.StartPos + Dir * ( i * Inc ) ) + VectorRand() * rnd
			local Coord = RealTime() + ( 1 / 12 ) * i

			render.AddBeam( Point, size, Coord, color )
		end

		render.AddBeam( self.HitPos, size, RealTime() + 1, color )

	render.EndBeam()


	// Beam Start Sprite
	render.SetMaterial( matLight )
		render.DrawQuadEasy( self.StartPos + self.Normal, self.Normal, 64, 64, Color( 25, 150, 255 ) )
		render.DrawQuadEasy( self.StartPos + self.Normal, self.Normal, math.Rand(32, 128), math.Rand(32, 128), Color( 25, 150, 255 ) )
		render.DrawQuadEasy( self.StartPos + self.Normal, self.Normal, math.Rand(64, 200), math.Rand(64, 200), Color( 255, 150, 255 ) )
	render.DrawSprite( self.StartPos + self.Normal, 64, 64, Color( 255, 150, 255, 255 ) )

	// Beam End Sprite
	render.SetMaterial( matLight )
		render.DrawQuadEasy( self.HitPos + self.Normal, self.Normal, 64, 64, Color( 255, 150, 25 ) )
		render.DrawQuadEasy( self.HitPos + self.Normal, self.Normal, math.Rand(32, 128), math.Rand(32, 128), Color( 255, 150, 25 ) )
		render.DrawQuadEasy( self.HitPos - self.Normal, -self.Normal, math.Rand(64, 200), math.Rand(64, 200), Color( 255, 150, 25 ) )
	render.DrawSprite( self.HitPos + self.Normal, 64, 64, Color( 255, 150, 25, 255 ) )

	if IsValid( self.HitEntity ) then

		// Sparks
		local effect2 = EffectData()
			effect2:SetOrigin( self.HitPos )
			if self.Normal then effect2:SetNormal( self.Normal ) end
		util.Effect( "laser_spark", effect2 )

		// Decals
		if !self.LastDecal || self.LastDecal < RealTime() then
			util.Decal( "FadingScorch", self.HitPos + self.Normal, self.HitPos + self.Normal * -20 + VectorRand() * 15 )
			self.LastDecal = RealTime() + 0.01
		end

		local dlight_end = DynamicLight( self:EntIndex() .. "end" )
		if dlight_end then
			dlight_end.Pos = self.HitPos
			dlight_end.r = 255
			dlight_end.g = 150
			dlight_end.b = 55
			dlight_end.Brightness = 4
			dlight_end.Decay = 320
			dlight_end.size = 80
			dlight_end.DieTime = CurTime() + .5
		end
	end

	//Dlights
	local dlight_start = DynamicLight( self:EntIndex() .. "start" )
	if dlight_start then
		dlight_start.Pos = self.StartPos
		dlight_start.r = 255
		dlight_start.g = 150
		dlight_start.b = 150
		dlight_start.Brightness = 1
		dlight_start.Decay = 340
		dlight_start.size = 120
		dlight_start.DieTime = CurTime() + .5
	end

end