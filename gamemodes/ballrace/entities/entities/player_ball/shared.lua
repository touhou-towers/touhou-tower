ENT.Type 			= "anim"
ENT.Base			= "base_anim"
ENT.PrintName			= "Ball"
ENT.Author			= "AzuiSleet"

ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

ENT.Model			= Model("models/gmod_tower/BALL.mdl")

ENT.RollSound			= Sound("GModTower/balls/BallRoll.wav")

function ENT:Initialize()
    self:SetCustomCollisionCheck( true )
end
