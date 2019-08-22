
Msg("Loading tmysql module...\n");

require( "tmysql4" )

module("SQL", package.seeall )

ColumnInfo = ColumnInfo or {}

function connectToDatabase()
	if tmysql then
		Msg("[MYSQL] Attempting connection to mysql\n")
		databaseObject, err = tmysql.initialize("database ip", "user name", "password", "database name", 3306, 3, 3)
		Msg("[MYSQL] Connected to mysql\n")
	end
end

connectToDatabase()

function getDB()
	return databaseObject
end

GTowerSQL = {}

local db = getDB()

include("mysql/colums.lua")
include("mysql/player.lua")

/*
column = COLUMN NAME

//What should be inserted into the UPDATE query
fullupdate = nil or function(ply) returning "columnname = value"

//If fullupdate is not set, this will be called, just return value
update = function(ply) return val end

//What should be put in the sql query
selectquery = nil or columnname

//What column should be selected from the database
selectresult = nil or columname

//Called when the new value has been se
onupdate = nil or function(ply, val) ply:SetVal( val ) end

//Called when the default value need to be set
defaultvalue = nil or function

*/

function GetColumns()
	return Colums
end

function StartColums()

	if Colums then
		return
	end

	Colums = {}

	hook.Call("SQLStartColumns", GAMEMODE )

	//Just some garbage collecting to make sure it won't be added twice
	hook.GetTable().SQLStartColumns = nil

end

function SqlError( error )
	local Match = string.match( error, "Table '([%a_]+)' is marked as crashed and should be repaired" )

	if Match then

		SQLLog('error', Match .. " marked as crashed. Repairing it." )

		databaseObject:Query( "REPAIR TABLE `".. Match .."`", self.RepairCallback )

	end

end

RepairCallback = function( res, status, error )

	local EndString = ""

	if status != 1 then
		EndString = "Repair callback: " .. error
	else
		for _, v in pairs( res ) do
			EndString = EndString .. table.concat( v, "\t") .. "\n"
		end
	end

	SQLLog('error', "Repair table crashed: " .. EndString )

end

ErrorCheckCallback = function( origin, res, status, error )

	if status != 1 then
		SQLLog('error', 'Origin: ' .. origin .. "\n MySQL Error: " .. error )
	end

end

hook.Add("PlayerAuthed", "GtowerSelectSQL", function(ply, steamid)

	if ply:IsBot() then
		return
	end

	StartColums()

	--ply.SQL = GTowerSQL:NewSQLPlayer( ply )
	ply.SQL = SQLPlayer.Init( ply )
	ply.SQL:ExecuteSelect()

	ply.NextSQLUpdate = CurTime() + 5
end )

hook.Add("PlayerDeath", "GtowerSQLPlayerDeath", function(ply)
	if !ply:IsBot() && ply.SQL then
		ply.SQL:Update( false )
	end
end)

hook.Add("PlayerThink", "GTowerSQLUpdate", function(ply)
	if !ply:IsBot() && ply.SQL && ply.NextSQLUpdate && CurTime() > ply.NextSQLUpdate then
		ply.NextSQLUpdate = CurTime() + 5
		ply.SQL:Update( false )
	end
end)

hook.Add("PlayerDisconnected", "GtowerSQLDisconnect", function(ply)

	if !ply:IsBot() && ply.SQL then
		ply.SQL:Update( true )
	end
end )


hook.Add( "MapChange", "GtowerSQLShutDown", function()

	Msg("Map change, mysql shut down.")

    for k, v in pairs( player.GetAll() ) do
		if !v:IsBot() && v.SQL then
			v.SQL:Update( true )
		end
    end

	//Remove hooks to prevent any confusion
	hook.Remove("PlayerDisconnected", "GtowerSQLDisconnect")
	hook.Remove("PlayerDeath", "GtowerSQLPlayerDeath")
	hook.Remove("PlayerAuthed", "GtowerSelectSQL")
	hook.Remove("PlayerThink", "GTowerSQLUpdate")

end )

hook.Add("CanChangeLevel", "SavingPlayers", function()
	for _, ply in pairs( player.GetAll() ) do
		if ply.SQL && ply.SQL.UpdateInProgress == true then
			return false
		end
	end
end )

concommand.Add("gmt_forceupdate", function( ply, cmd, args )

	if ply == NULL || ply:IsAdmin() then

		for _, v in ipairs( player.GetAll() ) do
			if !v:IsBot() && v.SQL then
				v.SQL:Update( false, true )
			end
	    end

	end

end )

concommand.Add("gmt_dumpsqldata", function( ply, cmd, args )

	file.Write( "SQLDUMP_" .. ply:SQLId() .. ".txt", table.ToNiceString( ply.SQL ) )

end )
