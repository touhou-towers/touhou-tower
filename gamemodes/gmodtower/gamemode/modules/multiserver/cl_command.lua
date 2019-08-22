
function GTowerServers:AskJoinServer( id )

	if GTowerGroup then
		if GTowerGroup:InGroup() && GTowerGroup.GroupOwner != LocalPlayer() then
			GtowerMessages:AddNewItem( "Only group owner can let your party into a server." )
			return
		end	
	end
	
	if id then
		RunConsoleCommand("gmt_mtsrv", 1, id )
	end
	
end

function GTowerServers:RemoveJoinServer()
	
	if id then
		RunConsoleCommand("gmt_mtsrv", 2 )
	end
	
end