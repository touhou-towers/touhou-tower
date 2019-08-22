ENT.Type 			= "anim"
ENT.Base			= "pvp_powerup_base"
ENT.PrintName		= "Headphones Power-Up"
ENT.Author			= "MacDGuy"

ENT.Model = "models/gmod_tower/headheart.mdl"
ENT.ActiveTime = 30
ENT.Sound1 = "GModTower/pvpbattle/HeadphonesOn.mp3"
ENT.Sound2 = "GModTower/pvpbattle/HeadphonesDie.mp3"

GtowerPrecacheModel( ENT.Model )
GtowerPrecacheSound( ENT.Sound1 )
GtowerPrecacheSound( ENT.Sound2 )
