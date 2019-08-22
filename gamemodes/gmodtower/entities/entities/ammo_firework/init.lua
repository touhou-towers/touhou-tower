
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(Model("models/gmod_tower/firework_rocket.mdl"))
    self:PhysicsInit(SOLID_VPHYSICS)
	self:DrawShadow(false)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
      phys:EnableGravity(false)
      phys:SetVelocity(Vector(0,0,0))
      local direction = self:GetOwner():EyePos() - self:GetPos()
      direction:Normalize()
      phys:ApplyForceCenter( direction *-1 * 200000 )
    end
		timer.Simple(3, function() 
		if IsValid(self) then
			self:DoFireworks()
		end
	end)
end

local effects = {
	"firework_explosion",
	"firework_multiexplosion",
	"firework_rainbowexplosion",
	"firework_ring",
}

function ENT:PhysicsCollide()

	self:DoFireworks()

end

function ENT:DoFireworks()
	local pos = self:GetPos()
	local eff = EffectData()
	eff:SetOrigin(pos)
	util.Effect("firework_sparks",eff,true,true)
	local pos = self:GetPos()
	local eff = EffectData()
	eff:SetOrigin(pos)
	--util.Effect("firework_pop",eff,true,true)
	local pos = self:GetPos()
	local eff = EffectData()
	eff:SetOrigin(pos)
	util.Effect("firework_shockwave",eff,true,true)
	local pos = self:GetPos()
	local eff = EffectData()
	eff:SetOrigin(pos)
	util.Effect(table.Random(effects),eff,true,true)
	self:Remove()
end

function ENT:OnRemove()
  self:EmitSound("GModTower/lobby/firework/firework_explode.wav",80)
end
