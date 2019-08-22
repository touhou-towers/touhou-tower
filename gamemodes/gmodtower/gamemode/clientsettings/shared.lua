
ClientSettings = {}
ClientSettings.DEBUG = false

include('sh_items.lua')

function ClientSettings:GetItem( id )
	return self.Items[ id ]
end

function ClientSettings:GetName( id )
	
	local Item = self:GetItem( id )
	
	if Item then
		return Item.Name
	end
end


function ClientSettings:IsNumber( type )
	return type == "Long" || type == "Float" || type == "Char" || type == "Short"
end

function ClientSettings:FindByName( Name )
	if !Name then return end
	for k, v in ipairs( self.Items ) do
		if Name == v.Name || Name == v.Var then
			return k
		end
	end
end

function ClientSettings:CompareId( id, Name )
	local Item = self:GetItem( id )
	return Item && ( Item.Var == Name || Item.Name == Name )
end

function ClientSettings:Get( ply, id )
	if type( id ) == "string" then
		id = self:FindByName( id )
	end
	
	if !id then return end
	
	local Item = self.Items[ id ]
	
	if !Item then return end

	if !ply._ClientSetting || ply._ClientSetting[ id ] == nil then
		return Item.Default
	end
	
	return ply._ClientSetting[ id ]

end

function ClientSettings:IsDefault( ply )
	for k, Item in pairs( ClientSettings.Items ) do
		if ClientSettings:Get( ply, k ) != Item.Default then
			return false
		end				
	end	
	return true
end

function ClientSettings:ResetValues( ply )
	for k, v in ipairs( ClientSettings.Items ) do
		if v.Var && !ply[ v.Var ] then
			ply[ v.Var ] = v.Default
		end
	end
end

hook.Add("PlayerAuthed", "ResetClientSettings", function( ply )
	ClientSettings:ResetValues( ply )
end )