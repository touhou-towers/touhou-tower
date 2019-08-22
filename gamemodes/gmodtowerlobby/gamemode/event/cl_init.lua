module("minievent", package.seeall )

local DrawTimer = CreateClientConVar( "gmt_draweventtimer", 1, true, false )

hook.Add( "HUDPaint", "DrawNextEventTime", function()

	/*if DrawTimer:GetBool() then

		local endtime = GetWorldEntity().NextEventTime or CurTime()
		local eventname = GetWorldEntity().NextEvent or "N/A"
		local timeleft = 1800000 - os.time() % 1800000

		if timeleft <= 0 then
			timeleft = 0
		end

		local timeformat = string.FormattedTime( timeleft, "%02i:%02i" )
		local time = "NEXT EVENT (" .. string.upper( eventname ) .. ") IN " .. timeformat

		surface.SetFont( "GTowerHUDMainSmall" )

    local infoX = 25
    local infoY = ScrH() - 150

		local tw, th = surface.GetTextSize( time )
		local tx, ty = infoX + GTowerHUD.Info.Width-24-tw, infoY + GTowerHUD.Info.Height - 10

		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( tx + 1, ty + 1 )
		surface.DrawText( time )

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( tx, ty )
		surface.DrawText( time )

	end*/

end )
