




if SERVER then
concommand.Add("gmt_testkart", function( ply )

	if !ply:IsAdmin() then
		return
	end
	
	if ply.Kart then
		
		SafeRemoveEntity( ply.Kart )
		
		ply:UnSpectate()
		ply:SetParent( nil )
		ply:SetOwner( nil )
		
		ply.Kart = nil
		
		ply:SetClientsideVehicle( nil )
		ply:SetScriptedVehicle( nil )
		
	
	else
		
		ply:UnSpectate()
		
		ply.Kart = ents.Create("kart")
		ply.Kart:Spawn()
		ply.Kart:Activate()
		ply.Kart:SetDriver(ply)
		
		ply.Kart:SetAngles( ply.Kart:GetAngles() )
		ply.Kart:SetPos( ply:EyePos() + ply:GetForward() * 128 )
		ply.Kart:DropToFloor()		
		
		//ply:SetParent( ply.Kart )
		
		print( ply.Kart:EntIndex() )
		
	end


end )
end