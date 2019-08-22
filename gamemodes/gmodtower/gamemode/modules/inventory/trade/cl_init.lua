
include("shared.lua")
include("cl_gui.lua")
include("cl_item.lua")

local IgnoreTrade = CreateClientConVar( "gmt_ignore_trade", "0", true, false )

GTowerTrade.TradingMoney = 0

function GTowerTrade:SendItems()

	if !GTowerTrade.GuiItems then
		return
	end

	local Ids = {}

	for _, v in ipairs( GTowerTrade.GuiItems ) do
		table.insert( Ids, v.OldCommandId )
	end

	GTowerTrade.MyAccepted = false
	GTowerTrade.OtherAccepted = false

	GTowerTrade.MyFinished = false
	GTowerTrade.OtherFinished = false

	RunConsoleCommand("gmt_tradeitems", GTowerTrade.TradingMoney, unpack( Ids ) )


end

net.Receive("GTrade",function()

	local ID = net.ReadInt(16)

	if ID == 0 then
		local PlyId = net.ReadInt(16)
		local ply = ents.GetByIndex( PlyId )

		if IsValid( ply ) then
			GTowerTrade:OpenTrade( ply )
		end

	elseif ID == 1 then

		GTowerTrade:CloseTrade()

	elseif ID == 2 then

		local ply = net.ReadEntity()

		Msg2( T("trade_him_space", ply:Name() ) )


	elseif ID == 3 then

		local Money = net.ReadInt(16)
		local Count = net.ReadInt(16)

		local Items = {}

		for i=1, Count do
			local Id = net.ReadInt(16) + 32768
			local Item = GTowerItems:CreateById( Id )

			if !Item then
				Msg( "NOTICE: Unable to create item by id: ", Id, "\n" )
			end

			if Item.ReadFromNW then
				Item:ReadFromNW( um )
			end

			table.insert( Items, Item )
		end

		GTowerTrade.MyAccepted = false
		GTowerTrade.OtherAccepted = false

		GTowerTrade.MyFinished = false
		GTowerTrade.OtherFinished = false

		GTowerTrade:OtherTrading( Money, Items )

	elseif ID == 4 then

		local Count = net.ReadInt(16)

		for i=1, Count do
			local id = net.ReadInt(16)
			local item = net.ReadString()
			GTowerTrade:RemoveItem( item, id )
		end

	elseif ID == 5 then
		GTowerTrade.MyAccepted = net.ReadBool()
		GTowerTrade.OtherAccepted = net.ReadBool()

		GTowerTrade.MyFinished = net.ReadBool()
		GTowerTrade.OtherFinished = net.ReadBool()

	elseif ID == 6 then

		GTowerTrade:RecieveRequest( net.ReadInt(16), net.ReadBool() )

	end

end )

function GTowerTrade:RecieveRequest( ply, bool )

	local PlyId = ply
	local Inviter = ents.GetByIndex( PlyId )

	if !IsValid( Inviter ) || !Inviter:IsPlayer() then return end

	if bool then
		Msg2( T("send_trade_request", Inviter:GetName() ) )
		return
	end

	if IgnoreTrade:GetBool() then return end

	local Question = GtowerMessages:AddNewItem( T("send_trade_recive", Inviter:GetName() ) , 25.0)

	Question:SetupQuestion(
		function() RunConsoleCommand("gmt_trade", PlyId ) end , //accept
		EmptyFunction , //decline
		EmptyFunction , //timeout
		nil,
		{120, 160, 120},
		{160, 120, 120}
	)

end

hook.Add( "ExtraMenuPlayer", "AddTradeItem", function( ply )
    if ply != LocalPlayer() then

		return {
			["Name"] = T("MenuTrade"),
			["function"] = function() RunConsoleCommand("gmt_trade", ply:EntIndex() ) end,
			["icon"] = GtowerIcons:GetIcon( 'trade' ),
			["order"] = 1
		}

	end

end )
