
local TRADE = {}
ActiveTrades = {}

util.AddNetworkString("GTrade")

function TRADE:Create( ply1, ply2 )

	local o = {}

	setmetatable( o, self )
	self.__index = self

	o.Id = 0

	o.Player1 = {
		ply = ply1,
		offer = {},
		money = 0,
		accepted = false,
		finished = false
	}
	o.Player2 = {
		ply = ply2,
		offer = {},
		money = 0,
		accepted = false,
		finished = false
	}

	o.TradeRequestTime = CurTime()
	o.TradeStarted = false

	o.NextTradeSend = CurTime()

	return o

end

function TRADE:IsValid()
	return IsValid( self.Player1.ply ) && IsValid( self.Player2.ply ) && self.TradeRequestTime + 60 > CurTime()
end

function TRADE:ValidTrade()
	return IsValid( self.Player1.ply ) && IsValid( self.Player2.ply ) && self.TradeStarted == true
end

function TRADE:IsPlayers( ply1, ply2 )

	return ( ply1 == self.Player1.ply && self.Player2.ply == ply2 ) ||
		( ply2 == self.Player1.ply && self.Player2.ply == ply1 )

end

function TRADE:HasPlayer( ply )
	return ply == self.Player1.ply || ply == self.Player2.ply
end

function TRADE:GetPlayer( ply )
	if ply == self.Player1.ply then
		return self.Player1, self.Player2
	elseif ply == self.Player2.ply then
		return self.Player2, self.Player1
	end
end

function TRADE:GetRP()

	local rp = RecipientFilter()

	if IsValid( self.Player1.ply ) then
		rp:AddPlayer( self.Player1.ply )
	end
	if IsValid( self.Player2.ply ) then
		rp:AddPlayer( self.Player2.ply )
	end

	return rp

end

function TRADE:PlayerStartAccept( ply )

	local Player, OherPlayer = self:GetPlayer( ply )

	Player.accepted = true

	if self.Player1.accepted == true && self.Player2.accepted == true then
		self:StartTrade()
		return true
	end

	if CurTime() >= self.NextTradeSend then
		/*umsg.Start("GTrade", OherPlayer.ply )
			umsg.Char( 6 )
			umsg.Char( Player.ply:EntIndex() )
			umsg.Bool( false )
		umsg.End()*/

		net.Start( "GTrade" )
			net.WriteInt( 6, 16 )
			net.WriteInt( Player.ply:EntIndex(), 16 )
			net.WriteBool( false )
		net.Send( OherPlayer.ply )

		/*umsg.Start("GTrade", Player.ply )
			umsg.Char( 6 )
			umsg.Char( OherPlayer.ply:EntIndex() )
			umsg.Bool( true )
		umsg.End()*/

		net.Start( "GTrade" )
			net.WriteInt( 6, 16 )
			net.WriteInt( OherPlayer.ply:EntIndex(), 16 )
			net.WriteBool( true )
		net.Send( Player.ply )

		self.NextTradeSend = CurTime() + 10.5
	end

	return false

end

function TRADE:StartTrade()

	//for k, v in pairs( ActiveTrades ) do
	//	if v != self && ( v:HasPlayer( self.Player1.ply ) || v:HasPlayer( self.Player2.ply ) ) then
	//		v:Destroy()
	//	end
	//end

	/*umsg.Start("GTrade", self.Player1.ply )
		umsg.Char( 0 )
		umsg.Char( self.Player2.ply:EntIndex() )
	umsg.End()*/
	net.Start( "GTrade" )
		net.WriteInt( 0, 16 )
		net.WriteInt( self.Player2.ply:EntIndex(), 16 )
	net.Send( self.Player1.ply )

	/*umsg.Start("GTrade", self.Player2.ply )
		umsg.Char( 0 )
		umsg.Char( self.Player1.ply:EntIndex() )
	umsg.End()*/
	net.Start( "GTrade" )
		net.WriteInt( 0, 16 )
		net.WriteInt( self.Player1.ply:EntIndex(), 16 )
	net.Send( self.Player2.ply )

	self.TradeStarted = true


