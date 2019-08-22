
ENT.Type = "anim"
ENT.Category = "GMTower"

ENT.PrintName = "Tiny Bumper"
ENT.Spawnable = true

ENT.LitMaterial		= "models/gmod_tower/bumper/bumperskin_lit"
ENT.LitMat	= Material( ENT.LitMaterial )

function ENT:Bump()

	self:EmitSound(Sound("gmodtower/balls/bumper.wav"),70,150)
	self:SetMaterial( self.LitMaterial )
	timer.Simple(0.25,function()
		self:SetMaterial("")
	end)

end
