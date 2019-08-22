
local DEBUG = false

hook.Add("SQLStartColumns", "SQLClientSettings", function()
	SQLColumn.Init( {
		["column"] = "clisettings",
		["selectquery"] = "HEX(clisettings) as clisettings",
		["selectresult"] = "clisettings",
		["update"] = function( ply ) 
			return ClientSettings:GetSQLSave( ply )
		end,
		["defaultvalue"] = function( ply )
			ClientSettings:ResetValues( ply )
		end,
		["onupdate"] = function( ply, val ) 
			ClientSettings:LoadSQLSave( ply, val )
		end
	} )
end )

function ClientSettings:GetSQLSave( ply )
	
	local Data = Hex()
	if DEBUG then Msg( "Reading data of ", ply, "\n") end
	
	for k, Item in pairs( ClientSettings.Items ) do
		
		local Value = ClientSettings:Get( ply, k )
		
		if Item.SQLSave != false && Value != Item.Default then
		
			Data:Write( k, 3 )
			
			if Item.NWType == "Bool" then
				Data:Write( Value, 1 )
			elseif Item.NWType == "Char" then
				Data:Write( Value, 2 )
			elseif Item.NWType == "Short" then
				Data:Write( Value, 4 )
			elseif Item.NWType == "Long" then
				Data:Write( Value, 8 )
			elseif Item.NWType == "Float" then
				Data:Write( math.Round( Value * 1000 ), 8 )
			else
				Data:WriteString( Value )
			end		
			
			if DEBUG then Msg( "\t'" .. Item.Name .. "' settings value: '".. tostring(Value) .. "'\n") end
		end
		
	end
	
	if DEBUG then Msg( "\t" .. Data:Get() .. "\n") end
	
	return Data:Get()
	
end

function ClientSettings:LoadSQLSave( ply, data )
	
	local Data = Hex( data )
	if DEBUG then Msg( "Reading data of ", ply, "\n") end
	
	while Data:CanRead( 3 ) do
	
		local ItemId = Data:Read( 3 )		
		local Item = self:GetItem( ItemId )
		local Value
		
		if !Item then
			Msg("FUCK! Reading client setting of an invalid id!(".. ItemId .. ")\n")
			Msg( data, "\n")
			return
		end
		
		if Item.NWType == "Bool" then
			Value = tobool( Data:Read( 1 ) )
		elseif Item.NWType == "Char" then
			Value = Data:Read( 2 )
		elseif Item.NWType == "Short" then
			Value = Data:Read( 4 )
		elseif Item.NWType == "Long" then
			Value = Data:Read( 8 )
		elseif Item.NWType == "Float" then
			Value = Data:Read( 8 ) / 1000
		else
			Value = Data:ReadString()
		end	
		
		if DEBUG then Msg( "\t'" .. Item.Name .. "'('".. ItemId .. "') value: '".. tostring(Value) .. "'\n") end
		
		ClientSettings:Set( ply, ItemId, Value )
	
	end
	
end