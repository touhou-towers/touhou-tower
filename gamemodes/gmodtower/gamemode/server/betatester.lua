
GTowerBeta = {}
GTowerBeta.Active = false

CreateConVar("gmt_var_betatest", "1" )

function GTowerBeta:Active()
	return GTowerBeta.Active
end



hook.Add("SQLStartColumns", "SQLUpdateBetaTest", function()
	SQLColumn.Init( {
		["column"] = "betatest",
		["onupdate"] = function( ply, val ) 
			GTowerBeta:CheckPlayerEntry( ply, val )
		end,
		["defaultvalue"] = function( ply )
			GTowerBeta:CheckPlayerEntry( ply, 0 )
		end
	} )
end )

function GTowerBeta:CheckPlayerEntry( ply, val )

	if GTowerBeta:Active() then
		//I am sorry, you are not a beta tester
		if tobool( val ) == false then
			ply:Kick("Beta testers only.")
		end
	end

end

local function UpdateTesterResult(result, status, error)
	if status != 1 then
		Msg( error .. "\n")
	end
end

function GTowerBeta:UpdateBetaTester( SteamID, IsBeta )
	
	if string.len( SteamID ) < 6 || string.sub( SteamID, 0, 8 ) != "STEAM_0:" then
		return
	end

	local StemSteamID = string.sub( SteamID, 9 )
	local ServerId = tonumber( string.sub( StemSteamID, 0, 1 ) )
	local UniqueId = tonumber( string.sub( StemSteamID, 3 ) )
	local MysqlId = UniqueId * 2 + ServerId
	
	local Query = "INSERT INTO `gm_users`(`id`,`steamid`,`betatest`,`CreatedTime`) VALUES " .. 
	"(" .. MysqlId  .. ",'" ..  SQL.getDB():Escape( SteamID ) .. "',".. IsBeta .. ",".. os.time() .. ")" .. 
	"  ON DUPLICATE KEY UPDATE `betatest`=" .. IsBeta
	
	 SQL.getDB():Query( Query, UpdateTesterResult )

end

concommand.Add( "gmt_addbetatest", function( ply, cmd, args )

	--if !ply:IsAdmin() then
	--	if GTowerHackers then
	--		GTowerHackers:NewAttemp( ply, 5, cmd, args )
	--	end
	--	return
	--end
	
	//Aparently the engine detetcs ":" as a new argument, giving the following table
	//1 = "STEAM_0"
	//2 = ":"
	//3 = "0"
	//4 = ":"
	//5 = "132"
	
	if tmysql && (#args == 1 || #args == 5) then
		GTowerBeta:UpdateBetaTester( table.concat( args ), 1 )
	end

end )

concommand.Add( "gmt_removebetatest", function( ply, cmd, args )

	if !ply:IsAdmin() then
		if GTowerHackers then
			GTowerHackers:NewAttemp( ply, 5, cmd, args )
		end
		return
	end

	if tmysql && #args == 5 then
		GTowerBeta:UpdateBetaTester( table.concat( args ), 0 )
	end

end )