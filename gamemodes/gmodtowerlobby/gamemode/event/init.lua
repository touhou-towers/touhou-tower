--Some Settings

//DEFAULT
local EventSound = "gmodtower/misc/notifyevent.wav"
if time.IsChristmas() then EventSound = "gmodtower/music/christmas/eventnotify.mp3" end

local minigameslist = { "balloonpop", "obamasmash", "chainsaw", "snowbattle" }
local shopslist = { 2, 3, 4, 5, 6, 7, 8, 11, 13, 15, 17, 24, 26, 27 }
minsale = 0.1
maxsale = 0.5
--local repeattimemin = 1800
--local repeattimemax = 5400
minitime = 600 -- 600
saletime = 120 -- 60
local ministarttime = 0
local enabled = true
local endtime = 0
local started = false
local currenttype = ""
local currentname = ""

function SecondsToFormat(Seconds)
	if(!Seconds) then
		return "N/A"
	end
	local Original 	= tonumber(Seconds)
	if(!Original) then
		return "N/A"
	end
	local Hours 	= math.floor(Seconds / 60 / 60)
	local Minutes 	= math.floor(Seconds / 60)
	local Seconds 	= math.floor(Seconds - (Minutes * 60))
	local Timeleft 	= ""
	if(Minutes >= 60) then
		while(Minutes >= 60) do
			Minutes = Minutes - 60
		end
	end
	if(Seconds >= 60) then
		while(Seconds >= 60) do
			Seconds = Seconds - 60
		end
	end
	if(Hours > 0) then
		Timeleft = Hours.." hour(s) "
	end
	if(Minutes > 0 and Minutes < 10) then
		Timeleft = Timeleft.."0"..Minutes.." minute(s) "
	elseif(Minutes >= 10) then
	    Timeleft = Timeleft..Minutes.." minute(s) "
	end
	if(Seconds >= 10) then
		Timeleft = Timeleft..Seconds.." second(s)"
	else
		Timeleft = Timeleft.."0"..Seconds.." second(s)"
	end
	return Timeleft
end

function StartEvent()
    --[[if #player.GetAll() < 10 then
		SendMessageToPlayers( "EventNeedMorePlayers", nil )
		endtime = 0
		timer.Create( "GMTEventReset", 60, 1, function() started = false end ) -- Just one non-critical to execution time timer
		return
	end]]
	math.randomseed(os.time())
	started = true

	local rnd = math.random(3, 4)
	if rnd == 3 and ministarttime <= os.time() then
		StartRandomMiniGame()
	elseif rnd == 4 then
		StartRandomStore()
	else
		StartRandomStore()
	end
end

function StartRandomStore()
	math.randomseed(os.time())
	local store = table.Random(shopslist)
	local value = math.Clamp(math.Rand(minsale,maxsale), -math.huge, 1)
	SendMessageToPlayers( "EventSetSale", GTowerStore.Stores[ store ].WindowTitle )
	for k,v in pairs(player.GetAll()) do v:SendLua([[surface.PlaySound("]]..EventSound..[[")]]) end
	SendMessageToPlayers( "EventEndingTime", SecondsToFormat( saletime ) )
	GTowerStore:BeginSale(store, value)
	endtime = os.time() + saletime
	eventtype = "sale"
	eventname = store
end

function StartRandomMiniGame()
	math.randomseed(os.time())
	ministarttime = os.time() + 18000
	local MiniGameStr = table.Random(minigameslist)
	for k,v in pairs(player.GetAll()) do v:SendLua([[surface.PlaySound("]]..EventSound..[[")]]) end
	local MiniGame = minigames[ MiniGameStr ]
	if !MiniGame then
		SendMessageToPlayers( "EventError" )
		enabled = false
		return
	end

	SendMessageToPlayers( MiniGame._M.MinigameMessage, ( MiniGame._M.MinigameArg1 or "" ), ( MiniGame._M.MinigameArg2 or "" ) )

    if MiniGameStr == "snowbattle" then
		SafeCall( MiniGame.Start, "a" )
	elseif MiniGameStr == "chainsaw" || MiniGameStr == "plane" then
		SafeCall( MiniGame.Start, "b" )
	else
		SafeCall( MiniGame.Start, "" )
	end

	endtime = os.time() + minitime
	SendMessageToPlayers( "EventEndingTime", SecondsToFormat( minitime ) )
	eventtype = "minigame"
	eventname = MiniGameStr
end

function SendMessageToPlayers(msgtype, ...)
	for _, v in ipairs(player.GetAll()) do
		v:MsgT( msgtype, select( 1, ... ) )
	end
end

function EndEvent()
	if eventtype == "sale" then
		GTowerStore:EndSale(eventname)
		SendMessageToPlayers( "EventEndSale", GTowerStore.Stores[ eventname ].WindowTitle )
	elseif eventtype == "minigame" then
		local MiniGame = minigames[ eventname ]
		SafeCall( MiniGame.End )
		--SendMessageToPlayers( MiniGame._M.MinigameMessage, ( MiniGame._M.MinigameArg1 or "" ), ( MiniGame._M.MinigameArg2 or "" ) )
	else
		SendMessageToPlayers( "EventError" )
		enabled = false
	end
	eventtype = ""
	eventname = ""
	started = false
	endtime = 0
end

function Checkforstart()
	if !enabled then return end
	if endtime > 0 and endtime <= os.time() then
		EndEvent()
	end
	if (os.date("%M") == "00" or os.date("%M") == "30") and !started then StartEvent() started = true end
end
hook.Add("Think", "GMTEventCheckStart", Checkforstart)

concommand.Add("gmt_enableevent", function( ply, cmd, args )

	if !ply:IsAdmin() then
		return
	end

	if !enabled then
		enabled = true
		SendMessageToPlayers( "EventAdminEnabled", ply:Name() )
	end

end )

/*
concommand.Add("gmt_eventsettings", function( ply, cmd, args )

	if !ply:IsAdmin() || #args != 4 then
		return
	end
	minsale = args[1]
	maxsale = args[2]
	minitime = args[3]
	saletime = args[4]
end )
*/

concommand.Add("gmt_manualevent", function( ply, cmd, args )

	if !ply:IsAdmin() then
		return
	end

	StartEvent()
	SendMessageToPlayers( "EventAdminManual", ply:Name() )

end )

concommand.Add("gmt_disableevent", function( ply, cmd, args )

	if !ply:IsAdmin() then
		return
	end

	if enabled then
		SendMessageToPlayers( "EventAdminDisabled", ply:Name() )
		enabled = false
	end

end )

concommand.Add("gmt_skipevent", function( ply, cmd, args )

	if !ply:IsAdmin() then
		return
	end

	if enabled and started then EndEvent() end

end )
