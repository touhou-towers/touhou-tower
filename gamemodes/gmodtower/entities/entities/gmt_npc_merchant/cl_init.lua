
include('shared.lua')

hook.Add("StoreFinishBuy", "PlayBuySound", function()

	if GTowerStore.StoreId == 8 then
		for _, ent in pairs( ents.FindByClass("gmt_npc_merchant" ) ) do
			ent:EmitSound("GModTower/stores/merchant/buyitem"..math.random(1,2)..".wav")
		end
	end

end )

hook.Add("GTowerCloseStore", "PlayMerchantClose", function()

	if GTowerStore.StoreId == 8 then
		for _, ent in pairs( ents.FindByClass("gmt_npc_merchant" ) ) do
			ent:EmitSound(Sound("GModTower/stores/merchant/close.wav"))
		end
	end

end )
