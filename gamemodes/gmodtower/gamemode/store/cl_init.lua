
include('shared.lua')
include('sh_store.lua')
include('hats/cl_init.lua')
include("pvpbattle/cl_init.lua")
include("ballracer/cl_init.lua")



function GTowerStore:LoadItems()
	GTowerStore.Items = {}
	hook.Call("GTowerStoreLoad", GAMEMODE )
end

function GTowerStore:SQLInsert( NewItem )

	if type( NewItem.price ) == "number" && !NewItem.prices then
		NewItem.prices = { NewItem.price }
	end
	
	local id = simplehash( NewItem.unique_Name )

	self.Items[ id ] = NewItem
	NewItem.maxlevel = 0
	NewItem.level = 0
	NewItem.Id = id
	
end

function GTowerStore:Get( id )

	if !self.Items then
		Error("Request store item before they are loaded.")
	end

	if type( id ) == "string" then
		
		for k, v in pairs( self.Items ) do
			if v.unique_Name == id then
				return v
			end			
		end
		
		local NewId = tonumber( id )
		
		if !NewId || NewId == 0 then
			ErrorNoHalt("Invalid store item", id )
			Msg( debug.traceback() )
			return
		end
		
		id = NewId
		
	end
	
	return GTowerStore.Items[ id ]

end