
timer.Create("GTowerMultiserver", 0.88, 0, function()

	for _, v in pairs( GTowerServers.Servers ) do
		
		v:NetworkThink()
		
	end

end )

hook.Add("SQLConnect", "GTowerServerSendData", function( ply ) 
	--print('running-------------------------------------')
	local Count = 0.0
	
	for _, Server in pairs( GTowerServers.Servers ) do
		
		timer.Simple( 0.3, function() 
			Server.NetworkSend( Server, ply )
		end)

		Count = Count + 0.3
	end

end )