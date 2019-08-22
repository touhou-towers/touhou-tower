
usermessage.Hook("t6", function( um )
    GtowerMessages:AddNewItem( um:ReadString() )
end ) 

usermessage.Hook("t7", function( um )
    
	local Name = um:ReadString()
	local Count = um:ReadChar()
	local Values = {}
	
	for i=1, Count do
		table.insert( Values, um:ReadString() )
	end
	
	GtowerMessages:AddNewItem( T( Name, unpack( Values ) ) )
	
end ) 

/*
 0 = pressed f1
 1 = pressed f2
 2 = pressed f3
 3 = pressed f4
*/

hook.Add("InitPostEntity", "test", function()
	for _, ply in pairs( player.GetAll() ) do
		timer.Simple( 1.0, hook.Call, "PlayerSpawn", GAMEMODE, ply )
	end
end )

usermessage.Hook("GT", function( um )      
	local help = um:ReadChar()
	
	if help == 0 then
		
	elseif help == 1 then
		
	elseif help == 2 then
		
	elseif help == 3 then
		
	elseif help == 4 then
	
		local ply = Entity( um:ReadChar() )
		if IsValid( ply ) then
			hook.Call("PlayerSpawn", GAMEMODE, ply )
		end
		
	end
	
end )  
