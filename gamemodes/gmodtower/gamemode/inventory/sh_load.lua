
local ListOnWaiting = {}
local LookingForBase = {}

function GTowerItems:CreateStoreItem( item )
	if ListOnWaiting then
		table.insert( ListOnWaiting, item )
	else
		GTowerItems:CreateStoreItemEnd( item )
	end
end

hook.Add("GTowerStoreLoad", "InventoryLoadStore", function()
	if !ListOnWaiting then return end
	
	for _, v in pairs( ListOnWaiting ) do
		GTowerItems:CreateStoreItemEnd( v )
	end
	
	ListOnWaiting = nil
end )

// insane hash algorithm
function simplehash(str)
	local hash = 1

	for i=1, #str do
		hash = (2 * hash) + string.byte(str, i)
	end
	hash = hash % 55565

	return hash
end

local function SetBase( Item, base )

	//base.__index = base

	setmetatable( Item, {
		__index = base
	})
	
	Item.BaseClass = base
	
end

local function CreateNewItem( Name, Item )

	//Check for the item base, and set the meta table to it
	if Item.Base then	
		//If the base exists, already set the limit
		if ITEMS[ Item.Base ] then
			SetBase( Item, GTowerItems.Items[ ITEMS[ Item.Base ] ] )
		else
			//If the base does not exist yet, put it on the waiting list
			if !LookingForBase[ Item.Base ] then
				LookingForBase[ Item.Base ] = { Item }
			else
				table.insert( LookingForBase[ Item.Base ], Item )
			end
			
			SetBase( Item, inventory.baseitem )
			
		end	
	else
		//If there is no base, just give the default base
		SetBase( Item, inventory.baseitem )
	end
	
	//Grab the unique ID and unique Name
	Item.UniqueName = string.gsub( Name , ".lua", "")
	Item.MysqlId = simplehash(Item.UniqueName)
	
	//Preache the model if necessary
	if Item.Model && Item.Model != "" then	
		if table.HasValue( TowerModules.LoadedModules, "inventory" ) then
			util.PrecacheModel( Item.Model )
		end
		Item.ComparableModel = string.lower( Item.Model )
	end
	
	//Check if the ID already exists
	if GTowerItems.Items[ Item.MysqlId ] || Item.MysqlId > 65535 then
		print("id collision", Item.MysqlId, Item.UniqueName, GTowerItems.Items[Item.MysqlId].UniqueName)
		
		//Not Error... You don't want the whole thing stopping because of one item.
		print("id collision")
	end
	
	//Store the items into tables
	ITEMS[ Item.UniqueName ] = Item.MysqlId
	GTowerItems.Items[ Item.MysqlId ] = Item
	
	//Put the item into store if necessary
	if Item.StoreId then
		GTowerItems:CreateStoreItem( Item )
	end
	
	//Prepare the model to be wearable if necessary
	if Item.ModelItem == true then
		GTowerItems.PrepareItemModel( Item )
	end
	
	//Finding if there is any items waiting to receive it's dependancy
	if LookingForBase[ Item.UniqueName ] then
		for _, v in ipairs( LookingForBase[ Item.UniqueName ] ) do
			SetBase( v, Item )
		end
		
		LookingForBase[ Item.UniqueName ] = nil
	end

	return Item
end

function GTowerItems.RegisterItem( Name, tbl )
	return CreateNewItem( Name, tbl )
end		

hook.Add("Initialize", "InitItems", function()

	local Dir = "gmodtower/gamemode/inventory/items/"

	for key, Name in pairs( file.Find( Dir .. "*.lua", "LUA") ) do
		if Name != "." && Name != ".." && Name != ".svn" then
			ITEM = {}
			
			local FilePath = Dir .. Name
			
			if SERVER then
				AddCSLuaFile( FilePath )
			end
			
			include( FilePath )
			
			if ( ITEM.EquipType == "Weapon" ) then
				ITEM.InvCategory = "weapon"
			end
			
			CreateNewItem( Name, ITEM )
			
			ITEM = nil
		end
	end
	
	local function ReturnTrue()
		return true
	end

	local Dir = "gmodtower/entities/weapons/"
	
	for k, v in pairs( file.Find( Dir .. "*.lua", "LUA" ) ) do
		if v != "." && v != ".." && v != ".svn" then

			ITEM = {}
			SWEP = {Primary={}, Secondary={}}
			
			include( Dir .. v .. "/shared.lua" )

			ITEM.Name = SWEP.PrintName
			ITEM.ClassName = v
			ITEM.Description = ""
			ITEM.Model = SWEP.WorldModel or ""
			ITEM.WeaponSafe = SWEP.WeaponSafe or false
			ITEM.NoBank = SWEP.NoBank or false
			ITEM.UniqueInventory = false
			ITEM.DrawModel = true
			ITEM.DrawName = true
			ITEM.IsWeapon = ReturnTrue
			ITEM.EquipType = "Weapon"
			ITEM.Equippable = true
			ITEM.UniqueEquippable = false
			ITEM.InvCategory = "weapon"

			SafeCall( CreateNewItem, v, ITEM )
			
			SWEP = nil
			ITEM = nil
			
		end
	end
	
	//Load all the items in the one giant file
	include("gmodtower/gamemode/inventory/itemslist.lua")
	
	hook.Call("LoadInventory", GAMEMODE )
	hook.GetTable().LoadInventory = nil

	for id, tbl in pairs(GTowerItems.Items) do
		if !tbl.NoBank then
			table.insert(GTowerItems.SortedItems, tbl)
		end
	end

	table.sort( GTowerItems.SortedItems, function(a, b)
		return a.UniqueName < b.UniqueName
	end )
	
	//Make sure there aren't any items without it's base
	for _, list in pairs( LookingForBase ) do
		for _, item in pairs( list ) do
			print("Item without base: ", item.UniqueName )
		end
	end
	
end)
