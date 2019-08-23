GM.DefaultDayTime = 120
GM.MaxDaysPerGame = 7
GM.GameStarted = false

function GM:Think()

	for k,v in pairs(player.GetAll()) do
		if v:GetNWInt("Combo") > 0 then
			if CurTime() > v.ComboTime then
				v:SetNWInt("Combo", 0)
			end
		end
	end

	if self:GetState() == STATE_WAITING && self:GetTimeLeft() <= 0 then

		self.BossRound = false
		self.BossSpawned = false

		if self.GameStarted == true && !self.LostRound then
			SetGlobalInt( "Round", GetGlobalInt( "Round" ) + 1 )
		end

		if GetGlobalInt( "Round" ) == 6 then
			self.BossRound = true
		end

		umsg.Start( "ZMClassSelector" )
			umsg.Bool(true)
		umsg.End()

		umsg.Start( "ZMPlayMusic" )
			umsg.Char(2)
		umsg.End()

		for k,v in pairs( ents.FindByClass("zm_player_gravestone") ) do
			v:Remove()
		end

		self:SetState( STATE_UPGRADING )
		SetGlobalInt( "ZMDayTime", CurTime() + 15 )

		for _, ply in ipairs( player.GetAll() ) do
			ply:SetFrags( 0 )
			ply:SetDeaths( 0 )
			ply:SetNWInt( "Lives", 2 )
			ply:SetNWInt( "Points", 0 )
			ply:StripAllInventory()
		end
	elseif self:GetState() == STATE_UPGRADING && self:GetTimeLeft() <= 0 then
		for _, ply in ipairs( player.GetAll() ) do
			ply:Freeze( false )
			ply:Spawn()

			ply:SetNWInt( "LastItem", 0)

			if self.GameStarted == false then
				ply:Give("weapon_zm_handgun")
			end

			if self.BossRound then
				--for k,v in pairs(player.GetAll()) do
					umsg.Start( "HUDMessage", ply )
						umsg.Char(11)
						umsg.Char(8)
						umsg.Entity(nil)
						umsg.Entity(nil)

						umsg.Short(255)
						umsg.Short(0)
						umsg.Short(0)
						umsg.Short(255)
					umsg.End()
				--end
			elseif GetGlobalInt("Round") != 1 && !self.LostRound then
				--for k,v in pairs(player.GetAll()) do
					umsg.Start( "HUDMessage", ply )
						umsg.Char(10)
						umsg.Char(8)
						umsg.Entity(nil)
						umsg.Entity(nil)

						umsg.Short(255)
						umsg.Short(255)
						umsg.Short(255)
						umsg.Short(255)
					umsg.End()
				--end
			end

		end

		umsg.Start( "ZMClassSelector" )
			umsg.Bool(false)
		umsg.End()

		umsg.Start( "ZMPlayMusic" )
			umsg.Char(3)
		umsg.End()

		self:SetState( STATE_WARMUP )
		SetGlobalInt( "ZMDayTime", CurTime() + 8 )
	elseif self:GetState() == STATE_WARMUP && self:GetTimeLeft() <= 0 then
		if GetGlobalInt( "Round" ) != 6 then
			umsg.Start( "ZMPlayMusic" )
				umsg.Char(4)
			umsg.End()
		else
			umsg.Start( "ZMPlayMusic" )
				umsg.Char(6)
			umsg.End()

			self:StartBossRound()

		end

		self:SetState( STATE_PLAYING )
		self:BeginGame()
	elseif self:GetState() == STATE_PLAYING && self:GetTimeLeft() <= 15 && self:GetTimeLeft() > 0 then

		local heli = GetGlobalEntity( "Helicopter" )

		if !IsValid( heli ) then
			self:SpawnHelicopter()
		end

	elseif self:GetState() == STATE_PLAYING && self:GetTimeLeft() <= 0 then

		--if self.BossRound then return end

		for _, ply in ipairs( player.GetAll() ) do
			ply:Freeze( true )

			umsg.Start( "HUDMessage", ply )
				umsg.Char(8)
				umsg.Char(8)
				umsg.Entity(ply)
				umsg.Entity(nil)

				umsg.Short(255)
				umsg.Short(255)
				umsg.Short(255)
				umsg.Short(255)
			umsg.End()
		end

		for k,v in pairs( ents.FindByClass("zm_player_gravestone") ) do
			v:Remove()
		end

		umsg.Start( "ZMPlayMusic" )
			umsg.Char(5)
			umsg.Bool(true)
		umsg.End()

		self:SetState( STATE_INTERMISSION )

		for k,v in pairs(player.GetAll()) do
			v:SendLua([[RunConsoleCommand( "gmt_showscores", "1" )]])
			v:AddAchivement( ACHIVEMENTS.ZMDAWNOFTHEDEAD, 1 )
			v:AddAchivement( ACHIVEMENTS.ZM28DAYS, 1 )
		end

		self.LostRound = false

		self:FlyAwayLittleHeli()
		self:GiveMoney()
		self:EndDay()
	elseif self:GetState() == STATE_INTERMISSION && self:GetTimeLeft() <= 0 then
	
		for k,v in pairs( ents.FindByClass("zm_player_gravestone") ) do
			v:Remove()
		end
	
		for _, ply in ipairs( player.GetAll() ) do
			ply:Freeze( false )
			ply:SendLua([[RunConsoleCommand( "gmt_showscores", "0" )]])
		end

		self:SetState( STATE_WAITING )

		local heli = GetGlobalEntity( "Helicopter" )
		if IsValid( heli ) then heli:Remove() end

	end

	if self.BossRound && self.BossSpawned && !self.HasBoss() then

		self.BossRound = false
		umsg.Start( "ZMPlayMusic" )
			umsg.Char(5)
			umsg.Bool(true)
		umsg.End()

		self:SetState( STATE_INTERMISSION )

		for k,v in pairs(player.GetAll()) do
			v:SendLua([[RunConsoleCommand( "gmt_showscores", "1" )]])
		end

		self.LostRound = false

		local heli = GetGlobalEntity( "Helicopter" )

		if !IsValid( heli ) then
			self:SpawnHelicopter()
		end

		self.WonBossRound = true

		timer.Simple(0.1,function()
			self:FlyAwayLittleHeli()
		end)

		self:GiveMoney()

		self:EndDay()

		SetGlobalInt("ZMDayTime",CurTime()+25)

		timer.Simple(10,function()
			self:EndServer()
		end)

		return
	end

	local deads = 0

	for k,v in pairs(player.GetAll()) do if !v:Alive() then deads = deads + 1 end end

	if deads == player.GetCount() && self:GetState() == STATE_PLAYING then
		for _, ply in ipairs( player.GetAll() ) do
			ply:Freeze( true )

			umsg.Start( "HUDMessage", ply )
				umsg.Char(9)
				umsg.Char(8)
				umsg.Entity(ply)
				umsg.Entity(nil)

				umsg.Short(255)
				umsg.Short(255)
				umsg.Short(255)
				umsg.Short(255)
			umsg.End()
		end

		for k,v in pairs( ents.FindByClass("zm_player_gravestone") ) do
			v:Remove()
		end

		umsg.Start( "ZMPlayMusic" )
			umsg.Char(5)
			umsg.Bool(false)
		umsg.End()

		self.LostRound = true

		SetGlobalInt( "ZMDayTime", CurTime() + 10 )

		self:SetState( STATE_INTERMISSION )

		for k,v in pairs(player.GetAll()) do
			v:SendLua([[RunConsoleCommand( "gmt_showscores", "1" )]])
		end

		self:EndDay()

	end

