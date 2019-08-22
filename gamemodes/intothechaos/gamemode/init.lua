
// === FILE INCLUDING ===

include( "shared.lua" )
include( "sh_sfx.lua" )
include( "sv_trains.lua" )
include( "meta_player.lua" )
AddCSLuaFile( "meta_player.lua" )
AddCSLuaFile( "sh_sfx.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_doors.lua" )
AddCSLuaFile( "cl_hud.lua" )

// === MAIN OVERRIDES ===

function GM:IsSpawnpointSuitable()
    return true
end

function GM:PlayerSwitchFlashlight()
    return false
end

function GM:PlayerShouldTakeDamage( ply, att )
  if !att:IsPlayer() then return true end
end

// === MAIN GAMEMODE ===

function GM:PlayerSpawn( ply )
  ply:SetWalkSpeed( self.WalkSpeed )
  ply:SetRunSpeed( self.WalkSpeed + 15 )
  ply:SetCrouchedWalkSpeed( self.WalkSpeed - 15 )

  ply:SetNWFloat("Battery",1)

  ply:SetCustomCollisionCheck(true)

  self:GiveChaosLoadout( ply )

  hook.Call( "PlayerSetModel", GAMEMODE, ply )

  timer.Simple(2.5,function()
    music.Play( 1, MUSIC_CHAOS, ply )
  end)

end

function GM:GiveChaosLoadout( ply )
  for k,v in pairs( self.WeaponList ) do ply:Give( v ) end
end

local function SpawnGhost( SpawnEnt )
  local e = ents.Create( table.Random( GAMEMODE.GhostList ) )
  e:SetPos( SpawnEnt:GetPos() + Vector(0,0,10) )
  e:Spawn()
  SpawnEnt.Ent = e

  local vPoint = Vector( e:GetPos() )
  local effectdata = EffectData()
  effectdata:SetOrigin( vPoint )
  util.Effect( "zombspawn", effectdata, true, true )

end

function GM:InitPostEntity()
  /*timer.Create( "SpawnGhosts", 10, 0, function()

    for k,v in pairs( ents.FindByClass("info_ghost_spawn") ) do
      if !IsValid( v.Ent ) then
        local e = ents.Create( table.Random( self.GhostList ) )
        e:SetPos( v:GetPos() )
        e:Spawn()
        v.Ent = e
      end
    end

  end)*/

  timer.Create( "SpawnGhosts", 5, 0, function()

  local SpawnTable = ents.FindByClass("info_ghost_spawn")
  local Spawn      = math.random( 1, #SpawnTable )
  local SpawnEnt   = SpawnTable[ Spawn ]
  if !IsValid( SpawnEnt.Ent ) then
    SpawnGhost( SpawnEnt )
  elseif (Spawn != #SpawnTable) then
    SpawnEnt = SpawnTable[ Spawn + 1 ]
    if IsValid( SpawnEnt.Ent ) then return end
    SpawnGhost( SpawnEnt )
  else
    SpawnEnt = SpawnTable[ Spawn - 1 ]
    if IsValid( SpawnEnt.Ent ) then return end
    SpawnGhost( SpawnEnt )
  end

  end)
end

function GM:Think()
  for k,v in pairs( player.GetAll() ) do
    local newBat = v:GetNWFloat("Battery") - FrameTime() / 50

    if v:GetActiveWeapon():GetClass() != "tracker" then
      newBat = v:GetNWFloat("Battery") + FrameTime() / 50
    end

    v:SetNWFloat( "Battery", math.Clamp( newBat, 0, 1 ) )

  end
end
