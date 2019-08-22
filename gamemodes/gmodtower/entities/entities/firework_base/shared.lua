
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = Model("models/gmod_tower/firework_spinner.mdl")

ENT.IsRocket = false  //determines if this stays on the ground, or lifts up on its own
ENT.TypeTrail = 1 // 0 is no trail, 1 is rocket, 2 is sparkles, 3 is swirl, 4 is fountain, 5 is glow sprites


function ENT:UpdateSkin()
	self:SetMaterial( self.Skin or "" )
end