include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize() 
	self:SetRenderBounds(Vector(-128,-128,-128), Vector(128,128,128))
end

function ENT:Think() end

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	// Aim the screen forward
	local ang = LocalPlayer():EyeAngles()
	local pos = self.Entity:GetPos() + Vector( 0, 0, 70 ) + ang:Up() * math.sin( CurTime() ) * 8
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	// Start the fun
	cam.Start3D2D( pos, ang, 1 )

		draw.DrawText( "Minigame!", "Gtowerhuge", -80, 0, Color( math.Rand(1, 255), math.Rand(1, 255), math.Rand(1, 255), 255 ) )

	cam.End3D2D()
end