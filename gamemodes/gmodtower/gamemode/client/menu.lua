
function GM:HideMouse()
	if !self.MouseEnabled then return end
	RememberCursorPosition()
	gui.EnableScreenClicker( false )
	self.MouseEnabled = false
end

GtowerMainGui = {}

local function CanClose()
    local tbl = hook.GetTable().CanCloseMenu
    
    if tbl == nil then return true end

    //For not closing when the trade is open
    for _, v in pairs( tbl ) do
        if v() == false then
            return false
        end
    end

    return true
end

function GtowerMainGui:GtowerHideMenus()
	if GtowerMainGui.ContextMenuEnabled then return end
    if CanClose() == false then return end

    RememberCursorPosition()

    gui.EnableScreenClicker( false )
	
	hook.Call("GtowerHideMenus", GAMEMODE )

	///////////////////
	// Theater Stuff //
	///////////////////

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
function GtowerMainGui:GtowerHideContextMenus()
	if GtowerMainGui.MenuEnabled then return end

	if hook.Call( "DisableMenu", GAMEMODE ) == false then return end

    RememberCursorPosition()
    gui.EnableScreenClicker( false )
    GtowerMainGui.ContextMenuEnabled = false
	
	hook.Call( "GtowerHideContextMenus", GAMEMODE )

end
concommand.Add("-menu", GtowerMainGui.GtowerHideMenus) 
concommand.Add("-menu_context", GtowerMainGui.GtowerHideContextMenus)


function GtowerMainGui:GtowerShowMenus()
	if GtowerMainGui.ContextMenuEnabled then return end
	if hook.Call("CanOpenMenu", GAMEMODE ) == false then return end
    
	hook.Call("GtowerShowMenusPre", GAMEMODE )

	gui.EnableScreenClicker( true )
	RestoreCursorPosition()
	
	hook.Call("GtowerShowMenus", GAMEMODE )

	///////////////////
	// Theater Stuff //
	///////////////////

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

	if LocalPlayer():IsAdmin() || LocalPlayer():IsUserGroup("mikumod") or
		( Theater:IsPrivate() and Theater:GetOwner() == LocalPlayer() ) then

		if !ValidPanel( GuiAdmin ) then
			GuiAdmin = vgui.Create( "ScoreboardAdmin" )
		end

		GuiAdmin:InvalidateLayout()
		GuiAdmin:SetVisible( true )

	end
end

function GtowerMainGui:GtowerShowContextMenus()
	if GtowerMainGui.MenuEnabled then return end

	if hook.Call( "DisableMenu", GAMEMODE ) == false then return end
	if hook.Call( "CanOpenMenu", GAMEMODE ) == false || ( Dueling && Dueling.IsDueling( LocalPlayer() ) ) then return end
    
	hook.Call( "GTowerShowContextMenusPre", GAMEMODE )

	GtowerMainGui.ContextMenuEnabled = true
	gui.EnableScreenClicker( true )
	RestoreCursorPosition()
	
	hook.Call( "GtowerShowContextMenus", GAMEMODE )

end

concommand.Add("+menu", GtowerMainGui.GtowerShowMenus)
concommand.Add("+menu_context", GtowerMainGui.GtowerShowContextMenus)

hook.Add("ScoreboardHide", "KeepMouseAvaliable", function()
	RememberCursorPosition()
	timer.Simple( 0.0, function()
		if CanClose() == false then
			gui.EnableScreenClicker( true )
			RestoreCursorPosition()
		end
	end )
end )
 