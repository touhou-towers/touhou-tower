--[[
	this file is for extending various existing classes
	]]
DeriveGamemode( "gmodtower" )

-- nice spelling on achievement
TowerModules.LoadModules({
	"achivement",
	"commands",
	"afk2",
	"friends",
	"scoreboard3",
	"weaponfix",
	"payout",
	"music"
})

-- i have no idea where this GM variable comes from
-- actually its straight from the api https://wiki.garrysmod.com/page/Structures/GM
GM.Name = "Touhou Tower: Ballrace Redone"
GM.Author = "Reimu"
GM.Website = "http://www.rhkr.ml"

-- and then stick some random fields on why not
GM.Lives = 3
GM.Tries = 2
GM.DefaultLevelTime = 60
GM.IntermissionTime = 35

-- here we determine the values based on the map
local LivesTriesOverride = {
	gmt_ballracer_midori = {
		Time = 120,
		Lives = 4
	},
	gmt_ballracer_memories04 = {
		Time = 70,
		Lives = 4
	},
	gmt_ballracer_tranquil = {
		Time = 70
	}
}
LivesTriesOverride.gmt_vallracer_midorib5 = LivesTriesOverride.gmt_ballracer_midori
LivesTriesOverride.gmt_ballracer_miracle = LivesTriesOverride.gmt_ballracer_tranquil

local map = game.GetMap()
if LivesTriesOverride[map] then
	GM.DefaultLevelTime = LivesTriesOverride[map] or GM.DefaultLevelTime
	GM.Lives = LivesTriesOverride[map].Lives or GM.Lives
end

if map == "gmt_ballracer_khromidro02" then
	music.Register( MUSIC_LEVEL, GetMusicSelection(), { Length = 322 * ( 1 / .75 ), Pitch = 75, Loops = true } )
else
	music.Register( MUSIC_LEVEL, GetMusicSelection(), { Loops = true, Length = GetMusicDuration() } )
end

music.Register( MUSIC_BONUS, "balls/bonusstage" )
SetTime(GM.DefaultLevelTime)

-- and now some methods
local novel = Vector(0,0,0)
function GM:Move(ply, movedata)
	movedata:SetForwardSpeed(0)
	movedata:SetSideSpeed(0)
	movedata:SetVelocity(novel)

	if SERVER then ply:SetGroundEntity(NULL) end

	local ball = ply:GetBall()
	if IsValid(ball) then movedata:SetOrigin(ball:GetPos())	end

	return true
end

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
	return true
end

function GM:ShouldCollide(ent1, ent2)
	if !self.CollisionsEnabled && ent1:GetClass() == "player_ball" && ent2:GetClass() == "player_ball" then
		return false
	end
	return true
end

function GM:Initialize()
	SetState(STATUS_WAITING)

	GAMEMODE.LateSpawn = nil
	GAMEMODE.RoundNum = 0

	SetGlobalInt( "Attempts", 0)
	
	-- TODO: update this
	RunConsoleCommand( "sv_loadingurl", "http://gmodtower.org/loading/?mapname=%m&steamid=%s" )
end

-- server logic loop basically
function GM:Think()
	-- if living and nonafk player, do nothing
	for _, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_PLAYERS and !v.AFK then
			return
		end
	end

	-- if a player is afk and everyone else is dead
	-- or afk, kill them
	for ply, afk in pairs(afks) do
		if afk && ply:Team() != TEAM_DEAD then
			ply:SetTeam(TEAM_DEAD)
			GAMEMODE:UpdateSpecs(ply, true)
			GAMEMODE:LostPlayer(ply)
		end
	end
end

function GM:RestartLevel()
	game.ConsoleCommand("changelevel " .. table.Random(Levels) .. "\n")
end

function GM:SpectateNext(ply)
	local start = ply.Spectating
	local newspec = start
	local players = player.GetAll()

	local k, v = next(players, start)
	if !k then k, v = next(players) end

	while k != start do
		if v:Team() == TEAM_PLAYERS then
			newspec = k
			break
		end

		k, v = next(players, k)
		if !k then
			if start == nil then break end
			k, v = next(players)
		end
	end

	ply.Spectating = newspec

	local ent = nil
	if players[newspec] then ent = players[newspec].Ball end

	ply:SetBall(ent)
end

function GM:UpdateSpecs(ply, dead)
	-- don't bother updating specs when we're spawning
	if GetState() == STATUS_SPAWNING then return end

	for k,v in ipairs(player.GetAll()) do
		if v:Team() != TEAM_PLAYERS && v.Spectating == ply:EntIndex() then
			if dead then
				GAMEMODE:SpectateNext(v)
			else
				v:SetBall(ply.Ball)
			end
		end
	end
end

