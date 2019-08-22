
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Duration = 3

ENT.RocketMultiplier = .018

ENT.Spins = true
ENT.SpinMultiplier = 15
ENT.SpinDirection = 3

ENT.ThinkEffect = nil
ENT.EndEffect = nil

ENT.Shockwave = false
ENT.TrailRandomColor = true

ENT.SoundLiftOff = Sound("GModTower/lobby/firework/firework_ufolaunch.wav")