
-----------------------------------------------------
include('shared.lua')
ENT.RenderGroup = RENDERGROUP_BOTH

surface.CreateFont( "PokerText", { font = "Bebas Neue", size = 48, weight = 500 } )
surface.CreateFont( "PokerNames", { font = "Bebas Neue", size = 32, weight = 500 } )
surface.CreateFont( "PokerSmall", { font = "Bebas Neue", size = 24, weight = 500 } )
surface.CreateFont( "PokerTiny", { font = "Bebas Neue", size = 18, weight = 500 } )

// NOTE: If you are going to get the player count (#self.Players) use table.Count(self.Players)
// The # operator doesn't count gaps in tables so just use that.

include('cl_panel_board.lua')
include('cl_panel_player.lua')

function ENT:Initialize()
	self.Players = {}
end

function ENT:Draw()

	self:SetRenderBounds( self:OBBMins(), self:OBBMaxs() + Vector(0, 0, 65) )
	self:DrawModel()

end

local reveal = Sound( "gmodtower/casino/poker_reveal.mp3" )
function ENT:Think()

	
end

// ========================================================
// POKER 3D2D DRAWING
// ========================================================

function ENT:DrawTranslucent()

	local tr = util.GetPlayerTrace( LocalPlayer(), GetMouseAimVector() )
	local trace = util.TraceLine( tr )
	if trace.Entity != self and !self:IsInGame( LocalPlayer() ) then return end
	
	local pos = self:GetPos() + Vector( 0, 0, self:GetTournament() and 70 or 60 ) + Vector(0,0, math.sin( RealTime() ) * 4 )
	local eyes = LocalPlayer():EyeAngles()
	local ang = Angle(0,eyes.y-90,0)

	if LocalPlayer():InVehicle() then
		local look=(pos-LocalPlayer():EyePos()):Angle()+Angle(-90,0,0)
		ang=Angle(-90,look.y,0)
		ang:RotateAroundAxis(ang:Up(),-90)
	end

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .25 )

		// Draw players
		pcall(function()
		if self.Players then

			local texty = self:GetTournament() and self:GetState() > self.States.NOPLAY and -270 or self:GetTournament() and -200 or -160
			for _, ply in pairs( self.Players ) do

				if !IsValid( ply ) then
					table.remove( self.Players, table.KeyFromValue( self.Players, ply ) )
					continue
				end

				texty = texty + 22

				// Get name and their current action
				local name = ply:GetName()
				local action = self:GetAction( ply )
				local actionname = self:GetActionName( action )
				if action && actionname then name = name .. " " .. actionname end

				draw.SimpleShadowText( name, "PokerNames", 0, texty, Color( 150, 150, 150, 255 ) )

				// Draw current player
				local cur = ( self:GetCurrentPlayer() == ply )
				if cur && self:StateHasTurns() then
					draw.SimpleShadowText( name, "PokerNames", 0, texty, Color( 255, 150, 150, 255 ) )
				end

				// Draw winning players
				if self.Winners && table.HasValue( self.Winners, ply ) then
					local color = colorutil.Smooth( 2 )
					draw.SimpleShadowText( name, "PokerNames", 0, texty, color )
				end

			end

		end

		// Draw Game Title
		local title = self:GetStateTitle()
		draw.TextBackground( title, "PokerText", 0, -38, 8 )
		draw.SimpleShadowText( title, "PokerText", 0, -15 )

		// Tourney mode
		if self:GetTournament() then
			
			local text = self:GetState() > self.States.NOPLAY and "Tournament in progress" or "Tournament mode"
			draw.TextBackground( text, "PokerText", 0, -38 - 40, 8 )
			draw.SimpleShadowText( text, "PokerText", 0, -38 - 40 + 23, colorutil.Smooth( 1 ) )

		end

		// Draw Player Count
		local state = self:GetState()
		if state == self.States.NOPLAY ||  state == self.States.STARTING and !self:GetTournament() then

			local playerCount = ( table.Count(self.Players) or 0 ) .. " / " .. self.MaxPlayers

			draw.TextBackground( playerCount, "PokerText", 0, 2, 8 )
			draw.SimpleShadowText( playerCount, "PokerText", 0, 24 )

			if !self:GetTournament() then
				
				draw.SimpleShadowText( "Min Bet", "PokerNames", -85, 16, Color( 150, 150, 150 ) )
				draw.SimpleShadowText( self:GetMinBet(), "PokerText", -85, 16 + 28 )

				draw.SimpleShadowText( "Max Bet", "PokerNames", 85, 16, Color( 150, 150, 150 ) )
				draw.SimpleShadowText( self:GetMaxBet(), "PokerText", 85, 16 + 28 )

			end

		// Draw Pot Amount
		else

			local pot = "POT: " .. string.FormatNumber( self:GetPot() ) .. " Chips"
			surface.SetFont( "PokerText" )
			local width = surface.GetTextSize( pot )
			draw.TextBackground( pot, "PokerText", 0, 0, 8 )
			draw.SimpleShadowText( pot, "PokerText", 0, 22 )

			local min, max = "Min Bet", "Max Bet"

			if self:GetTournament() then
				min = "Sm. Blind"
				max = "Big Blind"

				draw.SimpleShadowText( min, "PokerNames", -45, 54, Color( 150, 150, 150 ) )
				draw.SimpleShadowText( self:GetMinBet(), "PokerText", -45, 54 + 28 )

				draw.SimpleShadowText( max, "PokerNames", 45, 54, Color( 150, 150, 150 ) )
				draw.SimpleShadowText( self:GetMaxBet(), "PokerText", 45, 54 + 28 )

				
				draw.SimpleShadowText( "Grand Prize", "PokerNames", 0, -130, Color( 150, 150, 150 ) )
				draw.SimpleShadowText( string.Comma( self:GetGrandPrize() ) .. " GMC", "PokerText", 0, -130 + 28 )

			end

			/*if self:GetRound() > 0 then
				local round = "Round: " .. self:GetRound() or 0
				draw.TextBackground( round, "PokerNames", 130, 0, 8 )
				draw.SimpleShadowText( round, "PokerNames", 130, 22 )
			end*/

		end
		end)

	cam.End3D2D()

