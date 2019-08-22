
surface.CreateFont( "T_TITLE", {
	font = "Roboto",
	extended = false,
	size = 150,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
})

net.Receive("UpdateTourTitle",function()

  ply = net.ReadEntity()
  if LocalPlayer() != ply then return end
  enabled = net.ReadBool()
  if enabled then
    TourActive = true
    text = net.ReadString()
  else
    TourActive = false
  end


end)

text = "Loading..."

net.Receive("DisplaySkipButton",function()

  if net.ReadEntity() != LocalPlayer() then return end

  if net.ReadBool() then
		local SkipButton = vgui.Create( "DButton" )
    SkipButton:SetText( "Skip Tour" )
    SkipButton:SetPos( -250, ScrH()/2 )
    SkipButton:SetSize( 200, 30 )
    SkipButton:MoveTo(25,ScrH()/2,2,1,-10)
    SkipButton.DoClick = function()
  	   RunConsoleCommand( "gmt_endtour" )
       SkipButton:Remove()
     end
		 timer.Create("HideSkipButton",118,1,function()
			if IsValid(SkipButton) then
				SkipButton:Remove()
		 	end
		 end)
	else
		if timer.Exists("HideSkipButton") then
			timer.Destroy("HideSkipButton")
		end
  end

end)

hook.Add( "HUDPaint", "TourTitle", function()
  if !TourActive then return end
  surface.SetFont("T_TITLE")
  surface.SetDrawColor(25,25,25,200)
  surface.DrawRect( 0, ScrH()/1.2, ScrW(), select(2, surface.GetTextSize( text )))
	draw.DrawText( text, "BDON_LARGE", ScrW()/2, ScrH()/1.2, Color( 255, 255, 255, 200 ), TEXT_ALIGN_CENTER )
end )
