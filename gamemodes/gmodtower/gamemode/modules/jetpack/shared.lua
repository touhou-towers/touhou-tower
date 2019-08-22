local MOVETYPE_NONE = MOVETYPE_NONE
local SERVER = SERVER
local IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT, IN_DUCK, IN_JUMP = IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT, IN_DUCK, IN_JUMP
local Angle = Angle
local FrameTime = FrameTime
local _G = _G
local CurTime = CurTime
local math = math
local hook = hook
local IsValid = IsValid
local NoVector = Vector(0,0,0)
local meta = FindMetaTable( "Player" )
local print = print

module("jetpack", package.seeall)

local function CalculateAccumulatedFuelRemaining( ply, state )
	local JetPack = ply:GetJetpack()
	if !JetPack then return 1 end

	local availableFuel = JetPack.JetpackFuel
	if JetPack.JetpackFuel == -1 then
			ply._DisplayFuelAmount = 1
			return 1
	end

	local flightTime = state._AccumulatedFlightTime or 0

	if state._InJetpackFlight then
		flightTime = flightTime + engine.TickInterval()
	else
		local rechargeTime = (state._JetpackFlightEnd or 0) + JetPack.JetpackStartRecharge
		if CurTime() >= rechargeTime then
			local rechargeTime = (engine.TickInterval() * (1/JetPack.JetpackRecharge))
			flightTime = math.max(0, flightTime - rechargeTime)
		end
	end

	state._AccumulatedFlightTime = flightTime
	ply._DisplayFuelAmount = (availableFuel - flightTime) / availableFuel
	return availableFuel - flightTime
end

local function JetpackBegin( ply )
	ply:SetNWFloat("JetpackStart", CurTime())
	ply:SetNWBool("IsJetpackOn", true)
end

local function JetpackEnd( ply )
	ply:SetNWFloat("JetpackStart", 0)
	ply:SetNWBool("IsJetpackOn", false)
end

local function GetRollingState( ply )
	local t = CurTime()

	if not ply._LatestMoveState or t > ply._LatestMoveState then
		if not ply._MoveStateData then ply._MoveStateData = {} end
		ply._LatestMoveState = t

		for time, data in pairs(ply._MoveStateData) do
			if time < (t - 2) then
				ply._MoveStateData[time] = nil
			end
		end
	end

	local isFirstPredicted = false

	if t < ply._LatestMoveState then
		for time, data in pairs(ply._MoveStateData) do
			if time >= t then
				ply._MoveStateData[time] = nil
			end
		end
	else
		isFirstPredicted = true
	end

	return isFirstPredicted, ply._MoveStateData[table.maxn(ply._MoveStateData)] or {}
end

local function CommitRollingState( ply, data )
	local t = CurTime()
	ply._MoveStateData[t] = {}
	for k, v in pairs(data) do
		ply._MoveStateData[t][k] = v
	end
end

local function JetpackMove( ply, mv, state, firstPredicted )

	if !IsValid(ply) then return end

	if ply:GetMoveType() == MOVETYPE_NONE then
		mv:SetVelocity(NoVector)
		return
	end

	local Jetpack = ply:GetJetpack()

	if !Jetpack || ply._DisabledJetpack == true then
		return
	end

	local fuelRemaining = CalculateAccumulatedFuelRemaining( ply, state )

	if not ply:KeyDown( IN_JUMP ) or fuelRemaining <= 0 then
		if state._InJetpackFlight then
			JetpackEnd( ply )
			state._InJetpackFlight = false
			state._JetpackFlightEnd = CurTime()
		end
		return
	end

	local vel = mv:GetVelocity()
	local onGround = ply:IsOnGround()
	local mang = mv:GetMoveAngles()
	local fwd = mang:Forward()
	local right = mang:Right()
	fwd.z, right.z = 0, 0

	local power = Jetpack.JetpackPower

	if power > 1 && Jetpack.JetpackFuel == -1 && (ply:IsVIP() or ply:IsAdmin()) then
		power = math.Clamp( ply:GetInfoNum( "gmt_jetpackpower", 1 ), 1, 4.0 )
	end

	local flightVector = Vector(0,0,0)
	local directionalPower = 150 * power
	local upPower = 700

	if ply:KeyDown( IN_DUCK ) and not onGround then
		directionalPower = 2000
		upPower = 550
	end

	if not onGround and power < 1 then
		upPower = upPower * power
	end

	if not state._InJetpackFlight then
		JetpackBegin( ply )
		state._InJetpackFlight = true

		if onGround then
			directionalPower = directionalPower * Jetpack.ExtraOnFloor
			upPower = upPower * Jetpack.ExtraOnFloor
		end
	end
	if not state._InJetpackFlight and onGround then

	end

	fwdVector = (fwd * math.Clamp(mv:GetForwardSpeed(), -1, 1) * directionalPower * FrameTime())
	rightVector = (right * math.Clamp(mv:GetSideSpeed(), -1, 1) * directionalPower * FrameTime())
	flightVector = flightVector + fwdVector + rightVector + (Vector(0,0,1) * upPower * FrameTime())

	local maxvel = 1600
	if vel:Length() > maxvel then
		flightVector = flightVector - (vel * ( (vel:Length() - maxvel) / vel:Length() ) )
	end

	mv:SetVelocity(vel + flightVector)
end

local function JetpackMoveOuter( ply, mv )
	local firstPredicted, state = GetRollingState( ply )
	JetpackMove( ply, mv, state, firstPredicted )
	CommitRollingState( ply, state )
end

function meta:GetJetpack()
	return GetJetpack( self )
end

if engine.ActiveGamemode() == "gmodtowerlobby" then
	hook.Add("Move", "JetpackMove", JetpackMoveOuter )
end
