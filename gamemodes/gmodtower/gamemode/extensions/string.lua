



function string.hash( str )
	
	local bytes = {string.byte( str, 0, string.len( str ) )}
	local hash = 0
	
	//0x07FFFFFF
	//It is a sequrence of 31 "1".
	//If it was a sequence of 32 "1", it would not be able to send over network as a positive number
	//Now it must be 27 "1", because DTVarInt hates 31... Do not ask why...
	for _, v in ipairs( bytes ) do
		hash = math.fmod( v + ((hash*32) - hash ), 0x07FFFFFF )
	end
	
	return hash
	
end