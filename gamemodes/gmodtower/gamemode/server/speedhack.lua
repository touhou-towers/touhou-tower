
/*
Anti-Speed hack, modified from my code by Spacetech
*/

AntiHack = {}
AntiHack.CrashTime = 360
AntiHack.MinMoveNum = 160
AntiHack.AverageCalc = false

local Collect = RealTime()
local Lag, Count, TotalMoveNum, Message

function AntiHack.PlayerInitialSpawn(ply)
	ply.MoveNum = 0
	ply.CrashTime = 0
	ply.KickedByAntiHack = false
end
hook.Add("PlayerInitialSpawn", "AntiHack.PlayerInitialSpawn", AntiHack.PlayerInitialSpawn)

function AntiHack.Move(ply, MoveData)
	if(AntiHack.AverageCalc) then
		if(ply.MoveNum > (AntiHack.AverageCalc + 170) and ply.MoveNum > AntiHack.MinMoveNum) then
			if !ply.KickedByAntiHack then
				ply.KickedByAntiHack = true
				ply:Kick("Speed Hacking")
			end
		end
	end
	ply.MoveNum = ply.MoveNum + 1
end
hook.Add("Move", "AntiHack.Move", AntiHack.Move)

function AntiHack.Think()
	if(RealTime() < Collect + 1) then
		return
	end
	
	Lag = RealTime() - Collect
	
	Count = 0
	TotalMoveNum = 0
	
	for k,v in pairs(player.GetAll()) do
		if(Lag < 1.5) then
			if(v.MoveNum == 0) then
				if(v.CrashTime == 0) then
					v.CrashTime = RealTime()
				elseif(RealTime() - v.CrashTime > AntiHack.CrashTime and !v:InVehicle()) then
					hook.Call("OnAFK", GAMEMODE, v, true)
				end
			elseif(v.CrashTime != 0) then
				v.CrashTime = 0
			end
		end
		if(v:Alive()) then
			Count = Count + 1
			TotalMoveNum = TotalMoveNum + v.MoveNum
		end
		v.MoveNum = 0
	end
	
	AntiHack.AverageCalc = TotalMoveNum / Count
	
	Collect = Collect + 1
end
hook.Add("Think", "AntiHack.Think", AntiHack.Think)