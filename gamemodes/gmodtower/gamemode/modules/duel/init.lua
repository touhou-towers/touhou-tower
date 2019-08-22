util.AddNetworkString("StartDuel")
util.AddNetworkString("EndDuel")
util.AddNetworkString("RespawnWinner")
util.AddNetworkString("ClearDeathCheck")
util.AddNetworkString("SuddenDeath")
util.AddNetworkString("InviteDuel")

include("shared.lua")
include("sh_player.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_panel.lua")

/**
 * Hooks into move to set the origin of the player (hack to fix broken SetPos)
*/
hook.Add( "Move", "MoveElevator", function( ply, move )
	if ply.DesiredPosition != nil then
		ply.OldVel = ply:GetVelocity()
		move:SetOrigin( ply.DesiredPosition )
		ply:SetLocalVelocity( ply.OldVel )
		ply.OldVel = nil
		ply.DesiredPosition = nil
	end
end )

local DeathCheck = {}

local SnowSpawnPoints = {
	{Vector(-4850.8125,-8231.9375,409.15625), Angle(0,187.40008544922,0)},
	{Vector(-5493.375,-8315.40625,400.5625), Angle(0,187.40008544922,0)},
	{Vector(-6199.375,-8407.125,391.125), Angle(0,187.40008544922,0)},
	{Vector(-6919.9375,-8438,378.78125), Angle(0,213.36024475098,0)},
	{Vector(-7416.375,-9151.625,355.875), Angle(0,242.62026977539,0)},
	{Vector(-8083.84375,-9914.59375,383.15625), Angle(0,230.740234375,0)},
	{Vector(-7984.25,-10521.34375,313.28125), Angle(0,306.20031738281,0)},
	{Vector(-8170.5625,-11329.21875,441.46875), Angle(0,343.16033935547,0)},
	{Vector(-7441.5,-11350.0625,361.1875), Angle(0,15.500329971313,0)},
	{Vector(-7163.28125,-10943.96875,368.15625), Angle(0,40.360374450684,0)},
	{Vector(-6637.0625,-11160.34375,344.4375), Angle(0,321.38037109375,0)},
	{Vector(-5935.28125,-11744.34375,375.34375), Angle(0,10.000370025635,0)},
	{Vector(-5399.28125,-11367.46875,445.1875), Angle(0,60.820415496826,0)},
	{Vector(-5224.375,-10786.96875,483.6875), Angle(0,101.08046722412,0)},
	{Vector(-5435.15625,-10324.09375,465.375), Angle(0,104.60042572021,0)},
	{Vector(-5634.8125,-9571.0625,502.1875), Angle(0,106.36043548584,0)},
	{Vector(-6294.28125,-9199.625,505.15625), Angle(0,195.90051269531,0)},
	{Vector(-6458.96875,-10027.4375,509.03125), Angle(0,271.80059814453,0)},
	{Vector(-6724.875,-10618.09375,482.71875), Angle(0,218.78062438965,0)},
	{Vector(-6973.78125,-8964.21875,517.65625), Angle(0,26.940263748169,0)},
	{Vector(-4637.71875,-8633,548.75), Angle(0,214.9001159668,0)},
	{Vector(-4980.5,-9481.5625,241.53125), Angle(0,262.86019897461,0)},
	{Vector(-5016.65625,-10761.875,230.78125), Angle(0,267.70016479492,0)},
	{Vector(-5460.96875,-11543.84375,303.59375), Angle(0,168.91996765137,0)},
	{Vector(-6626.5625,-11304.90625,342.125), Angle(0,171.5599822998,0)},
	{Vector(-7135.40625,-10803.3125,376.25), Angle(0,132.61996459961,0)},
	{Vector(-8041,-10248.65625,336.03125), Angle(0,69.699897766113,0)},
	{Vector(-7406.1875,-9232.53125,421.5625), Angle(0,27.459844589233,0)},
	{Vector(-6076.3125,-8362.5,416.78125), Angle(0,3.2598395347595,0)},
	{Vector(-5316.53125,-9853.15625,402.65625), Angle(0,280.75979614258,0)},
	{Vector(-6155,-10332.53125,524.3125), Angle(0,136.43963623047,0)}
}

