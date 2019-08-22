
include("shared.lua")

usermessage.Hook("MServ", function(um)

	local MsgId = um:ReadChar()

	if MsgId == 0 then
		
		local ip = um:ReadString()
		local port = um:ReadString()
		local password = um:ReadString()
		
		Msg( string.format( "Redirecting you to: %s:%d (password: %s)", ip, tonumber( port ), password ) )
		
		GTowerServers:ConnectToServer( ip, port, password )

	end
	
end )


function GTowerServers:ConnectToServer( ip, port, password )

	print(ip, port, password)
	RunConsoleCommand("password", password )
	LocalPlayer():ConCommand( string.format("disconnect; connect %s:%d", ip, tonumber(port)) )

end