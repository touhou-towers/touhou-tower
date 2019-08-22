AddCSLuaFile()
ENT.Base = "base_entity"
ENT.Type = "brush"

/*---------------------------------------------------------
   Name: Initialize
   Desc: First func called. Use to set up your entity
---------------------------------------------------------*/
function ENT:SetBounds(min, max)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(min, max)
	self:SetTrigger(true)
end


function ENT:Touch(ball)
	if (ball:GetClass() == "golfball") then
		if ball.IsPocketed != true then
			ball:GetOwner():Pocket()
			local phys = ball:GetPhysicsObject()
			if (IsValid(phys)) then
				if ball:GetOwner():Swing() > 1 then
					timer.Simple(2, function() phys:EnableMotion(false) ball:SetParent(self.Entity) end )
				end
			end
		end
	end
end

