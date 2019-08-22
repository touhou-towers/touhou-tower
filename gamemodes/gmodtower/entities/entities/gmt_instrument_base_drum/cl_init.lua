

-----------------------------------------------------
include("shared.lua")

local Volume = CreateClientConVar( "gmt_volume_instrument", 80, true, false )

ENT.DEBUG = false

ENT.KeysDown = {}
ENT.KeysWasDown = {}

ENT.AllowAdvancedMode = false
ENT.AdvancedMode = false
ENT.ShiftMode = false
ENT.SlightPitchChange = false

ENT.PageTurnSound = Sound( "GModTower/inventory/move_paper.wav" )
surface.CreateFont( "InstrumentKeyLabel", {
	size = 22, weight = 400, antialias = true, font = "Impact"
} )
surface.CreateFont( "InstrumentNotice", {
	size = 30, weight = 400, antialias = true, font = "Impact"
} )

// For drawing purposes
// Override by adding MatWidth/MatHeight to key data
ENT.DefaultMatWidth = 128
ENT.DefaultMatHeight = 128
// Override by adding TextX/TextY to key data
ENT.DefaultTextX = 5
ENT.DefaultTextY = 10
ENT.DefaultTextColor = Color( 150, 150, 150, 255 )
ENT.DefaultTextColorActive = Color( 80, 80, 80, 255 )
ENT.DefaultTextInfoColor = Color( 120, 120, 120, 150 )

ENT.MaterialDir	= ""
ENT.KeyMaterials = {}

ENT.MainHUD = {
	Material = nil,
	X = 0,
	Y = 0,
	TextureWidth = 128,
	TextureHeight = 128,
	Width = 128,
	Height = 128,
}

ENT.AdvMainHUD = {
	Material = nil,
	X = 0,
	Y = 0,
	TextureWidth = 128,
	TextureHeight = 128,
	Width = 128,
	Height = 128,
}

ENT.BrowserHUD = {
	URL = "http://www.gmtower.org/apps/instruments/piano.php",
	Show = true, // display the sheet music?
	X = 0,
	Y = 0,
	Width = 1024,
	Height = 768,
}

function ENT:Initialize()
	self:PrecacheMaterials()
end

function ENT:Think()

	if gui.IsGameUIVisible() or gui.IsConsoleVisible() then return end
	if !IsValid( LocalPlayer().Instrument ) || LocalPlayer().Instrument != self then return end

	if self.DelayKey && self.DelayKey > CurTime() then return end

	// Update last pressed
	for keylast, keyData in pairs( self.KeysDown ) do
		self.KeysWasDown[ keylast ] = self.KeysDown[ keylast ]
	end

	// Get keys
	for key, keyData in pairs( self.Keys ) do

		// Update key status
		self.KeysDown[ key ] = input.IsKeyDown( key )

		// Check for note keys
		if self:IsKeyTriggered( key ) then

			if self.ShiftMode && keyData.Shift then
				self:OnRegisteredKeyPlayed( keyData.Shift.Sound )
			elseif !self.ShiftMode then
				self:OnRegisteredKeyPlayed( keyData.Sound )
			end

		end

	end

	// Get control keys
	for key, keyData in pairs( self.ControlKeys ) do

		// Update key status
		self.KeysDown[ key ] = input.IsKeyDown( tonumber(key) )

		// Check for control keys
		if self:IsKeyTriggered( key ) then
			keyData( self, true )
		end

		// was a control key released?
		if self:IsKeyReleased( key ) then
			keyData( self, false )
		end

	end

	// Send da keys to everyone
	//self:SendKeys()

end

function ENT:IsKeyTriggered( key )
	return self.KeysDown[ key ] && !self.KeysWasDown[ key ]
end

function ENT:IsKeyReleased( key )
	return self.KeysWasDown[ key ] && !self.KeysDown[ key ]
end

function ENT:OnRegisteredKeyPlayed( key )
	// Play on the client first
	local sound = self:GetSound( key )
	local pitch = 100
	if self.SlightPitchChange then pitch = math.random( 98, 102 ) end
	self:EmitSound( sound, 100, pitch )

	// Network it
	net.Start( "InstrumentNetworkDrum" )

		net.WriteEntity( self )
		net.WriteInt( INSTNET_PLAY, 3 )
		net.WriteString( key )

	net.SendToServer()

	// Add the notes (limit to max notes)
	/*if #self.KeysToSend < self.MaxKeys then

		if !table.HasValue( self.KeysToSend, key ) then // only different notes, please
			table.insert( self.KeysToSend, key )
		end

	end*/

end

// Network it up, yo
function ENT:SendKeys()
	if !self.KeysToSend then return end

	// Send the queue of notes to everyone

	// Play on the client first
	for _, key in ipairs( self.KeysToSend ) do

		local sound = self:GetSound( key )

		if sound then
			local pitch = 100
			if self.SlightPitchChange then pitch = math.random( 98, 102 ) end
			self:EmitSound( sound, 100, pitch )
		end

	end

	// Clear queue
	self.KeysToSend = nil

end

function ENT:DrawKey( mainX, mainY, key, keyData, bShiftMode )
end

function ENT:DrawHUD()
end

