
-----------------------------------------------------
ENT.Type 	= "anim"
ENT.Base 	= "base_anim"

ENT.Model	= Model( "models/gmod_tower/sourcekarts/ballionrocket.mdl" )

function ENT:GetKart()
	return self:GetOwner():GetKart()
end

function ENT:IsValidOwner()
	return IsValid( self:GetOwner() )
end