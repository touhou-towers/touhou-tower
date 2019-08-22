
EFFECT.Mat = Material("gmod_tower/lobby/sale")

function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.NPC = data:GetEntity()
end

function EFFECT:Think( )
	return (self.NPC && self.NPC.Sale) // these deals can't last forever!
end

function EFFECT:Render( )
	render.SetMaterial( self.Mat )

	local sin = math.abs(math.sin(CurTime()*1.5))
	local eyevec = EyeVector()*-1
	eyevec.z = 0

	render.DrawQuadEasy(	self.Pos,
				eyevec,
				64 + sin*4,
				32 + sin*4,
				color_white,
				180
				)
end