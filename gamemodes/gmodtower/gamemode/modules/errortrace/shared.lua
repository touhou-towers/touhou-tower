

-----------------------------------------------------
// ErrorTrace made by mitterdoo
// Used as a more helpful xpcall function
// Also filters out the path to the file of the caller of the function (see filter argument in Call)

module( "ErrorTrace", package.seeall )

function Debug( ... )

	// MsgC( Color( 255, 0, 0 ), "[ErrorTrace] ", ..., "\n" )

end

/*
	Error catching function
	func = function to call in protected environment
	err = function to call when error occurs in protected environment
		args given:
			string error
			table stack
	filter = string to replace any occurrences of the caller's path in trace/error with
		(ex. passing "Gamemode Init" from path "gamemodes/gmodtower/gamemode/init.lua" would
		replace the path with "Gamemode Init" in the trace and error string)

		pass nil or "" to have no filter
	full = must not be false/nil to return entire trace
	... = varargs to pass into func
*/
function Call( func, err, filter, full, ... )

	Debug( "called" )
	local FilterOut = debug.getinfo( 2, "Sln" ) // filter out the path to the caller of this function
	FilterOut = FilterOut.short_src
	Debug( "filtering out " .. FilterOut )

	local FunctionError

	local ErrorFunc = function( Error )

		Debug( "error: " .. Error )
		// backtrace
		local Stack = {}
		local Level = 1
		local Offset = 0 // offset to filter out how this error function was called
		while true do

			local info = debug.getinfo( Level + Offset, "Sln" )
			if !info then break end
			if info.what == "C" then

				table.insert( Stack, "Internal function" )

			else
				local format = "Line %d: \"%s\"  %s"
				format = string.format( format,
					info.currentline,
					info.name or "unknown",
					info.short_src
				)
				table.insert( Stack, format )

			end

			Level = Level + 1

		end

		// now to filter out stuff after the last occurrence of the caller
		if !full then
			for i = #Stack, 1, -1 do

				if string.find( Stack[i], FilterOut, nil, true ) then

					for i2 = i + 1, #Stack do

						Stack[i2] = nil

					end
					break

				end

			end
		end

		// filter out caller's path
		local function filt( str )

			local fx, fy = string.find( str, FilterOut, nil, true )
			if !( filter == "" or !filter ) and fx then

				if fx == 1 then

					return filter .. string.sub( str, fy + 1 )

				elseif fy == #str then

					return string.sub( str, 1, fx - 1 ) .. filter

				else

					return string.sub( str, 1, fx - 1 ) .. filter .. string.sub( str, fy + 1 )

				end

			end

			return str

		end
		Error = ( filter == "" or !filter ) and Error or filt( Error )

		for i = 1, #Stack do

			Stack[i] = filt( Stack[i] )

		end

		xpcall( err, function( FuncError ) // just in case the caller set up this function incorrectly

			FunctionError = FuncError

		end, Error, Stack )

	end

	xpcall( func, ErrorFunc, ... )

	if FunctionError then

		error( FunctionError ) // can't error in xpcall's error function; will just catch it and not notify us

	end

end
