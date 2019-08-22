

-----------------------------------------------------
ENT.Type = "anim"
ENT.Base = "pvp_explosive_base"

ENT.Model = Model("models/weapons/w_slam.mdl")

ENT.StickSound = {
	Sound("physics/metal/sawblade_stick1.wav"),
	Sound("physics/metal/sawblade_stick2.wav"),
	Sound("physics/metal/sawblade_stick3.wav")
}

ENT.BlastSound	= "weapon_AWP.Single"

ENT.TrailColor = Color(255, 0, 0, 255)

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Active" )
end

function ENT:CreateBeam()
	local tr = {}
	tr.start = self:GetPos()
	
	local Forward = self:GetAngles()
	Forward:RotateAroundAxis(Forward:Right(), 90)
	
	tr.endpos = tr.start + (Forward:Forward() * 4096 )
	tr.mask = MASK_NPCWORLDSTATIC
	
	self:SetEndPos(util.TraceLine(tr).HitPos)
end

function ENT:SetEndPos(Pos)
	self.EndPos = Pos
end

function ENT:GetEndPos()
	return self.EndPos
end