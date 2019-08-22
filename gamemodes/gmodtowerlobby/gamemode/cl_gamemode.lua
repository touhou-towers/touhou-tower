
-----------------------------------------------------
module( "GamemodeQueueMenu", package.seeall )

local PANEL = {}
PANEL.Padding = 2

function PANEL:Init()

	self.Color = color_transparent

	self.Title = vgui.Create( "DLabel", self )
	self.Title:SetText( "YOU ARE IN A QUEUE FOR" )
	self.Title:SetFont( "GTowerHUDMainSmall" )
	self.Title:SizeToContents()
	self.Title:CenterHorizontal()
	self.Title.y = self.Padding

	self.GMode = vgui.Create( "DLabel", self )
	self.GMode:SetText( "BALL RACE" )
	self.GMode:SetFont( "GTowerHUDHuge" )
	self.GMode:SizeToContents()
	self.GMode:CenterHorizontal()
	self.GMode.y = self.Title.y + 12

	self.LeaveButton = vgui.Create("DButton", self)
	self.LeaveButton:SetText( "Leave Queue" )
	self.LeaveButton:SetWide( 100 )

	self.LeaveButton:CenterHorizontal()
	self.LeaveButton.y = self.GMode.y + self.GMode:GetTall()

	self.LeaveButton.DoClick = function()
		Derma_Query( "Do you want to leave the queue?", "Leave Gamemode Queue",
			T("yes"), function() RunConsoleCommand("gmt_mtsrv", 2) end,
			T("no"), nil
		)
	end

end

function PANEL:Resize()

	self:SetSize( math.max( self.GMode:GetWide(), self.Title:GetWide() ) + 16, 90 + ( self.Padding * 2 ) )

	self.Title:CenterHorizontal()
	self.GMode:CenterHorizontal()
	self.LeaveButton:CenterHorizontal()

end

function PANEL:Paint( w, h )
	draw.RoundedBox( 6, 0, 0, w, h, Color( 3, 25, 54, 200 ) )
end

derma.DefineControl( "GamemodeQueueStatus", "", PANEL, "DPanel" )


net.Receive( "MultiserverJoinRemove", function( len, ply )

	local enabled = net.ReadInt( 2 )

	if enabled == 1 then
		Create( net.ReadString() or "" )
	else
		Remove()
	end

end )

function Create( title )

	Remove()

	GUI = vgui.Create("GamemodeQueueStatus")
	GUI:SetPos( ScrW()/2-GUI:GetWide()/2, ScrH()-110 )
	GUI:SetVisible( false )
	GUI.Think = function( panel )

		local ypos = 110

		-- Move up for ball race chooser GUI.
		if BallRacerChooser then
			if ValidPanel( BallRacerChooser.GUI ) then
				ypos = 110 + (BallRacerChooser.GUI:GetTall()-14)
			end
		end

		panel:SetPos( ScrW()/2-panel:GetWide()/2, ScrH()-ypos )

	end

	if title == "ultimatechimerahunt" then
		title = "UCH"
	elseif title == "pvpbattle" then
		title = "PvP Battle"
	elseif title == "sourcekarts" then
		title = "Source Karts"
	elseif title == "gourmetrace" then
		title = "Gourmet Race"
	elseif title == "zombiemassacre" then
		title = "Zombie Massacre"
	end


	GUI.GMode:SetText( string.upper(title) )
	GUI.GMode:SizeToContents()

	GUI:Resize()

end

function Remove()

	if GUI and IsValid( GUI ) then
		GUI:Remove()
		GUI = nil
	end

end

hook.Add("GtowerShowMenus", "ShowGamemode", function()
	if GUI and IsValid( GUI ) then
		GUI:SetVisible( true )
	end
end )
hook.Add("GtowerHideMenus", "HideGamemode", function()
	if GUI and IsValid( GUI ) then
		GUI:SetVisible( false )
	end
end )
