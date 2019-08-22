
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Duration = 2.25

ENT.RocketMultiplier = .03

ENT.Spins = false
ENT.SpinMultiplier = 10

ENT.ThinkEffect = nil
ENT.EndEffect = "firework_screamer"

ENT.Shockwave = true
ENT.TrailRandomColor = true

ENT.SoundLiftOff = Sound("GModTower/lobby/firework/firework_screamer.wav")