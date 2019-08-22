
GTowerStore = GTowerStore or {}
GTowerStore.DEBUG = false
GTowerStore.MinDistance = 512

GTowerStore.Items = {}

function GTowerStore:Get( id )
	
	if type( id ) == "string" then
	
		local ItemId = GTowerStore:GetItemByName( id )
		
		if ItemId then
			return GTowerStore.Items[ ItemId ]
		end
	end

	return GTowerStore.Items[ id ]
end

function GTowerStore:GetItemByName( Name )

	for k, v in pairs( self.Items ) do

		if v.unique_Name == Name then
			return k
		end
	
	end

	return nil

end

function GTowerStore:GetClientLevel( ply, id )
	if !id then return end
	
	local Item = self:Get( id )

	if !Item then return end
	
	return Item.level
	
end