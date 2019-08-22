AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

module("minigames", package.seeall )


function Start( name, Settings )

	local Minigame = List[ name ]
	
	if !Minigame then //Minigame does not exist
		return false
	end
	
	if !Settings then
		Settings = {}
	end

	for name, info in pairs( Minigame.Settings ) do
		
		if !Settings[ name ] then //Make sure the value exists
			Settings[ name ] = info.Default
		end
		
		if info.Type == "number" then //Make sure the value is within boundries
			
			Settings[ name ] = tonumber( Settings[ name ] )
			
			if info.Max && Settings[ name ] > info.Max then
				Settings[ name ] = info.Max
			end
			
			if info.Min && Settings[ name ] < info.Min then
				Settings[ name ] = info.Min
			end
			
		end
		
		if info.Type == "dropdown" then
			
			Settings[ name ] = tonumber( Settings[ name ] )
			
			if !info.Values[ Settings[ name ] ] then //The value of dropdown does not exist
				Settings[ name ] = info.Default
			end
			
		end
	
	end
	
	if table.Count( Settings ) == 0 then
		Error("Settings table was empty, could not start minigame.")
	end
	
	Minigame.ActiveSettings = Settings
	Minigame.Start(Settings)

end

concommand.Add("gmt_startmini", function( ply, cmd, args )
	
	if ply:IsAdmin() && args[1] then
		if !Start( args[1] ) then
			ply:Msg2("Could not find '" .. args[1] .. "'")
		end
	end
	
end )