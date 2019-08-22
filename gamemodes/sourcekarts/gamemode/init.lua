
AddCSLuaFile("camsystem/cl_init.lua")
AddCSLuaFile("camsystem/shared.lua")
AddCSLuaFile("Catmull/shared.lua")

AddCSLuaFile("gmt/camera/" .. game.GetMap() .. ".lua")
AddCSLuaFile("gmt/cl_particles.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("nwtranslator.lua")
AddCSLuaFile("cl_controls.lua")

AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_huditem.lua" )

AddCSLuaFile("meta_camera.lua");
AddCSLuaFile("meta_player.lua")

AddCSLuaFile("checkpoints/cl_init.lua")
AddCSLuaFile("checkpoints/shared.lua")

AddCSLuaFile("cl_debug3d.lua")

AddCSLuaFile("sh_items.lua")
include("sh_items.lua")

include("multiserver.lua")

include("checkpoints/shared.lua")

include("camsystem/shared.lua")
include("Catmull/shared.lua")

include("meta_camera.lua");
include("meta_player.lua")

include("nwtranslator.lua")
include("shared.lua")

CreateConVar("gmt_srvid", 16 )

util.AddNetworkString("KartSpin")
util.AddNetworkString("HUDMessage")
util.AddNetworkString("KartJump")
util.AddNetworkString("online_music")

hook.Add("GTowerMsg", "GamemodeMessage", function()
	if player.GetCount() < 1 then
		return "#nogame"
	else
		/*if !GAMEMODE:IsBattle() then

		else

		end*/

		return tostring(GAMEMODE:GetTrack()) .. "/" .. "3" .. "||||" .. tostring(GAMEMODE:GetTrack()) .. "/" .. "3"

	end
end )

local PlyJoined = false

// OVERRIDES ///////////////////////////////////////////

  // Disables player damage
  function GM:EntityTakeDamage( target, dmg )
    return false
  end

  function GM:PlayerShouldTakeDamage( ply, attacker )
    return false
  end

  // Disables killing yourself
  function GM:CanPlayerSuicide( ply )
	   return false
  end

  // Disables the use of the flashlight
  function GM:PlayerSwitchFlashlight( ply )
    return false
  end

  // Handles spawning with a lot of players
  function GM:IsSpawnpointSuitable( ply, spawnpointent, bMakeSuitable )
      return true
  end

/////////////////////////////////////////////////////////

function GM:PlayerSpawn( ply )

	if !ply:IsBot() then

  timer.Simple(60,function()
    timer.Create("CheckEmpty",10,0,function()
      if player.GetCount() == 0 then
        self:EndServer()
      end
    end)
  end)

  end

 	// Set player model
 	hook.Call( "PlayerSetModel", GAMEMODE, ply )

  ply:SetNoDraw( true )

	local PlyCol = ply:GetInfo("cl_playercolor")

	ply:SetNWVector( "PlyColor", (Vector( PlyCol ) * 255) )

  if self:GetState() == STATE_WAITING then

    ply:SetTeam( TEAM_READY )

    timer.Simple(2.5,function()
		music.Play( 1, MUSIC_WAITING, ply )
      self:SpawnPlayerKart( ply, false )
    end)

    --self:SpawnPlayerKart( ply, false )

  elseif self:GetState() == STATE_BATTLE then
    ply:SetTeam( TEAM_PLAYING )

    ply:SetLapTime(CurTime())

    timer.Simple(2.5,function()
      music.Play( 1, MUSIC_BATTLE1, ply )
      self:SpawnPlayerKart( ply, true )
    end)
  else
    ply:SetTeam( TEAM_PLAYING )

    ply:SetLapTime(CurTime())

    --self:SpawnPlayerKart( ply, true )

    local TrackName = {}
    TrackName[1] = MUSIC_RACE1
    TrackName[2] = MUSIC_RACE2
    TrackName[3] = MUSIC_RACE3

    timer.Simple(2.5,function()
		music.Play( 1, TrackName[ self:GetTrack() ], ply )
      self:SpawnPlayerKart( ply, true )
    end)
  end

  if ( PlyJoined or ply:IsBot() ) then return end

  GAMEMODE:SetTime( GAMEMODE.WaitingTime )

  PlyJoined = true

end

function GM:PlayerDisconnected( ply )
	 if IsValid( ply:GetKart() ) then ply:GetKart():Remove() end
end

function GM:Complete( ply )

  if GAMEMODE:GetFinishedPlayers() == 0 then
    self:SetTime( self.FirstCountdown )
  end

  ply:SetTeam( TEAM_FINISHED )
  ply:ClearItems()

if ply:GetPosition() == 1 then
    music.Play( 1, MUSIC_WIN, ply )
	ply:AddAchivement( ACHIVEMENTS.SKCHAMP, 1 )
  else
    music.Play( 1, MUSIC_LOSE, ply )
  end

  local vPoint = ply:GetKart():GetPos()
  local effectdata = EffectData()
  effectdata:SetOrigin( vPoint )
  util.Effect( "confetti", effectdata, true, true )

  ply:GetKart():EmitSound( "gmodtower/misc/confetti.wav", 80, math.random(125,150) )

	ply:SetNWFloat( "FinishedTime", CurTime() )

end

function GM:Lap( ply )

  local NewLap = ply:GetLap() + 1

  if (ply:GetBestLapTime() == 0 || self:GetTimeElapsed(ply:GetLapTime()) < ply:GetBestLapTime()) then
    ply:SetBestLapTime( self:GetTimeElapsed(ply:GetLapTime()) )
  end

  if NewLap > 3 then
    GAMEMODE:Complete( ply )
    return
  end

  ply:SetLapTime(CurTime())

  ply:SetLap( ply:GetLap() + 1 )

  local vPoint = ply:GetKart():GetPos()
  local effectdata = EffectData()
  effectdata:SetOrigin( vPoint )
  util.Effect( "confetti", effectdata, true, true )

  ply:GetKart():EmitSound( "gmodtower/misc/confetti.wav", 80, math.random(125,150) )

end

function GM:SpawnPlayerKart( ply, engineon )

  for k,v in pairs(ents.FindByClass("info_kart_spawn")) do
    if ( !v.Player && tostring(v.Track) == tostring(self:GetTrack()) ) then
      if IsValid( ply:GetKart() ) then ply:GetKart():Remove() end
      v.Player = ply
      ply:SpawnKart( v:GetPos(), v:GetAngles(), engineon )
      return
    end
  end

end

function GM:Think()
	for k,v in pairs(player.GetAll()) do
		local PlyCol = v:GetInfo("cl_playercolor")
		v:SetNWVector( "PlyColor", (Vector( PlyCol ) * 255) )
	end

  if self:GetState() == STATE_WAITING then

    for k,v in pairs(player.GetAll()) do v:SetCamera("Waiting",0) end

    if (self:NoTimeLeft() && PlyJoined) then

      for k,v in pairs(player.GetAll()) do v:SetTeam( TEAM_PLAYING ) end

      self:SetTime( self.CameraTime * self.Cameras + 6 )

      self:SetState( STATE_READY )

      self:DoIntroCamera( self:GetTrack() )

    end
  elseif self:GetState() == STATE_READY then
    if self:NoTimeLeft() then

      for k,v in pairs( ents.FindByClass( "sk_kart" ) ) do v:SetIsEngineOn( true ) end

      self:SetTime( self.RaceTime )
      self:SetState( STATE_PLAYING )

      local TrackName = {}
      TrackName[1] = MUSIC_RACE1
      TrackName[2] = MUSIC_RACE2
      TrackName[3] = MUSIC_RACE3

	music.Play( 1, TrackName[ self:GetTrack() ] )

      for k,v in pairs(player.GetAll()) do

        v:SetLapTime(CurTime())
	v:SetNWFloat("StartedTime", CurTime())
        v:SetBestLapTime(0)
        v:SetTotalTime(CurTime())

        // Ready set go boost
        if v.RevTime && v.RevTime != 0 && v:KeyDown(IN_FORWARD) then
          local RevDelay = CurTime() - v.RevTime

          --v:ChatPrint(tostring( "Rev time was: "..RevDelay.." seconds..." ))

          if RevDelay < 2 then
            --v:ChatPrint(tostring( "Boosting!..." ))
            v:GetKart():SetIsBoosting( true )
			v:AddAchivement(ACHIVEMENTS.SKROLLING, 1)
            timer.Simple(RevDelay,function()
              v:GetKart():SetIsBoosting( false )
            end)
          else
            --v:ChatPrint(tostring( "Spinning..." ))
            v:GetKart():Spin()
          end

        end

      end

      self:SetTotalStartTime()

    end
  elseif self:GetState() == STATE_PLAYING then

    if ( self:GetFinishedPlayers() > 0 && self:NoTimeLeft() ) then
      GAMEMODE:GiveMoney( true )
      self:SetTime( 10 )

      if GAMEMODE:GetTrack() == 3 then
        self:SetState( STATE_TOBATTLE )
      elseif GAMEMODE:GetTrack() == 5 then
        self:SetState( STATE_ENDING )
      elseif GAMEMODE:GetTrack() == 4 then
        self:SetState( STATE_NEXTBATTLE )
      else
        self:SetState( STATE_NEXTTRACK )
      end

    elseif ( self:GetFinishedPlayers() == 0 && self:NoTimeLeft() ) then
      GAMEMODE:GiveMoney( true )
      self:SetTime( 10 )

      if GAMEMODE:GetTrack() == 3 then
        self:SetState( STATE_TOBATTLE )
      elseif GAMEMODE:GetTrack() == 5 then
        self:SetState( STATE_ENDING )
      elseif GAMEMODE:GetTrack() == 4 then
        self:SetState( STATE_NEXTBATTLE )
      else
        self:SetState( STATE_NEXTTRACK )
      end

    elseif ( self:GetFinishedPlayers() == player.GetCount() ) then
      GAMEMODE:GiveMoney( true )
      self:SetTime( 10 )

      if GAMEMODE:GetTrack() == 3 then
        self:SetState( STATE_TOBATTLE )
      elseif GAMEMODE:GetTrack() == 5 then
        self:SetState( STATE_ENDING )
      elseif GAMEMODE:GetTrack() == 4 then
        self:SetState( STATE_NEXTBATTLE )
      else
        self:SetState( STATE_NEXTTRACK )
      end

    end

  elseif self:GetState() == STATE_NEXTTRACK then

    if self:NoTimeLeft() then
      self:IncreaseTrack()
      for k,v in pairs(player.GetAll()) do
        v:SetTeam( TEAM_PLAYING )
        v:SetLap( 1 )
	v.PassedPoints = {}
        self:SpawnPlayerKart( v, false )
        v:ClearItems()
		--v:AddAchivement(ACHIVEMENTS.SKMILESTONE1, 1)
      end

      self:SetTime( self.CameraTime * self.Cameras + 6 )

      self:SetState( STATE_READY )

      self:DoIntroCamera( self:GetTrack() )
    end
  elseif self:GetState() == STATE_NEXTBATTLE then

    if self:NoTimeLeft() then
      self:IncreaseTrack()
      for k,v in pairs(player.GetAll()) do
        v:SetTeam( TEAM_PLAYING )
        v:SetLap( 1 )
        v:ClearItems()

        v:SetDeaths(0)
        v:SetFrags(0)
        v:SetGhost( false )
        v.Dead = false
        v:GetKart():SetIsGhost( false )
        v:GetKart():SetIsInvincible( false )
	v:SetTeam(TEAM_PLAYING)
      end

      self:SetRound(2)

      self:SetTime( self.BattleTime )

      self:SetState( STATE_BATTLE )
      music.Play( 1, MUSIC_BATTLE2 )
    end
  elseif self:GetState() == STATE_BATTLEENDING then

    if self:NoTimeLeft() then
      self:IncreaseTrack()

      self:SetTime( 10 )

      self:SetState( STATE_ENDING )

	music.Play( 1, MUSIC_WAITING )

      for k,v in pairs(player.GetAll()) do
        v:SetCamera( "Waiting", 0 )
        v:ClearItems()
		v:SetTeam( TEAM_PLAYING )
      end

    end
  elseif self:GetState() == STATE_ENDING then

    if self:NoTimeLeft() then
      self:EndServer()
    end
  elseif self:GetState() == STATE_BATTLE then

    if self:NoTimeLeft() then
      GAMEMODE:GiveMoney( false )
      self:SetTime( 10 )
      if self:GetTrack() == 5 then
        self:SetState( STATE_BATTLEENDING )
        for k,v in pairs(player.GetAll()) do
          v:ClearItems()
        end
      else
        self:SetState( STATE_NEXTBATTLE )
        for k,v in pairs(player.GetAll()) do
          v:ClearItems()
        end
      end
    else

      local deadcount = 0
      for k,v in pairs(player.GetAll()) do
        if v.Dead then deadcount = deadcount + 1 end
      end

      if deadcount == player.GetCount() - 1 then
        GAMEMODE:GiveMoney( false )
        self:SetTime( 10 )
        if self:GetTrack() == 5 then
          self:SetState( STATE_BATTLEENDING )
        else
          self:SetState( STATE_NEXTBATTLE )
        end
      end

    end
  elseif self:GetState() == STATE_TOBATTLE then

    if self:NoTimeLeft() then
      self:IncreaseTrack()

      self:SetTime( self.CameraTime * self.Cameras + 6 )

      self:SetState( STATE_BATTLEINTRO )

      music.Play( 1, MUSIC_BATTLEINTRO )

      for k,v in pairs(player.GetAll()) do
        v:SetTeam( TEAM_PLAYING )
        v:SetLap( 1 )
        self:SpawnPlayerKart( v, true )
        v:SetCamera( "Battle", 0 )
        v:ClearItems()
		--v:AddAchivement(ACHIVEMENTS.SKMILESTONE1, 1)
      end

      timer.Simple(13,function()

        self:SetTime( self.BattleTime )

        self:SetState( STATE_BATTLE )

        music.Play( 1, MUSIC_BATTLE1 )

        for k,v in pairs(player.GetAll()) do
          v:SetCamera( "Playing", 0 )
        end
      end)

    end

  end


end

function GM:DoIntroCamera( track )

  print("STARTING INTRO CAMERAS ON TRACK "..tostring(track))

music.Play( 1, MUSIC_CAMERA )

  for k,v in pairs( player.GetAll() ) do

    --v:SendLua([[surface.PlaySound('gmodtower/sourcekarts/music/race_reveal3.mp3')]])

    v:SetCamera( "Waiting"..tostring(track).."1", 0 )

    timer.Simple(GAMEMODE.CameraTime,function()
      v:SetCamera( "Waiting"..tostring(track).."2", 0 )
    end)

    timer.Simple(GAMEMODE.CameraTime*2,function()
      v:SetCamera( "Waiting"..tostring(track).."3", 0 )
    end)

    timer.Simple(GAMEMODE.CameraTime*3,function()
      v:SetCamera( "Playing", 0 )
    end)

  end
end

concommand.Add("sk_spawnkart",function(ply)
  if !ply:IsAdmin() then return end

  local e = ents.Create("sk_kart")
  e:SetOwner(ply)
  e:SetPos(ply:GetPos())
  e:Spawn()

  e:SetIsEngineOn(true)

end)

concommand.Add("sk_removekart",function(ply)
  if !ply:IsAdmin() then return end


  if IsValid(ply:GetKart()) then ply:GetKart():Remove() end

end)

concommand.Add("sk_horn",function(ply)
  --print("TOOT?")
  if !ply.HornDelay then ply.HornDelay = 0 end

  if !IsValid(ply:GetKart()) or !IsValid(ply) or CurTime() < ply.HornDelay then return end

  ply.HornDelay = CurTime() + 3
  --print("HONK!")

local hornnum = ply:GetInfoNum("sk_hornnum",3)

  ply:GetKart():EmitSound("gmodtower/sourcekarts/effects/horns/horn" .. hornnum .. ".wav" ,80)

end)

concommand.Add("sk_rev",function(ply)

  if GAMEMODE:GetState() != STATE_READY then return end

  if !ply.RevDelay then ply.RevDelay = 0 end
  if !IsValid(ply:GetKart()) or !IsValid(ply) or CurTime() < ply.RevDelay then return end

  ply.RevDelay = CurTime() + .25

  ply:GetKart():EmitSound("gmodtower/sourcekarts/effects/rev.wav", 100, math.random(100,110))

  ply.RevTime = CurTime()

end)
/*
local kart = net.ReadEntity()
local height = net.ReadFloat() * 5

local downrate = net.ReadFloat() * .25

*/
concommand.Add("sk_jump",function(ply)

  --if GAMEMODE:GetState() != STATE_PLAYING then return end

  local kart = ply:GetKart()

  if !IsValid(kart) then return end

  net.Start( "KartJump" )
    net.WriteEntity( ply )
    net.WriteEntity( kart )
    net.WriteFloat( 2.5 )
    net.WriteFloat( 5 )
  net.Broadcast()

end)

concommand.Add("sk_reset",function(ply)

  if GAMEMODE:GetState() == STATE_BATTLE then

    local kart = ply:GetKart()

    if !IsValid(kart) then return end

    if !ply.RespawnDelay then ply.RespawnDelay = 0 end
    if !IsValid(ply:GetKart()) or !IsValid(ply) or CurTime() < ply.RespawnDelay then return end

    ply.RespawnDelay = CurTime() + 5

    	// Fade out...

	PostEvent( ply, "fadeon" )

	local ForwardVel = 0 -- Used to save our velocity



	timer.Simple( .85, function()

		if IsValid( ply ) && IsValid( kart ) then

			local KartPhys = kart:GetPhysicsObject()

			ForwardVel = KartPhys:GetAngles():Forward():Dot( KartPhys:GetVelocity() ) -- Store our vel


      local spawns = {}

      for k,v in pairs( ents.FindByClass("info_kart_spawn") ) do
        if v.Track == "4" then
          table.insert( spawns, v )
        end
      end

      local ResetSpawn = table.Random( spawns )

			ply:SpawnKart( ResetSpawn:GetPos() + Vector(0,0,25), ResetSpawn:GetAngles(), true )

			PostEvent( ply, "fadeoff" )

      ply:ClearItems()

	  ply:TakeBattleDamage()

		end

	end )



	// Boost!!!

	timer.Simple( 1, function()

		if IsValid( ply ) then

			local kart = ply:GetKart()

			if IsValid( kart ) then

			   kart:Boost(2,0.5)
			end

		end

	end )


    return
  end

  if GAMEMODE:GetState() != STATE_PLAYING || ply:Team() != TEAM_PLAYING then return end

  local kart = ply:GetKart()

  if !IsValid(kart) then return end

  if !ply.RespawnDelay then ply.RespawnDelay = 0 end
  if !IsValid(ply:GetKart()) or !IsValid(ply) or CurTime() < ply.RespawnDelay then return end

  ply.RespawnDelay = CurTime() + 5

	local point = checkpoints.Points[ math.Clamp( ply:GetCheckpoint(), 1, #checkpoints.Points ) ]

	if !point then return end



	for i=point.id-4, point.id do

		ply.PassedPoints[i] = true

	end



	local ang = point.ang

	local pos = point.pos + ( ang:Up() * -110 )



	// Fade out...

	PostEvent( ply, "fadeon" )

  ply:ClearItems()
	local ForwardVel = 0 -- Used to save our velocity



	timer.Simple( .85, function()

		if IsValid( ply ) && IsValid( kart ) then

			local KartPhys = kart:GetPhysicsObject()

			ForwardVel = KartPhys:GetAngles():Forward():Dot( KartPhys:GetVelocity() ) -- Store our vel



			ply:SpawnKart( pos, ang, true )

			PostEvent( ply, "fadeoff" )


		end

	end )



	// Boost!!!

	timer.Simple( 1, function()

		if IsValid( ply ) then

			local kart = ply:GetKart()

			if IsValid( kart ) then

			   kart:Boost(2,0.5)
			end

		end

	end )


end)
