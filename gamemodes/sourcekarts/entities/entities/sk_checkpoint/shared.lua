
-----------------------------------------------------
ENT.Type 		= "anim"
ENT.Base 		= "base_anim"
ENT.Model 		= Model("models/props_junk/watermelon01.mdl")
ENT.Distance 	= 1024

function ENT:IsInFront( pos )
	return (pos - self:GetPos()):DotProduct( self:GetForward() ) > 0
end

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "ID" )
end