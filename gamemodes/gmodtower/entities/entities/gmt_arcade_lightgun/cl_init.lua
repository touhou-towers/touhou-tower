
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

/*hook.Add("CanMousePress", "DisableArcadeCabinet", function()
	
	for _, v in pairs( ents.FindByClass( "gmt_arcade_lightgun" ) ) do
		if v.Browser && v.MouseRayInteresct && v:MouseRayInteresct() then
			return false
		end
	end
	
end )*/

usermessage.Hook("StartDoom", function(umsg)
	Doom = vgui.Create("DFrame")
	Doom:SetSize(830, 550)
	Doom:Center()
	Doom:SetDraggable(true)
	Doom:MakePopup()
	--Doom:SetTitle("Doom Triple Pack: Doom, Heretic, Hexen")
	Doom:SetTitle("Doom")
	Doom.btnMaxim:Hide()
	Doom.btnMinim:Hide()
	Doom.Paint = function(self, w, h)
	draw.RoundedBox(0,0,0,w,h,Color(0,80,161))
	draw.RoundedBox(0,0,0,w,25,Color(0,65,129))
	end
	
	Chat = vgui.Create("DButton", Doom)
	Chat:SetPos(681, 3)
	Chat:SetText( "Chat" )
	Chat:SetSize(40, 18)
	Chat.DoClick = function() chat.Open(1) end
	
	MissingPlugIn = vgui.Create("DButton", Doom)
	MissingPlugIn:SetPos(720, 3)
	MissingPlugIn:SetText( "Blue Screen ?" )
	MissingPlugIn:SetSize(75, 18)
	MissingPlugIn.DoClick = function()
	 gui.OpenURL("https://swampservers.net/video/plugin-guide.html")
	end

	local html = vgui.Create( "HTML", Doom )
	html:Dock( FILL )
	html:OpenURL( "http://swf-portal.weebly.com/uploads/9/3/5/3/9353061/doom.swf" )

	Doom.OnClose = function()
	Doom:SetVisible(false)
	end
end)

function ENT:Draw()
	self:DrawModel()
end