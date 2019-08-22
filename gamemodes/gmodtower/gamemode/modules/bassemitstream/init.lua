
AddCSLuaFile("cl_init.lua")

concommand.Add("gmt_bassemitstart", function(ply, cmd, args)

	if !( ply:IsSuperAdmin() || ClientSettings:Get( ply, "GTAllowEmitStream" ) ) then return end

	local stream = args[1]

	// Test for some errors
	if !stream then
		ply:PrintMessage( HUD_PRINTCONSOLE, "Unable to play stream, something broke.\n" )
		return
	end

	if string.sub( stream, 0, 5 ) != "http:" then
		ply:PrintMessage( HUD_PRINTCONSOLE, "Unable to play stream, http missing!\n" )
		return
	end

	local ext = string.sub( stream, -4 )
	if ext == ".mp3" || ext == ".pls" then

		if ply.EmitStream && IsValid( ply.EmitStream ) then
			ply.EmitStream:Remove()
			ply.EmitStream = nil
		end

		local ent = ents.Create( "gmt_emitstream" )
		ent:SetPos( ply:GetPos() + Vector( 0, 0, 48 ) ) //So it doesn't spawn on the ground.
		ent:Spawn()
		ent:SetParent( ply )
		ent:Activate()
		ent:SetOwner( ply )
		ent:LoadSong( stream)

		ply.EmitStream = ent

		AdminNotify(T( "AdminStartStream", ply:GetName() ))

	else
		ply:PrintMessage( HUD_PRINTCONSOLE, "Unable to play stream, file type not recognized!\n" )
	end

end)

concommand.Add("gmt_bassemitend", function(ply, cmd, args)

	if ply.EmitStream && IsValid( ply.EmitStream ) then
		ply.EmitStream:Remove()
		ply.EmitStream = nil
	end

end)

concommand.Add("gmt_removeallstreams", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then return end

	for k, v in ipairs( ents.FindByClass("gmt_emitstream") ) do
		if !IsValid(v) then return end
		v:GetOwner().EmitStream = nil
		v:Remove()
	end

		AdminNotify(T( "AdminClrStreams", ply:GetName() ))
end)

hook.Add("PlayerDisconnected", "GMTBassEmitDisconnectRemove", function(ply)
	if IsValid( ply.EmitStream ) then ply.EmitStream:Remove() end
end)
