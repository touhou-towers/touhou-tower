

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.Setup = false
ENT.Exploded = false

function ENT:Initialize()
	self:SharedInit()
	
	self.Entity:SetModel(self.Model)
	
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	
	local Phys = self.Entity:GetPhysicsObject()
	
	if(IsValid(Phys)) then
		Phys:Wake()
		Phys:SetDamping(0.2, 0)
		Phys:AddAngleVelocity(VectorRand() * 360)
	end
	
	util.SpriteTrail(self, 0, self.TrailColor, false, 15, 1, 0.8, 1 / 16 * 0.5, "trails/plasma.vmt")
	
	self.Spawned = CurTime()
	
	local tr = self:Trace()
	if(tr.Hit and tr.Entity and tr.Entity:IsValid() and !tr.Entity:IsPlayer()) then
		self.InitEnt = tr.Entity
	end
end

function ENT:Think()
	if(self:GetActive()) then
		local tr = self:Trace()
		if(tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
			self:Explode()
		end
	else
		if(self.Spawned + 2 < CurTime()) then
			self:SetActive(true)
			self:CreateBeam()
		end
	end
	self.Entity:NextThink(CurTime() + 0.01)
	return true
end

function ENT:PhysicsCollide(Data, Phys)
	if(self.Setup or !Data.HitEntity:IsWorld()) then 
		return
	end
	
	self.Entity:SetMoveType(MOVETYPE_NONE)
	Phys:EnableMotion(false)
	Phys:Sleep()
	
	self:SetUpTripMine(Data.HitNormal:GetNormal() * -1)
end

function ENT:Trace()
	local tr = {}
	tr.start = self.Entity:GetPos()
	tr.endpos = self.Entity:GetEndPos()
	if(IsValid(self.InitEnt)) then
		tr.filter = {self, self.InitEnt}
	else
		tr.filter = {self}
	end
	return util.TraceLine(tr)
end

function ENT:SetUpTripMine(Forward)
	self.Setup = true
	
	local tr = util.TraceLine({
		start 	= self.Entity:GetPos(),
		endpos 	= self.Entity:GetPos() - (Forward * 25),
		filter 	= self.Entity
	})
	
	self.Entity:SetPos(tr.HitPos + (Forward * 2))
	
	local NewAngle = Forward:Angle()
	NewAngle:RotateAroundAxis(Forward, self.Entity:GetAngles().y)
	NewAngle:RotateAroundAxis(NewAngle:Right(), -90)
	
	self.Entity:SetAngles(NewAngle)
	self.Entity:EmitSound(table.Random(self.StickSound))	
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:OnTakeDamage()
	self:Explode()
end

function ENT:Explode()
	if(!self:GetActive() or self.Exploded) then
		return
	end
	self.Exploded = true
	
	local Pos =  self.Entity:GetPos()
	
	local Explosion = EffectData()
	Explosion:SetStart(Pos)
	Explosion:SetOrigin(Pos)
	util.Effect("Explosion", Explosion, true, true)
	
	self.Entity:EmitSound(self.BlastSound, 400, 150)
	
	local Owner = self.Entity 
	if IsValid(self:GetOwner()) then 
		Owner = self:GetOwner() 
	end 
	
	util.BlastDamage(self.Entity, Owner, Pos, 300, 100)
	
	self.Entity:Remove()
end
