
local MaxJumpCount = 132

local function CountPlayerJump( ply )
	
	local Time = CurTime()
	
	if !ply._PlyJumpTablt then
		ply._PlyJumpTablt = {}
		ply._PlyJumpLast = Time
		ply._PlyJumpPointer = 1
		return
	end
	
	
	local Difference = Time - ply._PlyJumpLast
	
	ply._PlyJumpTablt[ ply._PlyJumpPointer ] = Difference
	ply._PlyJumpLast = Time
	ply._PlyJumpPointer = ply._PlyJumpPointer + 1
	
	if ply._PlyJumpPointer > MaxJumpCount then
		ply._PlyJumpPointer = 1
	end

end


hook.Add("KeyPress", "AntiAFKReset", function(ply, key)
	if IsValid(ply) && ply:Alive() then
		if key == IN_JUMP then
			CountPlayerJump( ply )
		else
			ply:AFKTimer()
		end
	end
end)

local function CheckJumping( ply, testfor )
	
	if !ply._PlyJumpTablt || !ply._PlyJumpTablt[1] then
		return
	end
	
	local TimeDiffs = {}
	local JumpTbl = ply._PlyJumpTablt
	local Avarge = 0
	local AvgCount = testfor or 0.05
	
	local function AddTime( time )
		local Val = math.abs( time )
		Avarge = Avarge + Val
		table.insert( TimeDiffs, Val )
	end
	
	for i=1, MaxJumpCount do
		if !JumpTbl[ i + 1 ] then
			AddTime( JumpTbl[i] - JumpTbl[1] )
			break
		else
			AddTime( JumpTbl[i] - JumpTbl[i+1] )
		end
	end

	Avarge = Avarge / #TimeDiffs
	
	local NearAvarge = 0
	
	for _, v in pairs( JumpTbl ) do
		if math.abs( v - Avarge ) < AvgCount then
			NearAvarge = NearAvarge + 1
		end	
	end
	
	return NearAvarge, #JumpTbl

end

concommand.Add("gmt_checkjump", function( ply, cmd, args )

	if ply != NULL && !ply:IsAdmin()  then	
		return
	end
	
	local Need = tonumber( args[1] ) or 50
	
	for _, v in pairs( player.GetAll() ) do
		
		local count, total = CheckJumping( v, tonumber( args[2] ) )
		
		if (count && total) && count >= Need then
			if ply == NULL then
				print( tostring(v) .. " avg: " .. AdvRound(count/total, 2) .. "("..count.."/"..total..")"  )
			else
				ply:Msg2( tostring(v) .. " avg: \t" .. AdvRound(count/total, 2) .. "("..count.."/"..total..")" )
			end
		end
		
	end

end )