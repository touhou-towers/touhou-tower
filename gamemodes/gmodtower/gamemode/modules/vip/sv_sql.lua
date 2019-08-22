

if !tmysql then
	Msg( "tmysql not found! Vip system disabled\n" )
	return
end

function Vip.SQLInit()
	 SQL.getDB():Query( "CREATE TABLE IF NOT EXISTS gm_vip( `steamid` varchar(20) NOT NULL, PRIMARY KEY (`steamid`) )" )
end

function Vip.SQLAuthed( ply, steamid )

	if ply:IsBot() then return end
	
	ply:SetVIP( false )
	
	local steamid =  SQL.getDB():Escape( ply:SteamID() )
	
	 SQL.getDB():Query( "SELECT * FROM gm_vip WHERE steamid = \"" .. steamid .. "\";", function( res, status, err )
	
		if !status then
			Msg( "Error getting VIP status: " .. err )
			return
		end
		
		if #res == 0 then return end
		
		ply:SetVIP( true )
		
	end )
	
end

function Vip.SQLCallback( res, status, err )

	if !status then
		SQLLog( "vip", "VIP sql updated failed: " .. err )
		return
	end
	
end

function Vip.AddVip( steamid )

	steamid =  SQL.getDB():Escape( steamid )
	 SQL.getDB():Query( "INSERT INTO gm_vip VALUES( \"" .. steamid .. "\" ) ON DUPLICATE KEY UPDATE steamid = \"" .. steamid .. "\";", Vip.SQLCallback )
	
end
Vip.AddVIP = Vip.AddVip

function Vip.SQLUpdate( ply )
	
	local steamid =  SQL.getDB():Escape( ply:SteamID() )
	
	if ply:IsVIP() then
		Vip.AddVIP( ply:SteamID() )
	else
		 SQL.getDB():Query( "DELETE FROM gm_vip WHERE steamid = \"" .. steamid .. "\";", Vip.SQLCallback )
	end
	
end

hook.Add( "Initialize", "VipInit", Vip.SQLInit )
hook.Add( "PlayerAuthed", "VipAuthed", Vip.SQLAuthed )

hook.Add( "MapChange", "VipShutdown", function()

	hook.Remove( "PlayerAuthed", "VipAuthed" )
	
end )