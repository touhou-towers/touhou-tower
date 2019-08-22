
-----------------------------------------------------
// === GMT SETUP ===
--DeriveGamemode("base")

GM.Name     = "GMod Tower: Zombie Massacre"
GM.Author   = "GMT Crew~"
GM.Website  = "http://www.gmtower.org/"

DeriveGamemode( "gmodtower" )

GM.AllowChangeSize = false

TowerModules.LoadModules( {
	"achivement",
	"friends",
	"commands",
	"afk2",
	"scoreboard3",
	"payout",
	"music",
	--"weaponfix",
	//"jetpack",
} )

--[[SetupGMTGamemode( "Zombie Massacre", "zombiemassacre",{
	Loadables = { "weaponfix" }, // Additional loadables
	AllowSmall = true, // Small player models
	DrawHatsAlways = true, // Always draw hats
	AFKDelay = 60, // Seconds before they will be marked as AFK
	ChatY = 450,
	ChatBGColor = Color( 50, 50, 50, 180 ),
	ChatScrollColor = Color( 80, 80, 80, 215 ),
	DisablePlayerClick = true,
	DisableDucking = true,
	DisableJumping = true,
	DisableRunning = true,
})]]
hook.Add("PostPlayerDraw", "CSSWeaponFix", function(v)
	local wep = v:GetActiveWeapon()
	if !IsValid(wep) then return end

	local hbone = wep:LookupBone("ValveBiped.Bip01_R_Hand")
	if !hbone then
		local hand = v:LookupBone("ValveBiped.Bip01_R_Hand")
		if hand then

			local pos, ang = v:GetBonePosition(hand)

			ang:RotateAroundAxis(ang:Forward(), 180)

			if wep:GetModel() == "models/weapons/w_pvp_neslg.mdl" then
				ang:RotateAroundAxis(ang:Up(), -90)
			end

			wep:SetRenderOrigin(pos)
			wep:SetRenderAngles(ang)

		end
	end
end)

-- Disable ducking
if SERVER then
	hook.Add( "PlayerSpawn", "DisableDucking", function( ply )
		ply:SetDuckSpeed( ply:GetWalkSpeed() )
		ply:SetHullDuck( Vector(-16, -16, 0), Vector(16, 16, 72) ) -- Default hull
	end )
else -- CLIENT
	hook.Add( "CreateMove", "DisableDucking", function( cmd )
		if ( cmd:KeyDown( IN_DUCK ) ) then
			cmd:SetButtons( cmd:GetButtons() - IN_DUCK )
		end
	end )
end

-- Disable jumping
if SERVER then
	hook.Add( "PlayerSpawn", "DisableJumping", function( ply )
		ply:SetJumpPower( 0 )
	end )
else -- CLIENT
	hook.Add( "CreateMove", "DisableJumping", function( cmd )
		if not LocalPlayer():Alive() then return end -- Allow jumping to handle respawning
		if ( cmd:KeyDown( IN_JUMP ) ) then
			cmd:SetButtons( cmd:GetButtons() - IN_JUMP )
		end
	end )
end

-- Disable running
if SERVER then
	hook.Add( "PlayerSpawn", "DisableRunning", function( ply )
		ply:SetRunSpeed( ply:GetWalkSpeed() )
	end )
else -- CLIENT
	hook.Add( "CreateMove", "DisableRunning", function( cmd )
		if ( cmd:KeyDown( IN_SPEED ) ) then
			cmd:SetButtons( cmd:GetButtons() - IN_SPEED )
		end
	end )
end

if CLIENT then
	local GtowerHudToHide = {
		--CHudChat = true,
		CHudHealth = true,
		CHudBattery = true,
		CHudAmmo = true,
		CHudSecondaryAmmo = true,
		CHudWeapon = true,
		CWeaponSelection = true,
		CHudCrosshair = true,
		CHudDamageIndicator = true,
	}

	hook.Add( "HUDShouldDraw", "HideHUD", function( name )
		if ( GtowerHudToHide[ name ] ) then return false end
	end )
end

NOTE_DAMAGE = 1
NOTE_POINTS = 2
NOTE_HEAL = 3
NOTE_KILLED = 4
NOTE_POWERUP = 5
STATE_NOPLAY = 0 // no players, game doesnt start
STATE_WAITING = 1 // waiting for players
STATE_UPGRADING = 2 // upgrade screen/class select
STATE_WARMUP = 3 // waiting for zombie infection
STATE_PLAYING = 4 // playing game
STATE_INTERMISSION = 5 // in between rounds (scoreboard show)
STATE_ENDING = 6 // game is ending
/* MUSIC */
MUSIC_WAITING = 1
MUSIC_UPGRADING = 2
MUSIC_WARMUP = 3
MUSIC_ROUND = 4
MUSIC_WINLOSE = 5
MUSIC_BOSS = 6
MUSIC_DEATH = 7
MUSIC_DEATHOFF = 8

