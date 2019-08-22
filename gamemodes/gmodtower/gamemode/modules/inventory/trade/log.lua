


function GTowerTrade.LogTrade( ply1, ply2, money1, money2, recv1, recv2 )

	local function CompileData( tbl )
	
		local Data = Hex()
		
		for _, v in pairs( tbl ) do
			Data:Write( v.mysqlid, 4 )
			Data:WriteString( v.data )
		end
		
		return Data:Get()
	
	end
	
	 SQL.getDB():Query( "INSERT INTO gm_log_trade(`ply1`,`ply2`,`money1`,`money2`,`recv1`,`recv2`) VALUES("
			..ply1:SQLId() ..","
			..ply2:SQLId() ..","
			.. money1 ..","
			.. money2 ..","
			.. CompileData( recv1 ) ..","
			.. CompileData( recv2 ) ..")", 
		GTowerSQL.ErrorCheckCallback,
		nil,
		"TradeLog")

end