// This is so I don't have to do GetTextureID in the table EACH TIME, ugh
function ENT:PrecacheMaterials()

	if !self.Keys then return end

	self.KeyMaterialIDs = {}

	for name, keyMaterial in pairs( self.KeyMaterials ) do
		if type( keyMaterial ) == "string" then // TODO: what the fuck, this table is randomly created
			self.KeyMaterialIDs[name] = surface.GetTextureID( keyMaterial )
		end
	end

	if self.MainHUD.Material then
		self.MainHUD.MatID = surface.GetTextureID( self.MainHUD.Material )
	end

	if self.AdvMainHUD.Material then
		self.AdvMainHUD.MatID = surface.GetTextureID( self.AdvMainHUD.Material )
	end

end

function ENT:OpenSheetMusic()

	if ValidPanel( self.Browser ) || !self.BrowserHUD.Show then return end

	self.Browser = vgui.Create( "HTML" )
	self.Browser:SetVisible( false )

	local width = self.BrowserHUD.Width

	if self.BrowserHUD.AdvWidth && self.AdvancedMode then
		width = self.BrowserHUD.AdvWidth
	end

	local url = self.BrowserHUD.URL

	if self.AdvancedMode then
		url = self.BrowserHUD.URL .. "?&adv=1"
	end

	local x = self.BrowserHUD.X - ( width / 2 )

	self.Browser:OpenURL( url )

	// This is delayed because otherwise it won't load at all
	// for some silly reason...
	timer.Simple( .1, function()

		if ValidPanel( self.Browser ) then
			self.Browser:SetVisible( true )
			self.Browser:SetPos( x, self.BrowserHUD.Y )
			self.Browser:SetSize( width, self.BrowserHUD.Height )
		end

	end )

end

function ENT:CloseSheetMusic()

	if !ValidPanel( self.Browser ) then return end

	self.Browser:Remove()
	self.Browser = nil

end

function ENT:ToggleSheetMusic()

	if ValidPanel( self.Browser ) then
		self:CloseSheetMusic()
	else
		self:OpenSheetMusic()
	end

end

function ENT:SheetMusicForward()

	if !ValidPanel( self.Browser ) then return end

	self.Browser:Exec( "pageForward()" )
	self:EmitSound( self.PageTurnSound, 100, math.random( 120, 150 ) )

end

function ENT:SheetMusicBack()

	if !ValidPanel( self.Browser ) then return end

	self.Browser:Exec( "pageBack()" )
	self:EmitSound( self.PageTurnSound, 100, math.random( 100, 120 ) )

end

function ENT:OnRemove()

	self:CloseSheetMusic()

end

function ENT:Shutdown()

	self:CloseSheetMusic()

	self.AdvancedMode = false
	self.ShiftMode = false

	if self.OldKeys then
		self.Keys = self.OldKeys
		self.OldKeys = nil
	end

end

function ENT:ToggleAdvancedMode()
	self.AdvancedMode = !self.AdvancedMode

	if ValidPanel( self.Browser ) then
		self:CloseSheetMusic()
		self:OpenSheetMusic()
	end

end

function ENT:ToggleShiftMode()
	self.ShiftMode = !self.ShiftMode
end

function ENT:ShiftMod() end // Called when they press shift
function ENT:CtrlMod() end // Called when they press cntrl

hook.Add( "HUDPaint", "InstrumentPaint", function()

	if IsValid( LocalPlayer().Instrument ) then

		// HUD
		local inst = LocalPlayer().Instrument
		inst:DrawHUD()

		// Notice bar
		local name = inst.PrintName or "INSTRUMENT"
		name = string.upper( name )

		surface.SetDrawColor( 0, 0, 0, 180 )
		surface.DrawRect( 0, ScrH() - 60, ScrW(), 60 )

		draw.SimpleText( "PRESS TAB TO LEAVE THE " .. name, "InstrumentNotice", ScrW() / 2, ScrH() - 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1 )

	end

end )

// Override regular keys
hook.Add( "PlayerBindPress", "InstrumentHook", function( ply, bind, pressed )

	if IsValid( ply.Instrument ) then
		return true
	end

end )

local function GetClientVolume()
	return Volume:GetInt() / 100
end

net.Receive( "InstrumentNetworkDrum", function( length, client )

	local ent = net.ReadEntity()
	local enum = net.ReadInt( 3 )

	// When the player uses it or leaves it
	if enum == INSTNET_USE then

		if IsValid( LocalPlayer().Instrument ) then
			LocalPlayer().Instrument:Shutdown()
		end

		ent.DelayKey = CurTime() + .1 // delay to the key a bit so they don't play on use key
		LocalPlayer().Instrument = ent

	// Play the notes for everyone else
	elseif enum == INSTNET_HEAR then

		// Instrument doesn't exist
		if !IsValid( ent ) then return end

		// Don't play for the owner, they've already heard it!
		if IsValid( LocalPlayer().Instrument ) && LocalPlayer().Instrument == ent then
			return
		end

		// Gather note
		local key = net.ReadString()
		local sound = ent:GetSound( key )

		if sound then
			local pitch = 100
			if ent.SlightPitchChange then pitch = math.random( 98, 102 ) end
			ent:EmitSound( sound, math.Fit(GetClientVolume() * 100,0,100,35,100), pitch )
		end

		// Gather notes
		/*local keys = net.ReadTable()

		for i=1, #keys do

			local key = keys[1]
			local sound = ent:GetSound( key )

			if sound then
				ent:EmitSound( sound, 80 )

				local eff = EffectData()
				eff:SetOrigin( ent:GetPos() + Vector(0, 0, 60) )
				eff:SetEntity( ent )

				util.Effect( "musicnotes", eff, true, true )
			end

		end*/

	end

end )
