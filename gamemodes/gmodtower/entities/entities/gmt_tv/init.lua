
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "gmt_theater" )
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

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
	end	
	
	self.LastUse = 0.0
	--self:SharedInit()
	
end

function ENT:Think()
		for _, ply in pairs( GTowerLocation:GetPlayersInLocation(41) ) do
				ply:AddAchivement( ACHIVEMENTS.SUITEYOUTUBE, 1/600 )
				for _, ply in pairs( GTowerLocation:GetPlayersInLocation(50) ) do
				ply:AddAchivement( ACHIVEMENTS.SUITEYOUTUBE, 1/600 )
		end
	end
end

function ENT:Use( ply )

end

hook.Add("MapChange", "DeleteTheater", function()
	for _, v in pairs( ents.FindByClass("gmt_theater") ) do
		v:Remove()
	end
end )