concommand.Add("gmt_dueldeny",function(ply, cmd, args)
	local Inviter = ents.GetByIndex(args[1])
	if Inviter:GetNWBool("HasSendInvite") then
		Inviter:SetNWBool("HasSendInvite",false)
		Inviter:Msg2(ply:GetName().." has denied your request or has dueling disabled.")
	end
end)

concommand.Add("gmt_duelaccept",function(ply, cmd, args)
	local Inviter = ents.GetByIndex(args[1])
	if Inviter:GetNWBool("HasSendInvite") then
		Inviter:SetNWBool("HasSendInvite",false)

		local InviteItemID = Inviter:GetNWInt("DuelID")
		print(InviteItemID)
		if !Inviter:HasItemById( InviteItemID ) then
			ply:Msg2("The person you've tried to duel with no longer owns the weapon. Duel has been cancelled.")
			return
		end

		for _, SlotList in pairs(Inviter._GtowerPlayerItems) do
			for slot, Item in pairs( SlotList ) do
				if Item.MysqlId == InviteItemID then
					Inviter:InvRemove(slot,true)
					StartDueling(Inviter:GetNWString("DuelWeapon"), Inviter, ply, Inviter:GetNWInt("DuelAmount"))
					return
				end
			end
		end

	end
end)

concommand.Add("gmt_duelinvite",function(ply, cmd, args)

  if #args != 6 then return end

  local Requester =  ents.GetByIndex(args[1])
  local Arriver =  ents.GetByIndex(args[2])
  local Weapon = args[3]
  local Amount = args[4]
	local WeaponName = args[5]
	local WeaponID = math.Round(args[6])

	if !Requester:IsPlayer() and !Arriver:IsPlayer() then return end

	if !Requester:HasItemById( WeaponID ) then return end

	Requester:SetNWBool("HasSendInvite", true)
	Requester:SetNWInt("DuelAmount", Amount)
	Requester:SetNWString("DuelWeapon", Weapon)
	Requester:SetNWInt("DuelID", WeaponID)

  net.Start("InviteDuel")
	net.WriteInt(Amount,32)
	net.WritePlayer(Arriver)
	net.WritePlayer(Requester)
	net.WriteString(WeaponName)
	net.Broadcast()
end)

function GM:EntityTakeDamage( target, dmginfo )
	if ( target:IsPlayer() and dmginfo:GetAttacker():IsPlayer() and target.ActiveDuel and dmginfo:GetAttacker().ActiveDuel and target.Opponent != dmginfo:GetAttacker() ) then
		dmginfo:ScaleDamage( 0.0 ) // Damage is now half of what you would normally take.
	end
end

