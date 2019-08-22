local function LockDoors( Vec, size )
 
	for _, ent in ipairs( ents.FindInSphere( Vec, size ) ) do

		if ( ent:GetClass() == "func_door" || ent:GetClass() == "func_door_rotating" ) then
  
			ent:SetKeyValue( "spawnflags", 16 )
			ent.LockedDoor = true

		end

	end

end

// clean up our maps
function GM:CleanUpMap()

	//kaBOOOM!!
	for _, ent in ipairs( ents.FindByClass( "tnt" ) ) do
		ent:Remove()
	end
	
	for _, ent in ipairs( ents.FindByClass( "weapon_*" ) ) do
		ent:Remove()
	end
	
	for _, ent in ipairs( ents.FindByClass( "item_*" ) ) do
		ent:Remove()
	end
	
	if string.find( game.GetMap():lower(), "gmt_virus_facility" ) then
		for _, ent in ipairs( ents.FindByClass( "info_player_*" ) ) do
		
			if ( ent:GetPos().z >= 109 ) then // remove vent spawns
				ent:Remove()
			end
			
		end

		LockDoors( Vector( 408.0000, 2029.0000, -100.0000 ), 50 )
		LockDoors( Vector( -116.0000, 34.0000, 48.0000 ), 5 )

		timer.Simple( 1, function()

			for _, ent in ipairs( ents.FindByClass( "prop_*" ) ) do

				if ( ent:GetModel() == "models/props_wasteland/controlroom_desk001b.mdl" ) then

					ent:Remove()
				
				else

					local phys = ent:GetPhysicsObject()
					if IsValid( phys ) then
						phys:EnableMotion( false )
					else
						ent:Remove()  //welp
					end

				end

			end

		end )

	end
	
	if string.find( game.GetMap():lower(), "gmt_virus_swamp" ) then
		for _, ent in ipairs( ents.FindByClass( "info_player_*" ) ) do
		
			local pos = ent:GetPos()
			pos.z = pos.z + 10
			
			ent:SetPos( pos )
		
		end
		
		for _, ent in ipairs( ents.FindInSphere( Vector( -986.7764, -1034.1051, -782.3086 ), 100 ) ) do
			ent:Remove()
		end
	end

	if string.find( game.GetMap():lower(), "gmt_virus_sewage" ) then
	
		self:AlterProp( "models/props_wasteland/kitchen_shelf001a.mdl", true )
		
		for _, ent in ipairs( ents.FindInSphere( Vector( -200.084900, 126.813332, 61.956268 ), 100 ) ) do
			if IsValid( ent ) then
				ent:Remove()
			end
		end

	end
	
	if string.find( game.GetMap():lower(), "gmt_virus_aztec" ) then
	
		self:AlterProp( "models/props_c17/woodbarrel001.mdl", true )

	end
  
	for _, ent in pairs( ents.FindByClass( "func_door*" ) ) do

		if !ent.LockedDoor then
			ent:Remove()
		end

	end
	
	if self.VirusDebug then
		for _, ent in ipairs( ents.FindByClass( "info_player*" ) ) do
	
			local spawnent = ents.Create( "spawn" )
			if IsValid( spawnent ) then
				spawnent:SetPos( ent:GetPos() )
				spawnent:ShouldRemove( false )
				spawnent:Spawn()
				spawnent:Activate()
			end
		end
	end

end

function GM:AlterProp( class, freeze ) // if true freeze, if false just remove

	timer.Simple( 1, function()

		for _, ent in ipairs( ents.FindByClass( "prop_*" ) ) do

			if ( ent:GetModel() == class ) then

				if freeze then

					local phys = ent:GetPhysicsObject()
					if IsValid( phys ) then
						phys:EnableMotion( false )
					else
						ent:Remove()  //welp
					end

				else

					ent:Remove()

				end

			end

		end

	end )

end