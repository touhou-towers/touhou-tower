
-----------------------------------------------------
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.MatPower = Material( "models/props_combine/portalball001_sheet" )

function ENT:Initialize()

	self:SetPos( self:GetPos() + Vector( 0, 0, 10 ) )
	self.Scale = 0

end

function ENT:Draw()

	local owner = self:GetOwner()
	if !IsValid( owner ) then return end

	local kart = owner:GetKart()
	if !IsValid( kart ) then return end
	if !kart:IsVisible() then return end
	if !IsValid( kart.ClientModel ) then return end


	// Offset
	self:SetPos( kart.ClientModel:GetPos() )

	// Scale
	self.Scale = math.Approach( self.Scale, .95, FrameTime() * 5 )
	self:SetModelScale( self.Scale, 0 )

	// Rotation
	local rot = self:GetAngles()
	rot.y = rot.y + 90 * FrameTime()
	rot.r = SinBetween( -30, 30, FrameTime() * 20 )

	self:SetAngles(rot)
	self:SetRenderAngles(rot)

	--self:DrawModel()

	// Outer ring
	DrawModelMaterial( self, self.Scale + .05, self.MatPower )
	DrawModelMaterial( self, self.Scale, self.MatPower )

end
