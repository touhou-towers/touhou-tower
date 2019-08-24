function GM:PlayerDisconnected(ply)
	ply:SetTeam(TEAM_SPEC)

	-- last player left, and we never started a game, so cancel the waiting start
	if game.GetWorld().State == STATUS_WAITING and #player.GetAll() == 1 then
		timer.Destroy("WaitingStart")
		timer.Destroy("WaitingFade")
	end

	if ply.IsVirus then
		game.GetWorld().NumVirus = game.GetWorld().NumVirus - 1
	end

	local numPlys = #player.GetAll()

	if numPlys == 0 then
		self:EndServer()
		return
	end

	if game.GetWorld().State ~= STATUS_PLAYING then
		return
	end

	if game.GetWorld().NumVirus == 0 then
		GAMEMODE:HudMessage(nil, 18, 5)
		timer.Simple(
			1,
			function()
				GAMEMODE:RandomInfect()
			end
		)
	end
end

function GM:PlayerShouldTakeDamage(victim, attacker)
	if victim:IsPlayer() and attacker:IsPlayer() and victim:Team() == attacker:Team() then
		return false
	end

	-- make players take damage

	local rp = RecipientFilter()
	rp:AddPlayer(victim)

	umsg.Start("DmgTaken", rp)
	umsg.End()

	return true
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	if ply.Flame ~= nil then -- flame off, bro
		ply.Flame:Remove()
		ply.Flame = nil

		ply.Flame2:Remove()
		ply.Flame2 = nil
	end

	if ply.IsVirus then
		eff = EffectData()
		eff:SetOrigin(ply:GetPos() + Vector(0, 0, 50))
		util.Effect("virus_explode", eff)
	end

	ply.RespawnTime = CurTime() + 4

	if IsValid(attacker) and attacker:IsPlayer() then
		if (attacker == ply) then
			attacker:AddDeaths(1)
		else
			self:AddScore(attacker, 1)
		end

		if IsValid(dmginfo:GetInflictor()) then
			local ent = dmginfo:GetInflictor():GetClass()
			if ent == "tnt" then
				attacker:AddAchivement(ACHIVEMENTS.VIRUSEXPLOSIVE, 1) -- yippee ki-yay mother huger
			elseif ent == "player" then
				if IsValid(attacker:GetActiveWeapon()) then
					local weapon = attacker:GetActiveWeapon():GetClass()
					if weapon == "weapon_doublebarrel" then
						attacker._Shell = attacker._Shell + 1
						if attacker._Shell >= 2 then
							attacker:SetAchivement(ACHIVEMENTS.VIRUSSHELLAWARE, 1)
							attacker._Shell = 0
						end
					end
				end
			end
		end
	end

	if (game.GetWorld().State ~= STATUS_PLAYING) then
		return
	end

	-- if died and you're a virus, add death
	if (game.GetWorld().State == STATUS_PLAYING and ply.IsVirus) then
		ply:AddDeaths(1)
		return
	end

	-- if died and you were a player, turn to virus
	if (game.GetWorld().State == STATUS_PLAYING and not ply.IsVirus) then
		self:Infect(ply)
	end

	ply:CreateRagdoll()

	if (#player.GetAll() - game.GetWorld().NumVirus == 1) then
		umsg.Start("LastSurvivor")
		umsg.End()

		local lastPlayer = team.GetPlayers(TEAM_PLAYERS)[1]
		PostEvent(lastPlayer, "lastman_on")
	end
end

function GM:AddScore(ply, score)
	ply:AddFrags(score)

	umsg.Start("ScorePoint", ply)
	umsg.End()
end

-- actually adds guns to players
function GM:PlayerLoadout(ply)
	for _, v in ipairs(self:GetSelectedWeapons()) do
		ply:Give(v)
	end

	if (#ply:GetWeapons() == 0) then
		return
	end

	ply:SelectWeapon(self:GetStartWeapon())

	-- Ammo
	ply:GiveAmmo(12, "SMG1", true)
	ply:GiveAmmo(24, "357", true)
	ply:GiveAmmo(28, "Pistol", true)
	ply:GiveAmmo(24, "Buckshot", true)
	ply:GiveAmmo(50, "AR2", true)
	ply:GiveAmmo(12, "XBowBolt", true)
	ply:GiveAmmo(12, "AlyxGun", true)
end

concommand.Add(
	"use_adrenaline",
	function(ply, cmd, args)
		if not ply:HasWeapon("weapon_adrenaline") then
			return
		end

		local adrenaline = ply:GetWeapon("weapon_adrenaline")
		if not IsValid(adrenaline) or adrenaline.Used then
			return
		end

		ply:SelectWeapon("weapon_adrenaline")
		timer.Simple(
			0.15,
			function()
				if IsValid(ply:GetActiveWeapon()) then
					ply:GetActiveWeapon():PrimaryAttack()
				end
			end
		)
	end
)