GM.Music = {
	[MUSIC_WAITING] = { "GModTower/zom/music/music_waiting", 3 },
	[MUSIC_UPGRADING] = { "GModTower/zom/music/music_upgrading", 1 },
	[MUSIC_WARMUP] = { "GModTower/zom/music/music_preround", 4 },
	[MUSIC_ROUND] = { "GModTower/zom/music/music_round", 6 },
	[MUSIC_WINLOSE] = {
		Win = Sound( "GModTower/zom/music/music_win.mp3" ),
		Lose = Sound( "GModTower/zom/music/music_lose.mp3" ),
	},
	[MUSIC_BOSS] = { "GModTower/zom/music/music_boss", 2 },
	[MUSIC_DEATH] = Sound( "GModTower/zom/music/music_death.mp3" ),
}
function GM:GetTimeLeft()
	return (GetGlobalInt( "ZMDayTime" ) - CurTime())
end

function GM:IsPlaying()
	return self:GetState() == STATE_PLAYING || self:GetState() == STATE_WARMUP || self:GetState() == STATE_UPGRADING
end
function GM:IsRoundOver()
	return self:GetState() == STATE_INTERMISSION || self:GetState() == STATE_UPGRADING
end
function GM:CurrentRound()
	return GetGlobalInt( "Round", 0 )
end
function GM:SetState( state )
	SetGlobalInt( "State", state )
end

function GM:GetState()
	return GetGlobalInt( "State", 0 )
end

function GM:IncreaseRound()
	SetGlobalInt( "Round", GetGlobalInt( "Round" ) + 1 )
end
function GM:HasBoss()
	return IsValid( GetGlobalEntity( "Boss" ) )
end
function GM:SetBoss( boss )
	SetGlobalEntity( "Boss", boss )
	SetGlobalInt( "BossHealth", boss:Health() )
	SetGlobalString( "BossName", boss.Name )
	SetGlobalInt( "BossMaxHealth", 20000 )
end
function GM:GetBoss()
	return GetGlobalEntity( "Boss" )
end
GM.SpawnProtectDelay = 3
GM.NoSpawnRadius = 80
GM.SpawnRadius = 2048
function GM:IsValidSpawn( spawn )
	// Check if something is blocking it
	for _, ent in pairs( ents.GetAll() ) do
		if ( ent:IsPlayer() || ent:IsNPC() ) && self:IsInRadius( ent, spawn, self.NoSpawnRadius ) then
			return false
		end
	end
	// Find players near by
	for _, ply in pairs( player.GetAll() ) do
		if ply:Alive() && self:IsInRadius( ply, spawn, self.SpawnRadius ) then
			return true
		end
	end
	return false
end
function GM:IsInRadius( ent1, ent2, radius )
	return ent2:GetPos():Distance( ent1:GetPos() ) < radius
end
function GM:ShouldCollide( ent1, ent2 )
	--[[if ent1:IsPlayer() and ent2:IsPlayer() then
		return false
	end]]

	if ent1:IsNPC() && ent2:IsNPC() then
		return false
	end

	if ent1:IsPlayer() && ent2:IsPlayer() then
		return false
	end

	return true
end


-----------------------------------------------------
payout.Register( "ThanksForPlaying", {
	Name = "Thanks For Playing",
	Desc = "For participating in the game!",
	GMC = 100,
} )

payout.Register( "BossDefeat", {
	Name = "Defeated The Boss",
	Desc = "You got that giant monster!",
	GMC = 150,
	Diff = 3,
} )

/*payout.Register( "BossDamageTier1", {
	Name = "Boss Destroyer",
	Desc = "Dealt the most damage on the boss!",
	GMC = 200,
	Diff = 4,
} )

payout.Register( "BossDamageTier2", {
	Name = "Boss Master",
	Desc = "Dealt the 2nd most damage on the boss.",
	GMC = 125,
	Diff = 4,
} )

payout.Register( "BossDamageTier3", {
	Name = "Boss Handler",
	Desc = "Dealt the 3rd most damage on the boss.",
	GMC = 50,
	Diff = 4,
} )*/

payout.Register( "Points", {
	Name = "Total Points",
	Desc = "Bonus for earning points.",
	GMC = 0,
	Diff = 2,
} )

function GM:GiveMoney()

	if CLIENT then return end

	local PlayerTable = player.GetAll() --player.sqlGetAll()

	// Sort for boss payout
	/*local SortedPlayerTable
	if self.WonBossRound then

		SortedPlayerTable = table.Copy( PlayerTable )

		table.sort( SortedPlayerTable, function( a, b )
			return a._BossDamage > b._BossDamage
		end )

	end*/

	// Payout
	for _, ply in pairs( PlayerTable ) do

		if ply.AFK then continue end

		payout.Clear( ply )

		if !self.LostRound then
			payout.Give( ply, "Points", math.Round( ply:GetNWInt( "Points" ) * .25 ) )
		end

		if self.WonBossRound then

			payout.Give( ply, "BossDefeat" )

			// Players don't like this as it's too luck based.
			/*if SortedPlayerTable[1] == ply then payout.Give( ply, "BossDamageTier1" ) end
			if SortedPlayerTable[2] == ply then payout.Give( ply, "BossDamageTier2" ) end
			if SortedPlayerTable[3] == ply then payout.Give( ply, "BossDamageTier3" ) end*/

		end

		payout.Payout( ply )

	end

end
