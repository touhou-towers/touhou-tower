
--[[
 	Post-Processing Event Handlers

	by PackRat ( packrat (at) plebsquad (dot) com )

	Version 1.0, 19th Feb 2007

	Because PostMan is entirely clientside,
	the server does not have direct access
	to the postman library. Post Events
	allow preset post-processing effects
	to be created and triggered by the
	server, similar to util.Effect.
]]--

util.AddNetworkString("postevent")

function PostEvent( ply, Name, mul, time )

	if ( !ply || !ply:IsValid() ) then return end
	if ( !Name || Name == "" ) then return end

 	mul = mul or 1
 	time = time or 0

  net.Start( "postevent" )
    net.WriteString( Name )
    net.WriteFloat( mul )
    net.WriteFloat( time )
  net.Send( ply )

	/*umsg.Start( "postevent", ply )
		umsg.String( Name )
		umsg.Float( mul )
		umsg.Float( time )
	umsg.End()*/

end
