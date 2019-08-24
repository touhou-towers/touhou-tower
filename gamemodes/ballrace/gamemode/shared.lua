include("sh_mapnames.lua")

GM.Name = "GMod Tower: Ballrace"
GM.Author = "GMT Crew~"
GM.Website = "http://www.gmtower.org/"

DeriveGamemode("gmodtower")

-- nice spelling on achievement
TowerModules.LoadModules(
	{
		"achivement",
		"commands",
		"afk2",
		"friends",
		"scoreboard3",
		"weaponfix",
		"payout",
		"music"
	}
)

GM.Lives = 3
GM.Tries = 2
GM.DefaultLevelTime = 60
GM.IntermissionTime = 35

LivesTriesOverride = {
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

-- i dont know why all of these look like global variables honestly
-- but ill make a closure to be safe
-- ok it complained about the closure
local map = game.GetMap()
if LivesTriesOverride[map] then
	GM.DefaultLevelTime = LivesTriesOverride[map].Time or GM.DefaultLevelTime
	GM.Lives = LivesTriesOverride[map].Lives or GM.Lives
end

function SetTime(lvltime)
	SetGlobalInt("GTIME", lvltime)
end

function GetTime()
	return GetGlobalInt("GTIME")
end

function GetRaceTime()
	return GAMEMODE.DefaultLevelTime - timer.TimeLeft("RoundEnd")
end

SetTime(GM.DefaultLevelTime)

LevelMusic = {
	gmt_ballracer_grassworld01 = {
		"balls/ballsmusicwgrass",
		126.955102
	},
	gmt_ballracer_iceworld03 = {
		"balls/ballsmusicwice",
		225
	},
	gmt_ballracer_khromidro02 = {
		"balls/ballsmusicwkhromidro",
		429.33333
	},
	gmt_ballracer_memories04 = {
		"balls/ballsmusicwmemories",
		260.127347
	},
	gmt_ballracer_metalworld = {
		"balls/ballsmusicwmetal",
		169
	},
	gmt_ballracer_midorib5 = {
		"balls/midori_vox",
		259
	},
	gmt_ballracer_neonlights = {
		"pikauch/music/manzaibirds",
		164
	},
	gmt_ballracer_nightball = {
		"balls/ballsmusicwnight",
		162
	},
	gmt_ballracer_paradise03 = {
		"balls/ballsmusicwparadise",
		305.057959
	},
	gmt_ballracer_prism03 = {
		"balls/ballsmusicwprism",
		132
	},
	gmt_ballracer_sandworld02 = {
		"balls/ballsmusicwsand",
		71
	},
	gmt_ballracer_skyworld01 = {
		"balls/ballsmusicwsky",
		83.644082
	},
	gmt_ballracer_spaceworld = {
		"balls/ballsmusicwspace",
		119
	},
	gmt_ballracer_summit = {
		"balls/ballswmusicsummit",
		200
	},
	gmt_ballracer_waterworld02 = {
		"balls/ballsmusicwwater",
		195
	},
	gmt_ballracer_facile = {
		"balls/ballsmusicwfacile",
		143
	},
	gmt_ballracer_flyinhigh01 = {
		"balls/ballsmusicwflyinhigh",
		195
	},
	gmt_ballracer_tranquil = {
		"balls/ballsmusicwtranquil",
		145
	},
	gmt_ballracer_rainbowworld = {
		"rainbow_world/ravenholm",
		77
	}
}

function GetMusicSelection()
	return LevelMusic[map][1]
end

function GetMusicDuration()
	return LevelMusic[map][2]
end

MUSIC_LEVEL = 1
MUSIC_BONUS = 2

music.Register(MUSIC_LEVEL, GetMusicSelection(), {Loops = true, Length = GetMusicDuration()})
music.Register(MUSIC_BONUS, "balls/bonusstage")

STATUS_WAITING = 1
STATUS_PLAYING = 2
STATUS_INTERMISSION = 3
STATUS_SPAWNING = 4

TEAM_PLAYERS = 1
TEAM_DEAD = 2
TEAM_COMPLETED = 3

function SetState(state)
	SetGlobalInt("GamemodeState", state)
end

function GetState()
	return GetGlobalInt("GamemodeState")
end

local novel = Vector(0, 0, 0)

function GM:Move(ply, movedata)
	movedata:SetForwardSpeed(0)
	movedata:SetSideSpeed(0)
	movedata:SetVelocity(novel)
	if SERVER then
		ply:SetGroundEntity(NULL)
	end

	local ball = ply:GetBall()
	if IsValid(ball) then
		movedata:SetOrigin(ball:GetPos())
	end

	return true
end

hook.Add(
	"DisableAdminCommand",
	"BallraceNoAdmin",
	function(cmd)
		if cmd == "addent" or cmd == "rement" or cmd == "physgun" then
			return true
		end
	end
)

function GM:PlayerFootstep(ply, pos, foot, sound, volume, rf)
	return true
end

local Player = FindMetaTable("Player")

function Player:SetBall(ent)
	self:SetOwner(ent)
end

function Player:GetBall()
	return self:GetOwner()
end

function GM:ShouldCollide(ent1, ent2)
	if not self.CollisionsEnabled and ent1:GetClass() == "player_ball" and ent2:GetClass() == "player_ball" then
		return false
	end
	return true
end
