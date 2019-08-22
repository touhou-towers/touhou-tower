
local meta = FindMetaTable( "Player" )

if (!meta) then
    Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:GetSetting( id )
	return ClientSettings:Get( self, id )
end

if SERVER then
	function meta:SetSetting( id, val )
		ClientSettings:Set( self, id, val )
	end
end