function StartDueling(Weapon, Requester, Arriver, Amount)

	if !Requester:Alive() then
		Requester:Spawn()
	end

	if !Arriver:Alive() then
		Arriver:Spawn()
	end

	if Requester.BallRaceBall and IsValid( Requester.BallRaceBall ) then
		Requester.BallRaceBall:SetPos(table.Random(SnowSpawnPoints)[1])
	elseif Requester.GolfBall and IsValid( Requester.GolfBall ) then
		Requester.GolfBall:Remove()
		Requester.DesiredPosition = table.Random(SnowSpawnPoints)[1]
	else
		Requester.DesiredPosition = table.Random(SnowSpawnPoints)[1]
	end

	if Arriver.BallRaceBall and IsValid( Arriver.BallRaceBall ) then
		Arriver.BallRaceBall:SetPos(table.Random(SnowSpawnPoints)[1])
	elseif Arriver.GolfBall and IsValid( Arriver.GolfBall ) then
		Arriver.GolfBall:Remove()
		Arriver.DesiredPosition = table.Random(SnowSpawnPoints)[1]
	else
		Arriver.DesiredPosition = table.Random(SnowSpawnPoints)[1]
	end

	for k,v in pairs(player.GetAll()) do
		local SanitizedReq = SafeChatName( Requester:Name() )
		local SanitizedArr = SafeChatName( Arriver:Name() )
		v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedReq..[[ has challenged ]]..SanitizedArr..[[ to a duel for ]]..(Amount or 0)..[[ GMC!", Color(150, 35, 35, 255))]])
	end

	Requester:StripWeapons()
	Arriver:StripWeapons()

	Requester.CanPickupWeapons = true
	Arriver.CanPickupWeapons = true

	Requester:Give(Weapon)
	Arriver:Give(Weapon)

	Requester:SetHealth(300)
	Arriver:SetHealth(300)

	Requester:SetNWBool("IsDueling",true)
	Arriver:SetNWBool("IsDueling",true)

	GiveDuelerAmmo(Requester)
	GiveDuelerAmmo(Arriver)

	Requester:GodDisable()
	Arriver:GodDisable()

	Requester.Opponent = Arriver
	Arriver.Opponent = Requester

	Requester.ActiveDuel = true
	Arriver.ActiveDuel = true
	Requester:SetCustomCollisionCheck(false)
	Arriver:SetCustomCollisionCheck(false)

	timer.Simple(0.5,function()
		Requester:Freeze(true)
		Arriver:Freeze(true)
		GTowerModels.Set( Requester, 1 )
		GTowerModels.Set( Arriver, 1 )
		GTowerModels.Set( Requester, 1 )
		GTowerModels.Set( Arriver, 1 )
	end)

	timer.Simple(7,function()
		Requester:Freeze(false)
		Arriver:Freeze(false)
		Requester.CanPickupWeapons = false
		Arriver.CanPickupWeapons = false
	end)

	local CurPlayers = { Requester, Arriver }

	table.Add( DeathCheck , CurPlayers )

	net.Start( "StartDuel" )
	net.WriteInt( Amount, 32 )
	net.WritePlayer( Requester )
	net.WritePlayer( Arriver )
	net.Broadcast()
end

function GiveDuelerAmmo(ply)
  ply:GiveAmmo( 250, "SMG1", true )
  ply:GiveAmmo( 250, "AR2", true )
  ply:GiveAmmo( 250, "AlyxGun", true )
  ply:GiveAmmo( 250, "Pistol", true )
  ply:GiveAmmo( 250, "SMG1", true )
  ply:GiveAmmo( 250, "357", true )
  ply:GiveAmmo( 250, "XBowBolt", true )
  ply:GiveAmmo( 250, "Buckshot", true )
  ply:GiveAmmo( 250, "RPG_Round", true )
  ply:GiveAmmo( 250, "SMG1_Grenade", true )
  ply:GiveAmmo( 250, "SniperRound", true )
  ply:GiveAmmo( 250, "SniperPenetratedRound", true )
  ply:GiveAmmo( 250, "Grenade", true )
  ply:GiveAmmo( 250, "Trumper", true )
  ply:GiveAmmo( 250, "Gravity", true )
  ply:GiveAmmo( 250, "Battery", true )
  ply:GiveAmmo( 250, "GaussEnergy", true )
  ply:GiveAmmo( 250, "CombineCannon", true )
  ply:GiveAmmo( 250, "AirboatGun", true )
  ply:GiveAmmo( 250, "StriderMinigun", true )
  ply:GiveAmmo( 250, "HelicopterGun", true )
  ply:GiveAmmo( 250, "AR2AltFire", true )
  ply:GiveAmmo( 250, "slam", true )
end

hook.Add( "PostPlayerDeath", "DuelDeathCheck", function(ply)
  if !table.HasValue(DeathCheck,ply) then return end

  net.Start("EndDuel")
  net.WritePlayer(ply)
	net.WriteBool(false)
  net.Broadcast()

end)

hook.Add( "PlayerDisconnected", "DisconnectDeathCheck", function(ply)
  if !table.HasValue(DeathCheck,ply) then return end

	table.RemoveByValue(DeathCheck, ply)

  net.Start("EndDuel")
  net.WritePlayer(ply)
	net.WriteBool(true)
  net.Broadcast()

end)

net.Receive("RespawnWinner",function()
  local ply = net.ReadEntity()
  timer.Simple(5,function()
    ply:StripWeapons()
    ply.DesiredPosition = Vector(1600,-3760,-192)
    ply:SetEyeAngles(Angle(0, -90, 0))
  end)
end)

net.Receive("SuddenDeath",function()
	local ply = net.ReadEntity()
	local Opponent = net.ReadEntity()
	local RandKill = net.ReadInt(3)

	if RandKill == 1 then
		ply:Kill()
	else
		Opponent:Kill()
	end

end)

net.Receive("ClearDeathCheck",function()
  local ply = net.ReadEntity()
	local ByDisconnect = net.ReadBool()
  local Opponent = net.ReadEntity()
	local Amount = net.ReadInt(32)

	if Amount > 0 then

		if !ByDisconnect then

			ply.ActiveDuel = false
			Opponent.ActiveDuel = false
			ply:SetCustomCollisionCheck(true)
			Opponent:SetCustomCollisionCheck(true)

		local OpponentMoney = Opponent:Money()

		if OpponentMoney <= Amount then
			ply:AddMoney(OpponentMoney)
			if !ByDisconnect then
			Opponent:AddMoney(-OpponentMoney)
			end
		else
			ply:AddMoney(Amount)
		end

		if !ByDisconnect then
		Opponent:AddMoney(-Amount)
		end

		end

		if ByDisconnect then

			ply:SetHealth(100)
			ply.ActiveDuel = false
			ply:SetCustomCollisionCheck(true)

			for k,v in pairs(player.GetAll()) do
				local Sanitized = SafeChatName( ply:Name() )
				v:SendLua([[GTowerChat.Chat:AddText("]]..Sanitized..[[ has won the duel!", Color(150, 35, 35, 255))]])
			end

		else

			ply.ActiveDuel = false
			ply:SetCustomCollisionCheck(true)
			ply:SetHealth(100)
			Opponent:SetHealth(100)
			Opponent.ActiveDuel = false
			Opponent:SetCustomCollisionCheck(true)

		for k,v in pairs(player.GetAll()) do
			local SanitizedPly = SafeChatName( ply:Name() )
			local SanitizedOpp = SafeChatName( Opponent:Name() )
			v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedPly..[[ has won the duel with ]]..SanitizedOpp..[[, winning ]]..Amount..[[ GMC!", Color(150, 35, 35, 255))]])
		end

		end
	else

		if ByDisconnect then

			if ply:GetNWBool("IsDueling") then
				ply:SetNWBool("IsDueling",false)
				ply.ActiveDuel = false
				ply:SetCustomCollisionCheck(true)
			end

			for k,v in pairs(player.GetAll()) do
				local SanitizedPly = SafeChatName( ply:Name() )
				v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedPly..[[ has won the duel!", Color(150, 35, 35, 255))]])
			end

		else

			if ply:GetNWBool("IsDueling") then
				ply:SetNWBool("IsDueling",false)
				ply.ActiveDuel = false
				ply:SetCustomCollisionCheck(true)
			end

			if Opponent:GetNWBool("IsDueling") then
				Opponent:SetNWBool("IsDueling",false)
				Opponent.ActiveDuel = false
				Opponent:SetCustomCollisionCheck(true)
			end

			for k,v in pairs(player.GetAll()) do
				local SanitizedPly = SafeChatName( ply:Name() )
				local SanitizedOpp = SafeChatName( Opponent:Name() )
				v:SendLua([[GTowerChat.Chat:AddText("]]..SanitizedPly..[[ has won the duel with ]]..SanitizedOpp..[[!", Color(150, 35, 35, 255))]])
			end

		end

	end

  if table.HasValue(DeathCheck, ply) then
    table.RemoveByValue(DeathCheck, ply)
  end

	if ByDisconnect then return end

  if table.HasValue(DeathCheck, Opponent) then
    table.RemoveByValue(DeathCheck, Opponent)
  end

end)

hook.Add("PlayerResize","SizeResetNarnia",function(ply,size)
	if ply.ActiveDuel then GTowerModels.Set( ply, 1 ) end
end)
