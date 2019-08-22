
include( "shared.lua" )

function ENT:Draw()
	self.Entity:DrawModel()
end

function TrampAnimate( um )

	local ent = um:ReadEntity()
	
	if ( ent == nil || !IsValid( ent ) ) then return end
	
	ent:Boing()
	
end

usermessage.Hook( "GTramp", TrampAnimate )