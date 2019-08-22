
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 2
	
	local ent = ents.Create( "gmt_room_remote" )
	ent:SetPos( SpawnPos )	
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	self.Entity:SetModel( self.Model )
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end	
end

function ENT:LoadRoom()
	self.RoomId = GtowerRooms.ClosestRoom( self:GetPos() )
end

function ENT:GetRoomOwner()
    return GtowerRooms.GetOwner( self.RoomId )
end

function ENT:Use( ply )
	if !self.RoomId then return end
	if !IsValid(ply) || (ply != self:GetRoomOwner() && !ply:IsAdmin()) then return end
	
	local room = GtowerRooms:Get( self.RoomId )
	if room then
		room:CallOnEnts( "RemoteClick", ply )
	end
end