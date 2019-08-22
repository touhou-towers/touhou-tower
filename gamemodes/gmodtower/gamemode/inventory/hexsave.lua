
function GTowerItems:Encode( ItemList )

	if !ItemList then return end
	
	local Data = Hex()
	
	for k, v in pairs( ItemList ) do
		
		Data:Write( k, 4 )
		Data:Write( v.MysqlId, 4 )
		Data:WriteString( v:GetSaveData() or "" )
	
	end
	
	return Data:Get()

end 

function GTowerItems:Decode( HexStr )

	local Data = Hex( HexStr )
	local Load = {}
	
	// this should be 10, 4 (int) + 4 (int) + 2 (null term empty string)
	while Data:CanRead( 7 ) do 
		
		local slot = Data:Read( 4 )
		local item = Data:Read( 4 )
		local savestr = Data:ReadString()
		
		table.insert( Load, {slot, item, savestr} ) 
		
	end
	
	return Load

end 