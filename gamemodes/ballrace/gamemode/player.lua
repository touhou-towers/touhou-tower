function GM:IsSpawnpointSuitable( pl, spawnpointent, bMakeSuitable )
	return
end

function GM:PlayerInitialSpawn(ply)

	if ply:IsBot() then return end

	ply:SetTeam(TEAM_DEAD)

	net.Start("pick_ball")
	net.Send(ply)

	-- if waiting and number of players is 1
	if GetState() == STATUS_WAITING && #player.GetAll() == 1 then
		game.CleanUpMap()
		SetTime(CurTime() + GAMEMODE.IntermissionTime)

		self:Announce("You are the first to join, waiting for additional players!")
		timer.Simple(GAMEMODE.IntermissionTime, self.StartRound, self)
	end
end

function GM:PlayerDisconnected(ply)
	ply:SetTeam(TEAM_DEAD)
	self:UpdateSpecs(ply, true)

	self:LostPlayer(ply, true)
	PrintMessage( HUD_PRINTTALK, ply:Name().. " has dropped out of the race." )
end

function GM:DoPlayerDeath(ply)
	if ply:Deaths() - 1 == 0 then
		ply:SetTeam(TEAM_DEAD)
		self:UpdateSpecs(ply, true)
	end

	ply:SetDeaths(ply:Deaths() - 1)

	self:LostPlayer(ply)

	ply.NextSpawn = CurTime() + 2
end

function GM:PlayerDeathThink( pl )
	if (pl.NextSpawn or 0) <= CurTime() then
		pl:Spawn()
	end
end

function GM:PlayerDeathSound( ply )
	local effectdata = EffectData()
	effectdata:SetOrigin( ply:GetPos() )
	util.Effect( "confetti", effectdata )

	ply:EmitSound("weapons/ar2/npc_ar2_altfire.wav", 75, math.random(160,180), 1, CHAN_AUTO )

	return true
end

function GM:PlayerSpawn(ply)
	if GetState() == STATUS_SPAWNING || ply:Team() == TEAM_PLAYERS then

		ply.Spectating = nil

		if IsValid(ply.Ball) then
			ply.Ball:Remove()
			ply.Ball = nil
		end

		ply:UnSpectate()
		ply:SetTeam(TEAM_PLAYERS)

		ply:SetColor(0,0,0,0)
		ply:SetNotSolid(true)
		ply:SetMoveType(MOVETYPE_NOCLIP)

		ply.Ball = ents.Create("player_ball")

		ply.Ball:SetPos(ply:GetPos() + Vector(0,0,48))

		ply.Ball:SetSkin((ply:EntIndex()-1) % 6)

		ply.Ball:SetOwner(ply)

		ply.Ball:Spawn()

		ply:SetBall(ply.Ball)

		self:UpdateSpecs(ply)

	else

		ply:Spectate(OBS_MODE_ROAMING)

		self:SpectateNext(ply)

		self:UpdateStatus()

	end

	ply:CrosshairDisable()
end

function GM:PlayerSelectSpawn(ply)
	if LateSpawn then
		return LateSpawn
	end
	return self.BaseClass:PlayerSelectSpawn(ply)
end

function GM:KeyPress(ply, key)
	if ply:Team() == TEAM_PLAYERS || !ply:Alive() then return end

	if key == IN_ATTACK then
		self:SpectateNext(ply)
	end
end

function GM:SetupPlayerVisibility(ply)
	local ball = ply:GetBall()
	if IsValid(ball) then
		AddOriginToPVS(ball:GetPos())
	end
end

function GM:CanPlayerSuicide( ply )
	return ply:Team() == TEAM_PLAYERS
end

function GM:PlayerSpray( pl )
	return pl:Team() != TEAM_PLAYERS
end

function GM:PlayerSwitchFlashlight(ply)
	return false
end

function GetPlayerStatus(ply)
	if ply:Team() == TEAM_DEAD then
		return = "DEAD"
	elseif ply:Team() == TEAM_COMPLETED then
		return = ply.placements
	elseif GetState() == STATUS_WAITING then
		return = "WAITING"
	elseif GetState() != STATUS_WAITING then
		return = "PLAYING"
	end
end

local function SetBallId( ply, BallId )
	BallId = tonumber(BallId)

	if BallId == 2 && GTowerStore:GetPlyLevel(ply,"BallRacerCube") == 1  then
		ply.ModelSet = 'models/gmod_tower/cubeball.mdl'
	elseif BallId == 3 && GTowerStore:GetPlyLevel(ply,"BallRacerIcosahedron") == 1  then
		ply.ModelSet = 'models/gmod_tower/icosahedron.mdl'
	elseif BallId == 4 && GTowerStore:GetPlyLevel(ply,"BallRacerCatBall") == 1 then
		ply.ModelSet = 'models/gmod_tower/catball.mdl'
	elseif BallId == 5 && ( ply.IsVIP || ply:IsAdmin() ) then
		ply.ModelSet = 'models/gmod_tower/ballion.mdl'
	elseif BallId == 6 && GTowerStore:GetPlyLevel(ply,"BallRacerBomb") == 1 then
		ply.ModelSet = 'models/gmod_tower/ball_bomb.mdl'
	elseif BallId == 7 && GTowerStore:GetPlyLevel(ply,"BallRacerGeo") == 1 then
		ply.ModelSet = 'models/gmod_tower/ball_geo.mdl'
	elseif BallId == 8 && GTowerStore:GetPlyLevel(ply,"BallRacerSoccerBall") == 1 then
		ply.ModelSet = 'models/gmod_tower/ball_soccer.mdl'
	elseif BallId == 9 && GTowerStore:GetPlyLevel(ply,"BallRacerSpikedd") == 1 then
		ply.ModelSet = 'models/gmod_tower/ball_spiked.mdl'
	else
		ply.ModelSet = 'models/gmod_tower/BALL.mdl'
	end
end

concommand.Add("gmt_setball", function( ply, cmd, args )

	local BallId = tonumber( args[1] )

	if BallId then
		SetBallId( ply, BallId )
	end

end )
