
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "shared.lua" );

include('shared.lua');

ENT.Occupant = nil
ENT.OccupantWeaps = {}
ENT.LastUseTime = 0

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 32
	
	local ent = ents.Create( "gmt_pooltube" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetSkin( math.random( 1, 4 ) )
	
	local phys = self.Entity:GetPhysicsObject()
	if( phys:IsValid() )then
		phys:Wake()
	end
end

function ENT:Think()
	/*local ply = self.Occupant

	if ply then
		local ang = ply:GetAngles()
		ply:SetAngles( Angle( 0, ang.yaw, 0 ) )
		ply:SetPos( self:GetPos() + Vector( 0, 0, -32 ) )

		if !ply:Alive() then
			self:Exit( ply )
		end

		if ply:KeyDown( IN_USE ) && self.LastUseTime < RealTime() then
			self:Exit( ply )
		end
	end

	self:NextThink( CurTime() )
	return true*/
end
--[[
function ENT:Use( ply )
	if self.Occupant then return end

	self:Enter( ply )

	self.LastUseTime = RealTime() + 1
end
--]]
function ENT:Enter( ply )
	self.Occupant = ply

	self:SetAngles( Angle( 0, 0, 0 ) )
	ply:SetPos( self:GetPos() + Vector( 0, 0, -32 ) )
	ply:SetParent( self )
	ply:SetMoveType( MOVETYPE_NONE )
	constraint.Keepupright( self, Angle( 0, 0, 0 ), self.PhysicsBone, 0 )

	for k, v in pairs( ply:GetWeapons() ) do
		self.OccupantWeaps[k] = v:GetClass()
	end
	ply:StripWeapons()
end

function ENT:Exit( ply )
	self.Occupant = nil

	ply:SetPos( self:GetPos() + Vector( 0, 0, 64 ) )
	ply:SetParent( nil )
	ply:SetMoveType( MOVETYPE_WALK )
	constraint.RemoveConstraints( self, "Keepupright" )

	for k, v in pairs( self.OccupantWeaps ) do
		ply:Give( v )
	end
end