end

function TRADE:SendAccepted()

	if !self:ValidTrade() then
		return false
	end

	net.Start( "GTrade" )
		net.WriteInt( 5, 16 )
		net.WriteBool( self.Player1.accepted )
		net.WriteBool( self.Player2.accepted )
		net.WriteBool( self.Player1.finished )
		net.WriteBool( self.Player2.finished )
	net.Send( self.Player1.ply )

	net.Start( "GTrade" )
		net.WriteInt( 5, 16 )
		net.WriteBool( self.Player2.accepted )
		net.WriteBool( self.Player1.accepted )
		net.WriteBool( self.Player2.finished )
		net.WriteBool( self.Player1.finished )
	net.Send( self.Player2.ply )

end

function TRADE:ResetAccepted()
	self.Player1.accepted = false
	self.Player2.accepted = false

	self.Player1.finished = false
	self.Player2.finished = false
end

function TRADE:PlayerAccept( ply, state )

	if !self:ValidTrade() then
		return false
	end

	local Player, OtherPlayer = self:GetPlayer( ply )

	if !Player || !OtherPlayer then
		return false
	end

	if state == false && (Player.finished || OtherPlayer.finished) then
		self:ResetAccepted()
		self:SendAccepted()
		return
	end

	Player.accepted = state

	self:SendAccepted()
end

function TRADE:PlayerFinish( ply, state )

	if !self:ValidTrade() then
		return false
	end

	local Player, OtherPlayer = self:GetPlayer( ply )

	if !Player || !OtherPlayer then
		return false
	end

	if !Player.accepted || !OtherPlayer.accepted then
		return false
	end

	if state == false then
		self:ResetAccepted()
		self:SendAccepted()
		return false
	end

	Player.finished = state

	if Player.finished && OtherPlayer.finished then
		self:SubmmitTrade()
	else
		self:SendAccepted()
	end
end

