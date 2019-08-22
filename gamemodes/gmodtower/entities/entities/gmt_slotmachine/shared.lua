
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName		= "Slot Machine"
ENT.Author			= "Sam"
ENT.Contact			= ""
ENT.Purpose			= "GMT"
ENT.Instructions	= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.AutomaticFrameAdvance = true

ENT.Model			= Model( "models/gmod_tower/casino/slotmachine.mdl")
ENT.LightModel		= Model( "models/props/de_nuke/emergency_lighta.mdl" )
//ENT.ChairModel		= Model( "models/props_c17/chair_stool01a.mdl")
ENT.ChairModel		= Model( "models/gmod_tower/medchair.mdl" )
ENT.IconPitches = {
	[1] = -180,	// Bell 
	[2] = -120,	// Community Logo
	[3] = -60,	// Lemon
	[4] = 0,	// Strawberry
	[5] = 60,	// Watermelon
	[6] = 120	// Cherry
}

// Need to move these elsewhere?
Casino = {}
Casino.SlotSpinTime = { 0.8, 1.6, 2.4 }
Casino.SlotsLocalBet = 10
Casino.SlotsMinBet = 5
Casino.SlotsMaxBet = 800
//Casino.SlotGameSound = Sound( /* NEED A SOUND HERE */ )
Casino.SlotSelectSound = Sound( "buttons/lightswitch2.wav" )
Casino.SlotPullSound = Sound( "GModTower/casino/slots/slotpull.wav" )
Casino.SlotWinSound = Sound( "GModTower/casino/slots/winner.wav" )
Casino.SlotSpinSound = Sound( "GModTower/casino/slots/spin_loop1.wav" )
Casino.SlotJackpotSound = "GModTower/casino/slots/you_win_forever.mp3"

function ENT:SetupDataTables()
	self:DTVar("Int", 0, "Jackpot")
end

local potsizes = { 8000, 5000, 2500, 2000, 1500 }
function ENT:GetRandomPotSize()
	return table.Random( potsizes )
end

function getRand()
	return math.random(1,6)
end

/*---------------------------------------------------------
	Jackpot
---------------------------------------------------------*/
function ENT:SetJackpot( amount )
	SetGlobalInt( "Jackpot", amount )
	--self.dt.Jackpot = amount
end


function ENT:GetJackpot()
	return GetGlobalInt( "Jackpot" )
	--return self.dt.Jackpot
end