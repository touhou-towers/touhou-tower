GM.Name     = "GMod Tower: PVP Battle"
GM.Author   = "GMod Tower Team"
GM.Website  = "http://www.gmodtower.org/"

DeriveGamemode("gmodtower")

TowerModules.LoadModules( {
	"achivement",
	"friends",
	"commands",
	"afk2",
	"scoreboard3",
	"payout",
	"weaponfix",
	"music",
	//"gibsystem",
	"jetpack"
} )

GM.MaxRoundsPerGame = 6
GM.AllowChangeSize = false

RegisterNWTableGlobal({ {"PVPRoundTime", 0, NWTYPE_FLOAT, REPL_EVERYONE},
			{"PVPRoundOver", false, NWTYPE_BOOLEAN, REPL_EVERYONE},
			{"PVPRoundCount", 0, NWTYPE_CHAR, REPL_EVERYONE } })

function PowerChange(ply, name, old, new)
	hook.Call("PowerupChange", GAMEMODE, ply, new)
end

RegisterNWTablePlayer({ {"PowerUp", 0, NWTYPE_NUMBER, REPL_EVERYONE, PowerChange} })

function GM:GetTimeLeft()
	return ( game.GetWorld():GetNWFloat("PVPRoundTime", 0) ) - CurTime()
end

function GM:IsRoundOver()
	return game.GetWorld():GetNWBool("PVPRoundOver")
end

-- ROUNDS
function GM:GetRoundCount()
	return game.GetWorld():GetNWFloat("PVPRoundCount", 0)
end

function GM:Dash(pl, move)
	local aim = move:GetMoveAngles()
	aim.p = 0

	local shoot = pl:GetShootPos()
	local aimvec = pl:GetAimVector()

	if pl.DashWeapon && CurTime() < pl.DashWeapon + 0.25 then
		// try to stop when we hit something
		local trace = util.TraceHull({start=shoot, endpos=shoot+aimvec*50, mins=Vector(-8, -8, -8), maxs=Vector(8, 8, 8), filter=pl})

		if !trace.Hit then
			pl.Dash = true

			return true
		end
	end

	pl.Dash = false
end

function GM:DoubleJump(pl, move)
	local onground = pl:IsOnGround()

	if !onground && pl:KeyPressed(IN_JUMP) && !pl.DoubleJumped then

		if pl.PowerUp == 0 || pl.IsPulp then

			pl.DoubleJump = true
			pl.DoubleJumped = true

			return true

		end
	end

	if onground then
		pl.DoubleJumped = false
	end

	pl.DoubleJump = false
end

function GM:HandleMove(pl, move)
	if !pl:Alive() then return end

	local onground = pl:OnGround()
	local aim = move:GetMoveAngles()
	local vel = move:GetVelocity()

	if IsFirstTimePredicted() then
		self:Dash(pl, move)
		self:DoubleJump(pl, move)
	end

	if pl.Dash then
		aim.p = 0

		if onground then
			move:SetVelocity(aim:Forward() * 1500)
		elseif vel:Length() > move:GetMaxSpeed() then
			local oldz = vel.z

			vel.z = 0
			local newvel = vel * (move:GetMaxSpeed()/vel:Length())

			newvel.z = oldz
			move:SetVelocity( newvel )
		end
	end

	if pl.DoubleJump then
		local forward, right = aim:Forward(), aim:Right()
		local fmove = move:GetForwardSpeed()
		local smove = move:GetSideSpeed()

		forward.z, right.z = 0,0
		forward:Normalize()
		right:Normalize()

		local wishvel = forward * fmove + right * smove
		wishvel:Normalize()

		local doublejump = ( wishvel * 150 ) + Vector( 0, 0, 225 )
		local newvel = vel + doublejump

		move:SetVelocity( newvel )

		pl:ViewPunch( Angle( -2, 0, 0 ) )
	end
end

// we keep a history because it's predicted and we can jump forward and back in time
local vars = {"DoubleJump", "DoubleJumped", "Dash"}

