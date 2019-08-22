AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_NONE )

	self:SetUseType( SIMPLE_USE )
	self:EmitSound( self.Sound )

end

function ENT:Think()

	if !IsValid( self:GetOwner() ) then

		self:Remove()

	end

end

/*function ENT:Use( ply )

	if !IsValid( self:GetOwner() ) then return end

	self:GetOwner():Spawn()
	self:Remove()

end*/

function ENT:Think()
    for k,v in pairs( ents.FindInSphere(self:GetPos(),64) ) do
			if v:IsPlayer() && v != self:GetOwner() then
				self:GetOwner():Spawn()
				self:GetOwner():SetPos( self:GetPos() )
				v:AddAchivement( ACHIVEMENTS.ZMGRAVESAVE, 1 )
				self:Remove()
			end
		end
end

function ENT:OnRemove()

	local eff = EffectData()
		eff:SetOrigin( self:GetPos() )
	util.Effect( "explosion", eff )

	if !IsValid( self:GetOwner() ) then return end

	util.BlastDamage( self:GetOwner(), self:GetOwner(), self:GetPos(), 800, 128 )

end
