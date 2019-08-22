

-----------------------------------------------------
GTowerChat = GTowerChat or {}
GTowerChat.Color = CreateClientConVar( "gmt_textcolor", 1, true, false )
GTowerChat.YOffset = 380
GTowerChat.XOffset = 40
GTowerChat.BGColor = Color( 26, 75, 117, 180 )
GTowerChat.ScrollColor = Color( 19, 50, 81, 215 )
//GTowerChat.ChatFont = "GTowerHUDMain"
GTowerChat.ChatFont = "ChatVerdana16"
GTowerChat.NewChatState = false
GTowerChat.TimeStamp = CreateClientConVar( "gmt_chat_timestamp", 0, true, false )
GTowerChat.TimeStamp24 = CreateClientConVar( "gmt_chat_timestamp24", 0, true, false )
GTowerChat.Sounds = CreateClientConVar( "gmt_chat_sound", 1, true, false )
GTowerChat.Location = CreateClientConVar( "gmt_chat_loc", 1, true, false )

include("cl_autocomplete.lua")
include("richformat.lua")
include("cl_richtext.lua")
include("cl_maingui.lua")
include("cl_chatbubble.lua")
include("cl_emotes.lua")
include("cl_settings.lua")
include("shared.lua")

//local blip = Sound("HL1/fvox/blip.wav") //friends/message.wav is too annoying
local blip1 = Sound("GModTower/misc/chat1.wav")
local blip2 = Sound("GModTower/misc/chat2.wav")
local altBlip = true

function CreateGChat(hide)

	if GTowerChat.Chat then return end

	GTowerChat.Chat = vgui.Create( "GTowerMainChat" )
	if GTowerChat.Chat then

		GTowerChat.Chat:SetPos( cookie.GetNumber( "gui_chatx" ) or GTowerChat.XOffset, cookie.GetNumber( "gui_chaty" ) or ( ScrH() - GTowerChat.YOffset ) )
		GTowerChat.Chat:SetSize( cookie.GetNumber( "gui_chatbox_width", 440 ), 255 )

		if hide then
			GTowerChat.Chat:Hide()
		end

	end

end

-- lua refresh fix
hook.Add( "OnReloaded", "ReloadChat", function()
	if GTowerChat and ValidPanel(GTowerChat.Chat) then
		GTowerChat.Chat:Remove()
		GTowerChat.Chat = nil
		CreateGChat( true )
	end
end )

hook.Add( "InitPostEntity", "CreateGChatPostEntity", function()
	CreateGChat( true )
end )

// we need to queue this for the next tick because the game calls FinishChat at odd times
local HookSendChatState = function()
	if SafeToSend then
		RunConsoleCommand("gmt_chat", tostring(GTowerChat.NewChatState), tostring(LocalPlayer().lc or false))
		hook.Remove("Tick", "ChatState")
	end
end

local function UpdateChatState( state )
	GTowerChat.NewChatState = state
	hook.Add("Tick", "ChatState", HookSendChatState)
end

function GM:StartChat( TeamSay )

	if !GTowerChat.Chat then CreateGChat( false ) end
	if !GTowerChat.Chat then return end
	chat.Close()

	if TeamSay then

		if GTowerGroup && GTowerGroup:InGroup() then
			GTowerChat.Chat:Show("Group")
			UpdateChatState( true )
			return true
		else
			GTowerChat.Chat:Show("Local")
			UpdateChatState( true )
			return true
		end

	end

	/*elseif TeamSay && IsValid(LocalPlayer()) && LocalPlayer():IsAdmin() && GTowerGroup && !GTowerGroup:InGroup() then
		GTowerChat.Chat:Show("MetroChat")
	else*/

	--if game.GetMap() == "gmt_build0s2b" && Location && Location.IsTheater( LocalPlayer():Location() ) then
	--	GTowerChat.Chat:Show("Theater")
	--else
		GTowerChat.Chat:Show("Server")
	--end

	UpdateChatState( true )

	return true

end

