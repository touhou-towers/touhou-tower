AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

/*---------------------------------------------------------
	Basics
---------------------------------------------------------*/
function ENT:Initialize()

	self.BetAmount = 10
	self.SlotsPlaying = nil
	self.SlotsSpinning = false
	self.LastSpin = CurTime()

	self:SetModelScale(0.7,0)

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow( false )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
		phys:Sleep()
	end

	self:SetJackpot(250)

end


function ENT:Think()

	// Player In Chair Check
	if !self.SlotsPlaying && self:IsInUse() then		// Game not in play, player in chair
		self:SendPlaying()
	elseif self.SlotsPlaying && !self:IsInUse() then	// Game in play, nobody in chair
		self.SlotsPlaying = nil
	end
	if self.CurPlayer then // Stops the game when you walk away
		if(self.CurPlayer:GetPos():Distance(self:GetPos()) > 75) then
			umsg.Start("slotsPlayingMini")
			umsg.End()
			self.CurPlayer.SeatEnt = nil
			self.CurPlayer.EntryPoint = nil
			self.CurPlayer.EntryAngles = nil
			self.CurPlayer.SlotMachine = nil
			timer.Simple(0.1,function()
				self.CurPlayer = nil
			end)
		end
	end

	// Player Idling Check
	if ( self.LastSpin + (60*3) < CurTime() ) && self:IsInUse() then
		local ply = self:GetPlayer()
		ply:ExitVehicle()
		//GAMEMODE:PlayerMessage( ply, "Slots", "You have been ejected due to idling!" )
	end

	if ( self.Jackpot && self.Jackpot < CurTime() ) then
		self.Jackpot = nil
	end

	self:NextThink(CurTime()) // Don't change this, the animation requires it

	return true
end


function ENT:IsInUse()

	if IsValid(self.chair) && self.chair:GetDriver():IsPlayer() then
		return true
	else
		return false
	end

end

/*---------------------------------------------------------
	Initial Player Interaction
---------------------------------------------------------*/
function ENT:Use( ply )

	if !IsValid(ply) || !ply:IsPlayer() then
		return
	end

	if !self.CurPlayer then
		self:SendPlaying( ply )
		umsg.Start("slotsPlayingMini", ply)
		umsg.End()
	else
		return
	end

end

/*---------------------------------------------------------
	Console Commands
---------------------------------------------------------*/
concommand.Add( "slotm_spin", function( ply, cmd, args )
	local bet = tonumber(args[1]) or 10
	local ent = ply.SlotMachine

	if !ply:Afford( bet ) && IsValid(ent) && !ent.SlotsSpinning && !ent.Jackpot then
		ply:MsgT( "SlotsNoAfford" )
	else
		if IsValid(ent) && !ent.SlotsSpinning && !ent.Jackpot then
			ply:AddMoney(-bet)
			ent.LastSpin = CurTime()
			ent.BetAmount = bet
			ent:PullLever()
			ent:PickResults()

			local bzr = ents.Create("gmt_money_bezier")

			if IsValid( bzr ) then
				bzr:SetPos( ply:GetPos() - Vector(0,0,10) )
				bzr.GoalEntity = ent
				bzr.GMC = bet
				bzr.RandPosAmount = 0
				bzr:Spawn()
				bzr:Activate()
				bzr:Begin()
			end

		end
	end
end )

/*---------------------------------------------------------
	Slot Machine Functions
---------------------------------------------------------*/
function ENT:GetPlayer()

	local ply = player.GetByID( self.SlotsPlaying )

	if IsValid(ply) && ply:IsPlayer() && self:IsInUse() then
		return ply
	end


end

function ENT:SendPlaying( ply )

	if ( !IsValid( self ) ) then return end

	self.CurPlayer = ply
	self.SlotsPlaying = ply:EntIndex()
	self.LastSpin = CurTime()

	--local ply = self:GetPlayer()
	ply.SlotMachine = self

	local rf = RecipientFilter()
	rf:AddPlayer( ply )

	umsg.Start("slotsPlayingMini", rf)
		umsg.Short( self:EntIndex() )
	umsg.End()

end


