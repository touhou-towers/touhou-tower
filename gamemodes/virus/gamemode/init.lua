AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_post_events.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_payout.lua")
AddCSLuaFile("cl_hudmessage.lua")
AddCSLuaFile("cl_radar.lua")

include("shared.lua")
include("sh_payout.lua")

include("multiserver.lua")

include("sv_cleanup.lua")
include("sv_think.lua")
include("sv_round.lua")
include("sv_spawn.lua")
include("sv_player.lua")
include("sv_weapons.lua")

include("sv_misc.lua")

GM.CurrentRound = 0
GM.NumRounds = 10

GM.WaitingTime = 30
GM.IntermissionTime = 12
GM.InfectingTime = {15, 24}
GM.RoundTime = 90

GM.Weapons = {}

GM.NextMapThink = 0
GM.NextRankThink = 0

GM.VirusSpeed = 330
GM.HumanSpeed = 300

GM.NumWaitingForInfection = 8
GM.NumRoundMusic = 5
GM.NumLastAlive = 2

-- modifiers
GM.zombiesWithGuns = false
GM.playerGuns = {true, true, true, true}
GM.zombieGuns = {false, false, false, false}
GM.jumpable = false

GM.HasLastSurvivor = false

local VirusColor = Color(155, 200, 160, 255)

CreateConVar("gmt_srvid", 6)

function GM:Initialize()
	self.State = STATUS_WAITING
	game.GetWorld().State = self.State
	game.GetWorld().SetTime = self.WaitingTime

	local map = game.GetMap()

	RunConsoleCommand("sv_loadingurl", "http://gmodtower.org/loading/?mapname=%m&steamid=%s")
end

function GM:InitPostEntity()
	self:CleanUpMap() -- sv_cleanup.lua
end

function GM:RandomInfect()
	game.GetWorld().State = STATUS_PLAYING

	local time = GAMEMODE.RoundTime

	game.GetWorld().Time = CurTime() + time

	local plys = player.GetAll()

	if (#plys == 0) then
		GAMEMODE:EndServer()
		return
	end

	math.randomseed(RealTime() * 5555)

	local virusPlayer
	local PlayerCount = #plys

	repeat
		local virusRand = math.random(1, PlayerCount)
		virusPlayer = plys[virusRand]
	until virusPlayer ~= GAMEMODE.LastInfected

	GAMEMODE:Infect(virusPlayer)

	if PlayerCount > 1 then
		GAMEMODE.LastInfected = virusPlayer
	end

	timer.Destroy("RoundEnd")
	timer.Create("RoundEnd", time, 1, GAMEMODE.EndRound, GAMEMODE, false)
end

function GM:Infect(ply, infector)
	if (game.GetWorld().State ~= STATUS_PLAYING) then
		return
	end

	if not IsValid(ply) then
		return
	end

	if (ply.IsVirus) then
		return
	end

	if (infector == nil) then
		infector = game.GetWorld()
		if ply:AchivementLoaded() then
			ply:AddAchivement(ACHIVEMENTS.VIRUSLOSTHOPE, 1)
		end

		-- %s has been infected
		self:HudMessage(nil, 16, 5, ply, nil, VirusColor)
	end

	if (infector:IsPlayer()) then
		local tr =
			util.TraceLine {
			start = infector:GetPos(),
			endpos = ply:GetPos(),
			filter = infector
		}
		if tr.HitWorld then
			return
		end

		infector:AddAchivement(ACHIVEMENTS.VIRUSPANDEMIC, 1)
		self:AddScore(infector, 1)

		ply:AddDeaths(1) -- todo: should being infected add 1 to deaths?
		ply:EmitSound("ambient/fire/ignite.wav", 75, math.random(170, 200), 1, CHAN_AUTO)

		for _, v in ipairs(player.GetAll()) do
			if (v ~= ply) then
				-- %s was infected by %s
				self:HudMessage(v, 17, 2, ply, infector, VirusColor)
			else
				-- %s has infected you
				self:HudMessage(ply, 13, 5, infector, nil, VirusColor)
			end
		end
	end

	game.GetWorld().NumVirus = game.GetWorld().NumVirus + 1

	-- Fucking zoom
	ply:SetFOV(0, 0)

	ply:SetTeam(TEAM_INFECTED)

	self:VirusSpawn(ply)

	ply.IsVirus = true

	PostEvent(ply, "lastman_off")
	PostEvent(ply, "adrenaline_off")

	ply:SetDSP(1) -- turn off adrenaline dsp

	local randSong = math.random(1, self.NumRoundMusic)

	umsg.Start("Infect")
	umsg.Entity(ply)
	umsg.Entity(infector)
	umsg.Char(randSong)
	umsg.End()

	if (game.GetWorld().NumVirus >= #player.GetAll()) then
		timer.Destroy("RoundEnd")

		self:EndRound(true) -- virus wins

		return
	end

	if (#player.GetAll() - game.GetWorld().NumVirus == 1) then
		if (self.HasLastSurvivor) then
			return
		end

		local randSurvSong = math.random(1, self.NumLastAlive)
		umsg.Start("LastSurvivor")
		umsg.Char(randSurvSong)
		umsg.End()

		local lastPlayer = team.GetPlayers(TEAM_PLAYERS)[1]

		PostEvent(lastPlayer, "adrenaline_off") -- in case they used it
		PostEvent(lastPlayer, "lastman_on")

		for _, v in ipairs(team.GetPlayers(TEAM_INFECTED)) do
			-- last survivor is %s
			self:HudMessage(v, 3, 5, lastPlayer)
		end
		-- your are the last survivor
		self:HudMessage(lastPlayer, 2, 5)

		self.HasLastSurvivor = true
	end
end

function GM:HudMessage(ply, index, time, ent, ent2, color)
	umsg.Start("HudMsg", ply)
	umsg.Char(index)
	umsg.Char(time)
	if (IsValid(ent)) then
		umsg.Entity(ent)
	end

	if (IsValid(ent2)) then
		umsg.Entity(ent2)
	end

	if color ~= nil then
		umsg.Short(color.r)
		umsg.Short(color.g)
		umsg.Short(color.b)
		umsg.Short(color.a)
	end

	umsg.End()
end

function GM:CanPlayerSuicide(ply)
	return false
end

hook.Add(
	"EntityTakeDamage",
	"DamageNotes",
	function(target, dmginfo)
		if game.GetWorld().State == STATUS_PLAYING then
			if target:IsPlayer() and dmginfo:GetAttacker():IsPlayer() and target.IsVirus then
				umsg.Start("DamageNotes", dmginfo:GetAttacker())
				umsg.Float(math.Round(dmginfo:GetDamage()))
				umsg.Vector(target:GetPos() + Vector(math.random(-3, 3), math.random(-3, 3), math.random(48, 50)))
				umsg.End()
			end
		end
	end
)