function GM:SpawnAllPlayers()
	for k,v in ipairs(player.GetAll()) do
		v:SetDeaths(GAMEMODE.Lives)
		v:Spawn()
	end
end

function GM:LostPlayer(ply, disc)
	if IsValid(ply.Ball) then
		ply.Ball:Remove()
	end

	ply.Ball = nil
	ply:SetBall(NULL)

	GAMEMODE:UpdateStatus(disc)
end

function GM:EndServer()
	-- I guess it is good bye
	GTowerServers:EmptyServer()

	--timer.Simple( 2.5, ChangeLevel, GTowerServers:GetRandomMap() or GAMEMODE:RandomMap( "gmt_ballracer" ) )
	timer.Simple(2.5, function()

		local map = (GTowerServers:GetRandomMap() or GAMEMODE:RandomMap( "gmt_ballracer" ))
		
		-- not sure where this event name comes from
		hook.Call("LastChanceMapChange", GAMEMODE, map)
		RunConsoleCommand("changelevel", map)

	end)
	Msg( "Server is empty, resetting self\n" )
end

function GM:EnterPlayingState()
	if self.CurrentLevel == 0 then
		self:AdvanceLevelStatus()
	end

	self:SetState( 2 )
end

function GM:UpdateStatus(disc)
	if GetState() != STATUS_PLAYING then return end

	local dead = NumPlayers(TEAM_DEAD)
	local complete = NumPlayers(TEAM_COMPLETED)

	local total = player.GetCount()
	if disc then
		total = total - 1
		dead = dead - 1
	end

	if total == 0 then
		self:RestartLevel()
		return
	end

	if dead + complete >= total then
		timer.Destroy("RoundEnd")

		if complete > 0 then
			for k,v in pairs(player.GetAll()) do
				for ply,afk in pairs(afks) do
					if !afk then continue end
					if !IsValid(ply) or !IsValid(v) then return end 
					v:SendLua("GTowerChat.Chat:AddText(\"" .. ply:Name() .. " has automatically forfeited due to being AFK.\", Color(100, 100, 100, 255))")
				end
			end

			timer.Simple( 0.5, function() level = level + 1 end )
			tries = 0
			-- Fokin' network delay
			timer.Simple( 0.2, function() GAMEMODE:GiveMoney() end )

			if NextMap then
				if string.StartWith(game.GetMap(),"gmt_ballracer_memories") then
					for k,v in pairs(player.GetAll()) do v:AddAchivement( ACHIVEMENTS.BRMEMORIES, 1 ) end
				end
				for k,v in pairs(player.GetAll()) do if !v:GetNWBool("Popped") then v:AddAchivement( ACHIVEMENTS.BRUNPOPABLE, 1 ) end end
				net.Start("roundmessage")
				net.WriteInt( 3, 3 )
				net.Broadcast()
				timer.Simple(8,function()
					self:EndServer()
				end)
			else
				net.Start("roundmessage")
				net.WriteInt( 1, 3 )
				net.Broadcast()
			end
			LateSpawn = ActiveTeleport
		else
			if LateSpawn != nil && (LateSpawn:GetName() == 'bonus_start' || LateSpawn:GetName() == 'bns_start' || LateSpawn:GetName() == 'bonus') then
				net.Start("roundmessage")
				net.WriteInt( 1, 3 )
				net.Broadcast()
				LateSpawn = BonusTeleport
				ActiveTeleport = BonusTeleport
				timer.Simple( 0.2, function() GAMEMODE:GiveMoney() end )
			else
				net.Start("roundmessage")
				if tries < 1 then
					net.WriteInt( 2, 3 )
				else
					net.WriteInt( 1, 3 )
				end
				net.Broadcast()
				self:ResetGame(true)
			end
		end
		SetState(STATUS_INTERMISSION)
		timer.Simple(8, self.StartRound, self)
	end
end

function GM:StopRound()
	for k,v in ipairs(player.GetAll()) do
		if v:Team() == TEAM_PLAYERS then
			v:SetDeaths(1)
			v:Kill()
		end
	end
end

function GM:Announce(message)
	for _, v in ipairs(player.GetAll()) do
		v:SendLua("GTowerChat.Chat:AddText(\"" .. message .. "\", Color(255, 255, 255, 255))")
	end
end

function GM:PlayerDeath( victim, inflictor, attacker )
	if LateSpawn != nil && (LateSpawn:GetName() == 'bonus_start' || LateSpawn:GetName() == 'bns_start' || LateSpawn:GetName() == 'bonus') then
	else
		victim:SetNWBool( "Died", true )
		victim:SetNWBool( "Popped", true )
	end
end

local Player = FindMetaTable("Player")
function Player:SetBall(ent)
	self:SetOwner(ent)
end

function Player:GetBall()
	return self:GetOwner()
end