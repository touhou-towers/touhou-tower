
module("TowerModules", package.seeall )

LoadedModules = {}
ModulesFolder = string.sub( GM.Folder, 11 )  .. "/gamemode/modules/"
	

function LoadModule( Name )

	local FileName = SERVER && "init.lua" || "cl_init.lua"	
	
	local ModuleDir = ModulesFolder .. Name .. "/"
	local ModuleFiles = file.Find( ModuleDir .. "*", "LUA" )
	
	if table.Count( ModuleFiles ) == 0 then
		print( "Module folder: " .. Name .. " not found!\n")
		return
	end
	
	if table.HasValue( ModuleFiles, FileName ) then
		include( ModuleDir .. FileName )
		
	elseif table.HasValue( ModuleFiles, "shared.lua" ) then
		include( ModuleDir .. "shared.lua" )
	
	else
		ErrorNoHalt( "Could not find file to load in " .. Name .. " " .. FileName .."!\n")
		return
	
	end
	
	if !table.HasValue( LoadedModules, Name ) then
		table.insert( LoadedModules, Name )
	end
end

function LoadModules( list )
	
	for _, Name in pairs( list ) do
		LoadModule( Name )
	end
	
end 