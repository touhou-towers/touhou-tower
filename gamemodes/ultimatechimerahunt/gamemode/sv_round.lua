GM.WaitingTime = 30
GM.IntermissionTime = 12
GM.OverTimeAdd = 10

function GM:StartRound()

	//We are done here, send them back to the main server
	if ( GetGlobalInt("Round") + 1 ) > self.NumRounds then
		self:EndServer()
		return
	end
	
	//Check if we have enough players.
	//local clients = player.GetAll()
	//local connecting = clients.spawning
	//if connecting < 1 && #player.GetAll() <= 1 then
	if #player.GetAll() <= 1 then

		Msg( "Not enough players - ending game.", "\n" )
		self:EndServer()  //no one connecting and not enough on the server...
		return

	//elseif connecting >= 1 && #player.GetAll() == 1 then
	elseif #player.GetAll() == 1 then

		Msg( "Enough players are connected, but only one spawned - waiting.", "\n" )
		self:WaitRound( true ) //jesus they're taking forever to join
		return

	end

	SetGlobalInt("Round", GetGlobalInt("Round") + 1)
	SetGlobalInt("Time", CurTime() + self.RoundTime)
	self.Intense = false
	self.UCAngry = false

	Msg( "Starting round! " .. tostring( GetGlobalInt("Round") ) .. "\n" )

	self:SetGameState( STATUS_PLAYING )

	self:CleanUp()
	//self.CanStartDead = CurTime() + 5
	
	for _, v in ipairs( player.GetAll() ) do
		v.IsChimera = false
	end

	SetGlobalEntity("UC", NULL)
	self:RandomChimera()
	self:NewSaturn()

	for _, v in ipairs( player.GetAll() ) do

		v:UnGhost()
		self:SetMusic( v, MUSIC_ROUND )
		v.IsDead = false
		if !v.IsChimera then v:SetTeam( TEAM_PIGS ) end
		//v:Freeze( false )

		v:SetFrags( 0 )
		v:SetDeaths( 0 )

		v:StripWeapons()
		v:RemoveAllAmmo()

		v:Spawn()
		
	end
  
	umsg.Start( "UCRound" )
	umsg.End()

end

function GM:WaitRound( force )

	Msg( "Waiting for players.", "\n" )

	self:SetGameState( STATUS_WAITING )

	if !self.FirstPlySpawned || force then
		SetGlobalInt("Time", CurTime() + self.WaitingTime)
	end

	if force then
		for _, v in ipairs( player.GetAll() ) do //restart music

			self:SetMusic( v, MUSIC_WAITING )
			self:HUDMessage( v, MSG_FIRSTJOIN, 10 )

			//v:Freeze( false )
			v:Spawn()

		end
	end

	/*timer.Destroy( "WaitingStart" )
	timer.Create( "WaitingStart", self.WaitingTime, 1, self.StartRound, self )*/

end

function GM:EndRound( teamid )

	local endofgame = false
	if ( GetGlobalInt("Round") + 1 ) > self.NumRounds then endofgame = true end

	SetGlobalInt("Time", CurTime() + ( self.IntermissionTime or 12 ))

	Msg( "Ending Round...\n" )

	self:SetGameState( STATUS_INTERMISSION )

	for _, v in ipairs( player.GetAll() ) do
		
		/*if v.IsChimera then
			v:Freeze( true )
		end*/

		v:AddAchivement(ACHIVEMENTS.UCHMILESTONE1,1)
		v:AddAchivement(ACHIVEMENTS.UCHMILESTONE2,1)

		if endofgame then

			self:SetMusic( v, MUSIC_ENDROUND, TEAM_SALSA )

		else

			self:SetMusic( v, MUSIC_ENDROUND, teamid )

		end

		if teamid == TEAM_PIGS then

			if v:Team() == TEAM_PIGS then

				v:AddAchivement( ACHIVEMENTS.UCHENTERTHEPIG, 1 )
				if team.AlivePigs() >= 3 then
					v:AddAchivement( ACHIVEMENTS.UCHDYNASTY, 1 )
				end

			end

			self:HUDMessage( v, MSG_PIGWIN, 10 )
			self.WinningTeam = TEAM_PIGS

		elseif teamid == TEAM_CHIMERA then

			self:HUDMessage( v, MSG_UCWIN, 10 )
			self.WinningTeam = TEAM_CHIMERA

		else
			self:HUDMessage( v, MSG_TIEGAME, 10 )
		end

	end
	
	self:GiveMoney()
	
	umsg.Start( "UCRound" )
	umsg.End()
	
end

function GM:RandomChimera()

	Msg( "Finding Chimera...", "\n" )

	local plys = player.GetAll()
	
	if #plys == 0 then
		self:EndServer()
		return
	end
	
	math.randomseed( RealTime() * 5555 )
	
	local ucPlayer
	local PlayerCount = #plys
	
	repeat
		local ucRand = math.random( 1, PlayerCount )
		
		ucPlayer = plys[ ucRand ]
		
	until ucPlayer != self.LastChimera

	SetGlobalEntity("UC", ucPlayer)
	self:SetChimera( ucPlayer )
	
	if PlayerCount > 1 then
		self.LastChimera = ucPlayer
	end

end

function GM:SetChimera( ply )

	ply.IsChimera = true
	ply:SetTeam( TEAM_CHIMERA )

end

function GM:CheckGame( ply ) //this function checks if the game should end or not based on the players alive
	
	if !self:IsPlaying() then return end
	
	Msg( "Alive pigs: " .. team.AlivePigs(), "\n" )

	if ply.IsChimera then
		
		self:EndRound( TEAM_PIGS )

	elseif team.AlivePigs() <= 0 then
	
		self:EndRound( TEAM_CHIMERA )

	end

end

function GM:CleanUp()

	game.CleanUpMap()

	local rag = self.UCRagdoll
	if IsValid( rag ) then
		rag:Remove()
	end
	local bird = self.BirdProp
	if IsValid( bird ) then
		bird:Remove()
	end
	
end