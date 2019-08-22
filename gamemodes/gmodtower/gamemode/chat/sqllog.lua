
local function SQLLogResult(res, status, err)
	if status != 1 then
		--ErrorNoHalt( "Chat error:" .. err )
	end
end

hook.Add("PlayerSay", "GTowerLogChat", function( ply, chat )
	
	if !tmysql then
		return
	end
	
	SQL.getDB():Query(
		"INSERT INTO gm_chat(`ply`,`message`,`srvid`) VALUES " ..
		"(".. ply:SQLId() ..",'"
		.. SQL.getDB():Escape(chat) .."',"
		.. tostring(GTowerServers:GetServerId()) ..")"
	, SQLLogResult)


end )