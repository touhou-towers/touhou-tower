local saturn = surface.GetTextureID( "UCH/hud_saturnbeacon" )

function GM:DrawSaturn()

	if !LocalPlayer():IsPig() then return end

	for k, v in ipairs( ents.FindByClass( "mr_saturn" ) ) do

		if !IsValid( v ) then return end

		local name = "Mr. Saturn"
		local pos = ( v:GetPos() + Vector( 0, 0, 25 ) ):ToScreen()

		local dist = LocalPlayer():GetPos():Distance( v:GetPos() )

		if dist <= 250 || dist >= 1024 then return end
		local opacity = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 200 ) // woot mathematica

		if pos.visible then

			local x, y = pos.x, pos.y
			local size = 64 //math.Clamp( dist / 64, 0, 64 )

			cam.Start2D()

				surface.SetTexture( saturn )
				surface.SetDrawColor( Color( 255, 255, 255, opacity ) )
				surface.DrawTexturedRect( x - (size/2), y - (size/2), size, size )

				/*draw.SimpleText( name, "UCH_TargetIDName", x + 2, y + 2, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( name, "UCH_TargetIDName", x, y, color_gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )*/

			cam.End2D()

		end

	end
	
end



// I don't know what the fuck I'm doing - so fuck this code.  Feel free to make this work!
/*local PANEL = {}

function PANEL:Init()

	self:SetModel( "models/gmod_tower/arrow.mdl" )
	
	self.Visible = false
	self:SetPos( ScrW() - 1 , 0 )
	
	self:PerformLayout()

end

function PANEL:Think()

	self:PerformLayout()

end

function PANEL:LayoutEntity( ent )

	if !IsValid( LocalPlayer() ) || !LocalPlayer():IsPig() then return end

	self:SetCamPos( Vector( 0, 20, 0 ) )
	self:SetLookAt( Vector( 0, 0, 0 ) )

	local saturn = ents.FindByClass( "mr_saturn" )[1]
	if !IsValid( saturn ) then self.Visible = false return end

	local TargetDir = saturn:GetPos()
	
	if TargetDir == Vector( 0, 0, 0 ) && self.Visible then

		self:MoveTo( ScrW() - 1, 0, 1, 0, 0.5 )
		self.Visible = false

	else

		self:MoveTo( ScrW() - self:GetWide(), 0, 1, 0, 2 )
		self.Visible = true

	end

	local TargetDir = ( LocalPlayer():EyePos() - TargetDir )
	TargetDir.z = 0

	local dir = TargetDir:Angle()
	local eyeangle = LocalPlayer():EyeAngles()

	eyeangle.pitch = 0
	local dir = dir - eyeangle

	ent:SetPos( Vector( 0, 0, 0 ) )
	ent:SetAngles( dir + Angle( 0, 90, 0 ) )
	ent:SetModelScale( Vector( .5, .5, .5 ) )

end

function PANEL:PerformLayout()

	self:SetSize( ScrW() * 0.3, ScrW() * 0.3 )

end

if Compass then Compass:Remove() end
Compass = vgui.CreateFromTable( vgui.RegisterTable( PANEL, "DModelPanel" ) )*/