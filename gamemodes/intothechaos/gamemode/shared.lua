
// === GAMEMODE SETUP ===
GM.Name 	= "GMod Tower: Into the Chaos"

DeriveGamemode( "gmodtower" )

TowerModules.LoadModules( {
	"achivement",
	"friends",
	"commands",
	"music",
	"payout",
	"scoreboard3",
} )

// === VARIABLES ===

GM.WalkSpeed = 100

GM.WeaponList = {
  "tracker",
  "item_lighter",
	"weapon_ectogun",
}

GM.GhostList = {
	"ghost_spider",
  "ghost_mutant",
  "ghost_zombie",
}

MUSIC_CHAOS = 1

music.DefaultFolder = "room209"

music.Register( MUSIC_CHAOS, "music_intothechaos", { Length = (120+37) } )

function GM:ShouldCollide( ent1, ent2 )
	if ent1:IsPlayer() && ent2:IsPlayer() then return false end
	if ent1.IsGhost && ent2.IsGhost then return false end

	return true

end
