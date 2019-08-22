
include("shared.lua")
include("pvpbattle/cl_init.lua")
include("cl_gui.lua")
include("cl_guiitem.lua")
include("cl_guibuybtn.lua")
include("cl_modelstore.lua")

--usermessage.Hook("Store", function( um )
net.Receive("Store",function()

	local Id = net.ReadInt(16)

	if Id == 0 then

		local StoreId = net.ReadInt(16)
		local discount = net.ReadFloat()

		GTowerStore:OpenStore( StoreId, nil, nil, discount )

	elseif Id == 2 then


		local ItemId = GTowerStore:ReadItemLevel( um )
		GTowerStore:LevelsChanged( ItemId )

	elseif Id == 4 then

		while GTowerStore:ReadItemLevel( um ) != false do
			//Just read it!
		end

		GTowerStore:LevelsChanged()

	elseif Id == 5 then // sale discount change
		local id = net.ReadInt(16)
		local discount = net.ReadFloat()

		GTowerStore:CheckAndUpdate(id, discount)
	end

end )

function GTowerStore:ReadItemLevel( um )

	local ItemId = net.ReadInt(16)

	if ItemId == 0 then
		return false
	end

	ItemId = ItemId + 32768

	if !GTowerStore.Items[ ItemId ] then
		ErrorNoHalt( "Could not find item: " .. ItemId .. "\n" )
	end

	local CurLevel = net.ReadInt(16)
	local MaxActiveLevel = net.ReadInt(16)

	GTowerStore.Items[ ItemId ].level = CurLevel
	GTowerStore.Items[ ItemId ].maxlevel = MaxActiveLevel

	return ItemId

end

function GTowerStore:LevelsChanged( ItemId )
	hook.Call("PlayerLevel", GAMEMODE, ItemId )
end

function GTowerStore:PromptToBuy( Id, GoLevel )

	local Item = self.Items[ Id ]

	if Item == nil then
		return
	end

	if Item.canbuy then

		local b, rtn = pcall( Item.canbuy, Item )

		if b && rtn != true then
			return
		end
	end

	local ItemName = Item.Name or ""
	local Price = GTowerStore:CalculatePrice( Item.prices, Item.maxlevel, GoLevel )
	local Message = ""

	if GTowerStore.StoreDiscount != 0 then
		Price = math.Round(Price - (Price * GTowerStore.StoreDiscount))
	end

	if Item.upgradable == true then
		Message = T("StoreConfirmUpgrade", ItemName, Price)
	else
		Message = T("StoreConfirmPurchase", ItemName, Price)
	end

	if Price == 0 then
		hook.Call("StoreFinishBuy", GAMEMODE, Id, GoLevel )
		RunConsoleCommand( "gmt_storebuy", Id, GoLevel )
		surface.PlaySound("gmodtower/stores/purchase.wav")

	elseif !Afford( Price ) then
		Msg2( T("StoreNotEnoughMoney") )

	else

		hook.Call("StoreFinishBuy", GAMEMODE, Id, GoLevel )
		RunConsoleCommand( "gmt_storebuy", Id, GoLevel )
		surface.PlaySound("gmodtower/stores/purchase.wav")

	end

end

hook.Add( "InitPostEntity", "LoadStoreItems", function()
	GTowerStore:LoadItems()
end )

hook.Add("OpenSideMenu", "ShopAdmin", function()

	if !LocalPlayer():IsAdmin() then return end
	local Ent = LocalPlayer():GetEyeTrace().Entity

	if !IsValid( Ent ) || !Ent:IsNPC() then return end

	local class = Ent:GetClass()

	local storeid = -1
	for k,v in ipairs(GTowerStore.Stores) do
		if class == v.NpcClass then
			storeid = k
			break
		end
	end

	if storeid == -1 then return end

	local Form = vgui.Create("DForm")
	Form:SetName( "Store " .. tostring(storeid) )

	local ChangeDiscount = Form:Button( "Set Discount")
	ChangeDiscount.DoClick = function()
		Derma_StringRequest( "Set Store Discount" ,
			"Set discount for store " .. tostring(storeid) .. " (0 <-> 1)",
			0,
			function( strTextOut )
				local Output = tonumber( strTextOut )
				if Output then
					Msg2("You set store " .. tostring(storeid) .. " to " .. Output )
					RunConsoleCommand("gmt_storesetdiscount", storeid, Output )
				end
			end,
			EmptyFunction,
			"Update",
			"Cancel" )
	end

	return Form
end)
