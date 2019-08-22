
-----------------------------------------------------
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Choo Choo Train"
ENT.Author			= "Foohy"
ENT.Information		= "It spins around"
ENT.Category		= "GMT Bullshit"

ENT.Spawnable		= true
ENT.AdminSpawnable	= true

ENT.Model			= Model( "models/gmod_tower/xmas_ttrack.mdl" )
ENT.Editable 		= true

-- Defaults for when spawning. To change it after spawn, use
--		trainent:SetRadius(int)
--		trainent:SetTrainVelocity(int)
--		trainent:SetTrainCount(int)
ENT.Radius = 75
ENT.TrainVelocity = 70
ENT.TrainCount = 7


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Radius", { KeyName = "Radius", Edit = { type = "Int", min = 1, max = 5000, order = 2 }})
	self:NetworkVar("Int", 1, "TrainVelocity", { KeyName = "Velocity", Edit = { type = "Int", min = 1, max = 1000, order = 3 }})
	self:NetworkVar("Int", 2, "TrainCount", { KeyName = "Number of carts", Edit = { type = "Int", min = 1, max = 30, order = 4 }})
end

--ImplementNW() -- Implement transmit tools instead of DTVars
