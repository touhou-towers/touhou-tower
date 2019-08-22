
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Radius = 100

function ENT:Think()
	local owner = self:GetOwner()

	if !IsValid(owner) || !owner:Alive() then
		self:Remove()
	end
end

function ENT:SetShieldOwner( ply )
	self:SetOwner( ply )
	self:SetParent( ply )

	ply.Shield = self
end

function ENT:Initialize()
	//Hey~ Hey~  Don't remove this Mr.!

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:DrawShadow( false )

	self:PhysicsInitSphere(self.Radius)

	local phys = self:GetPhysicsObject()
	if phys then
		phys:EnableCollisions( false )
	end

	self:SetTrigger( true )
	self:SetNotSolid( true )

	self:SetCollisionBounds( Vector( -self.Radius, -self.Radius, -self.Radius), Vector( self.Radius, self.Radius, self.Radius ) )
end

function ENT:StartTouch( entity )
	if entity == GetWorldEntity() then return end
	if entity:GetClass() == "shield" then return end
	if entity:GetOwner() == self:GetOwner() then return end
	if entity:GetClass() == "prop_ragdoll" then return end
	if entity:IsPlayer() && entity:GetSetting( "GTNoShield" ) then return end

	local phys = entity:GetPhysicsObject()
	if !phys:IsValid() or phys:IsMoveable() then return end

	local effect = EffectData()
	effect:SetOrigin(entity:GetPos())
	effect:SetScale(25)
	util.Effect("shield_block", effect)

	//This sound makes me hurl, but leave it anyways~
	//entity:EmitSound("ambient/machines/zap" .. math.random(1,3) .. ".wav")
end

function ENT:Touch( entity )
	if entity == GetWorldEntity() then return end
	if entity:GetClass() == "shield" then return end
	if entity:GetOwner() == self:GetOwner() then return end
	if entity:GetClass() == "prop_ragdoll" then return end
	if entity:IsPlayer() && entity:GetSetting( "GTNoShield" ) then return end

	//RPG Missiles
	if entity:GetClass() == "rpg_missile" then
		self:DoShieldLF( entity, 1000 )
		entity:SetHealth( 0 )

		local bullet = {
				Num = 1,
				Src = entity:GetPos(),
				Dir = Vector(0,0,0),
				Spread = Vector(0,0,0),
				Tracer = 0,
				Force = 1,
				Damage = 100
		}
		self:FireBullets( bullet )
		self:Effects( entity )
	end

	//Physics
	local physobj = entity:GetPhysicsObject()
	if physobj:IsValid() && physobj:IsMoveable() then
		self:DoShieldF( physobj, entity, 10000 )
		self:Effects(entity)
	end

	//Player
	if entity:IsPlayer() && !entity:GetSetting( "GTNoShield" ) then
		entity:TakeDamage( 1, self:GetOwner() )  //Don't let people get inside
		self:DoShieldPush( entity, 100000 )
		self:Effects( entity )
	end
end

function ENT:DoShieldLF(entity, force)
	entity:SetLocalVelocity((entity:GetPos() - self:GetPos()):GetNormalized() * force)
end

function ENT:DoShieldF( physobj, entity, force )
	physobj:ApplyForceCenter( ( entity:GetPos() - self:GetPos() ):GetNormalized() * force )
end

function ENT:DoShieldPush(entity, force)
	entity:SetVelocity((entity:GetPos() - self:GetPos()):GetNormalized() * force)
end

function ENT:Effects(entity)
	local effectdata = EffectData()
		effectdata:SetStart(entity:GetPos())
		effectdata:SetOrigin(entity:GetPos())
		effectdata:SetScale(10)
		effectdata:SetMagnitude(10)
		effectdata:SetEntity(entity)
	util.Effect("TeslaHitBoxes", effectdata)
end
