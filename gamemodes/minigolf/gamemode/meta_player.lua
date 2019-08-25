-----------------------------------------------------
local meta = FindMetaTable("Player")

if not meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:GetGolfBall()
	for _, ent in pairs(ents.FindByClass("golfball")) do
		if ent.GetOwner and ent:GetOwner() == self then
			return ent
		end
	end
end

function meta:CanPutt()
	if self:Team() == TEAM_FINISHED then
		return false
	end

	local ball = self:GetGolfBall()

	if not IsValid(ball) then
		return false
	end

	return ball.IsReady and ball:IsReady()
end

function meta:IsPocketed()
	return self:Team() == TEAM_FINISHED
end

function meta:GetBallColor()
	return Vector(self:GetNWString("BallColor"))
end

function meta:GetParDiff(swing)
	return swing - GAMEMODE:GetPar()
end

function meta:GetSwingResult(swing)
	local message = "BOGEY +" .. ((swing) - GAMEMODE:GetPar())
	local pardiff = self:GetParDiff(swing)

	if Scores[pardiff] then
		message = Scores[pardiff]
	end

	if swing == 1 then
		message = "HOLE IN ONE!"
	end

	return message
end

function meta:Swing()
	return self:GetNWInt("Swing")
end

function meta:SetSwing(swing)
	self:SetNWInt("Swing", swing)
end

