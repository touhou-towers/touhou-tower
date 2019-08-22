
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("gmt_startstream")

concommand.Add("gmt_startstream", function(ply, cmd, args, str)
	if !ply:IsAdmin() then return end

	for k,v in pairs(player.GetAll()) do
		if v.GLocation == ply.GLocation then
			net.Start("gmt_startstream")
				net.WriteString(args[1])
				net.WriteString( ply:Name() )
			net.Send(v)
		end
	end
	
end)