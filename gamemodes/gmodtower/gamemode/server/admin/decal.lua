
concommand.Add("gmt_cleardecals", function(ply, cmd, args)

		if !ply:IsSuperAdmin() then return end

		BroadcastLua("RunConsoleCommand('r_cleardecals')")
		AdminNotify(T( "AdminClrDecals", ply:GetName() ))

end)