end


// ========================================================
// MAIN POKER PANEL CREATION
// ========================================================

--local PokerPanel = nil
PokerPanel = PokerPanel or nil
local function CreateMainPanel( ent, invisible )

	PokerPanel = vgui.Create( "HoldemPanel" )
	PokerPanel:SetSize( 1024, 700 ) //Panel:SetSize( ScrW(), ScrH() )
	PokerPanel:SetPos( ScrW() / 2 - ( 1024 / 2 ), ScrH() / 2 - ( 700 / 2 ) )
	PokerPanel:SetTable( ent )
	PokerPanel:SetVisible( !invisible )

	PokerPanel:HighlightThink()
	PokerPanel:SetupCommunity()

end

hook.Add( "CanOpenMenu", "CanOpenMenuHoldem", function()
	if ValidPanel( PokerPanel ) then
		return false
	end
end )

/*hook.Add( "Location", "LocationCasino", function( ply, id )
	
	if !Location.IsCasino( id ) then

		if ValidPanel( PokerPanel ) then
			PokerPanel:Remove()
			GTowerMainGui:ToggleCursor( false )
		end

	end

end )*/

function ENT:OnRemove()

	if self.Music and self.Music.Remove then
		
		self.Music:Stop()
		self.Music = nil

	end

end

// ========================================================
// MAIN POKER NETWORKING
// ========================================================

local function ClearVars( ply, ent )

	ply.CurrentHand = nil
	ply._PAction = nil
	ply._PLastAction = nil
	ply._PActionVar = nil
	ply._PLastActionVar = nil
	ent.Winners = nil
	ent:SetIn( ply, 0 )

end
local SongLengths = { 74, 96, 131, 60 } // because SoundLength doesnt work on mp3's
function ENT:Think()

	if self.MusicPlaying and self.MusicEnd < RealTime() then

		local rnd = math.random( 1, 4 )
		self.Music = CreateSound( self, "GModTower/casino/cards/round" .. rnd .. ".mp3" )
		self.Music:PlayEx( .5, 100 )
		self.MusicEnd = RealTime() + SongLengths[rnd]

	end

end

