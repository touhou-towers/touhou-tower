
hook.Add("PlayerNoClip", "DisableNoclip", function(ply)
	
	if hook.Call( "GTCanNoClip", GAMEMODE, ply ) == false then return false end
	
	if ply:IsAdmin() || ply.GTNoClip == true then
		return true
	end
end) 

hook.Add("AdminCommand", "EnableNoclip", function( args, admin, ply )

	if args[1] == "noclip" then
		ClientSettings:Set( ply, "Noclip", !ply.GTNoClip )
	end

end )

hook.Add("ClientSetting", "CheckNoclip", function( ply, id, val )

	if ClientSettings:GetName( id ) == "Noclip" then
	
		if val == true then
			if ply:GetMoveType() == MOVETYPE_NOCLIP then
				ply:SetMoveType( MOVETYPE_WALK )
			end
		end
		
	end

end )

