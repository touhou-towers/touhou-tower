

-----------------------------------------------------
module( "ping", package.seeall )

local enableNotice = CreateClientConVar( "gmt_notice_reconnect", 1, true, false )

ConnectionTimeout = 20
LostConnection = false
LastPing = RealTime() + ConnectionTimeout

ReconnectIn = 30

net.Receive( "ServerPing", function( length, ply )

	LastPing = RealTime()
	RunConsoleCommand( "cl_timeout", 500 )

	// Get the IP and port to reconnect to
	/*if !IP then IP = game.GetIP() end
	if !Port then Port = GetConVarNumber("port") end*/

end )

hook.Add( "Think", "ClientPingCheck", function( ply )

	if !enableNotice:GetBool() then return end

	LostConnection = ( RealTime() - LastPing > ConnectionTimeout )

	if LostConnection then

		// Slowly increase that jazzy music

		if !ReconnectDelay then

			ReconnectDelay = RealTime() + ReconnectIn

			RunConsoleCommand( "stopsound" )

		end

		// Force a reconnect
		if ReconnectDelay < RealTime() then
			RunConsoleCommand( "retry" )
		end

	else
		ReconnectDelay = nil

		if LostConnectionMusic then
			LostConnectionMusic:Stop()
			LostConnectionMusic = nil
		end
	end

end )

hook.Add( "HUDPaint", "ClientPingDisplay", function()

	if !enableNotice:GetBool() then return end
	if !LostConnection then return end

	local w, h = ScrW() / 2, ScrH() / 2
	local x, y = ScrW() / 2, ScrH() / 2
	h = ( h * 2 ) - 150

	// Draw gradient boxes
	/*draw.GradientBox( x - 512, y, 256, 110, 0, Color( 0, 0, 0, 0 ), Color( 0, 0, 0, 230 ) )
	draw.GradientBox( x + 256, y, 256, 110, 0, Color( 0, 0, 0, 230 ), Color( 0, 0, 0, 0 ) )
	surface.SetDrawColor( 0, 0, 0, 230 )
	surface.DrawRect( x - 255, y, 512, 110 )*/
	surface.SetDrawColor( 0, 0, 0, 230 )
	surface.DrawRect( w - 512, y, 1024, 110 )

	// Draw title
	draw.WaveyText( "LOST CONNECTION TO SERVER", "GTowerHudCText", x, y + 40, Color( 255, 255, 255, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5 )

	// Draw text
	local timeleft = math.ceil( ReconnectDelay - RealTime() )

	if timeleft > 2 then
		draw.RainbowText( "Sorry, hold on! We're going to try to reconnect you in " .. math.ceil( ReconnectDelay - RealTime() ) + 2, "GTowerHudCSubText", x, y + 75, 255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 100, 2 )
	else
		draw.RainbowText( "Hold on to your butts, we're reconnecting to the server!", "GTowerHudCSubText", x, y + 75, 255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 100, 2 )
	end

end )
