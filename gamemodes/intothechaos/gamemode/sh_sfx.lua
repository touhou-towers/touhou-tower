
if SERVER then

local AlarmSnd = Sound( "ambient/levels/outland/basealarmloop.wav" )

  sound.Play( AlarmSnd, Vector(-1054, -966, 291), 80 )

else

local HeartSnd = Sound( "room209/heartbeat.wav" )

timer.Create("HeartBeatTimer",6,0,function()
  if IsValid( LocalPlayer() ) && !LocalPlayer():InVehicle() then
    LocalPlayer():EmitSound( HeartSnd, 40 )
  end
end)

end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
  local num = math.random(1,4)
	ply:EmitSound( "room209/carpet" .. tostring(num) .. ".wav", 45 )
	return true
end
