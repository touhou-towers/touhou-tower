function GM:CacheStuff()


	/* Models */
	for k, v in pairs( file.Find( "models/uch/uchimeragm.*", "GAME" ) ) do
		util.PrecacheModel( v )
	end

	for k, v in pairs( file.Find( "models/uch/birdgib.*", "GAME" ) ) do
		util.PrecacheModel( v )
	end

	for k, v in pairs( file.Find( "models/uch/pigmask.*", "GAME" ) ) do
		util.PrecacheModel( v )
	end

	for k, v in pairs( file.Find( "models/uch/mghost.*", "GAME" ) ) do
		util.PrecacheModel( v )
	end

	for k, v in pairs( file.Find( "models/uch/saturn.*", "GAME" ) ) do
		util.PrecacheModel( v )
	end


	/* Music */
	for k, v in pairs( file.Find( "sound/UCH/music/*", "GAME" ) ) do
		util.PrecacheSound( v )
	end

	for k, v in pairs( file.Find( "sound/UCH/music/endround/*", "GAME" ) ) do
		util.PrecacheSound( v )
	end

	for k, v in pairs( file.Find( "sound/UCH/music/ghost/*", "GAME" ) ) do
		util.PrecacheSound( v )
	end

	for k, v in pairs( file.Find( "sound/UCH/music/round/*", "GAME" ) ) do
		util.PrecacheSound( v )
	end

	for k, v in pairs( file.Find( "sound/UCH/music/spawn/*", "GAME" ) ) do
		util.PrecacheSound( v )
	end

	for k, v in pairs( file.Find( "sound/UCH/music/waiting/*", "GAME" ) ) do
		util.PrecacheSound( v )
	end

	
	/* Sound Effects */
	for k, v in pairs(file.Find("sound/UCH/chimera/*", "GAME")) do
		util.PrecacheSound(v)
	end

	for k, v in pairs(file.Find("sound/UCH/pigs/*", "GAME")) do
		util.PrecacheSound(v)
	end

	for k, v in pairs( file.Find( "sound/UCH/saturn/*", "GAME" ) ) do
		util.PrecacheSound( v )
	end
	

end