function GM:SetupMoveCurrent(pl, move)
	local tbl = pl.History[CurTime()] or pl.History[table.maxn(pl.History)] or {DoubleJump=false, DoubleJumped=false, Dash=false}

	for k,v in ipairs(vars) do
		pl[v] = tbl[v]
	end
end

DamageNotes = {}

function GM:DamageNotes()

	for _, note in ipairs( DamageNotes ) do

		if ( note.Time + note.TotalTime ) < CurTime() then
			table.remove( DamageNotes, _ )
			continue
		end

		local timer = CurTime() - note.Time
		if timer > note.TotalTime then timer = note.TotalTime end

		local scrpos = note.Pos:ToScreen()

		if ( note.Time + note.TotalTime ) > CurTime() then
			timer = ( note.Time + note.TotalTime ) - CurTime()
		end

		local y = scrpos.y + 40 * timer
		local c = Color( 250, 50, 50, 255 * timer )

		//surface.SetTexture( surface.GetTextureID( "sprites/sent_ball" ) )
		//surface.DrawTexturedRect( scrpos.x, y, 15, 15 )

		draw.SimpleTextOutlined( note.Message, note.Font, scrpos.x, y, c, 1, 1, 1, Color( 0, 0, 0, c.a ) )

	end

end

net.Receive( "DamageNotes", function( )

	local note 	= {}
	note.Amount = net.ReadFloat()
	note.Pos 	= net.ReadVector()
	note.Time 	= CurTime()
	note.Message = note.Amount
	note.Font = "DamageNote"
	note.TotalTime = .75

	local type = net.ReadInt(3) or 0

	if type == 1 then
		note.Message = "KILL"
		note.Font = "DamageNoteBig"
		note.TotalTime = 1.75
	end
	if type == 2 then
		note.Message = note.Amount .. "  x2!"
		note.Font = "DamageNoteBig"
	end

	table.insert( DamageNotes, note )

end )

function GM:FinishMoveCurrent(pl, move)
	pl.History[CurTime()] = {}

	for k,v in ipairs(vars) do
		pl.History[CurTime()][v] = pl[v]
	end

	for time, vec in pairs(pl.History) do
		if time < CurTime() - 1 then
			pl.History[time] = nil
		end
	end
end

function GM:Move(pl, move)
	if !pl.History then
		pl.History = {}
	end

	self:SetupMoveCurrent(pl, move)

	self:HandleMove(pl, move)

	self:FinishMoveCurrent(pl, move)
end

local MusicTable = {
	["gmt_pvp_mars"] = "pvpbattle/StartOfColonyRound",
	["gmt_pvp_meadow01"] = "pvpbattle/StartOfMeadowRound",
	["gmt_pvp_oneslip01"] = "pvpbattle/StartOfOneSlipRound",
	["gmt_pvp_construction01"] = "pvpbattle/StartOfConstructionRound",
	["gmt_pvp_frostbite01"] = "pvpbattle/StartOfFrostbiteRound",
	["gmt_pvp_pit01"] = "pvpbattle/StartOfThePitRound",
	["gmt_pvp_containership02"] = "pvpbattle/StartOfContainerShipRound",
	["gmt_pvp_shard01"] = "pvpbattle/StartOfShardRound",
	["gmt_pvp_subway01"] = "pvpbattle/StartOfSubwayRound",
	["gmt_pvp_aether"] = "pvpbattle/StartOfAetherRound",
	["gmt_pvp_neo"] = "pvpbattle/startofneoround",
	["dm_lockdown_d2"] = "pvpbattle/startoflockdownround",
	["cs_office_b"] = "pvpbattle/startofofficeround",
}

MUSIC_ROUND			= 1
MUSIC_ENDROUND 	= 2

music.Register( MUSIC_ROUND, MusicTable[ game.GetMap() ] )
music.Register( MUSIC_ENDROUND, "pvpbattle/EndOfRound" )
