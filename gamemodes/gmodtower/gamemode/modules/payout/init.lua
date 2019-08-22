
util.AddNetworkString("Payouts")

AddCSLuaFile("sh_init.lua")
AddCSLuaFile("cl_init.lua")

include("sh_init.lua")

module( "payout", package.seeall )

local earned = {}

function Clear( ply )
	earned = { payout.Get(1) }
end

function Give( ply, id, gmc )
	local ecard = { Get( GetByName( id ) ) }

	if gmc != nil then ecard[1].GMC = gmc end

	table.Add( earned, ecard )
end

function Payout( ply )
	local money = 0

	net.Start( "Payouts" )
	net.WriteTable( earned )
	net.Send( ply )

	for k, v in pairs( earned ) do
		money = money + earned[k].GMC
	end

	ply:AddMoney( money, true )
end
