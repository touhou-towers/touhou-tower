
include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
AddCSLuaFile('vocab.lua')

local function InsertHackerStatus(result, status, error)
	if status != 1 then
		MysqlError( error )
	end
end

function GTowerHackers:NewAttemp( ply, id, cmd, args, extra )

	if !tmysql then
		return
	end

	if type( args ) == "table" then
		args = string.Implode( " ", args )
	else
		args = tostring( args )
	end
	
	local SQLID = ply:SQLId()
	extra = extra or ""	
	
	local InsertString = "INSERT INTO `gm_hackers`(`user`,`hackid`,`cmd`,`args`,`extra`) VALUES ("..SQLID..","..id..",'".. SQL.getDB():Escape(cmd).."','".. SQL.getDB():Escape(args).."', '".. SQL.getDB():Escape(extra).."')"
	

	 SQL.getDB():Query( InsertString, InsertHackerStatus )
end