AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

ENT.Model = Model( "models/characters/mutants/major/major.mdl" )

ENT.HP = 400
ENT.Damage = 5
ENT.Points = 32

ENT.SAlert = { "GModTower/Zom/creatures/mutant/alert", 3 }
ENT.SAttack = { "GModTower/Zom/creatures/mutant/attack", 3 }
ENT.SDie = { "GModTower/Zom/creatures/mutant/death", 3 }
ENT.SIdle = { "GModTower/Zom/creatures/mutant/idle", 5 }
ENT.SPain = { "GModTower/Zom/creatures/mutant/pain", 3 }