function GM:FinishChat()

	if !GTowerChat.Chat then CreateGChat(true) end

	if hook.Call("CanCloseChat", GAMEMODE ) == false then
		return
	end

	UpdateChatState( false )
	//RunConsoleCommand( "gameui_allowescapetoshow" )

	if GTowerChat.Chat then
		GTowerChat.Chat:Hide()
	end
end

local color_white = Color(255, 255, 255, 255)
local color_console = Color(200, 200, 200, 255)
local color_admin = Color(255, 100, 100, 255)
local color_privadmin = Color(185, 100, 255, 255)

local color_nostalgia = Color(255, 255, 100, 255)

function GM:ChatText(pID, pName, Text, InternalType, Type)

	if !GTowerChat.Chat then CreateGChat(true) end

	local ply = player.GetByID(pID)
	local type = Type or "Server"
	local color = color_white

	-- Don't add messages of blocked players
	--if Friends.IsBlocked( LocalPlayer(), ply ) then return end

	if InternalType == "chat" then

		if IsValid(ply) and GTowerChat.Color:GetBool() then
		
			color = ply:GetDisplayTextColor()
			
		elseif IsValid(ply) then
			color = color_nostalgia
		
		else
			color = color_console
		end

		-- Play sounds
		if GTowerChat.Sounds:GetBool() then

			if altBlip then
				surface.PlaySound( blip1 )
			else
				surface.PlaySound( blip2 )
			end

			altBlip = !altBlip

		end

		GTowerChat.Chat:AddChat( type, ply, pID, Text, color )

    elseif InternalType == "joinleave" then
    	-- Don't show this.
    else
		GTowerChat.Chat:AddText(Text, color)
	end

end

function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )

	if IsValid(player) && player:IsPlayer() then

		local name
		if player.Name then
			name = player:Name()
		else
			name = "(Unknown Player)"
		end

		GAMEMODE:ChatText( player:EntIndex(), name, strText, "chat" )

	else
		GAMEMODE:ChatText( 0, "(Unknown Player)", strText, "chat" )
	end

	return true

end

net.Receive( "ChatPly", function( len, ply )

	local type = net.ReadInt(GTowerChat.TypeBits)
	local pl = net.ReadEntity()
	local text = net.ReadString()
	local hidden = net.ReadBool()
	type = GTowerChat.ChatGroups[type]

	local name = "(Unknown Player)"
	if pl.Name then
		name = pl:Name()
	end

	if hidden == 1 then
		type = "Hidden"
	else
		if FloatingChat then FloatingChat.AddChat( pl, text ) end
	end

	GAMEMODE:ChatText(pl:EntIndex(), name, text, "chat", type)

end )

net.Receive( "ChatSrv", function( len, ply )

	if !GTowerChat.Chat then CreateGChat(true) end

	local type = net.ReadInt(GTowerChat.TypeBits)
	local text = net.ReadString()
	local color = net.ReadColor()

	if !color then color = Color(255, 255, 255, 255) end
	type = GTowerChat.ChatGroups[type]


	if text then
		GTowerChat.Chat:AddText( text, color, type )
	end

end)
--function chat.AddText( ... )
--	for i=#args,1,-1 do
--		if type(args[i])=="table" and args[i][1]=="EMOTE" then args[i] = args[i].str end --So emotes show
--	end
--	return GTowerChat.Chat:AddText(unpack({...}))
--end


hook.Add("PlayerBindPress", "OverrideChat", function(ply, bind, pressed)

	if !pressed || IsValid( ply.Instrument ) then return end

	if bind == "messagemode" || bind == "messagemode2" then
		GAMEMODE:StartChat(bind == "messagemode2")
		return true
	end

end)

table.insert( GtowerHudToHide, "CHudChat" )

/*hook.Add("UpdateAnimation", "Chatting", function( ply )
	if CLIENT && ply.Chatting && ( emote && !emote.IsEmoting( ply ) ) then
		ply:AnimRestartGesture( GESTURE_SLOT_CUSTOM, ACT_GMOD_IN_CHAT )
	end
end )*/

hook.Add( "ShutDown", "RemoveChatBox", function()

	if ValidPanel( GTowerChat.Chat ) then
		GTowerChat.Chat:Hide()
		GTowerChat.Chat:Remove()
		GTowerChat.Chat = nil
	end

end )
