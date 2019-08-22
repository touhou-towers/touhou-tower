
hook.Add("SQLStartColumns", "StartBasicColumns", function()
	SQLColumn.Init( {
		["column"] = "money",
		["update"] = function( ply ) 
			return math.Clamp( ply:Money(), 0, 2147483647 )
		end,
		["defaultvalue"] = function( ply )
			ply:SetMoney( 0 )
		end,
		["onupdate"] = function( ply, val ) 
			ply:SetMoney( tonumber( val ) or 0 )
		end
	} )


	SQLColumn.Init( {
		["column"] = "Name",
		["fullupdate"] = function( ply ) 
			return "`Name`='" ..  SQL.getDB():Escape(ply:Name()) .. "'"
		end,
	} )


	SQLColumn.Init( {
		["column"] = "ip",
		["fullupdate"] = function( ply ) 
			if ply.SQL then
				return "`ip`='" .. tostring(ply.SQL:GetIP()) .. "'"
			end
		end,
	} )

	SQLColumn.Init( {
		["column"] = "LastOnline",
		["update"] = function( ply, ondisconnect ) 
			if ondisconnect == true then
				return os.time()
			end
		end,
	} )
	SQLColumn.Init( {
		["column"] = "time",
		["fullupdate"] = function( ply, onend )
			if onend == true then 
				return "`time`=`time`+" .. ply:TimeConnected()
			end
		end
	} )
end )


-- Useless shit
--[[
hook.Add("SQLStartColumns", "SQLUpdateFrags", function()
	SQLColumn.Init( {
		["column"] = "kills",
		["fullupdate"] = function( ply, onend )
			if onend != true then return nil end
			
			return "`kills`=`kills`+" .. ply:Frags()
		end,
	} )
end )

hook.Add("SQLStartColumns", "SQLUpdateDeaths", function()
	SQLColumn.NewColumn( {
		["column"] = "deaths",
		["fullupdate"] = function( ply, onend )
			if onend != true then return nil end
			
			return "`deaths`=`deaths`+" .. ply:Deaths()
		end,
	} )
end )
*/]]
