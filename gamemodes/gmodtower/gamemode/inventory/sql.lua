
hook.Add("SQLStartColumns", "SQLLoadInventory", function()
	SQLColumn.Init( {
		["column"] = "MaxItems",
		["update"] = function( ply )
			return ply:MaxItems()
		end,
		["defaultvalue"] = function( ply )
			ply:SetMaxItems( GTowerItems.DefaultInvCount )
		end,
		["onupdate"] = function( ply, val )
			ply:SetMaxItems( tonumber( val ), true )
		end
	} )

	SQLColumn.Init( {
		["column"] = "inventory",
		["selectquery"] = "HEX(inventory) as inventory",
		["selectresult"] = "inventory",
		["update"] = function( ply )
			return ply:GetInventoryData( 1 )
		end,
		["defaultvalue"] = function( ply )
			ply:LoadInventoryData( 0x0, 1 )
		end,
		["onupdate"] = function( ply, val )
			ply:LoadInventoryData( val, 1 )
		end
	} )

	SQLColumn.Init( {
		["column"] = "BankLimit",
		["update"] = function( ply )
			return ply:BankLimit()
		end,
		["defaultvalue"] = function( ply )
			ply:SetMaxBank( GTowerItems.DefaultBankCount )
		end,
		["onupdate"] = function( ply, val )
			ply:SetMaxBank( tonumber( val ), true )
		end
	} )

	SQLColumn.Init( {
		["column"] = "bank",
		["selectquery"] = "HEX(bank) as bank",
		["selectresult"] = "bank",
		["update"] = function( ply )
			return ply:GetInventoryData( 2 )
		end,
		["defaultvalue"] = function( ply )
			ply:LoadInventoryData( 0x0, 2 )
		end,
		["onupdate"] = function( ply, val )
			ply:LoadInventoryData( val, 2 )
		end
	} )

	/*SQLColumn.Init( {
		["column"] = "wearable",
		["selectquery"] = "HEX(wearable) as wearable",
		["selectresult"] = "wearable",
		["update"] = function( ply )
			return ply:GetInventoryData( 4 )
		end,
		["defaultvalue"] = function( ply )
			ply:LoadInventoryData( 0x0, 4 )
		end,
		["onupdate"] = function( ply, val )
			ply:LoadInventoryData( val, 4 )
			if IsValid( ply ) then
				GTowerItems.CheckEquipEntityItems( ply )
			end
		end
	} )*/
end )

concommand.Add("gmt_invuploaddatabase", function( ply )

	if ply != NULL && !ply:IsAdmin() then
		return
	end

	local UpdateStrs = {}

	for _, item in pairs( GTowerItems.Items ) do

		table.insert( UpdateStrs,
			string.format("(%s,'%s','%s','%s',%s,%s,'%s',%s)",
				item.MysqlId,
				 SQL.getDB():Escape(item.UniqueName or "") ,
				 SQL.getDB():Escape(item.Name or "") ,
				 SQL.getDB():Escape(item.Description or ""),
				item.StoreId or 0,
				item.StorePrice or 0,
				item.Model or "",
				item:IsWeapon() and 1 or 0
			)
		)

	end

	local EndRequest = string.format( "REPLACE INTO `gm_items`(`id`,`unique`,`Name`,`desc`,`storeid`,`price`,`model`,`weapon`) " ..
		"VALUES %s", table.concat( UpdateStrs,",") )

	local Start = SysTime()

	 SQL.getDB():Query( EndRequest, function( res, status, error )
		if status != 1 then
			Error( error )
		end

		Msg("Query took: " .. (SysTime() - Start ) .. " seconds.\n")
	end	)

end )
