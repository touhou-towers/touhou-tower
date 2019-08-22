
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 2
	
	local ent = ents.Create( "gmt_trunk" )
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
	self:DrawShadow(true)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end	
	
	self.LastUse = 0.0
	
end

function ENT:LoadRoom()
	self.RoomId = GtowerRooms.ClosestRoom( self:GetPos() )
end

function ENT:Use( ply )
	local Room = GtowerRooms.Get( self.RoomId )

	if !ply:IsPlayer() then return end
	
	if self.LastUse > CurTime() then
		return
	end
	
	self.LastUse = CurTime() + 0.5
	
	GTowerItems:OpenBank( ply )
	
end

function ENT:AllowAllUsers()
	
	self.Use = function( ent, ply )
		if ply._LastBankUse && ply._LastBankUse > CurTime() then
			return
		end
		
		ply._LastBankUse = CurTime() + 0.5
		
		GTowerItems:OpenBank( ply )
	end
	
end

hook.Add("AllowBank", "GTowerAllowInvBank", function( ply )
	
	for _, v in pairs( ents.FindByClass("gmt_trunk" ) ) do
		if v:GetRoomOwner() == ply && ply:GetPos():Distance( v:GetPos() ) < 300 then
			return true
		end	
	end


end )
