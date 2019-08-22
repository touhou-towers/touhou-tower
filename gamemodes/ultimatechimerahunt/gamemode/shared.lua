GM.Name 	= "GMod Tower: Ultimate Chimera Hunt"
GM.Author 	= "Aska & Fluxmage/GMT Krew"
GM.Email 	= ""
GM.Website 	= ""

GM.AllowSpecialModels = false
GM.AllowChangeSize = false
GM.NumRounds = 15
GM.RoundTime = 2 * 60

DeriveGamemode( "gmodtower" )
TowerModules.LoadModules( {
	"commands",
	"achivement",
	"friends",
	"scoreboard3",
	"payout",
} )

/* NETWORK VARS SETUP */

/*RegisterNWTableGlobal({
	{ "State", 1, NWTYPE_CHAR, REPL_EVERYONE },
	{ "Time", 0, NWTYPE_NUMBER, REPL_EVERYONE },
	{ "Round", 0, NWTYPE_CHAR, REPL_EVERYONE },
	{ "UC", Entity( 0 ), NWTYPE_ENTITY, REPL_EVERYONE },
})*/

function RegisterNWTableG()
	SetGlobalInt("State",1)
	SetGlobalInt("Time", 0)
	SetGlobalInt("Round", 0)
	SetGlobalEntity("UC",Entity(0))
end

