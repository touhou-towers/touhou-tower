
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_gui.lua")
AddCSLuaFile("cl_guiitem.lua")
AddCSLuaFile("cl_guibuybtn.lua")
AddCSLuaFile("cl_modelstore.lua")

include("shared.lua")
include("network.lua")
include("sales.lua")
include("pvpbattle/init.lua")

util.AddNetworkString("Store")

function GTowerStore:OpenStore( ply, id )

	if !id then
		Msg("ATTETION: Attempting to open nil store for player (".. tostring( ply ) ..")!\n")
		Msg( debug.traceback() )
	end

	self:SendItemsOfStore( ply, id )

	if self.DEBUG then Msg( "GTowerStore: " .. tostring( ply ) .. " opening store id " .. id .. "\n") end

	local discount = GTowerStore.Discount[id] or 0

	net.Start( "Store" )
		net.WriteInt( 0, 16 )
		net.WriteInt( id, 16 )
		net.WriteFloat( discount )
	net.Send( ply )

	/*umsg.Start("Store", ply )
		umsg.Char( 0 )
		umsg.Char( id )
		umsg.Float( discount )
	umsg.End()*/

end

function GTowerStore:SendItemsOfStore( ply, id )

	local ItemsNeeded = {}

	if !ply._StoreNeedSend then
		ply._StoreNeedSend = {}
	end

	if !ply._StoreHasSent then
		ply._StoreHasSent = {}
	end

	for k, v in pairs( self.Items ) do

		if v.storeid == id  then

			local Level, MaxLevel = ply:GetLevel( k ), ply:GetMaxLevel( k )

			if Level != 0 || MaxLevel != 0 then
				self:AddNetworkItem( ply, k )
			end

		end

	end

	self:AddPlayerNetwork( ply )

end


concommand.Add("gmt_storebuy", function( ply, cmd, args )

	if #args != 2 then return end

	local ItemId = tonumber( args[1] )
	local GoLevel = tonumber( args[2] )

	if !ItemId || !GoLevel then
		return
	end

	local Item = GTowerStore:Get( ItemId )

	if !Item then
		return
	end

	if !ply:IsAdmin() then
		local StoreTbl = GTowerStore.Stores[ Item.storeid ]

		if StoreTbl.NpcClass then

			local FoundNPC = false
			local PlyPos = ply:GetPos()

			for _, v in pairs( ents.FindByClass( StoreTbl.NpcClass ) ) do
				if PlyPos:Distance( v:GetPos() ) < GTowerStore.MinDistance then
					FoundNPC = true
					break
				end
			end

			if FoundNPC == false then
				return
			end
		else
			Msg("ATTETION: Player buying item without NpcClass! (".. ItemId ..",".. Item.storeid ..")\n")
		end
	end

	if GoLevel < 1 || GoLevel > #Item.prices then
		return
	end

	local MaxLevel = ply:GetMaxLevel( ItemId )

	if GoLevel <= MaxLevel then
		ply:SetLevel( ItemId, GoLevel )
		return
	end

	local MoneyNeeded = GTowerStore:CalculatePrice( Item.prices, MaxLevel, GoLevel )
	local PlyMoney = ply:Money()

	if GTowerStore.Discount[Item.storeid] then
		MoneyNeeded = math.Round(MoneyNeeded - (MoneyNeeded * GTowerStore.Discount[Item.storeid]))
	end

	if ply:Afford( MoneyNeeded ) then

		if Item.canbuy then
			local b, canbuy = pcall( Item.canbuy, ply, ItemId )

			if !b then
				Msg("Could not call store item#" .. ItemId .. "\n")
				Msg( canbuy .. "\n")
				return
			end

			if canbuy != true then
				return
			end
		end

		ply:AddMoney( -MoneyNeeded )

		local NpcEnt = nil

		local StoreTbl = GTowerStore.Stores[ Item.storeid ]

		if StoreTbl.NpcClass then

		local PlyPos = ply:GetPos()

		for _, v in pairs( ents.FindByClass( StoreTbl.NpcClass ) ) do
			if PlyPos:Distance( v:GetPos() ) < GTowerStore.MinDistance then
				FoundNPC = true
				NpcEnt = v
				break
			end
		end

		end

		local ent = ents.Create("gmt_money_bezier")

		if IsValid( ent ) and IsValid( NpcEnt ) then
			ent:SetPos( ply:GetPos() )
			ent.GoalEntity = NpcEnt
			ent.GMC = MoneyNeeded
			ent.RandPosAmount = 25
			ent:Spawn()
			ent:Activate()
			ent:Begin()
		end

		ply:Msg2( T("StorePurchased", Item.Name)  )

		ply:SetMaxLevel( ItemId, GoLevel )
		ply:SetLevel( ItemId, GoLevel )

		if Item.storeid == 4 && Item.Name != "Empty Bottle" then
			ply:AddAchivement( ACHIVEMENTS.SMARTINVESTER, MoneyNeeded )
		end
		
		if Item.storeid == 13 then
			ply:AddAchivement( ACHIVEMENTS.PLAYERMODEL, 1 )
		end
		
		if Item.storeid == 14 then
			ply:AddAchivement( ACHIVEMENTS.CELEBRATEGOODTIMES, 1 )
		end
		
		ply:AddAchivement( ACHIVEMENTS.HOLEINPOCKET, MoneyNeeded )
	else
		//You are poor!
		//This is handled client side - IGINORE
	end

end )



concommand.Add("gmt_openstore", function( ply, cmd, args )

	if !ply:IsAdmin() then
		return
	end

	local StoreId = tonumber( args[1] )

	if StoreId == 0 then
		return
	end

	if GTowerStore.DEBUG then Msg( "GTowerStore: " .. tostring( ply ) .. " admin open the store " .. StoreId .. "\n") end

	GTowerStore:OpenStore( ply, StoreId )

end )
