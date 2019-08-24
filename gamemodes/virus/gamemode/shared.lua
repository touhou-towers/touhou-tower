GM.Name = "GMod Tower: Virus"
GM.Author = "GMod Tower Team"
GM.Website = "http://www.gmodtower.org/"

GM.AllowSpecialModels = true
GM.AllowChangeSize = false

DeriveGamemode("gmodtower")

RegisterNWTableGlobal(
	{
		{"State", 1, NWTYPE_CHAR, REPL_EVERYONE},
		{"Time", 0, NWTYPE_NUMBER, REPL_EVERYONE},
		{"Round", 0, NWTYPE_CHAR, REPL_EVERYONE},
		{"MaxRounds", 0, NWTYPE_CHAR, REPL_EVERYONE}
	}
)

RegisterNWTablePlayer(
	{
		{"IsVirus", false, NWTYPE_BOOLEAN, REPL_EVERYONE},
		{"MaxHealth", 100, NWTYPE_NUMBER, REPL_PLAYERONLY},
		{"Rank", 0, NWTYPE_CHAR, REPL_PLAYERONLY}
	}
)

STATUS_WAITING = 1
STATUS_INFECTING = 2
STATUS_PLAYING = 3
STATUS_INTERMISSION = 4

TEAM_PLAYERS = 1
TEAM_INFECTED = 2
TEAM_SPEC = 3

MUSIC_WAITINGFORINFECTION = 1
MUSIC_INTERMISSION = 4

team.SetUp(TEAM_PLAYERS, "Survivors", Color(255, 255, 100, 255))
team.SetUp(TEAM_INFECTED, "Infected", Color(175, 225, 175, 255))
team.SetUp(TEAM_SPEC, "Waiting", Color(255, 255, 100, 255))

function GM:GetState()
	return game.GetWorld().State
end

function GM:IsPlaying()
	return game.GetWorld().State == STATUS_PLAYING
end

function GM:GetTimeLeft()
	return game.GetWorld().Time - CurTime()
end

TowerModules.LoadModules(
	{
		"achivement",
		"friends",
		"commands",
		"afk2",
		"scoreboard3",
		"payout",
		"weaponfix"
	}
)
