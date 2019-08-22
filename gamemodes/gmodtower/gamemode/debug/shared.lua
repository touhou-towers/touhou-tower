
DEBUG = DEBUG or {}

DEBUG.List = {}

function DEBUG:Add( tbl )

	self.List[ tbl.Name ] = tbl

end



function DEBUG:Call( Name, ... )

	if !Name || !self.List[ Name ] then
		ErrorNoHalt("Debug call not found: ", Name, "\n")
		return
	end

	local EndStr = ""
	
	for _, v in pairs( {...} ) do
		EndStr = EndStr .. tostring( v ) .. "\t"
	end
	
	EndStr = string.Trim( EndStr )

	hook.Call("DebugMsg", GAMEMODE, Name, EndStr, false )
	
	Msg( Name, ": ", EndStr, "\n" )
	
end

function DebugMsg( Name, ... )
	DEBUG:Call( Name, ... )
end

function DEBUG:Enabled( Name )
	return self.List[ Name ] && self.List[ Name ].Enabled
end

function DEBUG:Enable( Name )
	self:ChangeState( Name, true )
end

function DEBUG:Disable( Name )
	self:ChangeState( Name, false )
end

function DEBUG:ChangeState( Name, state )
	
	local item = self.List[ Name ]
	
	if !item then
		return
	end
	
	if item.func then
		local b, err = pcall( item.func, state )
		if !b then
			ErrorNoHalt( err )
		end
	end
	
	if item.tbl then
		local var = item.var or "DEBUG"
		
		item.tbl[ var ] = state
	end
	
	item.State = state
	
	if CLIENT then
		local StringState = "true"
		if state != true then
			StringState = "false"
		end
		
		RunConsoleCommand("debug_listen", Name, StringState )
		Msg2("DEBUG: " .. Name .. " changed to: " .. tostring(state) )
	else
		Msg("DEBUG: " .. Name .. " changed to: " .. tostring(state), "\n" )
	end
	
	

end

function DEBUG:Exists( Name )
	return self.List[ Name ] != nil
end

