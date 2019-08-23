--[[
    this file declares all the global variables used in
    other files
]]
Levels = {
	"gmt_ballracer_grassworld01",
	"gmt_ballracer_iceworld03",
	"gmt_ballracer_khromidro02",
	"gmt_ballracer_memories04",
	"gmt_ballracer_metalworld",
	"gmt_ballracer_midorib5",
	"gmt_ballracer_neonlights",
	"gmt_ballracer_nightball",
	"gmt_ballracer_paradise03",
	"gmt_ballracer_prism03",
	"gmt_ballracer_sandworld02",
	"gmt_ballracer_skyworld01",
	"gmt_ballracer_spaceworld",
	"gmt_ballracer_summit",
	"gmt_ballracer_waterworld02",
	"gmt_ballracer_facile",
	"gmt_ballracer_flyinhigh01",
	"gmt_ballracer_tranquil",
	"gmt_ballracer_rainbowworld"
}

LevelMusic = {
	"balls/ballsmusicwgrass" = 126.955102,
	"balls/ballsmusicwice" = 225,
	"balls/ballsmusicwkhromidro" = 322.377143,
	"balls/ballsmusicwmemories" = 260.127347,
	"balls/ballsmusicwmetal" = 169,
	"balls/midori_vox" = 259,
	"pikauch/music/manzaibirds" = 164,
	"balls/ballsmusicwnight" = 162,
	"balls/ballsmusicwparadise" = 305.057959,
	"balls/ballsmusicwprism" = 132,
	"balls/ballsmusicwsand" = 71,
	"balls/ballsmusicwsky" = 83.644082,
	"balls/ballsmusicwspace" = 119,
	"balls/ballswmusicsummit" = 200,
	"balls/ballsmusicwwater" = 195,
	"balls/ballsmusicwfacile" = 143,
	"balls/ballsmusicwflyinhigh" = 195,
	"balls/ballsmusicwtranquil" = 145,
	"rainbow_world/ravenholm" = 77
}

NiceMapNames={
	["gmt_ballracer_grassworld01"] = "Grass World",
	["gmt_ballracer_iceworld03"] = "Ice World",
	["gmt_ballracer_khromidro02"] = "Khromidro",
	["gmt_ballracer_memories04"] = "Memories",
	["gmt_ballracer_metalworld"] = "Metal World",
	["gmt_ballracer_midori"] = "Midori",
	["gmt_ballracer_neonlights"] = "Neon Lights",
	["gmt_ballracer_nightball"] = "Night World",
	["gmt_ballracer_paradise03"] = "Paradise",
	["gmt_ballracer_prism03"] = "Prism",
	["gmt_ballracer_rainbowworld"] = "Rainbow World",
	["gmt_ballracer_sandworld02"] = "Sand World",
	["gmt_ballracer_skyworld01"] = "Sky World",
	["gmt_ballracer_spaceworld"] = "Space World",
	["gmt_ballracer_summit"] = "Summit",
	["gmt_ballracer_waterworld"] = "Water World",
	["gmt_ballracer_waterworld02"] = "Water World"
}

STATUS_WAITING = 1
STATUS_PLAYING = 2
STATUS_INTERMISSION = 3
STATUS_SPAWNING = 4

TEAM_PLAYERS = 1
TEAM_DEAD = 2
TEAM_COMPLETED = 3

MUSIC_LEVEL = 1
MUSIC_BONUS = 2

LEVEL_MUSIC = 1
BONUS_STAGE = 2
STAGE_FAILED = 3

LEVEL_COUNT = 0
for k, v in pairs(ents.FindByClass("info_target")) do
	if string.StartWith(v:GetName(), "lv") then
		LEVEL_COUNT = LEVEL_COUNT + 1
	end
end

ActiveTeleport = nil
NextMap = nil
LateSpawn = nil
afks = {}
tries = 0

function GetNiceMapName(map)
	local map = map or game.GetMap();
	return NiceMapNames[map] or map
end

function SetTime(lvltime)
	SetGlobalInt("GTIME", lvltime);
end

function GetTime()
	return GetGlobalInt("GTIME");
end

function GetRaceTime()
	return GAMEMODE.DefaultLevelTime-timer.TimeLeft("RoundEnd")
end

-- better to cache the result here I guess?
local map = game.GetMap()
function GetMusicSelection()
	return LevelMusic[map]
end

function GetMusicDuration()
	return LevelMusic[map]
end

function SetState(state)
	SetGlobalInt("GamemodeState", state);
end

function GetState()
	return GetGlobalInt("GamemodeState");
end

function NumPlayers(team)
	local count = 0
	for k, v in ipairs(player.GetAll()) do
		if v:Team() == team then
			count = count + 1
		end
	end
	return count
end