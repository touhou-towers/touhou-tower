
function IPToInt(ip, hex)
	local spos = 1
	local pos = string.find(ip, ".", spos, true)
	
	while pos != nil do
		hex:Write( tonumber(string.sub(ip, spos, pos-1)), 2 )

		spos = pos + 1
		pos = string.find(ip, ".", spos, true)
	end

	hex:Write( tonumber(string.sub(ip, spos)) , 2)
end

function IntToIP(data)
	return string.format("%s.%s.%s.%s", data:Read(2), data:Read(2), data:Read(2), data:Read(2))
end

function GTowerServers:GetPlayerList()
	return GTowerServers:PlayerListToHex( player.GetAll() )
end

function GTowerServers:PlayerListToHex( Players )
	local PlayerList = {}
	local Count = 0
	
	for _, v in pairs( Players ) do
		if !v:IsBot() then
			table.insert( PlayerList, string.match( v:IPAddress() , "(%d+%.%d+%.%d+%.%d+)" ) )
			Count = Count + 1
		end
	end
	
	return GTowerServers:ListToHex( PlayerList ), Count
end

function GTowerServers:ListToHex( players )
	local Data = Hex()
	
	for _, v in pairs( players ) do
		IPToInt(v, Data)
	end
	
	return Data:Get()
end

function GTowerServers:PlayerListToIDs( hex )
	
	local EndList = {}
	local Data = Hex( hex )
	
	while Data:CanRead( 8 ) do		
		table.insert( EndList, IntToIP(Data) )
	end
	
	return EndList

end