
-----------------------------------------------------
include('shared.lua')
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:Draw()
end

function ENT:DrawTranslucent()

	local scale = SinBetween( .4, .5, RealTime() * 2 )
	SetModelScaleVector( self, Vector(1, 1, 1) * scale )

	local pos = self:GetPos()
	local scale = CosBetween( .75, 1, RealTime() * 10 )
	render.DrawSphere( pos, 15 * scale, 16, 16, Color( 125, 231, 156, 150 ) )
	render.DrawSphere( pos, 10 * scale, 16, 16, Color( 180, 231, 156, 255 ) )

	self:DrawModel()
	self:SetAngles( Angle( 180, 0, 0 ) )
	self:CreateShadow()

end