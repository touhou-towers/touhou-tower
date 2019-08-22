
----------------------------------------------
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

local EffectData = EffectData
local ents = ents
local hook = hook
local math = math
local Model = Model
local net = net
local pairs = pairs
local player = player
local string = string
local timer = timer
local util = util
local Vector = Vector
local table = table
local tonumber = tonumber

module("minigames.fun")

local fun = 0
local maxFun = 0

local leader = ""
local FunPlayers = 0

function Start( flags )
	StartFun()
end

function End( won )
	if won == nil then
		FunBloom(false)
		ToggleMusic(false)
		ToggleFunMeter(false)
		RemoveFunHooks()

		if timer.Exists("DecrementFun") then
			timer.Destroy("DecrementFun")
		end

		return
	end
	ShowLeader()
	EndFun( won )
end

function ShowLeader()

	local leaders = {}

	for k,v in pairs(player.GetAll()) do
		if v.Fun then
			table.insert(leaders,v.Fun)
		end
		if v.Fun == tonumber(leaders[table.GetWinningKey(leaders)]) then
			leader = v:Name()
		end
	end

	net.Start("PrintLeader")
	net.WriteString(leader)
	net.WriteInt(leaders[table.GetWinningKey(leaders)],32)
	net.Broadcast()

end

function StartFun()

	for k,v in pairs(player.GetAll()) do
		v.Fun = 0
	end

	fun = 0

	ToggleFunMeter(true)

	FunPlayers = player.GetCount()
	fun = (FunPlayers * FunPerPlayer) / 4
	maxFun = FunPlayers * FunPerPlayer

	for k,ply in pairs(player.GetAll()) do
		ply:SendLua([[surface.PlaySound("gmodtower/lobby/fun/fun_meter_intro.mp3")]])
	end

	timer.Simple(9,function()
		FunBloom(true)
		ToggleMusic(true)

		AddFunHooks()

		timer.Create("DecrementFun",0.5,0,function()
			AddFun( -FunPlayers )
		end)
	end)

end

function AddFunHooks()
	hook.Add( "KeyPress", "JumpHookFun", function( ply, key )
		if ( key == IN_JUMP ) and ply:OnGround() then
			AddFun(JumpFun)
			ply.Fun = ply.Fun + JumpFun
		end
	end )

	hook.Add( "PlayerFootstep", "RunHookFun", function( ply )
		AddFun(RunFun)
	end )

	hook.Add( "PlayerSay", "ChatHookFun", function( ply, text, team )
		if ( string.lower( text ) == "/dance" ) then
			AddFun(DanceFun)
			ply.Fun = ply.Fun + DanceFun
		else
			AddFun(ChatFun)
			ply.Fun = ply.Fun + ChatFun
		end
	end )

	hook.Add("StoreFinishBuy", "AddBuyFun", function()

		AddFun(SpendFun)

		for k,v in pairs(player.GetAll()) do
			if v.Fun then
				v.Fun = v.Fun + SpendFun
			end
		end

	end )

end

function RemoveFunHooks()
	hook.Remove( "KeyPress","JumpHookFun" )
	hook.Remove( "PlayerFootstep","RunHookFun" )
	hook.Remove( "PlayerSay","ChatHookFun" )
	hook.Remove( "StoreFinishBuy","AddBuyFun" )
end

function StartCelebration()
	for k,v in pairs(player.GetAll()) do
		v:Msg2("Get your rewards at the lobby!")
	end

	timer.Create("ConfettiTimer",0.25,40,function()

	local ConfettiPos = Vector(925, -1490, 400)

	local vPoint = Vector( ConfettiPos.x + math.random(-700,700), ConfettiPos.y + math.random(-700,700), ConfettiPos.z )
	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	util.Effect( "confetti", effectdata )

	end)

	timer.Create("MoneyTimer",0.75,20,function()
		local EntNames = {
			{"one", 1},
			{"ten", 10},
			{"twentyfive", 25},
			{"fifty", 50}
		}

		local selection = math.random(1,4)

		local EndName = Model("models/gmt_money/" .. EntNames[ selection ][ 1 ] .. ".mdl")

		local MoneyPos = Vector(925, -1490, 5)
		local prop = ents.Create( "gmt_money_base" )
		prop:SetModel( EndName )
		prop.MoneyValue = EntNames[ selection ][ 2 ]
		prop:SetPos( Vector( MoneyPos.x + math.random(-700,700), MoneyPos.y + math.random(-700,700), MoneyPos.z ) )
		prop:Spawn()
	end)

	timer.Simple(30,function()
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "gmt_money_base" then
				v:Remove()
			end
		end
	end)

end

function EndFun(won)

	local delay = math.random(5,15)

	net.Start("EndFun")
		net.WriteBool(won)
		net.WriteInt(delay,32)
	net.Broadcast()

	if !won then
		for k,v in pairs(player.GetAll()) do
			v:SetFOV(50,delay)
		end

		timer.Simple(delay,function()
			for k,v in pairs(player.GetAll()) do
				v:Ignite(10)
			end
		end)

		timer.Simple(delay + 10,function()
			for k,v in pairs(player.GetAll()) do
				v:Kill()
			end
		end)
	else

		StartCelebration()

	end

end

function AddFun( amount )
	net.Start("AddFun")
		net.WriteInt(amount,32)
	net.Broadcast()

	if amount > 0 then
		fun = fun + amount
	end

	if amount < 0 and fun > 0 then
		fun = fun + amount
	end

	if fun <= 0 then
		FunBloom(false)
		ToggleMusic(false)
		ToggleFunMeter(false)
		RemoveFunHooks()
		End(false)

		if timer.Exists("DecrementFun") then
			timer.Destroy("DecrementFun")
		end
	end

	if fun >= maxFun then
		FunBloom(false)
		ToggleMusic(false)
		ToggleFunMeter(false)
		RemoveFunHooks()
		End(true)

		if timer.Exists("DecrementFun") then
			timer.Destroy("DecrementFun")
		end
	end

end

function FunBloom( enabled )
	net.Start("FunBloom")
		net.WriteBool(enabled)
	net.Broadcast()
end

function ToggleMusic( on )
	net.Start("ToggleMusic")
		net.WriteBool(on)
	net.Broadcast()
end

function ToggleFunMeter( enabled )
	net.Start("FunMeterEnabled")
		net.WriteBool(enabled)
		net.WriteInt(player.GetCount(),8)
	net.Broadcast()
end

util.AddNetworkString("FunBloom")
util.AddNetworkString("PrintLeader")
util.AddNetworkString("ToggleMusic")
util.AddNetworkString("FunMeterEnabled")
util.AddNetworkString("AddFun")
util.AddNetworkString("EndFun")
