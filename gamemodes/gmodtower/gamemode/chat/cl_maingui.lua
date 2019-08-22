

-----------------------------------------------------
local PANEL = {}



PANEL.Opacity = 240

PANEL.TitleBarHeight = 32



PANEL.EmotePattern = "^:([^%s:]+):"

-- PANEL.EmotePattern = "^ː([^%s:]+)ː" -- uses special character colons

PANEL.UTF8CharPattern = "[%z\1-\127\194-\244][\128-\191]*"



-- Create emotes map

-- emotes[key] = "material/path.png"

PANEL.Emotes = (function()



	local emotes = {}



	for _, filename in pairs(file.Find( "materials/icon16/*.png", "GAME" )) do

		local emote = filename:sub(1,#filename - 4)

		emotes[emote] = Material(table.concat({"icon16/",filename}))

	end



	return emotes



end)()



function PANEL:Init()



	self.textpanel = vgui.Create( "DRichText", self )

	self.ChatType = ""



	self.inputpanel = vgui.Create( "DTextEntry", self )

	self.inputpanel:SetFont("ChatVerdana16")

	self.inputpanel:SetDrawBorder( false )

	self.inputpanel.m_colText = Color( 255, 255, 255 )

	self.inputpanel.m_colCursor = Color( 200, 200, 200 )

	self.inputpanel.m_colHighlight = Color( 255, 255, 255, 84 )



	self.inputpanel.Paint = function( panel, w, h )



		-- Draw background

		local color = colorutil.Brighten( Scoreboard.Customization.ColorBackground, .75 )

		surface.SetDrawColor( color.r, color.g, color.b, self.Opacity )

		surface.DrawRect( 0, 0, w, h )



		-- Draw input text

		panel:DrawTextEntryText( Color( 255, 255, 255 ), Color( 255, 255, 255 ), Color( 255, 255, 255 ) )


	end



	self.inputpanel.AutoCompleted = false

	self.inputpanel.OnKeyCodeTyped = function( panel, keycode )



		local Text = self.inputpanel:GetValue()

		if keycode == KEY_ESCAPE then



			if gui and gui.HideGameUI then gui.HideGameUI() end

			GAMEMODE:FinishChat()



		elseif keycode == KEY_BACKSPACE then



			if #panel:GetValue() == 0 then



				GAMEMODE:FinishChat()



			elseif self.inputpanel.AutoCompleted then



				local OldText = self.inputpanel.AutoCompleted[1]

				self.inputpanel:SetText(OldText)

				self.inputpanel:SetCaretPos(string.len(OldText))

				self.inputpanel.AutoCompleted = false



				return true

			end



		elseif keycode == KEY_TAB then



			local NewText, Ex = GTowerChat.AutoComplete(Text)

			if NewText then



				self.inputpanel:SetText(NewText)

				self.inputpanel:SetCaretPos(string.len(NewText))

				if Ex && self.inputpanel.AutoCompleted then



					self.inputpanel.AutoCompleted = {self.inputpanel.AutoCompleted[1], NewText}



				else



					self.inputpanel.AutoCompleted = {Text, NewText}



				end

			end



			return true



		elseif keycode == KEY_ENTER then



			if #Text > 0 then

				local cmd = "say"

				local valuetype = ""



				if self.ChatType == "Group" then

					cmd = "say_team"



				elseif self.ChatType != "Server" then

					cmd = "say2"

					valuetype = self.ChatType

				end



				if cmd == "say" || cmd == "say_team" then

					RunConsoleCommand(cmd, panel:GetValue())

				else

					RunConsoleCommand(cmd, valuetype, panel:GetValue())

				end

			end

			GAMEMODE:FinishChat()



		end



		self.inputpanel.AutoCompleted = nil

	end



	if GTowerChat.ChatGroups and game.GetMap() == "gmt_build0s2b" then



		self.prefixpanel = vgui.Create( "DLabel", self )

		self.prefixpanel:SetFont( "ChatVerdana16" )



		self.SettingsButton = vgui.Create( "DImageButton", self )

		self.SettingsButton:SetSize( 16, 16 )

		self.SettingsButton:SetImage( "materials/gmod_tower/icons/chat_settings.png" )

		self.SettingsButton.Think = function( self )

			if self:IsMouseOver( self ) then

				self:SetAlpha( 100 )

			else

				self:SetAlpha( 255 )

			end

		end

		self.SettingsButton.DoClick = function()

			if self.SettingsGUI and IsValid( self.SettingsGUI ) then

				self.SettingsGUI:ToggleVisible()

				self.SettingsGUI:SetPos( gui.MouseX() + 12, gui.MouseY() - 64 )

			end



			if self.EmoteGUI and IsValid( self.EmoteGUI ) then

				self.EmoteGUI:Remove()

				self.EmoteGUI = nil

			end

		end



		self.SettingsGUI = vgui.Create("GTowerChatSettings")

		self.SettingsGUI:SetOwner( self, self.textpanel )

		self.SettingsGUI:SetVisible( false )

		self.SettingsGUI:SetPos( gui.MouseX() + 6, gui.MouseY() - 48 )



	end



	self.EmotesButton = vgui.Create( "DImageButton", self )

	self.EmotesButton:SetSize( 16, 16 )

	self.EmotesButton:SetImage( "materials/gmod_tower/icons/chat_emotes.png" )

	self.EmotesButton.Think = function( self )

		if self:IsMouseOver( self ) then

			self:SetAlpha( 100 )

		else

			self:SetAlpha( 255 )

		end

	end

	self.EmotesButton.DoClick = function()

		if self.EmoteGUI and IsValid( self.EmoteGUI ) then

			self.EmoteGUI:Remove()

			self.EmoteGUI = nil

		else

			self.EmoteGUI = vgui.Create("GTowerChatEmotes")

			self.EmoteGUI:SetOwner( self )

			self.EmoteGUI:SetPos( gui.MouseX() + 6, gui.MouseY() - 48 )

		end

		if IsValid( self.SettingsGUI ) then

			self.SettingsGUI:SetVisible(false)

		end

	end



	self.Resizer = vgui.Create("GTowerResizer" )

	self.Resizer:SetSettingName( "gui_chat_width" )

	self.Resizer.DefaultValue = 450

	self.Resizer:SetMinMax( 450, 700 )

	self.Resizer:OnChange( function( value)

		if !GTowerChat.Chat then CreateGChat(true) end



		GTowerChat.Chat:SetWidth(value)

		GTowerChat.Chat:InvalidateLayout()



		if self.EmoteGUI and IsValid( self.EmoteGUI ) then

			self.EmoteGUI:Remove()

			self.EmoteGUI = nil

		end

		if IsValid( self.SettingsGUI ) then

			self.SettingsGUI:SetVisible(false)

		end

	end )



end



function PANEL:Think()



	-- Hide when using camera

	if LocalPlayer():IsCameraOut() then

		if not self.washidden then self.washidden = self.textpanel:IsVisible() end

		self.textpanel:SetVisible( false )

	else

		if self.washidden then

			self.textpanel:SetVisible( true )

		end

	end



	if self.DragThink then

		self:DragThink()

	end



end



function PANEL:DragThink()



	-- Change cursor

	if self:IsMouseOverTitleBar() or self.dragging then

		self:SetCursor("sizeall")

	else

		self:SetCursor("default")

	end



	-- Start drag

	if self:IsMouseOverTitleBar() and ( input.IsMouseDown(MOUSE_LEFT) and not self.WasMouseDown ) then

		if not self.dragging then

			self.dragx, self.dragy = ( self.x - gui.MouseX() ), ( self.y - gui.MouseY() )

			self.dragging = true

		end

	end



	-- Drag update

	if self.dragging and input.IsMouseDown(MOUSE_LEFT) then

		local newx, newy = gui.MouseX() + self.dragx, gui.MouseY() + self.dragy



		newx = math.Clamp( newx, 0, ScrW() - self:GetWide() )

		newy = math.Clamp( newy, 0, ScrH() - self:GetTall() )

		cookie.Set( "gui_chatx", newx )

		cookie.Set( "gui_chaty", newy )



		self:SetPos( newx, newy )

	else

		self.dragging = false

	end



	-- Store if the mouse was down last frame

	self.WasMouseDown = input.IsMouseDown(MOUSE_LEFT)



end



function PANEL:IsMouseOverTitleBar()



	local x,y = self:CursorPos()

	return x >= 0 && y >= 0 && x <= self:GetWide() - 8 && y <= self.TitleBarHeight



end



function PANEL:PerformLayout()

	local w,h = self:GetSize()

	local inputHeight = 20
	local off = 2
	local ny = h - inputHeight - off
	local pwidth = 0
	local ewidth = 16
	local padding = 4

	self.textpanel:SetPos( padding, padding + self.TitleBarHeight )
	self.textpanel:SetSize( w - (padding*2), ny - padding*2 - self.TitleBarHeight )
	self.textpanel:InvalidateLayout()

	if self.prefixpanel then
		self.prefixpanel:SetPos( padding, ny )
		self.prefixpanel:SetTextColor( Color( 255, 255, 255 ) )
		self.prefixpanel:SizeToContents()
		self.prefixpanel:SetTall( 18 )

		pwidth = self.prefixpanel:GetWide()
	end

	local buttonX, buttonY, buttonWidth = w - ewidth - padding, ny + 1, ewidth

	if self.SettingsButton then
		self.SettingsButton:SetPos( buttonX, buttonY )
		buttonWidth = buttonWidth + ewidth + padding
		buttonX = buttonX - ewidth - padding
	end

	self.EmotesButton:SetPos( buttonX, buttonY )

	self.inputpanel:SetPos( self.x + pwidth + 6, self.y + ny )
	self.inputpanel:SetSize( w - pwidth - (buttonWidth) - 14, 18)
	self.inputpanel:InvalidateLayout()

	if self.Resizer then
		self.Resizer:SetSize( 8, self:GetTall() )
		self.Resizer:SetPos( self.x + self:GetWide() - 4, self.y )
	end

end





function PANEL:GetInputPanel()

	return self.inputpanel

end



function PANEL:GetFilterForType(t)



	-- Chat filters setup

	if not self.ChatFilters then

		self.ChatFilters = {}

		for id, name in ipairs( GTowerChat.ChatGroups ) do

			self.ChatFilters[name] = math.pow(2, id-1)

		end

	end



	-- Return the proper value

	if self.ChatFilters then

		return self.ChatFilters[t]

	end



	return 0



end



function PANEL:AddText(text, color, type, NoNewline)



	local rf = self.textpanel.Text

	local filter = GTowerChat.Chat:GetFilterForType(type)



	if !NoNewline then

		text = text .. "\n"

	end



	rf:Add(text, color, GTowerChat.ChatFont, nil, nil, nil, filter, !NoNewline)



	chat.AddText(color, text)



	self.textpanel:InvalidateLayout()



end



local function ClickedPlayer(pname, pID)



	local ply = player.GetByID(pID)

	if !IsValid(ply) then return end



	--GAMEMODE:FinishChat()

	--GAMEMODE:ScoreboardShow()

	GTowerClick:ClickOnPlayer( ply, MOUSE_LEFT )

	--gui.EnableScreenClicker( true )



end



local function ParseURL( text )



	text = string.lower( text )



	if string.find( text, "http:--" ) || string.find( text, "https:--" ) then

		local match = string.match( text, "[https]+:--[%S]*[%w#/]" )

		if match then

			local split = string.Split( text, match )

			return { split[1], match, split[2] }

		end

	end



	return nil



end



local function ClickedURL( text, url )



	if GTowerChat then

		GTowerChat.Chat:Hide()

	end



	gui.EnableScreenClicker( false )



	timer.Simple( .1, function()



		Derma_Query( "Warning!\nYou're about to open a remote website link.\nWould you like to open " .. url, "Open URL",

			"Open", function()

				browser.OpenURL( "Remote Website", url )

			end,

			"Cancel", function() end

		)



	end )



end



local horrible_white = Color(240, 240, 240, 255)

local color_grey = Color(50, 50, 50, 150)

local color_white = Color(255, 255, 255, 255)

local color_blue = Color(100, 100, 255, 255)



function PANEL:AddChat(type, ply, id, text, color, forcename, forceloc)



	if ( !IsValid(ply) || !ply:IsPlayer() || CheckBlocked(ply) ) && ply != NULL then return end



	local filter = GTowerChat.Chat:GetFilterForType(type)

	local rf = self.textpanel.Text



	if type != "Server" && type != "Theater" && type != "Hidden" then

		rf:Add( "(" .. type .. ") ", horrible_white, GTowerChat.ChatFont, nil, nil, nil, filter )

	end



	local chatcolor = color_white



	if type == "Hidden" then

		color = color_grey

		chatcolor = color_grey

	end



	// Location tag
	if Location && GTowerChat.Location:GetBool() && string.StartWith( game.GetMap(), "gmt_build" ) then

		local locationName = "Unknown"
		if GTowerLocation:GetName( GTowerLocation:GetPlyLocation( ply ) ) then
			locationName = GTowerLocation:GetName( GTowerLocation:GetPlyLocation( ply ) ) .. " "
		end

		if forceloc || ply == NULL then
			locationName = "Server "
		end

		if !GTowerChat.TimeStamp:GetBool() then
			locationName = locationName .. "| "
		end

		rf:Add( locationName, Color( 200, 200, 200, 255 ), GTowerChat.ChatFont, nil, nil, nil, filter )

	end



	-- Timestamp tag

	if GTowerChat.TimeStamp:GetBool() then



		local time = os.date("%I:%M:%S %p")



		if GTowerChat.TimeStamp24:GetBool() then

			time = os.date("%H:%M:%S")

		end



		rf:Add( "[" .. time .. "] ", Color( 135, 196, 230, 255 ), GTowerChat.ChatFont, nil, nil, nil, filter )



	end



	-- Dead players

	if ply.Alive && !ply:Alive() then

		rf:Add( "*DEAD* ", Color( 254, 101, 116, 255 ), GTowerChat.ChatFont, nil, nil, nil, filter )

	end



	local name = "(Unknown Player)"

	if ply.Name then

		name = ply:Name()

	end



	-- Force the name

	if forcename || ply == NULL then

		name = forcename or "(Unknown Player)"

	end



	-- Fancy mode

	if ply.IsFancy then

		name = "Sir " .. name

	end



	rf:Add( name, color, GTowerChat.ChatFont, nil, ClickedPlayer, id, filter )



	text = ": " .. text



	chat.AddText( horrible_white, "(" .. type .. ") ", color, name, chatcolor, text )



	local nchar = #text

	local charpos = 0

	local buffer = {}



	local function addbuffer()

		rf:Add( table.concat(buffer), chatcolor, GTowerChat.ChatFont, nil, nil, nil, filter )

		buffer = {}

	end



	-- Parse chat text by character

	while charpos < nchar do



		-- Parse emoticons

		-- TODO: remove first condition

		if string.find( text, self.EmotePattern ) then

			local startpos, endpos, emote = string.find( text, self.EmotePattern )

			local material = self.Emotes[emote]

			if material then

				addbuffer()

				rf:AddMaterial( material, 16, 16, table.concat({':',emote,':'}) )

				text = text:sub(endpos+1)

				charpos = charpos + endpos

				continue

			end

		end



		-- TODO: Url parsing



		-- Advance by one character; handles utf8 encoding

		local startpos, endpos = text:find( self.UTF8CharPattern )

		if not startpos then break end

		table.insert( buffer, text:sub(startpos,endpos) )

		charpos = charpos + endpos



		text = text:sub(endpos+1)



	end



	-- Add last segment of text to chat

	table.insert( buffer, "\n" )

	addbuffer()



	self.textpanel:InvalidateLayout()



end



function PANEL:Show(type)

	self.textpanel:SetFade(false)

	self.textpanel:SetVisible(true)



	self:SetMouseInputEnabled(true)

	self:SetKeyboardInputEnabled(true)



	self:SetZPos(-30)



	self.inputpanel:RequestFocus()

	self.inputpanel:SetVisible(true)

	self.inputpanel:MakePopup()



	if self.ChatType then



		if self.ChatType != type then

			self.ChatType = type



			local chatprefix = string.upper(type)

			if type == "Server" then

				chatprefix = "SAY"

			end



			if self.prefixpanel then

				self.prefixpanel:SetText( " " .. chatprefix .. " " )

			end



			self:InvalidateLayout()

		end



	else

		if self.prefixpanel then

			self.prefixpanel:SetText( " SAY " )

		end

	end



	if self.prefixpanel then

		self.prefixpanel:SetVisible(true)

	end



	if self.Resizer then

		self.Resizer:SetVisible( true )

	end



	if self.SettingsButton then

		self.SettingsButton:SetVisible( true )

	end



	if self.EmotesButton then

		self.EmotesButton:SetVisible( true )

	end



	RestoreCursorPosition()

end



function PANEL:Hide()

	RememberCursorPosition()



	self.textpanel:SetFade(true)



	self:SetMouseInputEnabled(false)

	self:SetKeyboardInputEnabled(false)



	self.inputpanel:SetText("")

	self.inputpanel:SetVisible(false)



	if self.prefixpanel then

		self.prefixpanel:SetVisible(false)

	end



	if self.Resizer then

		self.Resizer:SetVisible( false )

	end



	if self.SettingsButton then

		self.SettingsButton:SetVisible( false )

	end



	if self.EmotesButton then

		self.EmotesButton:SetVisible( false )

	end



	if self.EmoteGUI then

		self.EmoteGUI:Remove()

		self.EmoteGUI = nil

	end



	if self.SettingsGUI then

		self.SettingsGUI:SetVisible( false )

	end

end



function PANEL:Paint( w, h )



	if self.textpanel && !self.textpanel.Fade then



		local col = Scoreboard.Customization.ColorBackground--GTowerChat.BGColor

		surface.SetDrawColor( col.r, col.g, col.b, self.Opacity )

		surface.DrawRect( 0, 0, w, h )


		surface.SetDrawColor( col.r - 25, col.g - 25, col.b - 25, self.Opacity - 25 )
		surface.DrawRect( 5, 5, w-10, h-30 )



		surface.SetDrawColor( 255, 255, 255, 255 )



		-- Filler

		surface.SetMaterial( Scoreboard.Customization.HeaderMatFiller )

		surface.DrawTexturedRect( 0, 0, w, self.TitleBarHeight )



		-- Logo

		surface.SetMaterial( Scoreboard.Customization.HeaderMatHeader )

		surface.DrawTexturedRect( 0, 0, Scoreboard.Customization.HeaderWidth/1.75, self.TitleBarHeight )



		-- Text

		--[[col = Scoreboard.Customization.HeaderTitleColor

		surface.SetTextColor( col.r, col.g, col.b, 255 )

		surface.SetFont( Scoreboard.Customization.HeaderTitleFont )

		surface.SetTextPos( Scoreboard.Customization.HeaderTitleLeft/1.75, -3 )

		surface.DrawText( Scoreboard.Customization.HeaderTitle )]]



	end



end



vgui.Register("GTowerMainChat", PANEL, "EditablePanel")
