
local EntityList = {}

hook.Add("InitPostEntity", "SaveEntityPositions", function()
	timer.Simple( 10.0, function()
		for _, v in pairs( ents.GetAll() ) do
			EntityList[ v ] = {v:GetPos(), v:GetAngles() }
		end
	end )	
end )

concommand.Add("gmt_resetents", function( ply, cmd, args ) 

	if !ply:IsAdmin() then
		return
	end
	
	for k, v in pairs( EntityList ) do
		if !IsValid( k ) then
			EntityList[ k ] = nil
		else
			k:SetPos( v[1] )
			k:SetAngles( v[2] )
			
			local phys = k:GetPhysicsObject()
			
			if IsValid( phys ) then
				phys:EnableMotion( false )
			end
			
		end
	end

end )