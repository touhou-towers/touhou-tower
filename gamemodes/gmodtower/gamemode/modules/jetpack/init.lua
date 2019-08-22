
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local hook = hook
local umsg = umsg
local ents = ents
local timer = timer
local SafeCall = SafeCall
local IsValid = IsValid
local CurTime = CurTime
local Vector = Vector
local tostring = tostring
local _G = _G

module("jetpack")

function GetJetpack( ply )
	local Jetpack = ply:GetEquipment( "Jetpack" )

	if Jetpack && Jetpack:IsValid() then
		return Jetpack
	end
end