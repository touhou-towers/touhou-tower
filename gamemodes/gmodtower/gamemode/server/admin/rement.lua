
concommand.Add("gmt_rement", function( ply, cmd, args )

	if !ply:IsAdmin() && ply:GetSetting("GTAllowInvAllEnts") == false then
		return
	end
	
	local Trace = ply:GetEyeTrace()
	
	if Trace.Entity then
		local ItemId = GTowerItems:FindByEntity( Trace.Entity )
		
		if ItemId then
			Trace.Entity:Remove()
		end
		
	end

end )