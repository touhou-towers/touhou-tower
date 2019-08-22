
GTowerStore = GTowerStore or {}
GTowerStore.DEBUG2 = false //Leave DEBUG for the main store, not the module
//GTowerStore.SendOnlyClientSide = true

function GTowerStore:CalculatePrice( PriceTbl, CurMax, GoMax )

	local i
	local MoneyNeeded = 0

	for i = CurMax + 1, GoMax do
		MoneyNeeded = MoneyNeeded + PriceTbl[ i ]		
	end
	
	return MoneyNeeded

end

hook.Add("LoadAchivements","AchiSpendingMoney", function () 

	GtowerAchivements:Add( ACHIVEMENTS.SMARTINVESTER, {
		Name = "'Smart' Investor", 
		Description = "Spend a total of 1,000 GMC on beer.", 
		Value = 1000
	})

	GtowerAchivements:Add( ACHIVEMENTS.HOLEINPOCKET, {
		Name = "Hole In Your Pocket", 
		Description = "Spend a total of 5,000 GMC.", 
		Value = 5000
	})

end )