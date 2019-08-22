
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Duration = 7

ENT.RocketMultiplier = .08

ENT.Spins = false
ENT.SpinMultiplier = 10
ENT.SpinDirection = 2

ENT.ThinkEffect = "cball_explode"
ENT.EndEffect = nil

ENT.Shockwave = false

ENT.SoundLiftOff = Sound("GModTower/lobby/firework/firework_spinner.wav")