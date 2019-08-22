
-----------------------------------------------------
ENT.Type 			= "anim"
ENT.Base 			= "base_anim"
ENT.PrintName		= "Money Button"

--Settings
ENT.MaxUseDist 		= 60	--How close you have to be to use the button
ENT.ChargeTimer		= 10 	--Charge time in seconds
ENT.Payout 			= 1 	--Payout in GMC per charge

--Model to use
ENT.Model 			= Model( "models/gmod_tower/podium_button.mdl")

--Model offsets
ENT.MeterHeight 	= 32.5 	--How high the meters should go
ENT.MeterVOffset 	= 3.5	--How far up from the origin the meters should be
ENT.MeterHOffset 	= 3.25 	--How far out from the origin the meters should render

--Shake parameters for when the button is charging up
ENT.ShakeRange 		= 256
ENT.ShakeAmp 		= 12
ENT.ShakeFrequency 	= 10

--Can players share the button
ENT.EnableHandoff 	= true

--OPTIONAL: Increase the charge time in tandem with the payout on each use
ENT.Inflation		= false
ENT.InflationRate	= 0.01 --x = x * (1 + InflationRate)

--Sounds to use
ENT.Sounds = {
	["cancel"] 		= "GModTower/podium_button/cancel.wav",
	["charge"] 		= "GModTower/podium_button/charge.mp3",
	["press"] 		= "GModTower/podium_button/press.wav",
	["release"] 	= "GModTower/podium_button/release.wav",
}

--Sound range
ENT.SoundLevel 		= 60

ENT.SoundScripts = {}

--Network Vars
function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Pressed" )			--Is the button currently pressed?
	self:NetworkVar( "Float", 0, "ChargeTime" )		--When was it pressed
	self:NetworkVar( "Float", 1, "ChargeDuration" )	--How long ya have to hold it
	self:NetworkVar( "Entity", 0, "UsePlayer" )		--Who's pressing it
	self:NetworkVar( "Entity", 1, "NextUsePlayer" )	--Who's the next in line to hold it

end

--Multiplier for charge sound pitch
function ENT:ChargeMultiplier()
	return 1 / (self:GetChargeDuration() / 10)
end

--Returns remaining charge time
function ENT:GetChargeRemaining()

	local chargeRemain = self:GetChargeTime() - CurTime()
	return math.max( 0, chargeRemain )

end

--Returns fractional amount charged
function ENT:GetChargeFraction()

	local fraction = 1 - ( self:GetChargeRemaining() / self:GetChargeDuration() )
	if (not self:GetPressed()) or fraction == 1 then fraction = 0 end
	return fraction

end

--Test to see if the player is in range and is looking at the button
function ENT:TestPlayerTrace( ply )

	--Trace test along eye vector
	local tr = util.TraceLine( {
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * self.MaxUseDist,
		filter = function( ent ) return ent == self end,
	} )

	return tr.Entity == self

end

--Init all sound scripts
function ENT:InitSounds()

	for k,v in pairs( ENT.Sounds ) do ENT:SoundScript( k ) end

end

--Creates a sound script which enables starting and stopping sounds
function ENT:SoundScript( name )

	local soundname = "gmt_podium_button_" .. name
	sound.Add( {
		name = soundname,
		channel = CHAN_AUTO,
		volume = 1.0,
		level = self.SoundLevel,
		pitch = 100,
		sound = ENT.Sounds[name],
	})

	ENT.SoundScripts[name] = Sound( soundname )

end

--ImplementNW() -- Implement transmit tools instead of DTVars
