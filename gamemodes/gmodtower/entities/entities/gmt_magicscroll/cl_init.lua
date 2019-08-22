
include("shared.lua")

function ENT:Initialize()

	self.RotSpeed = 45
	self.CanJump = false
	self.SpeedMultiplier = 1

	self.csModel = ClientsideModel("models/props_medieval/medieval_scroll.mdl")
	timer.Create("ScrollPTimer",.5,0,function()
		if self:GetNWBool("ShouldSpeedUp") then
		local vPoint = self:GetPos() + Vector(0,0,5)
		local effectdata = EffectData()
		effectdata:SetColor(255,0,0)
		effectdata:SetOrigin( vPoint )
		util.Effect( "pickup_money", effectdata )
		end
	end)
end

function ENT:Draw()

	local scrollAngle = (CurTime() * self.RotSpeed) % 360
	local scrollHeight = math.abs(math.sin(CurTime() * 1)) * self.SpeedMultiplier

	self.csModel:SetPos(self:GetPos() + Vector(0,0, scrollHeight-10))
	self.csModel:SetAngles(Angle(0,scrollAngle,0))
	self.csModel:DrawShadow(false)

end

function ENT:OnRemove()
	timer.Destroy("ScrollPTimer")
	self.csModel:Remove()
end

function ENT:Think()
    if self:GetNWBool("ShouldSpeedUp") and !self:GetNWBool("ShouldSlowDown") then
			self.SpeedMultiplier = math.Clamp(self.SpeedMultiplier + 0.1,1,50)
		elseif self:GetNWBool("ShouldSlowDown") and !self:GetNWBool("ShouldSpeedUp") then
			self.SpeedMultiplier = math.Clamp(self.SpeedMultiplier - 0.1,1,50)
		else
			self.SpeedMultiplier = 1
		end
end
