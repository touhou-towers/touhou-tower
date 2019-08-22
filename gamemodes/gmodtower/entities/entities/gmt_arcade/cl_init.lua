
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

/*hook.Add("CanMousePress", "DisableArcadeCabinet", function()
	
	for _, v in pairs( ents.FindByClass( "gmt_arcade" ) ) do
		if v.Browser && v.MouseRayInteresct && v:MouseRayInteresct() then
			return false
		end
	end
	
end )*/

local GameIDS = ENT.GameIDs
local GameHTML = ENT.GameHTML

usermessage.Hook("StartGame", function(umsg)
	local game = umsg:ReadChar()

	local Arcades = vgui.Create( "DFrame" )
	Arcades:SetTitle(GameIDS[game])
	Arcades:SetSize( 830, 500 )
	Arcades:Center()
	Arcades:MakePopup()

	local html = vgui.Create( "HTML", Arcades )
	html:Dock( FILL )
	html:OpenURL( GameHTML[game] )

	Chat = vgui.Create("DButton", Arcades)
	Chat:SetPos(681, 3)
	Chat:SetText( "Chat" )
	Chat:SetSize(40, 18)
	Chat.DoClick = function() chat.Open(1) end
	
	MissingPlugIn = vgui.Create("DButton", Arcades)
	MissingPlugIn:SetPos(720, 3)
	MissingPlugIn:SetText( "Blue Screen ?" )
	MissingPlugIn:SetSize(75, 18)
	MissingPlugIn.DoClick = function()
		gui.OpenURL("https://swampservers.net/video/plugin-guide.html")
	end
end)

function ENT:Draw()
	self:DrawModel()
end

usermessage.Hook("ArcJunkie", function(um)

	local Count = um:ReadChar()
	local Names = {}
	
	Msg("You still need to complete:\n")
	
	for i=1, Count do
		
		local Id = um:ReadChar()
		
		Msg( "\t" .. i .. ". " .. GameIDS[ Id ] .. "\n")
	end

end )