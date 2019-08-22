
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include("shared.lua")

function ENT:Initialize()

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()
	if phys then
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(1)
		phys:SetBuoyancyRatio(0)
	end
	
	self.RemoveTime = CurTime() + 10
	
end

function ENT:PhysicsCollide(data, phys)
	
	local hitEnt = data.HitEntity
	
	if hitEnt:IsPlayer() and hitEnt != hitEnt:GetOwner() then
		hitEnt:TakeDamage(100, self:GetOwner(), self)
	end
	
	self:Remove()
	
	self:Splat({Pos = data.HitPos, Normal = data.HitNormal})
	
end

function ENT:Think()

	if self.RemoveTime > CurTime() then return end
	
	self:Remove()

end

function ENT:Splat(hit)
	
	/*local effectdata = EffectData()
	effectdata:SetStart(self:GetPos())
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(.25)
	util.Effect("AntlionGib", effectdata)*/
	
	--WorldSound("npc/antlion_grub/squashed.wav", hit.Pos, 100, 100)
	self:EmitSound( Sound("npc/antlion_grub/squashed.wav"), 100, 100, 1, CHAN_AUTO )
	
	util.Decal("YellowBlood", hit.Pos + hit.Normal, hit.Pos - hit.Normal)
	
end