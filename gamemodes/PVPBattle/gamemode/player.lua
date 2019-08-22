PlayerMeta = FindMetaTable( "Player" )

// switches to the next available weapon on the player
function PlayerMeta:SwitchToNextWeapon()

	if !SERVER then return end
	
	local weps = self:GetWeapons()
	
	local index = 1
	
	for k, v in ipairs( weps ) do
		if ( self.Classname == v.Classname ) then
			index = k + 1
			break
		end
	end
	
	if ( index > #weps ) then
		index = 1
	end
		
	self:SelectWeapon( weps[ index ].Classname )
	
end