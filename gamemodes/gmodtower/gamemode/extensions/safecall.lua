


module( "hook2", package.seeall )

local HandleError
local ErrorMemory = {}

if SERVER then
	HandleError = function( err )
		if err == nil then err = "#EMPTY_ERROR" end
		local traceback = debug.traceback()
		if traceback == nil then traceback = "#EMPTY_TRACEBACK" end
		
		local ErrorMsg = err .. "\n" .. traceback
		
		if table.HasValue( ErrorMemory, err ) then
			return
		end
		
		table.insert( ErrorMemory, err )
		
		// this is gross
		// but it should be safe to assume this function always exists at this point
		//Sql.Log( "error", ErrorMsg )
		
		ErrorNoHalt( "\n\n" .. ErrorMsg .. "\n\n" )
		
		return ErrorMsg
	end
else
	HandleError = function( err )
		if table.HasValue( ErrorMemory, err ) then
			return
		end
		
		table.insert( ErrorMemory, err )
	
		if LocalPlayer():IsAdmin() then
			ErrorNoHalt( err )
		else
			print( err )
		end
		
		local trace = debug.traceback()
		
		print( trace .. "\n" )
		
		return err
	end
end

function SafeCall( func, ... )
	
	local argcache = {...}
	
	if #argcache == 0 then
		return xpcall( func, HandleError )
	end
	
	return xpcall( function()
		return func( unpack(argcache) )
	end, HandleError )

end

_G.SafeCall = SafeCall