RegisterNWTablePlayer({

	/* Ranks */
	{ "Rank", 1, NWTYPE_CHAR, REPL_EVERYONE },
	{ "NextRank", 1, NWTYPE_CHAR, REPL_PLAYERONLY },

	/* Player States */
	{ "IsChimera", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	{ "IsGhost", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	{ "IsFancy", false, NWTYPE_BOOLEAN, REPL_EVERYONE },

	/* Pigs */
	{ "IsScared", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	{ "IsTaunting", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	{ "IsStunned", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	{ "IsPancake", false, NWTYPE_BOOLEAN, REPL_EVERYONE },

	/* Chimera */
	{ "IsRoaring", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	{ "IsBiting", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	{ "FirstDoubleJump", false, NWTYPE_BOOLEAN, REPL_PLAYERONLY },
	{ "DoubleJumpNum", 0, NWTYPE_CHAR, REPL_PLAYERONLY },
	{ "SwipeMeter", 0, NWTYPE_FLOAT, REPL_PLAYERONLY },

	/* Sprint */
	{ "Sprint", 1, NWTYPE_FLOAT, REPL_PLAYERONLY },
	{ "IsSprintting", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
	//{ "IsSwimming", false, NWTYPE_BOOLEAN, REPL_EVERYONE },

	/* Animations */
	{ "PlaybackRate", 1, NWTYPE_FLOAT, REPL_EVERYONE },
	{ "PlaybackRateOV", false, NWTYPE_BOOLEAN, REPL_EVERYONE },

	/* Saturn */
	{ "HasSaturn", false, NWTYPE_BOOLEAN, REPL_EVERYONE },
})


/* WONDERFUL ARRAY OF INDEXES */

STATUS_WAITING		= 1
STATUS_PLAYING		= 2
STATUS_INTERMISSION	= 3

TEAM_PIGS		= 1
TEAM_CHIMERA	= 2
TEAM_GHOST		= 3
TEAM_SALSA		= 4

RANK_ENSIGN		= 1
RANK_CAPTAIN	= 2
RANK_MAJOR		= 3
RANK_COLONEL	= 4

MSG_FIRSTJOIN = 1
MSG_WAITJOIN = 2
MSG_UCSELECT = 3
MSG_UCNOTIFY = 4
MSG_PIGNOTIFY = 5
MSG_PIGWIN = 6
MSG_UCWIN = 7
MSG_TIEGAME = 8
MSG_30SEC = 9
MSG_MRSATURN = 10
MSG_ANGRYUC = 11
MSG_MRSATURNDEAD = 12

MUSIC_WAITING = 1
MUSIC_ROUND = 2
MUSIC_ENDROUND = 3
MUSIC_SPAWN = 4
MUSIC_GHOST = 5
MUSIC_FGHOST = 6
MUSIC_30SEC = 7
MUSIC_MRSATURN = 8


/* MUSIC */

GM.Music = {
	[MUSIC_WAITING] = { "UCH/music/waiting/waiting_music", 13 },
	[MUSIC_ROUND] = { "UCH/music/round/round_music", 9 },
	[MUSIC_ENDROUND] = {

		Chimera =  {
			win 	= Sound( "UCH/music/endround/chimera_win.mp3" ),
			lose 	= Sound( "UCH/music/endround/chimera_lose.mp3" ),
		},

		Pigmask = {
			win 	= Sound( "UCH/music/endround/pigs_win.mp3" ),
			lose 	= Sound( "UCH/music/endround/pigs_lose.mp3" ),
		},

		Tie	= Sound( "UCH/music/endround/gameend.mp3" ),
		Salsa = Sound( "UCH/music/endround/salsa.mp3" ),

	},
	[MUSIC_SPAWN] = {

		Chimera = Sound( "UCH/music/spawn/chimera_spawn.wav" ),

		Pigmask = {

			ensign 	= Sound( "UCH/music/spawn/ensign_spawn.wav" ),
			captain = Sound( "UCH/music/spawn/captain_spawn.wav" ),
			major 	= Sound( "UCH/music/spawn/major_spawn.wav" ),
			colonel = Sound( "UCH/music/spawn/colonel_spawn.wav" ),

		},

	},
	[MUSIC_GHOST] = { "UCH/music/ghost/ghost_music", 8 },
	[MUSIC_FGHOST] = { "UCH/music/ghost/fancy/fancyghost_music", 5 },
	[MUSIC_30SEC] = Sound( "UCH/music/round/round_30secsleft.mp3" ),
	[MUSIC_MRSATURN] = Sound( "UCH/saturn/saturn_win.wav" ),
}


/* TEAM SETUP */
team.SetUp( TEAM_PIGS, "Pigmasks", Color( 225, 150, 150, 255 ) )
team.SetUp( TEAM_CHIMERA, "Ultimate Chimera", Color( 230, 30, 110, 255 ) )
team.SetUp( TEAM_GHOST, "Ghosts", Color( 255, 255, 255, 255 ) )

team.SetSpawnPoint( TEAM_PIGS, { "info_player_start", "info_player_teamspawn" } )
team.SetSpawnPoint( TEAM_CHIMERA, { "chimera_spawn" } )
team.SetSpawnPoint( TEAM_GHOST, { "info_player_start", "info_player_teamspawn" } )


/* PLAYER VARIABLES */
GM.SprintRecharge = .0062
GM.SprintDrain = .015
GM.DJumpPenalty = .042


/* RANKS */

GM.Ranks = {
	[RANK_ENSIGN] = {
		Name = "Ensign",
		Color = Color( 250, 180, 180 ),
		SatColor = Color( 255, 255, 255 )
	},
	[RANK_CAPTAIN] = {
		Name = "Captain",
		Color = Color( 150, 200, 250 ),
		SatColor = Color( 153, 204, 255 )
	},
	[RANK_MAJOR] = {
		Name = "Major",
		Color = Color( 90, 200, 90 ),
		SatColor = Color( 115, 255, 115 )
	},
	[RANK_COLONEL] = {
		Name = "Colonel",
		Color = Color( 250, 250, 250 ),
		SatColor = Color( 225, 225, 225 )
	},
}


/* MAP NAMES */

GM.NiceMapNames = {
	["gmt_uch_tazmily"] = "Tazmily Village",
	["gmt_uch_shadyoaks"] = "Shady Oaks",
	["gmt_uch_laboratory"] = "Laboratory",
	["gmt_uch_clubtitiboo"] = "Club Titiboo",
	["gmt_uch_camping"] = "Camping Grounds",
	["gmt_uch_headquarters"] = "Headquarters",
}

/* STATE/GAMEMODE LOGIC FUNCTIONS */

function GM:SetGameState( state )
	SetGlobalInt("State",state)
end

function GM:GetGameState()
	return GetGlobalInt("State")
end

function GM:IsPlaying()
	return self:GetGameState() == STATUS_PLAYING
end

function GM:IsRoundOver()
	return GetGlobalInt("State") == STATUS_INTERMISSION
end

function GM:GetUC()
	return GetGlobalEntity("UC") or NULL
end

/* Timer Functions */

function GM:GetTimeLeft()
	return ( GetGlobalInt("Time") or 0 ) - CurTime()
end

function GM:AddTime( add )

	if self.Intense then return end

	local time = self:GetTimeLeft()

	time = math.Clamp( time + add, 0, 2.10 * 60 )
	SetGlobalInt("Time", CurTime() + time)

	umsg.Start( "UpdateRoundTimer" )
		umsg.Long( add )
	umsg.End()

end


/* MISC SHARED FUNCTIONS */

function team.AlivePigs()

	local num = 0

	for k, v in ipairs( team.GetPlayers( TEAM_PIGS ) ) do

		if v:IsPig() && !v.IsDead then // just in case
			//Msg( tostring( v ), "\n" )
			num = num + 1
		end

	end

	return num

end

function GM:IsLastPigmasks()
	return #team.GetPlayers( TEAM_PIGS ) <= 3
end

function GM:UpdateHull( ply )

	if !IsValid( ply ) then return end

	if ply.IsChimera then

		ply:SetHull( Vector(-25, -25, 0), Vector( 25, 25, 55 ) )
		ply:SetHullDuck( Vector(-25, -25, 0), Vector( 25, 25, 55 ) )

		ply:SetViewOffset( Vector( 0, 0, 68)  )
		ply:SetViewOffsetDucked( Vector( 0, 0, 68 ) )

	else

		ply:SetHull( Vector(-16, -16, 0), Vector( 16, 16, 55 ) )
		ply:SetHullDuck( Vector(-16, -16, 0), Vector( 16, 16, 40 ) )

		ply:SetViewOffset( Vector( 0, 0, 48 ) )
		ply:SetViewOffsetDucked( Vector( 0, 0, ( 48 * .75 ) ) )

		if ply.IsGhost then

			ply:SetHull( Vector(-16, -16, 0 ), Vector( 16, 16, 55 ) )
			ply:SetHullDuck( Vector(-16, -16, 0 ), Vector( 16, 16, 55 ) )

			ply:SetViewOffset( Vector( 0, 0, 55 ) )
			ply:SetViewOffsetDucked( Vector( 0, 0, 55 ) )

		end

	end

end

function GM:ShouldCollide( ent1, ent2 )

	if (ent1:IsValid() && ent2:IsValid()) then
		if ((ent1:IsPlayer() && ent1.IsGhost) || (ent2:IsPlayer() && ent2.IsGhost)) then
			return false;
		end
		if (ent1:IsPlayer() && ent2:IsPlayer() && ent1:Team() == ent2:Team()) then
			return false;
		end
	end
	
	return true;

end

function GetWorldEntity()
	return game.GetWorld()
end

if CLIENT then return end

function GM:PlayerCanHearPlayersVoice( ply1, ply2 )

	return ( ply1:Team() == ply2:Team() ) || ( ply1.IsChimera && !ply2.IsGhost ) || ( !ply1.IsGhost && ply2.IsChimera ) || !self:IsPlaying()

end
