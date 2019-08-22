
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	
	self.ImageZoom = 0.1
	
	self:DrawShadow( false )
	
end

function ENT:Draw()
	
end


function ENT:DrawTranslucent()

	local pos = self.Entity:GetPos()
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 		90 )
	ang:RotateAroundAxis(ang:Forward(), 		90 )

	cam.Start3D2D( pos, ang, self.ImageZoom )
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawRect( -220, -220, 440, 440 )

	cam.End3D2D()

end