if SERVER then
	function meta:SetupForHole()
		-- Reset swing and pocketed
		self:SetSwing(0)
		self:SetTeam(TEAM_PLAYING)
		self:SetCamera("Playing", 1.0)

		-- Move to hole
		--[[GAMEMODE:MoveToHole( self )
		umsg.Start( "SendHole", self )
			umsg.Vector( GAMEMODE:GetCurrentHole():GetPos() )
		umsg.End()]]
	end

	function meta:SetupBall(hole)
		self:SetTeam(TEAM_PLAYING)

		local spawn = self

		if hole then
			spawn = hole
		--self:RemoveBall() // Clear out the old ball
		end

		local ball = ents.Create("golfball")
		ball:SetPos(spawn:GetPos() + Vector(0, 0, 10))
		ball:SetOwner(self)
		ball:Spawn()

		local phys = ball:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(self:GetVelocity())
		end
	end

	function meta:SetupScores()
		if not GAMEMODE.CurrentHoleNum or GAMEMODE.CurrentHoleNum <= 0 then
			return
		end
		GAMEMODE:UpdateScore(self)
	end

	local swingSounds = {125, 100, 50, 0}

	function meta:Putt(ball, power, vec)
		if not self:CanPutt() then
			return
		end

		-- Override for practice round setup
		if self:GetCamera() ~= "Playing" and GAMEMODE:IsPracticing() then
			self:SetCamera("Playing", 1.0)
			return
		end

		if not ball then
			ball = self:GetGolfBall()
		end

		-- Play swing sound
		for _, snd in ipairs(swingSounds) do
			if power >= snd then
				ball:EmitSound(SOUND_SWING .. snd .. ".wav", 100, math.random(80, 120))
				break
			end
		end

		-- Effect
		local edata = EffectData()
		edata:SetOrigin(ball:GetPos())
		edata:SetStart(Vector(power, power, power))
		edata:SetEntity(self)
		util.Effect("golfhit", edata, true, true)

		-- sv_controls.lua
		Putt(ball, vec)

		-- Increase swing
		if GAMEMODE:IsPlaying() then
			self:SetSwing(self:Swing() + 1)
		end

		-- Undo AFK
		self.AfkTime = (CurTime() + AFKTime)
	end

	function meta:MessageSwing(swing)
		GAMEMODE:HUDMessage(self, self:GetSwingResult(swing))
	end

	function meta:AwardSwing(swing)
		self:AddAchivement(ACHIVEMENTS.MINIMILESTONE1, 1)
		self:AddAchivement(ACHIVEMENTS.MINIGREENGREENS, 1)
		--self:AddAchivement( ACHIVEMENTS.MINIMILESTONE1, 1 )

		if swing == 1 then
			self:SetAchivement(ACHIVEMENTS.MINIHOLEINONE, 1)
			self:AddAchivement(ACHIVEMENTS.MINIMASTERS, 1)
			return
		end

		local pardiff = self:GetParDiff(swing)

		if pardiff == -3 then
			self:AddAchivement(ACHIVEMENTS.MINIALBATROSS, 1)
		end

		if pardiff == -2 then
			self:AddAchivement(ACHIVEMENTS.MINIEAGLES, 1)
		end

		if pardiff == -1 then
			self:AddAchivement(ACHIVEMENTS.MINIBIRDIE, 1)
		end
	end

	function meta:AnnounceSwing(swing)
		local pardiff = self:GetParDiff(swing)

		-- Announcer
		if swing ~= 1 and pardiff < 1 then
			timer.Simple(
				.15,
				function()
					if IsValid(self) then
						GAMEMODE:PlaySound(SOUNDINDEX_ANNOUNCER, self)
					end
				end
			)
		end

		-- Clapping
		if swing == 1 then
			GAMEMODE:PlaySound(SOUNDINDEX_CLAP, self, 3)
		else
			timer.Simple(
				.5,
				function()
					if IsValid(self) then
						if pardiff < 0 then
							GAMEMODE:PlaySound(SOUNDINDEX_CLAP, self, 2)
						else
							GAMEMODE:PlaySound(SOUNDINDEX_CLAP, self, 1)
						end
					end
				end
			)
		end
	end

	function meta:LateJoin()
		if (GAMEMODE:GetState() == STATE_INTERMISSION and team.NumPlayers(TEAM_FINISHED) >= 1) then
			self:SetTeam(TEAM_FINISHED)
			self:SetSwing(15)
		else
			self:SetSwing(0)
		end

		self.LateSpawned = true
		local score = self:Swing()
		local count = GAMEMODE:GetHole() - 1

		for i = 1, count do
			local score = PenaltyScores(i) + 3
			GAMEMODE:SetScore(self, i, score)
		end
	end

	function meta:AutoFail(message)
		self:SetTeam(TEAM_FINISHED)
		self:SetCamera("Pocket", 1.0)

		GAMEMODE:HUDMessage(self, message)

		local score = self:Swing()

		if score > 15 then
			score = 15
		end

		GAMEMODE:SetScore(self, GAMEMODE:GetHole(), score)
	end

	function meta:Pocket()
		if self:IsPocketed() then
			return
		end

		local ball = self:GetGolfBall()

		if IsValid(ball) then
			ball:Pocket()
		end

		-- End ball for playing round
		if GAMEMODE:IsPlaying() then
			self:SetTeam(TEAM_FINISHED)

			self:SetCamera("Pocket", 2.0)

			-- Set Score
			GAMEMODE:SetScore(self, GAMEMODE:GetHole(), self:Swing())

			self:MessageSwing(self:Swing())
			self:AnnounceSwing(self:Swing())
			self:AwardSwing(self:Swing())
		end

		-- Reset ball for practice round
		if GAMEMODE:IsPracticing() then
			timer.Simple(
				1,
				function()
					if IsValid(self) then
						self:SetBallPos(PracticeSpawn():GetPos())
						ball:DropToFloor()
						ball.IsPocketed = false
					end
				end
			)
		end

		-- Update hats
		if self.ActiveWearables then
			Hats.RemoveHats(self)
		end
	end

	function meta:OutOfBounds(lastsafe, message)
		if not message then
			message = "OUT OF BOUNDS"
		end

		self:SetBallPos(lastsafe)

		if not GAMEMODE:IsPracticing() then
			GAMEMODE:HUDMessage(self, message)
			GAMEMODE:HUDMessage(self, "+1 PENALTY")
		end

		-- Increase swing
		if GAMEMODE:IsPlaying() then
			self:SetSwing(self:Swing() + 1)
		end
	end

	function meta:RemoveBall(time)
		local ball = self:GetGolfBall()
		if IsValid(ball) then
			if ball.RemoveOn then
				ball:RemoveOn(time)
			else
				ball:Remove()
			end
		end
	end

	function meta:SetBallPos(pos)
		if not pos then
			self:GetGolfBall():SetPos(CurrentHole)
			return
		end

		local ball = self:GetGolfBall()

		if IsValid(ball) then
			ball:SetVelocity(Vector(0, 0, 0))
			ball:SetPos(pos)
			ball.IsPocketed = false
			ball:EnableMotion(false)
		end
	end

	function meta:ResetSpeeds()
		self:SetWalkSpeed(150)
		self:SetRunSpeed(200)
		self:SetCanWalk(false)
	end
else -- CLIENT
	function meta:SpectateNext()
		local players = player.GetAll()
		local start = nil

		if not self.Spectating then
			self.Spectating = LocalPlayer()
		end

		for k, v in ipairs(players) do
			if v:EntIndex() == self.Spectating:EntIndex() then
				start = k
				break
			end
		end

		local newspec = start
		local k, v = next(players, start)

		if not k then
			k, v = next(players)
		end

		while k ~= start do
			if v:Team() == TEAM_PLAYING then
				newspec = k
				break
			end

			k, v = next(players, k)
			if not k then
				if start == nil then
					break
				end
				k, v = next(players)
			end
		end

		local ply = nil

		if newspec and players[newspec] then
			ply = players[newspec]
		end

		self.Spectating = ply
	end

	function meta:ClearSpectate()
		self.Spectating = nil
	end
end
