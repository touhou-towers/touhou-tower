


module("concommand", package.seeall )

local OldAdd = Add

function ClientAdd( cmd, func )
	
	OldAdd( cmd, function( ply, cmd, args )
		Errors.ClientCall( func, ply, cmd, args )
	end )

end

function DebugAdd( cmd, func )
	
	OldAdd( cmd, function( ply, cmd, args )
		if not _G.DEBUG then
			return
		end
	
		SafeCall( func, ply, cmd, args )
	end )

end