

GAllTalk = false

hook.Add("PlayerCanHearPlayersVoice", "GMTAdminAllTalk", function(listener, talker)

	if talker:GetNWBool("GlobalMute") then return false end

	if !string.StartWith(game.GetMap(),"gmt_build") && !string.StartWith(game.GetMap(),"gmt_halloween") then return true end

	if GAllTalk or talker.AllTalkActive then return true
	elseif listener:GetPos():Distance(talker:GetPos()) < 1024 then
			return true,true -- TODO check if the listener has gmt_rangevoice enabled.
		else
			return false
	end

end)

local function SendMessage( ply )

	umsg.Start("GTAllTalk", ply )
		umsg.Bool( ply.AllTalkActive == true )
	umsg.End()

end

concommand.Add( "gmt_alltalk", function( ply, cmd, args )

	if !ply:IsAdmin() then return end

	if #args == 0 then return end

	if ( args[ 1 ] == "1" ) then

		GAllTalk = true

		AdminNotify( ply:Name().." has enabled alltalk!" )

	else

		GAllTalk = false

		AdminNotify( ply:Name().." has disabled alltalk!" )

	end

end )

timer.Create( "DisableAllTalk", 30, 0, function( )

	// don't need to do anything if alltalk is disabled
	if !GAllTalk then return end

	local adminPresent = false

	for _, v in ipairs( player.GetAll() ) do
		if IsValid( v ) && v:IsAdmin() then
			adminPresent = true
		end
	end

	if !adminPresent then

		GAllTalk = false

		for _, v in ipairs( player.GetAll() ) do
			if IsValid( v ) then v:Msg2( "Alltalk his been automatically disabled!" ) end
		end

	end

end )

concommand.Add("+alltalk", function( ply )

	if ply:IsAdmin() || ply:GetSetting("GTAllowAllTalk") == true  then
		ply.AllTalkActive = true
		SendMessage( ply )
	end

end )

concommand.Add("-alltalk", function( ply )

	if ply:IsAdmin() || ply:GetSetting("GTAllowAllTalk") == true  then
		ply.AllTalkActive = nil
		SendMessage( ply )
	end

end )

concommand.Add("gmt_resetvoice", function( ply )

	if ( ply:IsAdmin() || ply:GetSetting("GTAllowAllTalk") ) then
		ply.AllTalkActive = nil
	end

end )