end

function GM:SpawnHelicopter()
	local heli = ents.Create( "zm_helicopter" )
	heli:SetPos( self:GetHelicopterPosition() )
	heli:Spawn()
	SetGlobalEntity( "Helicopter", heli )
end

function GM:FlyAwayLittleHeli()
	local heli = GetGlobalEntity( "Helicopter" )

	if IsValid( heli ) then
		net.Start( "gmt_heli_fly" )
			net.WriteEntity( heli )
		net.Broadcast()
	end

end

function GM:StartBossRound()

	if game.GetMap() == "gmt_zm_arena_trainyard01" then
		for k,v in pairs(player.GetAll()) do
			v:AddAchivement( ACHIVEMENTS.ZMSPIDER, 1 )
		end
	elseif game.GetMap() == "gmt_zm_arena_thedocks01" then
		for k,v in pairs(player.GetAll()) do
			v:AddAchivement( ACHIVEMENTS.ZMDINO, 1 )
		end
	end

	local SpawnPoint = ents.FindByClass("info_boss_spawn")[1]

	if !IsValid(SpawnPoint) then return end

	local bossNum = math.random(1,2)

	local bossClasses = {
		--"zm_npc_boss_spider",
		"zm_npc_boss_trex"
	}

	local SpawnPos = SpawnPoint:GetPos()

	local boss1 = ents.Create( bossClasses[bossNum] )
	boss1:SetPos( SpawnPoint:GetPos() + Vector(0,0,150) )
	boss1:Spawn()

	timer.Simple(0.5,function()
		local boss2 = ents.Create( bossClasses[bossNum] )
		boss2:SetPos( SpawnPoint:GetPos() + Vector(0,0,150) )
		boss2:Spawn()
		boss1:Remove()

		boss2:SetMaxHealth(20000)
		boss2:SetHealth(20000)

		self:SetBoss( boss2 )
		self.BossSpawned = true
	end)

end

function GM:BeginGame()
	SetGlobalInt( "ZMDayTime", CurTime() + self.DefaultDayTime )
	SetGlobalBool( "ZMDayOver", false )

	self:StartDay()
end

function GM:StartDay()

	if GetGlobalInt( "Round" ) > self.MaxDaysPerGame then
		return
	end

	local DayTimes = {
		59,
		self.DefaultDayTime,
		self.DefaultDayTime,
		self.DefaultDayTime+60,
		self.DefaultDayTime+60,
		self.DefaultDayTime+120
	}
	
	SetGlobalInt( "ZMDayTime", CurTime() + DayTimes[GetGlobalInt( "Round" )] )

	SetGlobalBool( "ZMDayOver", false )

	self:SpawnZombies()

	umsg.Start( "ZMShowScores" )
		umsg.Bool( false )
	umsg.End()

	self.GameStarted = true
end

function GM:EndDay()

	SetGlobalInt( "ZMDayTime", CurTime() + 10 )
	SetGlobalBool( "ZMDayOver", true )

	for _, zom in ipairs( ents.FindByClass( "zm_npc_*" ) ) do
		zom:Remove()
	end

	/*for _, equip in ipairs( ents.FindByClass( "zm_item_*" ) ) do
		equip:Remove()
	end*/

	umsg.Start( "ZMShowScores" )
		umsg.Bool( true )
	umsg.End()

end
