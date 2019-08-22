AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetModel(self.Model)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if phys && phys:IsValid() then
		phys:EnableMotion(false)
	end

	self.Lit = 0
end

function ENT:Think()
	if self.Lit > 0 && CurTime() > self.Lit + 0.25 then
		self.Lit = 0
		self:SetMaterial("")
	end
	
	if self.Entity:GetParent() != NULL then
		self.Entity:GetPhysicsObject():SetPos(self.Entity:GetPos())
		self:NextThink( CurTime() )
		return true
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.Lit == 0 && IsValid(data.HitEntity) && data.HitEntity:GetClass() == "player_ball" then
		local norm = data.HitNormal * -1
		local vel = data.TheirOldVelocity

		local dot = self:GetUp():Dot(data.HitNormal)

		if math.abs(dot) > 0.1 then return end

		local force = norm * data.HitObject:GetMass() * math.min(400, vel:Length()) * 2
		data.HitObject:ApplyForceCenter( force )

		self:SetMaterial(self.LitMaterial)

		self.Lit = CurTime()
		self:EmitSound(self.BumpSound)

		data.HitEntity:GetOwner():AddAchivement( ACHIVEMENTS.BRMILESTONE2, 1 )

	end
end
