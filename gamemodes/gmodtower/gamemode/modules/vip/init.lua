

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_player.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_player.lua" )

include( "shared.lua" )

include( "sv_sql.lua" )
include( "sv_admin.lua" )


local meta = FindMetaTable( "Player" )


function meta:SetVIP( isVip, update )

	if isVip then
		self.Vip = 1
	else
		self.Vip = 0
	end
	
	if ( update ) then
		Vip.SQLUpdate( self )
	end
	
end

meta.SetVip = meta.SetVIP