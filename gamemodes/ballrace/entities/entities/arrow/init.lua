AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	if self.Parent then
		local Parent = ents.FindByName( self.Parent )

		if IsValid( Parent[1] ) then
			self:SetParent( Parent[1] )
		end
	end

	self:SetModel( self.Model )
	self:SetSolid( SOLID_NONE )
	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	local phys = self:GetPhysicsObject()
	if ( phys:IsValid() ) then
		phys:EnableMotion( false )
	end
end

function ENT:KeyValue( key, value )
	if key == "parentname" then
		self.Parent = value
	end
end

function ENT:OnRemove()
	local edata = EffectData()
		edata:SetOrigin( self:GetPos() )
	util.Effect( "arrow_remove", edata )
end