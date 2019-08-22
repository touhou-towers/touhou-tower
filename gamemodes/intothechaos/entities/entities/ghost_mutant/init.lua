AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Model = Model( "models/characters/mutants/major/major.mdl" )

ENT.HP = 400
ENT.Damage = 30
ENT.Points = 32

ENT.SAlert = { "room209/ghost/alert", 3 }
ENT.SAttack = { "room209/ghost/attack", 3 }
ENT.SDie = { "room209/ghost/death", 3 }
ENT.SIdle = { "room209/ghost/idle", 5 }
ENT.SPain = { "room209/ghost/pain", 3 }
