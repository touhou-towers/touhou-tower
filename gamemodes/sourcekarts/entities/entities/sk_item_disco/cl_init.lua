
-----------------------------------------------------
include('shared.lua')

ENT.Sprite = Material( "sprites/powerup_effects" )
ENT.Laser = Material( "effects/laser1.vmt" )

function ENT:Initialize()
end

function ENT:Draw()

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	local kart = owner:GetKart()
	if !IsValid( kart ) then return end
	if !kart:IsVisible() then return end
	if !IsValid( kart.ClientModel ) then return end

	self:DrawModel()

	// Offset
	self:SetPos( kart.ClientModel:GetPos() + kart:GetUp() * 48 )

	local scale = SinBetween( .5, 1, RealTime() * 12 )
	local color = colorutil.Smooth( .3 )

	// Main sprite
	local size = scale * 180
	render.SetMaterial( self.Sprite )
	render.DrawSprite( self:GetPos() + VectorRand():GetNormal() * 2, size, size, color )

	// Rotation
	local rot = self:GetAngles()
	rot.y = rot.y + 90 * FrameTime()
	rot.r = SinBetween( -30, 30, FrameTime() * 20 )

	self:SetAngles(rot)
	self:SetRenderAngles(rot)

	// Scale
	self:SetModelScale( scale, 0 )

	// Lasers
	render.SetMaterial( self.Laser )

	for i=1, 8 do
		render.StartBeam( 2 )
			render.AddBeam(
				self:GetPos(),
				30,
				CurTime(),
				Color( color.r, color.g, color.b, 255 * scale )
			)
			render.AddBeam(
				self:GetPos() + VectorRand() * 50,
				30,
				CurTime() + 1,
				Color( 0, 0, 0, 0 )
			)
		render.EndBeam()
	end

end

function ENT:DrawTranslucent()
end

function ENT:Think()

end
