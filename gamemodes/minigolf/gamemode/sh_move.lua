-----------------------------------------------------
local novel = Vector(0, 0, 0)

function GM:Move(ply, movedata)
	--if IsValid( ply:GetGolfBall() ) || ( !self:IsPlaying() && self:GetState() != STATE_WAITING ) then
	if IsValid(ply:GetGolfBall()) then
		movedata:SetForwardSpeed(0)
		movedata:SetSideSpeed(0)
		movedata:SetVelocity(novel)

		if SERVER then
			ply:SetGroundEntity(NULL)
		end

		local ball = ply:GetGolfBall()
		local offset = 16

		if IsValid(ball) then
			if ball:WaterLevel() > 0 then
				offset = 64
			end

			movedata:SetOrigin(ball:GetPos() + Vector(0, 0, offset))
		end

		return true
	end

	if not ply:Alive() then
		return true
	end
end