function TRADE:PlayerOffer( ply, money, items )

	if !self:ValidTrade() then
		return false
	end

	local Player, OtherPlayer = self:GetPlayer( ply )

	if !Player then
		return false
	end

	Player.money = math.Clamp( money, 0, ply:Money() )

	self:ResetAccepted()

	local function CanTradeSlot( id )

		local Slot = GTowerItems:NewItemSlot( Player.ply, id )

		if !Slot || !Slot:IsValid() || !Slot:CanManage() then
			return false, 1
		end

		local Item = Slot:Get()

		if !Item || Item.Tradable == false then
			return false, 2
		end

		if Item.UniqueInventory == true && OtherPlayer.ply:HasItemById( Item.MysqlId ) then
			return false, 3
		end

		return Slot

	end

	local TradeableItems = {}
	local CannotTrade = {}
	Player.offer = TradeableItems

	//Clean up items
	for k, v in ipairs( items ) do

		local result, id = CanTradeSlot( v )

		if result != false then
			table.insert( TradeableItems, result )
		else
			table.insert( CannotTrade, { v, id } )
		end

	end

	if #CannotTrade > 0 then

		net.Start("GTrade")
		net.WriteInt(4,16)
		net.WriteInt(#CannotTrade,16)
		for k, v in pairs( CannotTrade ) do
			net.WriteInt( v[2], 16 )
			net.WriteString( v[1] )
		end
		net.Send(Player.ply)

		/*umsg.Start("GTrade", Player.ply )
			umsg.Char( 4 )
			umsg.Char( #CannotTrade )

			for k, v in pairs( CannotTrade ) do
				umsg.Char( v[2] )
				umsg.String( v[1] )
			end

		umsg.End()*/

	end

	//Now send to the other player the items that are going to be traded

	net.Start("GTrade")

	net.WriteInt(3,16)
	net.WriteInt(Player.money,16)
	net.WriteInt(#TradeableItems,16)

	for k, v in pairs( TradeableItems ) do

		local Item = v:Get()

		net.WriteInt( Item.MysqlId - 32768, 16 )

		if type( Item.CustomNW ) == "function" then
			Item:CustomNW()
		end

	end

	net.Send(OtherPlayer.ply)

	/*umsg.Start("GTrade", OtherPlayer.ply )

	umsg.Char( 3 )
	umsg.Long( Player.money )
	umsg.Char( #TradeableItems )

	for k, v in pairs( TradeableItems ) do

		local Item = v:Get()

		umsg.Short( Item.MysqlId - 32768 )

		if type( Item.CustomNW ) == "function" then
			Item:CustomNW()
		end

	end

	umsg.End()*/


end


function TRADE:EndTrade()

	/*umsg.Start("GTrade", self:GetRP() )
		umsg.Char( 1 )
	umsg.End()*/

	net.Start("GTrade")
		net.WriteInt(1,16)
	net.Send(self:GetRP())

	self:Destroy()

end

function TRADE:Destroy()
	ActiveTrades[ self.Id ] = nil
end

function TRADE:SubmmitTrade()

	self.Player1.money = math.Clamp( self.Player1.money, 0, self.Player1.ply:Money() )
	self.Player2.money = math.Clamp( self.Player2.money, 0, self.Player2.ply:Money() )

	//Calculate space left on each inventory
	local function HaveEnoughSpaceLeft( Player, OtherPlayer )

		//Msg("Player SPACE:" , Player.ply, "\n")

		Player.TradingSlots = {}

		local function NotUsingSlot( Slot )
			for _, v in pairs( Player.TradingSlots ) do
				if v:Compare( Slot ) then
					return false
				end
			end
			return true
		end

		local function FindSlot( ComingSlot )

			local Item = ComingSlot:Get()

			if !Item || Item == false then
				return false
			end

			if Item.UniqueInventory == true && Player.ply:HasItemById( Item.MysqlId ) then
				return nil
			end

			//Let's look in the inventory for a space for the item
			for i=1, Player.ply:MaxItems() do
				local Slot = GTowerItems:NewItemSlot( Player.ply, i .. "-1" )

				if NotUsingSlot( Slot ) == true && Slot:IsValid() && Slot:CanManage() && Slot:Empty() && Slot:Allow( Item , true ) then
					return Slot
				end

			end

			//Look on the spaces that are being traded out
			for _, v in pairs( Player.offer ) do
				if NotUsingSlot( v ) == true && v:IsValid() && v:CanManage() && v:Allow( Item, true ) then
					return v
				end
			end

			//Let's look in the bank!
			for i=1, Player.ply:BankLimit() do
				local Slot = GTowerItems:NewItemSlot( Player.ply, i .. "-2" )

				if NotUsingSlot( Slot ) == true && Slot:IsValid() && Slot:CanManage() && Slot:Empty() && Slot:Allow( Item, true ) then
					return Slot
				end

			end

		end

		for _, v in pairs( OtherPlayer.offer ) do

			local Slot = FindSlot( v )

			if Slot == nil then
				return false
			elseif Slot != false then
				//Other players slot = players slot
				Player.TradingSlots[ v ] = Slot

				//Msg("\t", v:Name(), " - ", Slot:Name(),"\n")
			end

		end

		return true
	end

	if HaveEnoughSpaceLeft( self.Player1, self.Player2 ) == false then
		/*umsg.Start("GTrade", self:GetRP() )
			umsg.Char( 2 )
			umsg.Entity( self.Player1.ply )
		umsg.End()*/
		net.Start("GTrade")
			net.WriteInt(2,16)
			net.WriteEntity(self.Player1.ply)
		net.Send(self:GetRP())
		self:EndTrade()
		return
	end

	if HaveEnoughSpaceLeft( self.Player2, self.Player1 ) == false then
		/*umsg.Start("GTrade", self:GetRP() )
			umsg.Char( 2 )
			umsg.Entity( self.Player2.ply )
		umsg.End()*/
		net.Start("GTrade")
			net.WriteInt(2,16)
			net.WriteEntity(self.Player2.ply)
		net.Send(self:GetRP())
		self:EndTrade()
		return
	end

	/*===========
		GATHER ALL ITEMS
	==============*/


	local function GatherItems( Player )

		Player.Items = {}

		//Msg("Player COLLECT:" , Player.ply, "\n")

		for k, v in pairs( Player.TradingSlots ) do

			local Item = k:Get()

			//Player slot = Stuff to go in it
			Player.Items[ v ] = {
				mysqlid = Item.MysqlId,
				mdl = Item.Model,
				data = Item:GetSaveData() or ""
			}

			//Msg("\t", v:Name(), " - ", Item.MysqlId,"\n")

		end

	end

	//Gather all the items
	GatherItems( self.Player1 )
	GatherItems( self.Player2 )

	//Delete all the items
	for _, v in pairs( self.Player1.offer ) do
		v:Remove()
		v:ItemChanged()
	end

	for _, v in pairs( self.Player2.offer ) do
		v:Remove()
		v:ItemChanged()
	end


	//Put all items back
	for Slot, Info in pairs( self.Player1.Items ) do
		local Item = GTowerItems:CreateById( Info.mysqlid, self.Player1.ply, Info.data )
		Slot:Set( Item )
		Slot:ItemChanged()
	end

	for Slot, Info in pairs( self.Player2.Items ) do
		local Item = GTowerItems:CreateById( Info.mysqlid, self.Player2.ply, Info.data )
		Slot:Set( Item )
		Slot:ItemChanged()
	end

	//Give the money
	self.Player1.ply:AddMoney( self.Player2.money, true )
	self.Player1.ply:AddMoney( -self.Player1.money, true )

	self.Player2.ply:AddMoney( self.Player1.money, true )
	self.Player2.ply:AddMoney( -self.Player2.money, true )

	self:EndTrade()

	if self.Player1.money > 0 then

	local bzr = ents.Create("gmt_money_bezier")

	if IsValid( bzr ) then
		bzr:SetPos( self.Player1.ply:GetPos() )
		bzr.GoalEntity = self.Player2.ply
		bzr.GMC = self.Player1.money
		bzr.RandPosAmount = 50
		bzr:Spawn()
		bzr:Activate()
		bzr:Begin()
	end

	end

	if self.Player2.money > 0 then

	local bzr = ents.Create("gmt_money_bezier")

	if IsValid( bzr ) then
		bzr:SetPos( self.Player2.ply:GetPos() )
		bzr.GoalEntity = self.Player1.ply
		bzr.GMC = self.Player2.money
		bzr.RandPosAmount = 50
		bzr:Spawn()
		bzr:Activate()
		bzr:Begin()
	end

	end

	SafeCall( GTowerTrade.LogTrade,
		self.Player1.ply,
		self.Player2.ply,
		self.Player2.money,
		self.Player1.money,
		self.Player1.Items,
		self.Player2.Items
	)

end


function GTowerItems:FindActiveTrade( ply )

	for k, v in pairs( ActiveTrades ) do
		if v.TradeStarted == true && v:HasPlayer( ply ) then
			return v
		end
	end

end


function GTowerItems:GetTrade( ply1, ply2 )

	for k, v in pairs( ActiveTrades ) do
		if !v:IsValid() && v.TradeStarted == false then

			v:Destroy()

		else

			if v:IsPlayers( ply1, ply2 ) then
				return v
			end

		end

	end

	local Trade = TRADE:Create( ply1, ply2 )

	Trade.Id = table.insert( ActiveTrades, Trade )

	//No trade with those players found, create a new instance
	return Trade

end
