
include("shared.lua")

CreateClientConVar("gmt_petname_bcorn","",true,true)

function ENT:DrawText( text, font, x, y, alpha, xalign, yalign )
	if text then
		draw.DrawText( text, font, x + 2, y + 2, Color( 0, 0, 0, alpha ), xalign, yalign )
		draw.DrawText( text, font, x, y, Color( 255, 255, 255, alpha ), xalign, yalign )
	end
	
end

function ENT:Draw()

	self.Entity:DrawModel()
	
	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + self:GetUp() * -50
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	pos.z = pos.z + 30
	
	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
		
		if self:GetPetName() and self:GetPetName() != "" then
			self:DrawText( self:GetPetName(), "PetName", 0, -30, 255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

	cam.End3D2D()
	
end
