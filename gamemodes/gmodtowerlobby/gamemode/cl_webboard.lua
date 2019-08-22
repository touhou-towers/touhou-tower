/*
local pos = Vector(1656.03, -764.8, 300)
local ang = Angle(0, 314.042, 90)
local width = 1024
local height = 1024
local scale = 0.25
--local url = "http://83.128.17.45/MyWeb/Leaderboards/changelog2/index.php"
local url = "http://127.0.0.1/bumpy/index.php"

UpdatePanel = vgui.Create( "HTML" )
UpdatePanel:SetPos( pos )
UpdatePanel:SetSize( width, height )
UpdatePanel:OpenURL( url )
UpdatePanel:SetAlpha( 0 )

-- Prevents the update panel from loading on other maps
if string.StartWith(game.GetMap(),"gmt_build") then
	UpdateScreenEnabled = true
else
	UpdateScreenEnabled = false
end

local function DrawSign()
    -- Draw the update panel
		if UpdatePanel:GetHTMLMaterial() != nil then
			render.SetMaterial(UpdatePanel:GetHTMLMaterial())
      render.DrawQuad(Vector(0, 0, 0),
        Vector(width, 0, 0),
        Vector(width, height, 0),
        Vector(0, height, 0))
		end
end

hook.Add("RenderScreenspaceEffects", "3DHTMLSign", function()
		if UpdateScreenEnabled == true then
     cam.Start3D(EyePos(), EyeAngles())
     cam.Start3D2D(pos, ang, scale)
     local status, err = pcall(DrawSign)
     cam.End3D2D()
     if not status then Error(err) end
	 end
end)

concommand.Add("gmtc_refresh_updatepanel",function()
	UpdatePanel:Refresh(true)
	print("Update panel refreshed...")
end)
*/
