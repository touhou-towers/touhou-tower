
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:DrawTranslucent()

	local title = self.Title or "Unknown Store"
	local offset = Vector( 0, 0, 85 )

	if ( title == "PVP Battle Store" || title == "Ball Race Store" ) then
		offset = Vector( 0, 0, 110 )
	end

	if self.Sale then
		offset = Vector( 0, 0, 120 )
	end

	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + offset + ang:Up() * ( math.sin( CurTime() ) * 4 )

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )

		draw.DrawText( title, "GTowerNPC", 2, 2, Color( 0, 0, 0, 225 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.DrawText( title, "GTowerNPC", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	cam.End3D2D()

end
