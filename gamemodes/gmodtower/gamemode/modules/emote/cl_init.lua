
include( "shared.lua" )
include( "cl_emotes.lua" )

net.Receive( "EmoteAct", function()
	RunConsoleCommand( "act", net.ReadString() )
end )

hook.Add( "KeyPress", "EmoteEndByKey", function( ply, key )

	if ply:GetNWBool("Sitting") || ply:GetNWBool("Laying") then

		if key == IN_FORWARD || key == IN_BACK || key == IN_MOVELEFT || key == IN_MOVERIGHT || key == IN_JUMP then
			RunConsoleCommand( "gmt_emoteend" )
		end

	end

end )

hook.Add( "ForceViewSelf", "ForceViewSelfEmotes", function( ply )

	return emote && emote.IsEmoting( ply )

end ) 

