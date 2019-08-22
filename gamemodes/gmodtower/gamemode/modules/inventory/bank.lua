
function GTowerItems:OpenBank( ply )

	umsg.Start("Inv", ply )
		umsg.Char( 3 )
	umsg.End()

end

concommand.Add("gmt_openbank", function( ply, cmd, args )
	if !ply:GetSetting( 19 ) then
		return
	end

	if ply:AllowBank() then
		GTowerItems:OpenBank( ply )
	end
end )

concommand.Add("gmt_invbank", function( ply, cmd, args )
	if !ply:IsAdmin() then
		return
	end

	if ply:AllowBank() then
		GTowerItems:OpenBank( ply )
	end
end )
