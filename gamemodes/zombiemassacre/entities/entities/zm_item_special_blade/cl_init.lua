include( "shared.lua" )
ENT.Color = Color( 150, 150, 150, 200 )
ENT.SpriteOffset = Vector( 0, 0, -30 )
ENT.ProgressCircleOffset = -20
function ENT:Draw()
	self.BaseClass.Draw( self )
	self:SetAngles( Angle( 0, CurTime() * 1440, 0 ) )
end