GM.Name = "GMod Tower: Minigolf"

DeriveGamemode("gmodtower")

GM.Holes = GM.Holes or {}

STATE_NOPLAY = 0
STATE_WAITING = 1 -- waiting for players
STATE_SETTINGS = 2 -- selecting
STATE_PREVIEW = 3 -- selecting
STATE_PLAYING = 4 -- playing game
STATE_INTERMISSION = 5 -- in between holes (scoreboard show)
STATE_ENDING = 6 -- game is ending

-- Types of cameras
STATIC = 1 -- does not move. just point/angle
FUNCTION = 2 -- lua controlled. just like calcview
SPLINE = 3 -- looping spline track
SPLINE_TIMED = 4 -- timed spline track (start-finish)

-- GAME SETTINGS
WaitTime = 80
MaxPower = 300
StrokeLimit = 15
LatePenality = 3 -- Amount of strokes + par for late joining

SafeMaterials = {
	-- Materials that are safe for the ball to be on
	"tools/toolsnodraw",
	"golf/grass_in",
	"golf/sand",
	"golf/puttputt_sand",
	"golf/puttputt_grass",
	"dev/dev_measuregeneric01b",
	"gmod_tower/mrsaturnvalley/saturn_grass",
	"gmod_tower/minigolf/green",
	"wood/milbeams002",
	"maps/gmt_minigolf_02/nature/blendrockslime01a_wvt_patch",
	"gmod_tower/minigolf/sand",
	"gmod_tower/minigolf/zen_green",
	"stone/stonewall033a",
	"garden/gravel_waves_single",
	"garden/gravel_waves",
	"maps/gmt_minigolf_zen/concrete/blendbunk_conc01_wvt_patch",
	"gmod_tower/minigolf/snowfall/snowfall_mainsnow",
	"gmod_tower/minigolf/snowfall/snowfall_mainice",
	"gmod_tower/minigolf/snowfall/snowfall_iceslide",
	"gmt_minigolf_moon/grass_in_blue",
	"metal/metalhull003a",
	"metal/metalfence007a",
	"gmod_tower/minigolf/forest/green_checkers",
	"cs_havana/woodm",
	"gmod_tower/minigolf/puttputt_wood_in",
	"gmt_minigolf_desert/desert_brick_edge",
	"gmt_minigolf_desert/desert_floor_tile",
	"gmt_minigolf_desert/desert_puttputt_start",
	"gmt_minigolf_desert/desert_stone"
}

SandMaterials = {
	"gmod_tower/minigolf/sand",
	"golf/sand",
	"garden/gravel_waves_single",
	"garden/gravel_waves"
}

IceMaterials = {
	"gmod_tower/minigolf/snowfall/snowfall_mainice",
	"gmod_tower/minigolf/snowfall/snowfall_iceslide"
}

Scores = {
	[-4] = "CONDOR",
	[-3] = "ALBATROSS",
	[-2] = "EAGLE",
	[-1] = "BIRDIE",
	[0] = "PAR",
	[1] = "BOGEY",
	[2] = "DOUBLE BOGEY"
}

function GM:GetHoles()
	for _, hole in pairs(ents.FindByClass("golfstart")) do
		table.insert(self.Holes, hole)
	end
end

function GetWorldEntity()
	return game.GetWorld()
end

-- NETVARS
function RegisterNWGlobal()
	SetGlobalInt("Hole", 0)
	SetGlobalInt("Par", 0)
	SetGlobalString("HoleName", "")
	SetGlobalBool("HasPractice", false)
	SetGlobalInt("State", 0)
	SetGlobalInt("Time", 0)
	SetGlobalInt("Round", 0)
end

-- MUSIC
MUSIC_NONE = 0
MUSIC_WAITING = 1
MUSIC_SETTINGS = 2
MUSIC_INTERMISSION = 3
MUSIC_ENDGAME = 4
MUSIC_ENDINGGAME = 5

GM.Music = {
	[MUSIC_WAITING] = {"GModTower/minigolf/music/waiting", 7},
	[MUSIC_SETTINGS] = {"GModTower/minigolf/music/customize", 2},
	[MUSIC_INTERMISSION] = {"GModTower/minigolf/music/intermission", 5},
	[MUSIC_ENDINGGAME] = {"GModTower/minigolf/music/ending", 2},
	[MUSIC_ENDGAME] = {
		"GModTower/minigolf/music/end1.mp3",
		"GModTower/minigolf/music/end2.mp3",
		"GModTower/minigolf/music/end3.mp3",
		"GModTower/minigolf/music/end4.mp3"
	}
}

