AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:PreInit()

	self.NeverRemoves = true
	self.PickUpDelay = CurTime() + 1
	
end

function ENT:PickUp( ply )

	self.BaseClass:PickUp( ply )

	if IsValid( ply.HeldItem ) then return end
	
	local ent = ents.Create( "held_item" )
		ent:SetOwner( ply )
		ent:SendModel( self.Model )
	ent:Spawn()
	
	ply.HeldItem = ent

	// this is always picked up
	return true

end

function ENT:KeyValue( key, value )

	if key == "model" then
		self.Model = value
	end

end