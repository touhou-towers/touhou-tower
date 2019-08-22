
GTowerStore.PlayerData = {}
local meta = FindMetaTable( "Player" )

if meta then 
	
	function meta:GetLevel( id )
		return GTowerStore:GetPlyLevel( self, id )
	end
	function meta:SetLevel( id, level )
		GTowerStore:SetPlyLevel( self, id, level )
	end
	function meta:GetMaxLevel( id )
		return GTowerStore:GetPlyMaxLevel( self, id )
	end
	function meta:SetMaxLevel( id, level )
		GTowerStore:SetPlyMaxLevel( self, id, level )
	end
	
	meta.MaxLevel = meta.GetMaxLevel
	meta.Level = meta.GetLevel
	
else
	Msg("WTF?! NO Player Meta Table Found!\n")
end

//Instead of having two different functions that almost does the same thing, why not just make a extra variable
function GTowerStore:GetPlyLevel( ply, id, tbl )

	if !id then
		return
	end

	if type( id ) == "string" then
		id = self:GetItemByName( id )
	end
	
	tbl = tbl or ply.GTowerLevels
	
	if tbl && tbl[ id ] then
		return tbl[ id ]
	end
	
	local Item = self:Get( id )
	
	if !Item then
		SQLLog('error', "Invaid item id: " .. tostring(id) .. debug.traceback() .. "\n" )
		return
	end
	
	if Item.prices[ 1 ] == 0 then
		return 1
	end
	
	return 0
end


function GTowerStore:GetPlyMaxLevel( ply, id )
	return 	self:GetPlyLevel( ply, id, ply.GTowerMaxLevels )
end


function GTowerStore:SetPlyLevel( ply, id, level )
	if type( id ) == "string" then
		id = self:GetItemByName( id )
	end
	
	local MaxLevel = ply:GetMaxLevel( id )
	local NewLevel = math.Clamp( tonumber( level or 1 ), 1, MaxLevel )
	local Item = GTowerStore:Get( id )
	
	if Item.onbuy then
		SafeCall( Item.onbuy, ply, id )
	end
	
	if !ply.GTowerLevels then
		ply.GTowerLevels = {}
	end
	
	if Item.upgradable == true then
		ply.GTowerLevels[ id ] = NewLevel
	end
	
	if !ply.GTowerMaxLevels[ id ] then
		ply.GTowerMaxLevels[ id ] = 0
	end
	
	hook.Call("PlayerLevel", GAMEMODE, ply, id, Item.upgradable )
end


function GTowerStore:SetPlyMaxLevel( ply, id, level )
	if type( id ) == "string" then
		id = self:GetItemByName( id )
	end
	
	level = math.Clamp( tonumber( level ), 1, 16 )
	
	local Item = self:Get( id )
	
	if level > #Item.prices then
		level = #Item.prices
	end
	
	if !ply.GTowerLevels then
		ply.GTowerMaxLevels = {}
	end
	
	if Item.upgradable == true then
		ply.GTowerMaxLevels[ id ] = level
	end
	
	if ply:GetLevel( id ) > level then //Don't let they stay above limit
		ply:SetLevel( id, level ) 
	end
	
	--if !ply.GTowerLevels[ id ] then
	--	ply.GTowerLevels[ id ] = 0
	--end
	
end


hook.Add("SQLStartColumns", "SQLStoreData", function()
	SQLColumn.Init( {
		["column"] = "levels",
		["selectquery"] = "HEX(levels) as levels",
		["selectresult"] = "levels",
		["update"] = function( ply ) 
			return GTowerStore:GetPlayerData( ply )
		end,
		["defaultvalue"] = function( ply )
			GTowerStore:DefaultValue( ply )
		end,
		["onupdate"] = function( ply, val ) 
			GTowerStore:UpdateInventoryData( ply, val )
		end
	} )
end )

function GTowerStore:DefaultValue( ply )
	ply.GTowerLevels = {}
	ply.GTowerMaxLevels = {}
end

function GTowerStore:UpdateInventoryData( ply, val )
	
	ply.GTowerLevels = {}
	ply.GTowerMaxLevels = {}
	
	local Data = Hex( val )
	
	while Data:CanRead() do
		local ItemId = Data:SafeRead()
		local MaxLevel = Data:SafeRead()
		local Level = Data:SafeRead()
		
		ply.GTowerLevels[ ItemId ] = Level
		ply.GTowerMaxLevels[ ItemId ] = MaxLevel
		
	end

end 


function GTowerStore:GetPlayerData( ply )

	if self.SQLCanSave == false || !ply.GTowerLevels then //Do not allow to save data with wrong IDs
		return nil
	end
	
	local Data = Hex()
	
	for k, v in pairs( ply.GTowerLevels ) do
		
		Data:SafeWrite( k )
		Data:SafeWrite( v )
		Data:SafeWrite( ply.GTowerMaxLevels[ k ] )
		
	end
	
	return Data:Get()

end


