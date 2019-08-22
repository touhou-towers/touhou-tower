module("minigames", package.seeall )

function file.FindDir( File, Dir )



	local files, folders = file.Find( File, Dir )

	return table.Add( files, folders )



end

do
	local MiniGames = file.FindDir( "gmodtowerlobby/gamemode/minigames/*", "LUA" )

	for _, v in ipairs( MiniGames ) do
		if v != "shared.lua" then
			print(v)
		end
		if v != "." && v != ".." && v != ".svn" && string.sub( v, -4 ) != ".lua" then
			if SERVER then
				include( v .. "/init.lua" )
			else
				include( v .. "/cl_init.lua" )
			end

		end

	end
end
