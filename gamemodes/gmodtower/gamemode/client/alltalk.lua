

usermessage.Hook("GTAllTalk", function( um )      		
	if um:ReadBool() == true then
		RunConsoleCommand( "+voicerecord")
	else
		RunConsoleCommand( "-voicerecord")
	end
end)

local function AllTalkBindPress( ply, bind, pressed )

	if string.find( bind, "voicerecord" ) then
		ply:ConCommand( "gmt_resetvoice" )
	end

end

hook.Add( "PlayerBindPress", "AllTalkBindPress", AllTalkBindPress )