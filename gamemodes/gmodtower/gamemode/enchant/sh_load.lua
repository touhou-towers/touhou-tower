

local List = {'clonemaker'}

for _, v in pairs( List ) do

	local File = "enchants/" .. v .. ".lua"

	if SERVER then
		AddCSLuaFile( File )
	end
	
	include( File )
	
end