net.Receive( "ClientHoldem", function( length, ply )

	local ent = net.ReadEntity()
	local ply = net.ReadEntity()
	local enum = net.ReadInt( 5 )

	if !IsValid( ent ) || ent:GetClass() != "gmt_casino_holdem" then return end

	// PLAYER JOINED
	if enum == ent.Network.JOIN then

		ent.Players = net.ReadTable()

		if !IsValid( ply ) then return end
		ClearVars( ply, ent )

		// Sound
		if ply == LocalPlayer() then
			CreateMainPanel( ent, true )
			local rnd = math.random( 1, 4 )
			ent.Music = CreateSound( ent, "GModTower/casino/cards/round" .. rnd .. ".mp3" )
			ent.Music:PlayEx( .5, 100 )
			ent.MusicEnd = RealTime() + SongLengths[rnd]
			ent.MusicPlaying = true
		end

		return

	end


	// PLAYER LEFT
	if enum == ent.Network.LEAVE then

		ent.Players = net.ReadTable()

		if !IsValid( ply ) then return end
		ClearVars( ply, ent )

		if ply == LocalPlayer() then

			if ValidPanel( PokerPanel ) then
				PokerPanel:Remove()
				RememberCursorPosition()
				gui.EnableScreenClicker( false )
			end

			// Sound
			if ent.Music && ent.Music.FadeOut then
				ent.Music:FadeOut( 1 )
				ent.MusicEnd = nil
				ent.MusicPlaying = nil
			end

		end

		return

	end


	// PLAYER PREFORMED AN ACTION
	if enum == ent.Network.ACTION then

		if !IsValid( ply ) then return end

		// Store last action so players don't forget
		ply._PLastAction = ply._PAction
		ply._PLastActionVar = ply._PActionVar
		ply._PAction = net.ReadInt( 4 )

		// Handle extra info like raise/call amount and discard amount
		if ply._PAction == ent.Actions.RAISE || ply._PAction == ent.Actions.CALL then

			ply._PActionVar = net.ReadInt( 32 )

		// Fold / All in
		elseif ply._PAction == ent.Actions.FOLD || ply._PAction == ent.Actions.FOLDAUTO || ply._PAction == ent.Actions.ALLIN then

			ply._PActionVar = nil

		end

		return

	end


	// PLAYER UPDATED IN
	if enum == ent.Network.IN then

		if !IsValid( ply ) then return end
		ent:SetIn( ply, net.ReadInt( 32 ) )

		return

	end


	// WE GOT WINNERS!
	if enum == ent.Network.WINNER then

		ent.Players = net.ReadTable()
		ent.Winners = net.ReadTable()

		// Music
		if ent:IsInGame( LocalPlayer() ) then

			if ent.Music && ent.Music.FadeOut then
				ent.Music:FadeOut( .5 )
			end

			// Play win/lose music
			if table.HasValue( ent.Winners, LocalPlayer() ) then
				ent:EmitSound( ent.Sounds.WIN[1] .. math.random( 1, ent.Sounds.WIN[2] ) .. ".mp3" )
			else
				ent:EmitSound( ent.Sounds.LOSE[1] .. math.random( 1, ent.Sounds.LOSE[2] ) .. ".mp3" )
			end

		end

		return

	end

	// NEW ROUND
	if enum == ent.Network.NEW then

		ent.Players = net.ReadTable()
		ClearVars( LocalPlayer(), ent )

		return

	end

	// CLEAR
	if enum == ent.Network.CLEAR then

		ent.Players = {}
		ClearVars( LocalPlayer(), ent )

		return

	end

	// REVEAL SOUND
	if enum == ent.Network.REVEAL then

		ent:EmitSound( reveal, 100, 100 )

	end

end )


// ========================================================
// NETWORKING CARDS
// ========================================================

net.Receive( "ClientHoldemCards", function( length, client )

	local ent = net.ReadEntity()

	local handType = net.ReadInt( 4 )
	//print( "Received cards! Type: " .. handType )
	if handType == ent.Hands.HOLE then

		local ply = net.ReadEntity()


		local handint = net.ReadInt( 32 )
		local hand = Cards.Hand():FromInt( handint )

		if !PokerPanel then CreateMainPanel( ent ) end
		PokerPanel:SetVisible( true )
		hand:Evaluate()

		// Set the main hand
		if ply == LocalPlayer() then

			PokerPanel:SetHand( hand )
			GTowerMainGui:ToggleCursor( true )

		// Set the other player hands
		else
			PokerPanel:SetHandOther( hand, ply )
		end

		ply.CurrentHand = hand

	elseif handType == ent.Hands.COMMUNITY then
		
		local handint = net.ReadInt( 32 )
		local hand = Cards.Hand():FromInt( handint )

		if !PokerPanel then CreateMainPanel( ent ) end
		PokerPanel:SetVisible( true )

		for k, v in pairs( hand.cards ) do
			
			if PokerPanel.Community then

				local has = false
				for _, c in pairs( PokerPanel.Community.cards ) do
					//print( tostring( v ) .. " IS " .. ( c.value == v.value and c.suit == v.suit and "IN" or "NOT IN" ) )
					if c.value == v.value and c.suit == v.suit then has = true end
				end
				if has then continue end

			end
			PokerPanel:AddCommunity( v.value, v.suit )

		end

	end

end )