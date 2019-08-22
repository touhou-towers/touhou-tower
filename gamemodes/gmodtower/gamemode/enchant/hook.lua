
module("enchant", package.seeall )

//_DeathHookList = {}

function CallPlayerDeath( ply )
	
	if ply._DeathEnchantList then
		
		for _, v in pairs( ply._DeathEnchantList ) do
			if v:IsValid() then
				v:Destroy()
			end
		end
		
		ply._DeathEnchantList = nil
	end
	
	
end


hook.Add("PlayerDeath", "CheckEnchtRemove", CallPlayerDeath )

function _NewDeathHook( item, ply )
	
	if !ply._DeathEnchantList then
		ply._DeathEnchantList = { item }
	else
		table.insert( ply._DeathEnchantList, item )
	end
	
end

function _RemoveDeathHook( item, ply )
	
	if ply._DeathEnchantList then
		table.RemoveValue( ply._DeathEnchantList, item )
	end
	
end