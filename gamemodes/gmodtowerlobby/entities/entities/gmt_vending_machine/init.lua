include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()

	self:SetModel(self.Model)
	self:PhysicsInit( SOLID_VPHYSICS )
  self:SetMoveType( MOVETYPE_NONE )
  self:SetSolid( SOLID_VPHYSICS )

	self:SetUseType( SIMPLE_USE ) // Or else it'll go WOBLBLBLBLBLBLBLBL

	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then
		phys:EnableMotion( false )
	end

	local nameEnt = ents.Create( "gmt_npcmsg" )

	nameEnt:SetParent( self )
	nameEnt:SetPos( self:GetPos() + Vector(0,0,25) )

	nameEnt:Spawn()

	self.NameEnt = nameEnt

	nameEnt:SetTitle( "Vending Machine" )

	--self:SetPos(self:GetPos() + Vector(0,0,45))
end
