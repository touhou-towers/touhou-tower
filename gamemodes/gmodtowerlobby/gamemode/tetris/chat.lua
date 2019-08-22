local hook = hook
local CurTime = CurTime
local tmysql = tmysql
local IsValid = IsValid
local tonumber = tonumber
local Msg = Msg
local umsg = umsg
local SQLLog = SQLLog
local ChatCommands = ChatCommands
local SQL = SQL
local pairs = pairs

module("tetrishighscore")

function GetPlayerPosition( ply, res, status, err )

	if res[1].status != true then
		SQLLog('error', "Could not get tetris score: " .. res[1].error )
		return
	end

	if !IsValid( ply ) then
		return
	end

	local Count = 0

	for k,v in pairs(res[1].data[1]) do
		Count = tonumber( v ) + 1
	end

	umsg.Start("TetHiS")
		umsg.Char( 1 )
		umsg.Char( ply:EntIndex() )
		umsg.Long( Count )
	umsg.End()


end

if !ChatCommands then
	SQLLog( 'error', "Chat commands module not loaded, /tetris commands will be unavailable\n" )
	return
end

ChatCommands.Register( "/tetris", 5, function( ply )
	SQL.getDB():Query("SELECT COUNT(*) FROM gm_users WHERE `tetrisscore`>".. Get( ply ), function(res)
		GetPlayerPosition(ply,res)
	end)
	return ""
end )
