
-----------------------------------------------------
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName			= "Texas Hold 'Em"
ENT.Author				= "mitterdoo + Macklin Guy"
ENT.Purpose				= "GMod Tower"
ENT.Spawnable			= true
ENT.AdminSpawnable		= true

// NOTE: If you are going to get the player count (#self.Players) use table.Count(self.Players)
// The # operator doesn't count gaps in tables so just use that.

ENT.Model				= Model( "models/gmod_tower/aigik/pokertable.mdl" )

ENT.GameTitle   		= "Poker - Texas Hold 'Em"
ENT.MaxRounds 			= 3
ENT.MinPlayers  		= 2
ENT.MaxPlayers  		= 5

ENT.MaxPlayerDelays   	= 2 // AFK kickout
ENT.MaxPlayerRejoins    = 5 // Prevent players from grief joining/leaving

ENT.DefaultMinBet 		= 5
ENT.DefaultMaxBet 		= 50

ENT.StartDelay  		= 20

ENT.BetTime 			= 20

ENT.States   			= {
	NOPLAY = 0,
	STARTING = 1,
	DEAL = 2,
	BET1 = 3,
	FLOP = 4,
	BET2 = 5,
	TURN = 6,
	BET3 = 7,
	RIVER = 8,
	BET4 = 9,
	REVEAL = 10,
	END = 11,
}

ENT.StateNames = {
	[ENT.States.STARTING] = "Starting...",
	[ENT.States.DEAL] = "Deal",
	[ENT.States.BET1] = "Bet",
	[ENT.States.FLOP] = "Flop",
	[ENT.States.BET2] = "Second Bet",
	[ENT.States.TURN] = "Turn",
	[ENT.States.BET3] = "Third Bet",
	[ENT.States.RIVER] = "River",
	[ENT.States.BET4] = "Final Bet",
	[ENT.States.REVEAL] = "Reveal"
}

ENT.Hands = { // 4 bits
	HOLE = 0,
	COMMUNITY = 1,
}

ENT.Network 			= { // 5 bits
	JOIN = 0,
	LEAVE = 1,
	ACTION = 2,
	WINNER = 3,
	IN = 4,
	NEW = 5,
	CLEAR = 6,
	COMMUNITY = 7,
	REVEAL = 8,
}

ENT.Actions 			= { // 4 bits
	NONE = 0,
	FOLD = 1,
	FOLDAUTO = 2,
	CALL = 3,
	RAISE = 4,
	ALLIN = 5,
}

ENT.Sounds 				= {
	// File/Pattern, Amount
	WIN = { "GModTower/casino/cards/win", 2 }, // MP3
	LOSE = { "GModTower/casino/cards/lose", 2 }, // MP3
	SHUFFLE = "GModTower/casino/cards/shufflecards01.wav",
}

ENT.Music 				= {
	// File, Duration
	{ "GModTower/casino/cards/round1.mp3", 60 + 16 },
	{ "GModTower/casino/cards/round2.mp3", 60 + 37 },
	{ "GModTower/casino/cards/round3.mp3", 60 * 2 + 13 },
	{ "GModTower/casino/cards/round4.mp3", 60 },
}

function ENT:SetupDataTables()

	self:NetworkVar( "Int", 0, "State" )
	self:NetworkVar( "Int", 1, "Pot" )
	self:NetworkVar( "Int", 2, "CurrentPlayerID" )
	self:NetworkVar( "Int", 3, "MinBet" )
	self:NetworkVar( "Int", 4, "MaxBet" )

	self:NetworkVar( "Float", 0, "Time" )

	--self:NetworkVar( "Bool", 0, "Tournament" )
	--self:NetworkVar( "Int", 5, "BuyIn" )
	--self:NetworkVar( "Int", 6, "GrandPrize" )

	self.GetMinBlind = self.GetMinBet
	self.GetMaxBlind = self.GetMaxBet
	self.SetMinBlind = self.SetMinBet
	self.SetMaxBlind = self.SetMaxBet	

