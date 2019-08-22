
include("shared.lua")

DEBUG.Gui = nil

--usermessage.Hook("GTDebug", function( um )
net.Receive("GTDebug",function()

	local Name = net.ReadString()
	local Message = net.ReadString()

	hook.Call("DebugMsg", GAMEMODE, Name, Message, true )

	Msg("SERVER: ", Name, ": ", Message )

end )

concommand.Add("gmt_debug", function( ply, cmd, args )

	if !ply:IsAdmin() then
		return
	end

	if ValidPanel( DEBUG.Gui ) then
		DEBUG.Gui:Remove()
	end

	DEBUG.Gui = vgui.Create("DFrame")
	DEBUG.Gui:SetTitle( "DEBUG MESSAGES" )


	local Form = vgui.Create("DForm", DEBUG.Gui )
	Form:SetName( "DEBUG" )
	Form:SetPos( 3, 23 )
	Form:SetWide( ScrW() * 0.25 )

	for _, v in pairs( DEBUG.List ) do

		local Checkbox = Form:CheckBox( v.Name )

		Checkbox:SetValue( v.State )
		Checkbox.DebugName = v.Name
		Checkbox.OnChange = function( panel, state )
			DEBUG:ChangeState( panel.DebugName, state )
		end

	end

	Form:InvalidateLayout( true )

	DEBUG.Gui:SetSize( Form:GetWide() + 6 , Form:GetTall() + Form.y + 3 )
	DEBUG.Gui:SetPos(
		ScrW() - DEBUG.Gui:GetWide() - 10,
		10
	)

end )
