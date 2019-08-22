

module("minigames", package.seeall )

List = {}

function RegisterMinigame( env )
	
	if List[ env._NAME ]  then
		ErrorNoHalt("Attetion! Registering two minigames under the name " .. name )
	end
	
	List[ env._NAME ] = env
	
end


do
	local MiniGames = file.Find("deathrun/gamemode/minigames2/*.lua", "LUA")

	for _, v in ipairs( MiniGames ) do
		
		if v != "." && v != ".." && v != ".svn" && string.sub( v, -4 ) != ".lua" then
			
			if SERVER then
				include( v .. "/init.lua" )
			else
				include( v .. "/cl_init.lua" )
			end
			
		end

	end
end