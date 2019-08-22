include('shared.lua')
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

ENT.PileMerge = 15

function ENT:Initialize()
	self:SetModel( self.Model )

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:DrawShadow(false)
	self:SetTrigger(true)

	self.Value = 1
	self.PickupTime = CurTime() + 1
	self.CombineCheck = self.PickupTime
	self.DieTime = CurTime() + 15
end

function ENT:Use(ply)
	self:Touch(ply)
end

function ENT:Touch(ent)
	if !self.RemovedNow && CurTime() > self.PickupTime && IsValid(ent) && ent:IsPlayer() then
		self.RemovedNow = true
		//ent:AddAchivement( ACHIVEMENTS.CANDYCORNCONSUMER, self.Value )
		self:Remove()
	end
end

function ENT:Think()
	if CurTime() > self.DieTime then
		self.RemovedNow = true
		self:Remove()
		return
	end
end

function ENT:PhysicsUpdate(phys)
	if phys:GetVelocity():Length() < 2 then
		phys:EnableMotion(false)
	end

	if self.RemovedNow || CurTime() < self.CombineCheck then return end
	self.CombineCheck = CurTime() + 1

	local nearby = ents.FindInSphere(self:GetPos(), 16)

	if #nearby < self.PileMerge then return end
	local corn = {}

	for k,v in pairs(nearby) do
		if v:GetClass() == "candycorn" && !v.RemovedNow then
			table.insert(corn, v)
		end		
	end

	if #corn < self.PileMerge then return end

	local removed = 0
	for k,v in pairs(corn) do
		v.RemovedNow = true
		v:Remove()
		removed = removed + 1
		if removed == self.PileMerge then break end 
	end

	local pile = ents.Create("candycornpile")
	pile:SetPos(self:GetPos())
	pile:Spawn()

	local phys = pile:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end

end