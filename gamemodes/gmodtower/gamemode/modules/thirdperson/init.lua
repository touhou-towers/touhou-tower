
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_viewself.lua" )


local function ChangeThird( ply, cmd, args )

	if #args == 0 then return end
	
	local chEnable = args[ 1 ]
	
	if ( chEnable == "true" ) then
		ply:CrosshairDisable()
	else
		--ply:CrosshairEnable()
	end
	
end

concommand.Add( "gmt_changethirdperson", ChangeThird )
