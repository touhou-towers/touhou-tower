include('shared.lua')
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.MatPower = Material( "models/effects/comball_tape" )
function ENT:Initialize()
	self:SetPos( self:GetPos() + Vector( 0, 0, 10 ) )
	self.Scale = 0
end
function ENT:Draw()
	self.Scale = math.Approach( self.Scale, 1.3, FrameTime() * 10 )
	self:SetModelScale( self.Scale, 0 )
	self:DrawModel()
	GAMEMODE:DrawModelMaterial( self, self.Scale + .1, self.MatPower )
end