
ENT.Type 			= "anim"
ENT.PrintName 		= "Pink Sims Bed"
ENT.Author 			= "GMod Tower Team"
ENT.Contact 		= "http://www.gmodtower.org"
ENT.Purpose 		= "The suite bed, for sleeping in."
ENT.Instructions 	= "Press use to sleep."

ENT.Models		= {	"models/sims/gm_pinkbed.mdl",
				"models/sims/gm_pinkbed.mdl"}

ENT.SleepSound		= Sound("GModTower/music/sleep.mp3")
ENT.HealSound		= Sound("player/geiger1.wav")
local StoreBedId = nil

function ENT:GetStoreId()
	return StoreBedId
end
