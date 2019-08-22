include("shared.lua")
include("cl_hud.lua")
include("cl_post_events.lua")
include("cl_scoreboard.lua")
include("cl_gamemode.lua")
include("calcview.lua")
include("minigames/shared.lua")
include("tetris/cl_init.lua")
include("cl_webboard.lua")
include("cl_hudchat.lua")
include("cl_tetris.lua")
include("uch_anims.lua")
include("event/cl_init.lua")

local tourmsgnotice = CreateClientConVar( "gmt_enabletournotice", "1", true, true )

EnableParticles = CreateClientConVar("gmt_enableparticles","1",true,false)
NoGMMsg = CreateClientConVar("gmt_ignore_gamemode","0",true,false)

VoiceDistance = CreateClientConVar("gmt_voice_distance","1024",true,true)

// holy shit cosmetics
function GM:OverrideHatEntity(ply)

	if IsValid( ply ) && !ply:Alive() then
		return ply:GetRagdollEntity()
	end

	if IsValid( ply.BallRaceBall ) then
		return ply.BallRaceBall.PlayerModel
	end

	return ply
end

// ball orb support
hook.Add( "GShouldCalcView", "ShouldCalcVewBall", function( ply, pos, ang, fov )

	// if the ball race ball is set, we should override the pos and dist
	return IsValid( ply.BallRaceBall )

end )

hook.Add( "DrawDeathNotice", "DisableLobbyDeaths", function()

	return false

end )

hook.Add( "GCalcView", "CalcViewBall", function( ply, pos, dist )

	// we'll eventually want to support multiple cases, so that only one ent can override the position and distance
	if IsValid( ply.BallRaceBall ) then

		local pos2 = ply.BallRaceBall:GetPos() + Vector( 0, 0, 30 )
		local dist2 = dist + 50

		return pos2, dist2

	end

	// default values
	return pos, dist

end )

local WalkTimer = 0
local VelSmooth = 0
local cl_viewbob = CreateConVar( "gmt_viewbob", "0", { FCVAR_ARCHIVE } )

hook.Add("CalcView", "GMTViewBob", function( ply, origin, angle, fov)

	if cl_viewbob:GetBool() && ply:Alive() && not ( ply.ThirdPerson || ply.ViewingSelf ) then

		local vel = ply:GetVelocity()
		local ang = ply:EyeAngles()

		VelSmooth = VelSmooth * 0.9 + vel:Length() * 0.075
		WalkTimer = WalkTimer + VelSmooth * FrameTime() * 0.05

		angle.roll = angle.roll + ang:Right():DotProduct( vel ) * 0.01

		if ( ply:GetGroundEntity() != NULL ) then
			angle.roll = angle.roll + math.sin( WalkTimer ) * VelSmooth * 0.001
			angle.pitch = angle.pitch + math.sin( WalkTimer * 0.5 ) * VelSmooth * 0.001
		end

	end

end )

//Halloween map only
local function RemoveAllFogs()
	Msg("REMOVING ALL FOG!\n")
	for _, v in pairs( ents.FindByClass("func_smokevolume") ) do
		v:Remove()
	end
end

local allowfog = cookie.GetNumber("gmtallowfog", 0 )

hook.Add("OnEntityCreated", "GMTRemoveFog", function( ent )
	if IsValid(ent) && allowfog > 0 && ent:GetClass() == "func_smokevolume" then
		timer.Simple(3.0, RemoveAllFogs )
	end
end )

hook.Add("InitPostEntity", "GMTRemoveFog", function()
	timer.Simple(5.0, function()
		if allowfog > 0 then
			Msg("Start: REMOVING ALL FOG!\n")
			RemoveAllFogs()
		end
	end )
end )

hook.Add("HUDPaint", "PaintMapChanging", function()

	if !GetGlobalBool("ShowChangelevel") then return end

	local curClientTime = os.date("*t")
	local timeUntilChange = GetGlobalInt("NewTime") - CurTime()

	local timeUntilChangeFormatted = string.FormattedTime(timeUntilChange,"%02i:%02i")

	draw.RoundedBox(0, 0, 0, ScrW(), 40, Color(25,25,25,200))
	draw.SimpleText("RESTARTING FOR UPDATE IN: " .. timeUntilChangeFormatted, "GTowerHUDMainLarge", ScrW()/2, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

net.Receive("gmt_gamemodestart",function()
	if NoGMMsg:GetBool() then return end

	local Gmode = net.ReadString()
	local plys = net.ReadInt(32)
	local id = net.ReadInt(32)

	local NiceNames = {}
	NiceNames["ballrace"] = "Ball Race"
	NiceNames["minigolf"] = "Minigolf"
	NiceNames["pvpbattle"] = "PvP Battle"
	NiceNames["virus"] = "Virus"
	NiceNames["zombiemassacre"] = "Zombie Massacre"
	NiceNames["sourcekarts"] = "Source Karts"
	NiceNames["ultimatechimerahunt"] = "UCH"
	NiceNames["gourmetrace"] = "Gourmet Race"
	NiceNames["monotone"] = "Monotone"

	Gmode = NiceNames[Gmode] or Gmode

	local Question = Msg2( Gmode .. " is about to begin with " .. plys .. " players in 20 seconds. Join?" )
	Question:SetupQuestion(
	function() RunConsoleCommand( "gmt_mtsrv", 1, id ) end,
	function() end,
	function() end,
	nil,
	{120, 160, 120},
	{160, 120, 120}
)
end)

net.Receive("AdminMessage",function()

	local ply = net.ReadEntity()
	local Text = net.ReadString()

	if ( IsValid(ply) && !ply:IsAdmin() ) then return end

	local Message = Msg2(Text)
	Message:SetColor(Color( 255, 50, 50 ))
	Message:SetTargetAlpha(255)
	Message:SetTextColor(Color(0,0,0,255))
	Message:SetIcon("admin")


end)

concommand.Add("gmt_tourmsg",function(ply)

	/*if tourmsgnotice:GetInt() == 0 then return end

	local tourmsg = Msg2('Welcome to GMod Tower, would you like to watch a quick tour?')
	tourmsg:SetupQuestion( function() RunConsoleCommand("gmt_starttour") end, function()
		 RunConsoleCommand("gmt_enabletournotice","0")
		 Msg2("Okay, we won't show you this again.")
	 end,
	 function() end )*/
end)

concommand.Add("gmt_removefog", function( ply, cmd, args )

	if !args[1] then
		Msg("Usage: gmt_removefog <1/0>\n")
		return
	end

	local val = tonumber( args[1] ) or 0
	cookie.Set("gmtallowfog", val )

	if val > 0 then
		Msg2("All fog entites have been removed.")
		timer.Simple(0, RemoveAllFogs )
	else
		Msg2("Fog entities will not be removed next time you join the server.")
	end

end )

hook.Add( "KeyPress", "UsePlayerMenu", function( ply, key )
	if ( key == IN_USE ) then
		local ent = LocalPlayer():GetEyeTrace().Entity
		if IsValid(ent) and ent:IsPlayer() and ent:Alive() and (LocalPlayer():GetPos():Distance(ent:GetPos()) < 100) then
			PlayerMenu.Show(ent)
		end
	end
end )
