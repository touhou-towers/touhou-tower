
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.LastModel = ""
ENT.LastPlayerModel = ""
ENT.LastScale = Vector(0,0,0)

local HatsGM = {}
HatsGM["ballrace"] = true
HatsGM["minigolf"] = false
HatsGM["sourcekarts"] = true
HatsGM["zombiemassacre"] = true
HatsGM["virus"] = false
HatsGM["ultimatechimerahunt"] = false

function ENT:Initialize()
	self:SetRenderBounds( Vector(-60, -60, -60), Vector(60, 60, 60) )
	self:DrawShadow(false)

	self:InitOffset()
end

function ENT:InitOffset()
end

function ENT:Think()
	local ply = self:GetOwner()

	if !IsValid(ply) then return end

	local r,g,b,a = ply:GetColor()
	self:SetColor(r,g,b,a)
	self:SetMaterial(ply:GetMaterial())

	if self.PlayerEquipIndex == 0 then
		self:AddToEquipment()
	end

	if self:GetModel() != self.LastModel || ply:GetModel() != self.LastPlayerModel || ply:GetModelScale() != self.LastScale then

		self.LastModel = self:GetModel()
		self.LastPlayerModel = ply:GetModel()
		self.LastScale = ply:GetModelScale()

		self:UpdatedModel(ply)
	end

	self:NextThink(CurTime() + 0.1)
end

function ENT:UpdatedModel()

end

function ENT:Draw()
	if self:Position() == nil then return end
	local pos, ang = self:Position()
	if pos != false then
		self:SetPos(pos)
		self:SetAngles(ang)
		self:DrawModel()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Position()
	local ply = self:GetOwner()

	if !self:Check( ply ) then return false end

	//if !IsValid(ply) || ( ply == LocalPlayer() && !GAMEMODE:ShouldDrawLocalPlayer( true ) ) then return false end

	if GAMEMODE.OverrideHatEntity then
		ply = GAMEMODE:OverrideHatEntity(ply)
	elseif !ply:Alive() then
		ply = ply:GetRagdollEntity()
	end

	if !IsValid(ply) then return false end
	ply:SetupBones()

	return self:PositionItem(ply)
end

function ENT:Check( ply )
	if !IsValid( ply ) then return false end

	if ply == LocalPlayer() then
		if ply.ThirdPerson || !ply:Alive() || HatsGM[engine.ActiveGamemode()] then
			return true
		end

		return false
	end

	return true
end

function ENT:PositionItem()
	return false
end

local PlayerMeta = FindMetaTable("Player")

// manual drawing for ballrace!
function PlayerMeta:ManualEquipmentDraw()
 	if !self.CosmeticEquipment then return end

	for k,v in pairs(self.CosmeticEquipment) do
		if v.DrawTranslucent then // really crappy computers can't handle drawing
			v:DrawTranslucent()
		end
	end
end
