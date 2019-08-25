function GM:Move(ply, move)
	if ply:KeyDown(IN_FORWARD) and ply:KeyDown(IN_MOVELEFT) then
		move:SetMoveAngles(Angle(315, 0, 0))
	elseif ply:KeyDown(IN_FORWARD) and ply:KeyDown(IN_MOVERIGHT) then
		move:SetMoveAngles(Angle(45, 0, 0))
	elseif ply:KeyDown(IN_BACK) and ply:KeyDown(IN_MOVELEFT) then
		move:SetMoveAngles(Angle(0, 0, 315))
	elseif ply:KeyDown(IN_BACK) and ply:KeyDown(IN_MOVERIGHT) then
		move:SetMoveAngles(Angle(0, 0, 45))
	else
		if ply:KeyDown(IN_FORWARD) then
			move:SetMoveAngles(Angle(0, 0, 0))
		elseif ply:KeyDown(IN_MOVELEFT) then
			move:SetMoveAngles(Angle(270, 0, 0))
		elseif ply:KeyDown(IN_MOVERIGHT) then
			move:SetMoveAngles(Angle(90, 0, 0))
		elseif ply:KeyDown(IN_BACK) then
			move:SetMoveAngles(Angle(0, 0, 180))
		end
	end
end
