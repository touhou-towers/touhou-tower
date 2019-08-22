
if string.StartWith(game.GetMap(),"gmt_build") then return end

local pairs = pairs
local unpack = unpack
local hookTable = hook.GetTable()
local hook = hook
local print = print

module("hook2")

local function GetArguments( status, ... )
	local args = {...}
	if status && args[1] != nil then
		return args
	end
end

function hook.Remove( event_Name, Name )
	
	if hookTable[ event_Name ] then
		hookTable[ event_Name ][ Name ] = nil
	end
	
end

function hook.Call( Name, gm, ... )
	
	local HookTable = hookTable[ Name ]
	local Args
	
	if HookTable then
		
		for k, v in pairs( HookTable ) do 
			
			// Call hook function
			Args = GetArguments( SafeCall( v, ... ) )
			
			// Allow hooks to override return values
			if Args then			
				return unpack( Args )
			end
			
		end
		
	end
	
	if gm && gm[ Name ] then
		
		// This calls the actual gamemode function - after all the hooks have had chance to override
		Args = GetArguments( SafeCall( gm[ Name ], gm, ... ) )
		
		if Args then
			return unpack( Args )
		end
		
	end
	
end