-- SOUNDS
SOUND_CUP = "GModTower/minigolf/effects/cup.wav"
SOUND_HIT = "GModTower/minigolf/effects/hit.wav"
SOUND_EXPLOSION = "GModTower/minigolf/effects/explosion.wav"
SOUND_ROCKET = "GModTower/minigolf/effects/launch.wav"
SOUND_SWING = "GModTower/minigolf/effects/swing" -- power + .wav
SOUND_CLAP = "GModTower/minigolf/effects/golfclap" -- 1-3 + .wav

SOUNDS_ANNOUNCER = {
	"GModTower/minigolf/effects/voice/niceapproach.wav",
	"GModTower/minigolf/effects/voice/nicein.wav",
	"GModTower/minigolf/effects/voice/niceon.wav",
	"GModTower/minigolf/effects/voice/niceshot.wav",
	"GModTower/minigolf/effects/voice/nicetouch.wav"
}

SOUNDINDEX_CLAP = 1
SOUNDINDEX_ANNOUNCER = 2

--STATE
function GM:IsPracticing()
	return GetGlobalInt("State") == STATE_WAITING and GetGlobalBool("HasPractice") == true
end

-- TEAM
TEAM_PLAYING = 1
TEAM_FINISHED = 2

TowerModules.LoadModules(
	{
		"achivement",
		"friends",
		"commands",
		"afk2",
		"scoreboard3",
		"payout"
		--"weaponfix",
		--"jetpack",
	}
)

function GM:SetState(state)
	if not state then
		return
	end
	MsgN("[GMode] Setting state: " .. state)
	SetGlobalInt("State", state)
	--self.State = state
end

function GM:GetState()
	return GetGlobalInt("State", 0)
end

function GM:IsPlaying()
	return GetGlobalInt("State") == STATE_PLAYING
end

function PracticeSpawn()
	local spawn

	for k, v in pairs(ents.FindByClass("golfwaiting")) do
		spawn = v
	end

	return spawn
end

function FirstSpawn()
	local spawn

	for k, v in pairs(ents.FindByClass("info_player_start")) do
		spawn = v
	end

	return spawn
end

-- TIME
function GM:GetTimeLeft()
	local timeLeft = (self:GetTime() or 0) - CurTime()
	if timeLeft < 0 then
		timeLeft = 0
	end

	return timeLeft
end

function GM:NoTimeLeft()
	return self:GetTimeLeft() <= 0
end

function GM:SetTime(time)
	if not time then
		return
	end

	if time ~= 60 then
		MsgN("[GMode] Setting time: " .. time)
	end

	SetGlobalInt("Time", CurTime() + time)
end

function GM:GetTime()
	return GetGlobalInt("Time")
end

-- ROUNDS
function GM:GetRoundCount()
	return GetGlobalInt("Round", 0)
end

-- CONCOMMANDS
concommand.Add(
	"mg_setstate",
	function(ply, cmd, args)
		if not ply:IsAdmin() then
			return
		end
		GAMEMODE:SetState(tonumber(args[1]))
	end
)

concommand.Add(
	"mg_settime",
	function(ply, cmd, args)
		if not ply:IsAdmin() then
			return
		end
		GAMEMODE:SetTime(tonumber(args[1]))
	end
)

function GM:GetPar()
	return GetGlobalInt("Par")
end

function GM:SetPar(par)
	return SetGlobalInt("Par", par)
end

function GM:GetHoleName()
	return GetGlobalString("HoleName")
end

function GM:SetHoleName(name)
	SetGlobalString("HoleName", name)
end

function GM:UpdateNetHole(hole)
	SetGlobalInt("Hole", hole)
end

function GM:GetHole()
	return GetGlobalInt("Hole", 0)
end

hook.Add(
	"ShouldCollide",
	"ShouldCollideMinigolf",
	function(ent1, ent2)
		if ent1:IsPlayer() and ent2:IsPlayer() then
			return false
		end

		if ent1:GetClass() == "golfball" and ent2:GetClass() == "golfball" then
			return false
		end

		return true
	end
)

hook.Add(
	"OverrideHatEntity",
	"OverrideHatMinigolf",
	function(ply)
		local ball = ply:GetGolfBall()

		if IsValid(ball) then
			return ball
		end

		return ply
	end
)
