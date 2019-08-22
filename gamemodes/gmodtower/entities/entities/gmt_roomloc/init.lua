
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:KeyValue( key, value )

end

function ENT:SetId( id )
	self.RoomId = id
end