function ENT:PullLever()

	local seq = self:LookupSequence("pull_handle")

	if seq == -1 then return end

	self:ResetSequence(seq)

end


function ENT:PickResults()

	self.SlotsSpinning = true

	local rf = RecipientFilter()
	//rf:AddPlayer( self:GetPlayer() )
	rf:AddAllPlayers()

	local random = { getRand(), getRand(), getRand() }

	umsg.Start("slotsResultMini", rf)
		umsg.Short( self:EntIndex() )
		umsg.Short( random[1] )
		umsg.Short( random[2] )
		umsg.Short( random[3] )
	umsg.End()

	self:EmitSound( Casino.SlotPullSound, 60, 145 )

	timer.Simple( Casino.SlotSpinTime[3], function()
		self:CalcWinnings( random )
	end )

	// Prevent spin button spam
	timer.Simple( Casino.SlotSpinTime[3] + 1, function()
		self.SlotsSpinning = false
	end )
end

// Ranked highest to lowest
ENT.ExactCombos = {
	["6"] = { 2, 2, 2 }, //Jackpot?
	["5.5"] = { 1, 1, 1 },
	["5"] = { 3, 3, 3 },
	["4.5"] = { 4, 4, 4 },
	["4"] = { 5, 5, 5 },
	["3.5"] = { 6, 6, 6 },
}

ENT.AnyTwoCombos = {
	["2.5"] = 2,
}

function ENT:CalcWinnings( random )

	if !self.CurPlayer then
		return
	end

	local ply = self.CurPlayer
	local winnings = 0

	// Jackpot
	if table.concat(random) == "222" then
		local winnings = math.Round( self:GetJackpot() + self.BetAmount )
		self:SendWinnings( ply, winnings, true )

		self:SetJackpot(1000)

		return
	end

	// Exact Combos
	for x, combo in pairs( self.ExactCombos ) do
		if table.concat(random) == table.concat(combo) then
			local winnings = math.Round( self.BetAmount * tonumber(x) )
			self:SendWinnings( ply, winnings )
			return
		end
	end

	// Any Two Combos
	for x, combo in pairs( self.AnyTwoCombos ) do
		if random[3] == combo then
			local winnings = math.Round( self.BetAmount * tonumber(x) )
			self:SendWinnings( ply, winnings )
			return
		end
	end

	// Player lost
	self:SetJackpot( self:GetJackpot() + self.BetAmount )
	print(self:GetJackpot())
	ply:MsgT( "SlotsLose" )

end

function ENT:BroadcastJackpot(ply, amount)
	for _, v in ipairs(player.GetAll()) do
		if v != ply then
			v:MsgT( "SlotsJackpotAll", ply:Name(), amount )
		end
	end
end

function ENT:SendWinnings( ply, amount, bJackpot )

	if bJackpot then
		self:BroadcastJackpot(ply, amount)
		ply:MsgT( "SlotsJackpot" )
		ply:AddMoney(amount,true)
		self:EmitSound( Casino.SlotJackpotSound, 100, 100 )
		self.Jackpot = CurTime() + 25

		timer.Create("JackpotFun",0.25,50,function()

			local bzr = ents.Create("gmt_money_bezier")

			if IsValid( bzr ) then
				bzr:SetPos( self:GetPos() )
				bzr.GoalEntity = ply
				bzr.GMC = 50
				bzr.RandPosAmount = 5
				bzr:Spawn()
				bzr:Activate()
				bzr:Begin()
			end

		end)

	else
		self:EmitSound( Casino.SlotWinSound, 75, 125 )
		ply:MsgT( "SlotsWin", amount )
		ply:AddMoney(amount,true)

		local bzr = ents.Create("gmt_money_bezier")

		if IsValid( bzr ) then
			bzr:SetPos( self:GetPos() )
			bzr.GoalEntity = ply
			bzr.GMC = amount
			bzr.RandPosAmount = 10
			bzr:Spawn()
			bzr:Activate()
			bzr:Begin()
		end

	end

	--GAMEMODE:Payout( ply, amount )

	//ParticleEffect( "coins", self:GetPos(), self:GetForward(), self )

end
