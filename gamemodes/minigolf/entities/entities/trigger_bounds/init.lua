ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:SetBounds(min, max)
	self:SetCollisionBounds(min, max)
	self:SetTrigger(true)
end

function ENT:Touch(ball)
	if (ball:GetClass() == "golfball") then
		ball.HitBounds = true
	end
end

