
surface.CreateFont( "LabelFont", { font = "Open Sans Condensed Light", size = 22, weight = 200 } )

SCOREBOARD = {}
SCOREBOARD.TheaterHeight = 456
SCOREBOARD.CurrentHeight = 256


if ValidPanel( Gui ) then 
	Gui:Remove()
	Gui = nil
end

if ValidPanel( GuiQueue ) then
	GuiQueue:Remove()
	GuiQueue = nil
end

if ValidPanel( GuiAdmin ) then
	GuiAdmin:Remove()
	GuiAdmin = nil
end

GM.MouseEnabled = false

function GM:ShowMouse()
	if self.MouseEnabled then return end
	gui.EnableScreenClicker( true )
	RestoreCursorPosition()
	self.MouseEnabled = true
end

function GM:HideMouse()
	if !self.MouseEnabled then return end
	RememberCursorPosition()
	gui.EnableScreenClicker( false )
	self.MouseEnabled = false
end

hook.Add( "OnVideoVote", "SortQueueList", function()

	-- Resort the video queue after voting
	if IsValid( GuiQueue ) and GuiQueue:IsVisible() then
		GuiQueue:SortList()
	end

end )

function GM:MenuShow()

	if !IsValid(LocalPlayer()) or !LocalPlayer().GetTheater then return end

	local Theater = LocalPlayer():GetTheater()
	if !Theater then return end

	-- Queue
	if !ValidPanel( GuiQueue ) then
		GuiQueue = vgui.Create( "ScoreboardQueue" )
	end

	GuiQueue:InvalidateLayout()
	GuiQueue:SetVisible( true )

	GAMEMODE:ShowMouse()

	if LocalPlayer():IsAdmin() or
		( Theater:IsPrivate() and Theater:GetOwner() == LocalPlayer() ) then

		if !ValidPanel( GuiAdmin ) then
			GuiAdmin = vgui.Create( "ScoreboardAdmin" )
		end

		GuiAdmin:InvalidateLayout()
		GuiAdmin:SetVisible( true )

	end

end
--concommand.Add("+menu", GM.MenuShow ) 
--concommand.Add("+menu_context", GM.MenuShow )

function GM:MenuHide()

	if ValidPanel( GuiQueue ) then
		GuiQueue:SetVisible( false )
	end

	if ValidPanel( GuiAdmin ) then
		GuiAdmin:SetVisible( false )
	end

	if not ( ValidPanel( Gui ) and Gui:IsVisible() ) then
		GAMEMODE:HideMouse()
	end

end
--concommand.Add("-menu", GM.MenuHide ) 
--concommand.Add("-menu_context", GM.MenuHide )

-- Scroll playerlist
hook.Add( "PlayerBindPress", "PlayerListScroll", function( ply, bind, pressed )

	local guiVisible = ( ValidPanel(Gui) and Gui:IsVisible() )

	if bind == "+attack" then

		-- Show mouse if the scoreboard or queue menu are open
		if not GAMEMODE.MouseEnabled and ( guiVisible or
			( ValidPanel(GuiQueue) and GuiQueue:IsVisible() ) ) then

			GAMEMODE:ShowMouse()
			return true

		end

	end

	if guiVisible then

		if bind == "invnext" then
			Gui.PlayerList.PlayerList.VBar:AddScroll(2)
			return true
		elseif bind == "invprev" then
			Gui.PlayerList.PlayerList.VBar:AddScroll(-2)
			return true
		end

	end

end )

hook.Add( "GUIMousePressed", "RequestClose", function( key )

	if key == MOUSE_LEFT then

		-- Check if the user clicked outside of the request panel. If so,
		-- close the panel.
		if ValidPanel(RequestPanel) then
			RequestPanel:CheckClose()
		end

	end

end )
