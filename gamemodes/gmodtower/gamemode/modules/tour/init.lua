
util.AddNetworkString("UpdateTourTitle")
util.AddNetworkString("DisplaySkipButton")
AddCSLuaFile("cl_init.lua")

concommand.Add("gmt_starttour",function(ply)

  if !string.StartWith( game.GetMap(), "gmt_build" ) then return end

  ply:SetNWBool("IsWatchingTour", true)
  ply:SetNWBool("EndedTour",false)
  ply:ConCommand("gmt_hud 0")
  ply:ConCommand("gmt_ambiance_enable 0")
  net.Start("DisplaySkipButton")
  net.WriteEntity(ply)
  net.WriteBool(true)
  net.Broadcast()
  InitTour(ply)
end)

concommand.Add("gmt_endtour",function(ply)

  if !string.StartWith( game.GetMap(), "gmt_build" ) then return end

  InitTour(ply, true)
  ply:SetNWBool("EndedTour",true)
  --ply:CrosshairEnable()
  ply:ConCommand("gmt_hud 1")
  ply:ConCommand("gmt_ambiance_enable 1")
  ply:Freeze(false)
  ply:SetMoveType(MOVETYPE_WALK)
  ply:SetNoDraw( false )

  net.Start("DisplaySkipButton")
  net.WriteEntity(ply)
  net.WriteBool(false)
  net.Broadcast()

  net.Start("UpdateTourTitle")
  net.WriteEntity(ply)
  net.WriteBool(false)
  net.Broadcast()

  if ply:GetNWBool("IsWatchingTour") then
    ply:SetPos(Vector(250, -3664, -230))
    ply:SetEyeAngles(Angle(0,0,0))
    ply:SetNWBool("IsWatchingTour",false)
  end

end)

function InitTour(ply, stop)

  if stop then
    TourAudio:Stop()
    return
  end

  TourAudio = CreateSound(ply,"GModTower/tour/tour.mp3")
  timer.Simple(1,function() TourAudio:Play() end)

  ply:SetMoveType(MOVETYPE_NOCLIP)
  ply:Freeze(true)
  ply:CrosshairDisable()
  ply:SetNoDraw( true )

  timer.Simple(0,function() SendCam(ply, Vector(-10195, 10464, 39), Angle(-27, 111, 0), "Welcome!") end)
  timer.Simple(8,function() SendCam(ply, Vector(1106.784058, -1974.384888, 152), Angle(10.160307, 109.821609, 0), "The Lobby") end)
  timer.Simple(38,function() SendCam(ply, Vector(734.720947, 1582.478760, 63), Angle(-3.553025, -69.822960, 0), "Entertainment Plaza") end)
  timer.Simple(57,function() SendCam(ply, Vector(367, -1477, 50), Angle(-15, 180, 0), "The Theater") end)
  timer.Simple(67,function() SendCam(ply, Vector(-1749.079590, 2053.278809, 51.235008), Angle(-4.275013, 33.303940, 0), "The Arcade") end)
  timer.Simple(82,function() SendCam(ply, Vector(10735.080078, 10621.224609, 6749.930664), Angle(-3, -180, 0), "Gamemode Ports") end)
  timer.Simple(96,function() SendCam(ply, Vector(4715.258301, -9992.108398, 4155.892090), Angle(-1.657023, -134.834183, 0), "Suites") end)
  timer.Simple(119,function()
    if ply:GetNWBool("EndedTour") then return end
    SendCam(ply, Vector(250, -3664, -191), Angle(0,0,0), "Have fun!")
    timer.Simple(1,function() ply:ConCommand("gmt_endtour") end)
    if ply:GetNWBool("WatchedTour") then return end
    ply:AddMoney(25)
    ply:SetNWBool("WatchedTour", true)
  end)

end

function SendCam(ply, pos, ang, title)

  if ply:GetNWBool("EndedTour") then return end

  ply:ScreenFade(SCREENFADE.OUT,Color(0,0,0),0.5,1)

  timer.Simple(0.5,function()
    ply:Freeze(false)
  end)

  timer.Simple(0.6,function()
    ply:SetPos(pos)
    ply:SetEyeAngles(ang)
  end)

  timer.Simple(0.75,function()
    ply:SetEyeAngles(ang)
    ply:ScreenFade(SCREENFADE.IN,Color(0,0,0),0.5,1)
    ply:Freeze(true)
  end)

  net.Start("UpdateTourTitle")
  net.WriteEntity(ply)
  net.WriteBool(true)
  net.WriteString(title)
  net.Broadcast()

end
