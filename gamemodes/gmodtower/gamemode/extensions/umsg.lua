

local DEBUG = false

if CLIENT then

	local bf_read = FindMetaTable( "bf_read" )

	if !bf_read then
		Msg( "Unable to get bf_read meta table.\n" )
		return
	end


	function bf_read:ReadColor()
		
		if DEBUG then
			Msg( "bf_read reading color.\n" )
		end
		
		local r = self:ReadChar() + 128
		local g = self:ReadChar() + 128
		local b = self:ReadChar() + 128
		local a = self:ReadChar() + 128
		
		if DEBUG then
			Msg( "Recieved color: ( ", r, ", ", g, ", ", b, ", ", a, " )\n" )
		end
		
		return Color( r, g, b, a )
	end

end

if SERVER then

	function umsg.Color( clr )
	
		if DEBUG then
			Msg( "umsg sending color.\n" )
			Msg( "pre-serialization: ( ", clr.r, ", ", clr.g, ", ", clr.b, ", ", clr.a, " )\n" )
		end
			
		local r = math.Clamp( math.floor( clr.r ), 0, 255 ) - 128
		local g = math.Clamp( math.floor( clr.g ), 0, 255 ) - 128
		local b = math.Clamp( math.floor( clr.b ), 0, 255 ) - 128
		local a = math.Clamp( math.floor( clr.a ), 0, 255 ) - 128
		
		if DEBUG then
			Msg( "post-serialization: ( ", r, ", ", g, ", ", b, ", ", a, " )\n" )
		end
		
		umsg.Char( r )
		umsg.Char( g )
		umsg.Char( b )
		umsg.Char( a )
		
	end

end