
local function UpdateData( ply, ondisconnect )

	local Room = ply:GetRoom()

	if Room then
		return Room:GetSQLSave()
	end

end
if string.StartWith(game.GetMap(),"gmt_build0s2b") or string.StartWith(game.GetMap(),"gmt_0c3") then
hook.Add("SQLStartColumns", "SQLRoomData", function()
	SQLColumn.Init( {
		["column"] = "roomdata",
		["selectquery"] = "HEX(roomdata) as roomdata",
		["selectresult"] = "roomdata",
		["update"] = UpdateData,
		["defaultvalue"] = function( ply )
			ply._RoomSaveData = nil
		end,
		["onupdate"] = Suite.SQLLoadData
	} )
end )
elseif string.StartWith(game.GetMap(),"gmt_build0h") or string.StartWith(game.GetMap(),"gmt_002a") then
hook.Add("SQLStartColumns", "SQLRoomData", function()
	SQLColumn.Init( {
		["column"] = "romdata",
		["selectquery"] = "HEX(romdata) as romdata",
		["selectresult"] = "romdata",
		["update"] = UpdateData,
		["defaultvalue"] = function( ply )
			ply._RoomSaveData = nil
		end,
		["onupdate"] = Suite.SQLLoadData
	} )
end )
else
hook.Add("SQLStartColumns", "SQLRoomData", function()
	SQLColumn.Init( {
		["column"] = "rumdata",
		["selectquery"] = "HEX(rumdata) as rumdata",
		["selectresult"] = "rumdata",
		["update"] = UpdateData,
		["defaultvalue"] = function( ply )
			ply._RoomSaveData = nil
		end,
		["onupdate"] = Suite.SQLLoadData
	} )
end )
end