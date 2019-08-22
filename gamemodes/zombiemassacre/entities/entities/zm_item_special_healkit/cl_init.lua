include( "shared.lua" )
ENT.MatLight 	= Material( "sprites/gmdm_pickups/light" )
ENT.MatBeam		= Material( "effects/tool_tracer" )
ENT.MatRing		= Material( "effects/select_ring" )
function ENT:Initialize()
	--self.BaseClass.Initialize( self )
	self.Size = 0
	self.Alpha = 0
	--self:SetRenderBoundsWS( self:GetPos(), self:GetPos(), Vector() * self.Radius )
end
function ENT:DrawTranslucent()
	self:DrawModel()
	local angles = self:GetAngles()
	local norm = angles:Up()
	local sizeto = 40
	local alphato = 20
	local spread = 20
	local color = Color( 255, 255, 255, 255 )
	for id, ply in pairs( player.GetAll() ) do
		if self:IsInRadius( ply )  && ply:Alive() then
			sizeto = 128
			alphato = 255
			spread = 30
			color = Color( math.random( 0, 50 ), 255, math.random( 0, 50 ), 255 )
			local pos = ply:GetPos() + Vector( 0, 0, 20 )
			local length = ( pos - self:GetPos() ):Length()
			// Beam
			render.SetMaterial( self.MatBeam )
			render.DrawBeam( pos,
							 self:GetPos(),
							 20,
							 CurTime() / 3,
							 ( CurTime() / 3 ) + length / 256,
							 Color( 255, 255, 255, self.Alpha )
			)
			// Sprite
			render.SetMaterial( self.MatLight )
			render.DrawSprite( pos, 50, 50, color )
		end
	end
	self.Size = math.Approach( self.Size, sizeto, FrameTime() * 150 )
	self.Alpha = math.Approach( self.Alpha, alphato, FrameTime() * 150 )
	// Rings
	render.SetMaterial( self.MatRing )
	for i=1, 3 do
		render.DrawQuadEasy( self:GetPos() + norm + Vector( 0, 0, spread * i ),
							norm,
							self.Size, self.Size,
							Color( color.r, color.g, color.b, self.Alpha ) )
	end
end
