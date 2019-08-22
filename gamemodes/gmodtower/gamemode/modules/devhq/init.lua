AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

timer.Create( "HeartBeatTimer", 10, 0, function() 
for k,v in pairs(player.GetAll()) do
	if v.GLocation == 9 then
		v:SendLua([[surface.PlaySound('room209/heartbeat.wav')]])
	end
end
end)

timer.Create( "ScreamsTimer", 25, 0, function() 

local alert = math.random(1,3)

for k,v in pairs(player.GetAll()) do
	if v.GLocation == 9 then
		v:SendLua([[surface.PlaySound('room209/ghost/alert]] .. tostring(alert) .. [[.wav')]])
	end
end
end)

timer.Create( "ElevTimer", 60, 0, function() 

local alert = math.random(1,3)

for k,v in pairs(player.GetAll()) do
	if v.GLocation == 9 then
		v:SendLua([[surface.PlaySound('gmodtower/lobby/halloween/elevator_voice.wav')]])
	end
end
for k,v in pairs(player.GetAll()) do
	if v.GLocation == 9 then
	StartBloodEvent()
	end
end
end)

concommand.Add("gmt_testparticle", function(ply, cmd, args, str)
	if !ply:IsAdmin() then return end
	local vPoint = ply:GetPos()
	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	util.Effect( str, effectdata, true, true ) 
end)

timer.Create( "WhisperTimer", 120, 0, function() 

local alert = math.random(1,2)

for k,v in pairs(player.GetAll()) do
	if v.GLocation == 9 then
		if alert == 1 then
			v:SendLua([[surface.PlaySound('gmodtower/lobby/halloween/ghostwhispers2.mp3')]])
		else
			v:SendLua([[surface.PlaySound('gmodtower/lobby/halloween/ghostwhispers.mp3')]])
		end
	end
end
end)

timer.Create( "ChantTimer", 10, 0, function() 

local alert = math.random(1,9)

for k,v in pairs(player.GetAll()) do
	if v.GLocation == 9 then
		v:SendLua([[surface.PlaySound('gmodtower/lobby/halloween/chant]]..tostring(alert)..[[.mp3')]])
	end
end
end)

local blood = {
	[1] = Vector(-404, -1305, 97),
	[2] = Vector(-415, -1245, 97),
	[3] = Vector(-418, -1194, 97),
	[4] = Vector(-421, -1143, 97),
	[5] = Vector(-423, -1103, 97),
	[6] = Vector(-418, -1030, 97),
}

function StartBloodEvent()
	for k,v in pairs(player.GetAll()) do
	if v.GLocation == 9 then
		v:SendLua([[surface.PlaySound('gmodtower/lobby/halloween/stinger4.wav')]])
		v:SendLua([[surface.PlaySound('gmodtower/lobby/halloween/wallslamming.wav')]])
	end
end

BloodAt( blood[1] )

timer.Simple( 1, function() 
	BloodAt( blood[2] )
end)

timer.Simple( 2, function() 
	BloodAt( blood[3] )
end)

timer.Simple( 3, function() 
	BloodAt( blood[4] )
end)

timer.Simple( 4, function() 
	BloodAt( blood[5] )
end)

timer.Simple( 5, function() 
	BloodAt( blood[6] )
end)

end

function BloodAt(pos)
	local vPoint = pos
	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	util.Effect( "bloodstream", effectdata )
end

hook.Add( "Location", "BWDev", function( ply, loc )

	if loc == 9 then
		PostEvent( ply, "bw_on" )
	else
		PostEvent( ply, "bw_off" )
	end
	
 end )