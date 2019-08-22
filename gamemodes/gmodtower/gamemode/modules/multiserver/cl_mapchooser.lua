
GTowerServers.MapChooserGUI = nil

GTowerServers.MapEndTime = 0
GTowerServers.MapTotalTime = 0
GTowerServers.ChoosenServer = 0
GTowerServers.ChoosenMap = ""
GTowerServers.ChoosenVotes = {}
GTowerServers.CooldownVotes = {}
GTowerServers.ChoosenServerId = 0
GTowerServers.CurrentGamemode = nil
GTowerServers.Music = nil

function GTowerServers:CanStillVoteMap()
	return math.max( GTowerServers.MapEndTime - CurTime(), 0 ) >= 1
end

function GTowerServers:ChooseMap( map )

	if GTowerServers:CanStillVoteMap() then
		GTowerServers.ChoosenMap = map
		RunConsoleCommand("gmt_mtsrv", "3", map )
	end

end

function GTowerServers:NoLongerWorking( serverid )

	if serverid == GTowerServers.ChoosenServerId then
		GTowerServers:CloseChooser()
	end

end

function GTowerServers:OpenChooser( ServerId, EndTime, GamemodeName, Votes, CooldownVotes )

	GTowerServers.ChoosenVotes = Votes
	GTowerServers.CooldownVotes = CooldownVotes
	GTowerServers.ChoosenServerId = ServerId

	// No need to reopen this, just update votes
	if self.MapChooserGUI && EndTime == GTowerServers.MapEndTime then
		self.MapChooserGUI:UpdateVotes()
		return
	end

	GTowerServers.MapEndTime = EndTime
	GTowerServers.MapTotalTime = EndTime - CurTime()
	GTowerServers.ChoosenMap = ""
	// Open map vote list
	local Gamemode = GTowerServers:GetGamemode( GamemodeName )
	GTowerServers:OpenGamemodeChooser( Gamemode )

end

function GTowerServers:OpenGamemodeChooser( Gamemode )
	self:CloseChooser()

	// Close all other windows
	//vgui.CloseDermaMenus()
	GTowerMenu:CloseAll()

	self.MapChooserGUI = vgui.Create( "MapSelector" )
	/*self.MapChooserGUI:SetPos( 0, 0 )
	self.MapChooserGUI:SetSize( ScrW(), ScrH() )
	self.MapChooserGUI:MakePopup()*/

	self.MapChooserGUI:SetGamemode( Gamemode )
	self.CurrentGamemode = Gamemode
	//// Music
	//if Gamemode.Music then
	//	local song = table.Random( Gamemode.Music )
	//	GTowerServers.Music = CreateSound( LocalPlayer(), song )
	//	GTowerServers.Music:PlayEx( .1, 100 )
	//end

end

function GTowerServers:CloseChooser()

	// we can't keep calling GTowerMainGui:GTowerHideMenus because of the frequency of this call
	if !ValidPanel( self.MapChooserGUI ) then return end

	GtowerMainGui:GtowerHideMenus()

	self.MapChooserGUI:Remove()
	self.MapChooserGUI = nil

	self.CurrentGamemode = nil
	self.ChoosenServerId = 0

	// Music
	if GTowerServers.Music && GTowerServers.Music:IsPlaying() then
		GTowerServers.Music:FadeOut( 2 )
	end

end

function GTowerServers:GetVotes( mapname )

	for id, map in pairs( self.MapChooserGUI.Gamemode.Maps ) do

		if map == mapname then
			return GTowerServers.ChoosenVotes[ id ] or 0
		end

	end

end

function GTowerServers:CanPlayMap( mapname )
	for id, map in pairs( self.MapChooserGUI.Gamemode.Maps ) do
	
		if map == mapname then
			if GTowerServers.CooldownVotes[id] == 1 then
				return false
			end
		end
	
	end
	return true
end

function GTowerServers:GetTotalVotes()

	local totalvotes = 0

	for id, map in pairs( self.MapChooserGUI.Gamemode.Maps ) do

		local votes = GTowerServers.ChoosenVotes[ id ] or 0
		totalvotes = totalvotes + votes

	end

	return totalvotes

end

hook.Add( "CalcView", "SpectateMap", function( ply, pos, ang, fov )

	if !ValidPanel( GTowerServers.MapChooserGUI ) then return end
	if GTowerServers.CurrentGamemode.View then
	pos = GTowerServers.CurrentGamemode.View.pos
	ang = GTowerServers.CurrentGamemode.View.ang
	end

	// Apply view
	local view = {}
	view.origin = pos
	view.angles = ang
	view.fov = fov

	return view

end )

hook.Add( "GShouldCalcView", "ShouldCalcVewBall", function( ply, pos, ang, fov )
	return ValidPanel( GTowerServers.MapChooserGUI )
end )

hook.Add( "CanOpenMenu", "GTowerMapSelection", function()
	if ValidPanel( GTowerServers.MapChooserGUI ) then
		return false
	end
end )

hook.Add( "CanCloseMenu", "GTowerMapSelection", function()
	if ValidPanel( GTowerServers.MapChooserGUI ) then
		return false
	end
end )

hook.Add( "DisableThirdpersonAll", "DisableThirdpersonAllMapSelection", function()
	return ValidPanel( GTowerServers.MapChooserGUI )
end )

hook.Add( "GTowerServerUpdate", "CheckForLocalPlayer", function( ServerId )

	if ServerId == GTowerServers.ChoosenServerId || GTowerServers.ChoosenServerId == 0 then

		local Server = GTowerServers.Servers[ ServerId ]

		if !table.HasValue( Server.Players, LocalPlayer() ) then
			GTowerServers:CloseChooser()
		end

	end

end  )

concommand.Add( "gmt_mapchooser", function( ply, cmd, args )

	if !ply:IsAdmin() then return end

	if #args != 1 then return end

	local Gamemode = GTowerServers:GetGamemode( args[1] )

	if Gamemode then
		GTowerServers:OpenGamemodeChooser( Gamemode )
	end
end )
