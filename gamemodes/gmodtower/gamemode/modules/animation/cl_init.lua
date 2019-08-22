
include("shared.lua")

module( "Animation", package.seeall )

local function AnimHandler( um )

	local msgType = um:ReadChar()
	if ( msgType == nil ) then
	
		if ( Animation.DEBUG ) then
			Msg( "AnimHandler recieved an invalid umsg type!\n" )
		end
		
		return
	end
	
	local ent = um:ReadEntity()
	if ( !IsValid( ent ) ) then
	
		if ( Animation.DEBUG ) then
			Msg( "AnimHandler recieved an invalid umsg entity!\n" )
		end
		
		return
	end
	
	if ( msgType == Animation.TYPE_SCALE ) then 
	
		local scale = um:ReadFloat() or 1
		local vec = Vector( scale, scale, scale )
		
		if ( Animation.DEBUG ) then
			Msg( "scale: " .. tostring( scale ) .. "\n" )
		end
		
		ent:SetModelScale( vec )
		
	
	elseif ( msgType == Animation.TYPE_ANIMATION ) then
	
		local anim = um:ReadShort() or 0
		
		if ( Animation.DEBUG ) then
			Msg( "anim: " .. tostring( anim ) .. "\n" )
		end
		
		ent:DoAnimationEvent( anim )

		
	end
	
end

usermessage.Hook( "GAnim", AnimHandler )