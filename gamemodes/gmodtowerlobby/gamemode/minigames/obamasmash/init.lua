AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include("shared.lua")

//local umsg, math, ents, timer, table = umsg, math, ents, timer, table
//local hook, util = hook, util
//local Msg = Msg
//local Vector = Vector
local hook, string = hook, string
local umsg = umsg
local player = player
local table = table
local timer = timer
local ents  = ents
local math = math
local pairs = pairs
local IsValid = IsValid
local VectorRand = VectorRand
local Vector = Vector
local Angle = Angle
local SafeCall = SafeCall
local _G = _G
local print = print
local CurTime = CurTime
local ACHIVEMENTS = ACHIVEMENTS
local GTowerLocation = GTowerLocation
local EffectData = EffectData
local util = util

local OBAMA_GAME_ACTIVE = false

module("minigames.obamasmash" )

TotalMoney = 0
ObamaCount = 0
MoneyPerKill = 3

function GiveWeapon( ply )

	if !ply:HasWeapon( WeaponName ) then
		ply.CanPickupWeapons = true
		ply:Give( WeaponName )
		ply:SelectWeapon( WeaponName )
		ply.CanPickupWeapons = false
	end

end

function CheckGiveWeapon( ply, loc )

	if loc == MinigameLocation  then
		GiveWeapon( ply )
	else
		RemoveWeapon( ply )
	end

end

function RemoveWeapon( ply )
	--if ply:HasWeapon(WeaponName) && ply:GetSetting( "GTAllowWeapons" ) == false && !ply:IsAdmin() then
	if ply:HasWeapon(WeaponName) then
		ply:StripWeapons()
	end
end

function PlayerDissallowResize( ply )
	if !ply:IsAdmin() then
		return false
	end
end

local function ObamaBounds()

	local entities = ents.FindInSphere(Vector(4512.097656, -10177.549805, 4096),130)

	for index, ent in pairs(entities) do
		if ent:GetClass() == "gmt_minigame_obama" && ent.MiniGame == true then
			ent:Remove()
			ObamaCount = (ObamaCount-1)
		end
	end

end

local function SmashObama( ent, dmg )

	if ( ent:GetClass() == "gmt_minigame_obama" && dmg:IsDamageType(128) && ent.MiniGame == true ) then
		if ObamaCount != nil then
			ObamaCount = (ObamaCount-1)
		end

		local ply = dmg:GetAttacker()
		local ComboTime = 1

		ply.Combo = (ply.Combo or 0) + 1

		if CurTime() - (ply.SmashTime or CurTime()) > ComboTime then
			ply.Combo = 0
		end

		ply.SmashTime = CurTime()

		MoneyPerKill = 1 + (ply.Combo or 0)

		TotalMoney = TotalMoney + MoneyPerKill

		local vPoint = ent:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint+Vector(0,0,55) )
		effectdata:SetMagnitude( MoneyPerKill )
		util.Effect( "gmt_money", effectdata )

		dmg:GetAttacker():AddMoney( MoneyPerKill )

		ent:Remove()
	end

end

local function ObamaManStart()

	ObamaCount = 0

	timer.Create( "ObamaMan", .5, 0, function()
		if ObamaCount < 20 then
			ObamaCount = (ObamaCount+1)
			local entposX = math.Rand(4288.218262,4911.975586)
			local entposY = math.Rand(-10543.968750,-9808.031250)
			local ent = ents.Create("gmt_minigame_obama")
			ent:SetAngles(Angle(0,math.Rand(0,360),0))
			ent:SetPos( Vector(entposX,entposY,4096) )
			ent.MiniGame = true
			ent:Spawn()
		end
	end)

end

local function ObamaManStop()

	if ( timer.Exists( "ObamaMan" ) ) then
		timer.Remove( "ObamaMan" )

		for k,v in pairs (ents.FindByClass("gmt_minigame_obama")) do
			if v.MiniGame == true then
				v:Remove()
				ObamaCount = 0
			end
		end
	end

end

function Start( flags )

	OBAMA_GAME_ACTIVE = true

	ObamaManStart()

	hook.Add("Location", "ObamaSmashLocation", CheckGiveWeapon )
	hook.Add("EntityTakeDamage", "SmashObama", SmashObama )
	hook.Add("Think", "ObamaBoundsCheck", ObamaBounds )
	hook.Add("PlayerResize", "DoNotAllowResize", PlayerDissallowResize )

	for _, v in pairs( player.GetAll() ) do
		SafeCall( CheckGiveWeapon, v, GTowerLocation:GetPlyLocation( v ) )
	end

	TotalMoney = 0

end

function End()

	OBAMA_GAME_ACTIVE = false

	ObamaManStop()

	hook.Remove("Location", "ObamaSmashLocation" )
	hook.Remove("EntityTakeDamage", "SmashObama" )
	hook.Remove("Think", "ObamaBoundsCheck" )
	hook.Remove("PlayerResize", "DoNotAllowResize")

	for _, v in pairs( player.GetAll() ) do
		SafeCall( RemoveWeapon, v )
	end

	for _, v in pairs( ents.FindByClass(WeaponName) ) do
		v:Remove()
	end

	umsg.Start("obamasmash")
		umsg.Char( 1 )
		umsg.Long( TotalMoney )
	umsg.End()

end

hook.Add("ScalePlayerDamage","ObamaDamage",function(ply, h, d)

	if ( OBAMA_GAME_ACTIVE and GTowerLocation:GetPlyLocation(ply) == 4 ) then
		return true
	end

end)
