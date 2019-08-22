
concommand.Add("gmt_dumpentities", function( ply )

	if ply != NULL && !ply:IsAdmin() then
		return
	end

	local Str = ""
	local Tbl = {}
	local AllEntityList = ents.GetAll()

	for _, v in pairs( ents.GetAll() ) do
		local pos = v:Location() or 0
		
		if !Tbl[ pos ] then
			Tbl[ pos ] = { v }
		else
			table.insert( Tbl[ pos ], v )
		end
		
	end

	for k, entlist in pairs( Tbl ) do
		
		Str = Str .. tostring(Location.GetName( k )) .. " (".. tostring(k) ..")\n"
		
		for _, v in pairs( entlist ) do
			Str = Str .. "\t" .. tostring(v) .. "\n"
		end

	end


	file.Write("dump.txt", Str )
	
	if ply != NULL then
		ply:Msg2("Entity dump: " .. tostring(#AllEntityList) .. " entities found.")
	end
	
end )
