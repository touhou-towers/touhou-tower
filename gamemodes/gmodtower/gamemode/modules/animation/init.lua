
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


module( "Animation", package.seeall )


local function AnimUMSG( ply, msgType, val )

	umsg.Start( "GAnim" )
	
	umsg.Char( msgType )
	umsg.Entity( ply )
	
	if ( msgType == Animation.TYPE_SCALE ) then
	
		umsg.Float( val or 1 )
		
	elseif ( msgType == Animation.TYPE_ANIMATION ) then
	
		umsg.Short( val or 0 )
		
	else
	
		if ( Animation.DEBUG ) then
			Msg( "AnimUMSG with incorrect type!\n" )
		end
		
	end

	umsg.End()
	
end

function ScaleModel( ply, scale )

	if ( Animation.DEBUG ) then
		Msg( "Scaling model to " .. tostring( scale ) .. " for player " .. tostring( ply ) .. "\n" )
	end
	
	ply._IginoreChangeSize = true
	ply._PlyModelSize = scale
	
	AnimUMSG( ply, Animation.TYPE_SCALE, scale )
	
end

function PlayAnim( ply, anim )

	local eval = _G[ anim ] or anim
	
	if ( Animation.DEBUG ) then
		Msg( "Playing animation " .. tostring( anim ) ":" .. tostring( eval ) .. " for player " .. tostring( ply ) .. "\n" )
	end
	
	ply:DoAnimationEvent( eval )
	
	AnimUMSG( ply, Animation.TYPE_ANIMATION, eval )
	
end

