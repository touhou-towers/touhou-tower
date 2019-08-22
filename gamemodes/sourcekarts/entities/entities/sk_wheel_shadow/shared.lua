
-----------------------------------------------------
AddCSLuaFile()

local BaseClass = baseclass.Get( "base_anim" )

function ENT:Initialize()

	self:SetCustomCollisionCheck( true )

	self:SetModel( "models/gmod_tower/kart/kart_backwheel.mdl" )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self:SetSolid( SOLID_NONE )
	self:DrawShadow( true )

end

function ENT:Draw()
	//self:DrawModel()
end