end

function ENT:GetTournament()
	return false
end

function ENT:GetGrandPrize()
	return false
end

function ENT:GetStateName()

	local state = self:GetState()
	return self.StateNames[state] or self.GameTitle

end

function ENT:GetActionName( action )

	if action == self.Actions.FOLD then return "FOLDED" end
	if action == self.Actions.FOLDAUTO then return "FOLDED (AUTO)" end
	if action == self.Actions.ALLIN then return "ALL IN" end
	if action == self.Actions.CALL then return "CALLED" end
	if action == self.Actions.RAISE then return "RAISED" end
	if action == self.Actions.DISCARD then return "DISCARDED" end

	return nil

end

function ENT:GetAction( ply )
	if !IsValid( ply ) then return 0 end
	return ply._PAction or 0
end

function ENT:GetTimeLeft()
	return math.ceil( ( self:GetTime() or 0 ) - CurTime() )
end

function ENT:GetStateTitle()

	local title = self:GetStateName()

	if self:GetState() != self.States.NOPLAY && self:GetTimeLeft() > 0 then
		return title .. " | " .. self:GetTimeLeft()
	end

	return title

end

function ENT:GetCurrentPlayer()

	if CLIENT then
		tbl = self.Players
	else
		tbl = self.OriginalPlayers
	end

	return tbl[self:GetCurrentPlayerID()]

end

function ENT:StateHasTurns()
	return self:GetState() == self.States.BET1 || self:GetState() == self.States.BET2 || self:GetState() == self.States.BET3 || self:GetState() == self.States.BET4
end
ENT.StateIsBet = ENT.StateHasTurns

function ENT:StatePlaying()
	return self:GetState() != self.States.NOPLAY && self:GetState() != self.States.STARTING
end

function ENT:IsInGame( ply )
	return table.HasValue( self.Players, ply )
end

function ENT:ScoreHand( hand, community )

	if !hand or !community then return end
	local scored = Cards.Hand()
	for k, v in pairs( hand.cards ) do
		table.insert( scored.cards, v )
	end
	for k, v in pairs( community.cards ) do
		if v.value == 1 then continue end
		table.insert( scored.cards, v )
	end
	scored:Evaluate()
	return scored

end

function ENT:GetHandScore( hand, community )
	local scored = self:ScoreHand( hand, community )
	return Cards.rankstrings[scored.hand] .. " (" .. Cards.cardstrings[scored.score] .. " High)"
end

function ENT:GetScoredHand( hand, community )
	local scored = self:ScoreHand( hand, community )
	local final = Cards.Hand()
	for k, v in pairs( scored.winningHand ) do
		table.insert( final.cards, v )
	end
	for k, v in pairs( scored.kickers ) do
		table.insert( final.cards, v )
	end
	return final
end

function ENT:GetIn( ply )
	return ply._PIn or 0
end

function ENT:SetIn( ply, amt, network )

	ply._PIn = amt

	if network && SERVER then

		net.Start( "ClientPoker" )
			net.WriteEntity( self )
			net.WriteEntity( ply )
			net.WriteInt( self.Network.IN, 4 )
			net.WriteInt( self:GetIn( ply ), 32 )
		net.Send( Location.GetPlayersInLocation( self:Location() ) )

	end

end

function ENT:GetTopBet()

	local top = 0
	for _, ply in pairs( self.Players ) do

		if IsValid( ply ) && self:IsInGame( ply ) then

			if self:GetIn( ply ) > top then
				top = self:GetIn( ply )
			end

		end

	end

	return top

end

function ENT:SetMinMaxBet( min, max )
	self:SetMinBet( min or self.DefaultMinBet )
	self:SetMaxBet( max or self.DefaultMaxBet )
end

function ENT:CanUse( ply )
	return true, "PLAY"
end

ImplementNW() -- Implement transmit tools instead of DTVars