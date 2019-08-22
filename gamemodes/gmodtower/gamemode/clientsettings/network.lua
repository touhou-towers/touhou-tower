
ClientSettings.NeedSend = {}

function ClientSettings:ValueChanged( target )
	
	if self.DEBUG then
		Msg("Updating data of " .. tostring(target) .. "\n")
	end
	
	for _, ply in pairs( player.GetAll() ) do
		
		if ply:IsAdmin() || target == ply then
		
			if !self.NeedSend[ply] then
				self.NeedSend[ply] = {}
			end
			
			if !table.HasValue( self.NeedSend[ply], target ) then
				if self.DEBUG then Msg("\tAdding " .. tostring(ply) .. "\n") end
				table.insert( self.NeedSend[ply], target )
			end
		
		end
	end
	
end

function ClientSettings:SendPlayer( ply, target )
	
	if !IsValid( target ) then
		return
	end
	
	local IsAdmin = ply:IsAdmin()
	if self.DEBUG then Msg( "Sending Network: " .. tostring( ply ) .. " of " , target , "\n") end
	
	umsg.Start("PlySett", ply )
		umsg.Char( target:EntIndex() )
		umsg.Bool( IsAdmin )
		
		for k, v in ipairs( ClientSettings.Items ) do
			
			if ( (v.SendType == true && ply == target) || IsAdmin) && umsg[ v.NWType ] then
				
				local Value = ClientSettings:Get( target, k )
				
				if v.NWType == "Bool" then
					//if self.DEBUG then Msg( "\t" .. v.Name .. ":Sending Bool (" ..tostring(Value).. ")\n") end
					umsg.Bool( Value )
				elseif Value == v.Default then
					//if self.DEBUG then Msg( "\t" .. v.Name .. ":Sending Default value\n") end
					umsg.Bool( true )
				else
					//if self.DEBUG then Msg( "\t" .. v.Name .. ":Sending ".. tostring( Value ) .."\n") end
					umsg.Bool( false )
					umsg[ v.NWType ]( Value )
				end
				
			end		
			
		end
	
	umsg.End()

end

timer.Create("UpdateClientSettings", 0.3, 0, function()

	for ply, v in pairs( ClientSettings.NeedSend ) do
	
		if !IsValid( ply ) then
			ClientSettings.NeedSend[ ply ] = nil
			
		elseif #v > 0 then
			
			ClientSettings:SendPlayer( ply, table.remove( v ) )
			
		end	
		
	end

end )

hook.Add( "SQLConnect", "ClientSettingsRefresh", function( ply )
	timer.Simple( 1.0, function() 
		if !ClientSettings.NeedSend[ply] then
			ClientSettings.NeedSend[ply] = {}
		end
		
		if !ply:IsAdmin() then 
			if !ClientSettings:IsDefault( ply ) then
				table.insert( ClientSettings.NeedSend[ply], ply )
			end
			return
		end
		
		if ClientSettings.DEBUG then Msg( ply, " just connected\n") end
		
		for _, v in pairs( player.GetAll() ) do
			//if !ClientSettings:IsDefault( v ) then
				if !table.HasValue( ClientSettings.NeedSend[ply], v ) then
					if ClientSettings.DEBUG then Msg("\tAdding to send" .. tostring(v) .. "\n") end
					table.insert( ClientSettings.NeedSend[ply], v )
				end
			//end		
		end
		
	end )
end )