
GTowerItems = GTowerItems or {}
GTowerItems.NetworkLoaded = true

local function ReloadMaxItems()
	if CLIENT then
		timer.Simple( 0, function() GTowerItems.ReloadMaxItems( GTowerItems ) end)
	end
end

RegisterNWTablePlayer({ 
	{"GtowerMaxItems", GTowerItems.DefaultInvCount, NWTYPE_CHAR, REPL_PLAYERONLY, ReloadMaxItems},
	{"GtowerBankMax", GTowerItems.DefaultBankCount, NWTYPE_CHAR, REPL_PLAYERONLY, ReloadMaxItems} 
})


hook.Add( "GTowerPhysgunPickup", "OnlyAllowInvItems", function( ply, ent )
	
	if ply:GetSetting("GTAllowPhysInventory") == true then
		return GTowerItems:FindByEntity( ent ) != nil
	end
	
	return true
end )