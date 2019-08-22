
-----------------------------------------------------
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName			= "Poker"
ENT.Author				= "Macklin Guy"
ENT.Purpose				= "GMod Tower"
ENT.Spawnable			= true
ENT.AdminSpawnable		= true

// NOTE: If you are going to get the player count (#self.Players) use table.Count(self.Players)
// The # operator doesn't count gaps in tables so just use that.

ENT.Model				= Model( "models/gmod_tower/aigik/pokertable.mdl" )

ENT.GameTitle   		= "Poker - 5 Card Draw"
ENT.MaxRounds 			= 3
ENT.MinPlayers  		= 2
ENT.MaxPlayers  		= 5

ENT.MaxPlayerDelays   	= 2 // AFK kickout
ENT.MaxPlayerRejoins    = 5 // Prevent players from grief joining/leaving

ENT.DefaultMinBet 		= 5
ENT.DefaultMaxBet 		= 50

ENT.StartDelay  		= 20

ENT.BetTime 			= 20
ENT.DrawTime 			= 20

ENT.States   			= {
	NOPLAY = 0,
	STARTING = 1,
	DEAL = 2,
	BET = 3,
	DRAW = 4,
	BETFINAL = 5,
	REVEAL = 6,
	END = 7,
}

ENT.Network 			= { // 4 bits
	JOIN = 0,
	LEAVE = 1,
	ACTION = 2,
	WINNER = 3,
	IN = 4,
	NEW = 5,
	CLEAR = 6,
}

ENT.Actions 			= { // 4 bits
	NONE = 0,
	FOLD = 1,
	FOLDAUTO = 2,
	CALL = 3,
	RAISE = 4,
	DISCARD = 5,
	ALLIN = 6,
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
	self:NetworkVar( "Int", 1, "Time" )
	self:NetworkVar( "Int", 2, "Pot" )
	self:NetworkVar( "Int", 3, "CurrentPlayerID" )
	self:NetworkVar( "Float", 0, "Round" )
	self:NetworkVar( "Float", 1, "MinBet" )
	self:NetworkVar( "Float", 2, "MaxBet" )

end

function ENT:GetStateName()

	local state = self:GetState()

	if state == self.States.STARTING then return "Starting..." end
	if state == self.States.DEAL then return "Deal" end
	if state == self.States.BET then return "Bet" end
	if state == self.States.DRAW then return "Draw" end
	if state == self.States.BETFINAL then return "Final Bet" end
 	if state == self.States.REVEAL then return "Reveal" end

	return self.GameTitle

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
	return self:GetState() == self.States.BET || self:GetState() == self.States.BETFINAL
end

function ENT:StatePlaying()
	return self:GetState() != self.States.NOPLAY && self:GetState() != self.States.STARTING
end

function ENT:IsInGame( ply )
	return table.HasValue( self.Players, ply )
end

function ENT:GetHandScore( hand )
	return Cards.rankstrings[hand.hand] .. " (" .. Cards.cardstrings[hand.score] .. " High)"
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
