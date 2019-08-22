--print('a')
hook.Add( "Move", "EmoteMove", function( ply, mv ) 
	
	if ply:GetNWBool("Emoting") then
		return true
	end
	
end)