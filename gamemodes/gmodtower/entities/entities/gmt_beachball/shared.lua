

-----------------------------------------------------
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.RenderGroup 	= RENDERGROUP_OPAQUE
ENT.PrintName 		= "Beach Ball"
ENT.Spawnable 		= true
ENT.AdminSpawnable 	= true
ENT.SleepPhysics 	= 10

AddCSLuaFile()

function ENT:Initialize()

	if SERVER then

			local CurLoc = GTowerLocation:FindPlacePos(self:GetPos())

			self.LocationChecked = CurTime() + 2.5

	    self:SetModel( "models/gmod_tower/beachball.mdl" )
	    self:PhysicsInit( SOLID_VPHYSICS )
	    self:SetMoveType( MOVETYPE_VPHYSICS )
	    self:SetSolid( SOLID_VPHYSICS )

			self.LocationChecked = CurTime()

			if CurLoc != 56 then
				self:SetNWBool("OwnedByAdmin" , true)
			end

	    local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
			phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
			phys:SetMass( 5 )
			phys:Wake()
		end

		self.LastKicker = nil
		self:SetTrigger( true )

		timer.Simple( 1, function()
			self.OriginalPos = self:GetPos()
		end )
	end

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

	self.NextImpact = CurTime()
	self.NextKickSound = CurTime()
	self.PhysDelay = CurTime() + self.SleepPhysics

end

function ENT:OnTakeDamage( dmginfo )

	if dmginfo:GetDamage() < 2 then return end

	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
	util.Effect( "confetti", effectdata )

	self:Remove()

end

function ENT:PhysicsCollide( data, physobj )

	local ent = data.HitEntity

	self:PhysicsWake()

	if self.NextImpact < CurTime() && data.DeltaTime > 0.2 && data.OurOldVelocity:Length() > 100 && !self:IsPlayerHolding() then
		self:EmitSound("Rubber.ImpactHard")
		self.NextImpact = CurTime() + 0.1
	end

end

function ENT:StartTouch( ent )

	if !IsValid( ent ) || !ent:IsPlayer() && !self:IsPlayerHolding() then return end

	self:PhysicsWake()
	self.LastKicker = ent

	/*if ent:GetVelocity():Length() < 5 then
		return
	end*/

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then

		local mult = .65
		local velocity = ent:GetVelocity() * mult

		phys:AddVelocity( velocity + Vector( 0, 0, 300 ) )

		if self.NextKickSound < CurTime() then
			self:EmitSound( "Rubber.BulletImpact" )
			self.NextKickSound = CurTime() + 0.1
		end

	end

end

function ENT:Think()

	if SERVER then
		self:HandlePhysicsSleep()
		self:CheckLocation() // Pool
	end

end

function ENT:HandlePhysicsSleep()

	if self.PhysDelay && self.PhysDelay < CurTime() then

		self:ResetPos()

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then
			phys:EnableMotion( false )
		end

	end

end

function ENT:PhysicsWake()

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:EnableMotion( true )
		phys:Wake()
	end

	self.PhysDelay = CurTime() + self.SleepPhysics

end

function ENT:ResetPos()
	if self.NoReset then return end
	if self.OriginalPos then
		self:SetPos( self.OriginalPos )
	end
end

function ENT:CheckLocation( loc )

	if self.LocationChecked >= CurTime() then return end

	self.LocationChecked = CurTime() + 2.5

	local CurLoc = GTowerLocation:FindPlacePos(self:GetPos())

	if CurLoc == 5 or CurLoc == 6 or CurLoc == 49 then
		self:ResetPos()
	end

	if self:GetNWBool("OwnedByAdmin") then return end

	if CurLoc != 56 then
		self:ResetPos()
	end

end
