AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.PointValue = 0

function ENT:Initialize()
	if !self.PointValue || self.PointValue == 0 then
		self.PointValue = 1
	end

	if self.PointValue == 5 then
		self:SetModel(self.ModelExtra)
	else
		self:SetModel(self.Model)
	end

	self.Entity:SetSolid(SOLID_BBOX)

	self.Entity:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	self.Entity:SetCollisionBounds( Vector( -25, -25, -25 ), Vector( 25, 25, 30 )  )
	self.Entity:SetTrigger( true )

	local phys = self.Entity:GetPhysicsObject()
	if(phys and phys:IsValid()) then
		phys:EnableMotion(false)
	end
end

function ENT:Touch(ent)
	if ent:GetClass() != "player_ball" || self.Eaten then return end

	ent:GetOwner():AddFrags(self.PointValue)

	ent:GetOwner():EmitSound( self.EatSound )
	ent:GetOwner():AddAchivement( ACHIVEMENTS.BRBANANABINGER, 1 )
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() + Vector( 0, 0, 20 ) )
	util.Effect( "bananaeat", effectdata, true, true )

	self.Eaten = true

	self:Remove()
end

function ENT:KeyValue(key, value)
	if key == "points" then
		self.PointValue = tonumber(value)
	end
end
