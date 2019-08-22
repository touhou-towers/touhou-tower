
local ErrorLogMessages = {}

local function SQLLogResult(res, status, err)
	if status != 1 then
		//TODO: Broken
		--ErrorNoHalt( "LOG ERROR: " .. res.error .. "\n" )
	end
end

function SQLLog( source, ... )

	if !tmysql then
		return
	end

	local message = ""

	for _, v in pairs( {...} ) do
		if type( v ) == "Player" then
			message = message .. "[p=".. tostring(v:SQLId()) .."]"
		else
			message = message .. tostring ( v )
		end
	end

	if string.len( message ) < 3 then
		return
	end

	if !source || !message || !GTowerServers then
		print("no message")
		debug.Trace()
		return
	end

	if source == 'error' then
		local Hash = tonumber( util.CRC( select(1, ...) ) )

		if table.HasValue( ErrorLogMessages, Hash ) then
			return
		end
		table.insert( ErrorLogMessages, Hash )
		ErrorNoHalt( message )

		 SQL.getDB():Query(
			"INSERT INTO  `gm_log_error`(`message`,`srvid`) VALUES " ..
			"('"..  SQL.getDB():Escape(message) .."',"
			.. tostring(GTowerServers:GetServerId()) ..")"
		, SQLLogResult )

	else

		 SQL.getDB():Query(
			"INSERT INTO  `gm_log`(`type`,`message`,`srvid`) VALUES " ..
			"('"..  SQL.getDB():Escape(tostring(source)) .."','"
			..  SQL.getDB():Escape(message) .."',"
			.. tostring(GTowerServers:GetServerId()) ..")"
		, SQLLogResult)

	end

end
