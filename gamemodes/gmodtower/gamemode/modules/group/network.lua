
hook.Add("PlayerThink", "GTowerSendGroups", function(ply)
	if ply._SendNoGroup then

		net.Start( "GGroup" )
			net.WriteInt( 3, 16 )
		net.Send( ply )

		/*umsg.Start("GGroup", ply)
			umsg.Char( 3 )
		umsg.End()*/
		ply._SendNoGroup = nil
	end
end)

timer.Create("GTowerSendGroups", 1, 0, function()

	for _, v in pairs( GTowerGroup.Groups ) do
		if v.NeedSendNetwork then
			v:SendNetwork()
		end
	end

end)
