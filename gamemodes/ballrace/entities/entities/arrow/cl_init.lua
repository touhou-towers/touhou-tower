include("shared.lua")

function ENT:Draw()

	// lets not draw on maps that haven't been fixed yet
	local map = game.GetMap()
	if ( map == "gmt_ballracer_skyworld" || map == "gmt_ballracer_grassworld" ) then return end
	
	self:DrawModel()

	local ang = LocalPlayer():EyeAngles()
	self:SetAngles( Angle( 0, ang.y, 0 ) )
	self:SetPos( self:GetPos() + self:GetAngles():Up() * math.sin( CurTime() * 3 ) * 0.2 )
end