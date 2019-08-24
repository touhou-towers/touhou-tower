function GM:PlayerInitialSpawn(ply)
	if (ply.IsVirus) then
		ply:SetTeam(TEAM_INFECTED)
	else
		ply:SetTeam(TEAM_PLAYERS)
	end

	ply.NextWeaponThink = 0

	if (game.GetWorld().State ~= STATUS_PLAYING and not ply.IsVirus) then
		hook.Call("PlayerSetModel", GAMEMODE, ply)
	end

	ply:StripWeapons()

	if ply:IsBot() then
		return
	end

	if (game.GetWorld().State == STATUS_WAITING and #player.GetAll() > 1) then
		game.GetWorld().Time = CurTime() + self.WaitingTime
		-- your are the first to join
		self:HudMessage(ply, 14, 10)

		timer.Destroy("WaitingStart")
		timer.Create("WaitingStart", GAMEMODE.WaitingTime, 1, GAMEMODE.StartRound, GAMEMODE)

		timer.Destroy("WaitingFade")
		timer.Create("WaitingFade", GAMEMODE.WaitingTime - 2, 1, GAMEMODE.FadeWaiting, GAMEMODE)

		game.GetWorld().State = 2
	end

	-- because apparently LocalPlayer() is nil when this usermessage arrives
	timer.Simple(
		1,
		function()
			if (game.GetWorld().State == STATUS_INFECTING) then
				umsg.Start("LateMusic", ply)
				umsg.Char(MUSIC_WAITINGFORINFECTION)
				umsg.Char(self.WaitingSong)
				umsg.End()
			end

			if (game.GetWorld().State == STATUS_INTERMISSION) then
				umsg.Start("LateMusic", ply)
				umsg.Char(MUSIC_INTERMISSION)
				if (self.EndRoundMusic == true) then
					umsg.Char(1)
				else
					umsg.Char(0)
				end
				umsg.End()
			end
		end
	)

	ply:CrosshairDisable()

	PostEvent(ply, game.GetMap())
end

function GM:PlayerSpawn(ply)
	if (game.GetWorld().State ~= STATUS_PLAYING and not ply.IsVirus) then
		hook.Call("PlayerSetModel", GAMEMODE, ply)
	end

	-- jump power
	if not GAMEMODE.jumpable then
		ply:SetJumpPower(0)
	else
		ply:SetJumpPower(150)
	end

	ply:SetWalkSpeed(300)
	ply:SetRunSpeed(300)

	umsg.Start("Spawn", ply)
	umsg.Entity(ply)
	umsg.End()

	local vm = ply:GetViewModel()
	if IsValid(vm) then
		vm:SetColor(Color(255, 255, 255, 255))
	end

	ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	if (game.GetWorld().State == STATUS_WAITING) then
		return
	end

	if (ply.Flame ~= nil) then
		ply.Flame:Remove()
		ply.Flame = nil

		ply.Flame2:Remove()
		ply.Flame2 = nil
	end

	if (game.GetWorld().State == STATUS_PLAYING and not ply.IsVirus) then
		timer.Simple(2, GAMEMODE.Infect, self, ply)

		return
	end

	if (ply.IsVirus) then
		self:VirusSpawn(ply)
	else
		self:HumanSpawn(ply)
	end

	-- Do some sweet effects.
	ply:EmitSound("GModTower/virus/player_spawn.wav")
	local spawnent = ents.Create("spawn")
	if IsValid(spawnent) then
		spawnent:SetPos(ply:GetPos() + Vector(0, 0, 40))
		spawnent:SetOwner(ply)
		spawnent:SetSpawnOwner(ply)
		spawnent:ShouldRemove(true)
		spawnent:Spawn()
		spawnent:Activate()
	end

	PostEvent(ply, game.GetMap())
	PostEvent(ply, "adrenaline_off")
end

function GM:FadeWaiting()
	umsg.Start("FadeWaiting")
	umsg.End()
end

-- spawns a virus
function GM:VirusSpawn(ply)
	local numVirus = game.GetWorld().NumVirus

	local healthScale = math.Clamp(15 * (#player.GetAll() / numVirus) + 30, 50, 100)

	ply:SetModel("models/player/virusi.mdl")

	ply:SetWalkSpeed(self.VirusSpeed)
	ply:SetRunSpeed(self.VirusSpeed)

	ply:SetHealth(healthScale)
	ply.MaxHealth = healthScale

	-- here we can give  weapon and ammo
	ply:StripWeapons()
	ply:RemoveAllAmmo()

	ply:CrosshairDisable()

	if (not ply:Alive()) then
		ply:Spawn()
	end

	PostEvent(ply, "infection_on")

	timer.Simple(
		2,
		function()
			if ply:Alive() then
				local pos = ply:GetPos() + Vector(0, 0, 50)

				-- flame OOOONNN!!
				-- yeah fuck me leave it like this it looks fine
				if (ply.Flame == nil) then
					local sprite = ents.Create("env_sprite")
					sprite:SetPos(pos)
					sprite:SetKeyValue("rendercolor", "70 255 70")
					sprite:SetKeyValue("renderamt", "150")
					sprite:SetKeyValue("rendermode", "5")
					sprite:SetKeyValue("renderfx", "0")
					sprite:SetKeyValue("model", "sprites/fire1.spr")
					sprite:SetKeyValue("glowproxysize", "32")
					sprite:SetKeyValue("scale", "0.4")
					sprite:SetKeyValue("framerate", "20")
					sprite:SetKeyValue("spawnflags", "1")
					sprite:SetParent(ply)
					sprite:Spawn()

					ply.Flame = sprite

					sprite = ents.Create("env_sprite")
					sprite:SetPos(pos)
					sprite:SetKeyValue("rendercolor", "110 255 110")
					sprite:SetKeyValue("renderamt", "150")
					sprite:SetKeyValue("rendermode", "5")
					sprite:SetKeyValue("renderfx", "0")
					sprite:SetKeyValue("model", "sprites/fire1.spr")
					sprite:SetKeyValue("glowproxysize", "32")
					sprite:SetKeyValue("scale", "0.5")
					sprite:SetKeyValue("framerate", "14")
					sprite:SetKeyValue("spawnflags", "1")
					sprite:SetParent(ply)
					sprite:Spawn()

					ply.Flame2 = sprite

					ply:SetNetworkedEntity("Flame1", ply.Flame)
					ply:SetNetworkedEntity("Flame2", ply.Flame2)
					ply:EmitSound("ambient/fire/ignite.wav", 75, 95, 1, CHAN_AUTO)
				end
			end
		end
	)

	if (ply.IsVirus and ply:Deaths() == 2 and game.GetWorld().NumVirus == 1) then
		-- infected has become enraged
		self:HudMessage(nil, 19, 5)
	end
end

function GM:HumanSpawn(ply)
	ply:SetWalkSpeed(self.HumanSpeed)
	ply:SetRunSpeed(self.HumanSpeed)

	PostEvent(ply, "lastman_off")
	PostEvent(ply, "infection_off")
	ply._Shell = 0 -- yeah yeah shell yourself

	local ViewModel = ply:GetViewModel()
	if IsValid(ViewModel) then
		ViewModel:SetColor(Color(255, 255, 255, 255))
	end
end

function GM:PlayerSelectSpawn(ply)
	local spawns = ents.FindByClass("info_player*")
	local availspawns = {}

	for _, ent in ipairs(spawns) do
		if self:IsValidSpawn(ent) then
			table.insert(availspawns, ent)
		end
	end

	if #availspawns > 0 then
		return availspawns[math.random(#availspawns)]
	else
		return spawns[math.random(#spawns)]
	end
end

function GM:IsValidSpawn(ent)
	for _, v in ipairs(ents.FindInSphere(ent:GetPos(), 100)) do
		return false
	end

	return true
end
