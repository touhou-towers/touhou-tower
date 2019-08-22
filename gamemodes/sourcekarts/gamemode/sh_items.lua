
-----------------------------------------------------
local meta = FindMetaTable( "Player" )
if !meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

if SERVER then

	util.AddNetworkString( "ItemReady" )
	util.AddNetworkString( "ItemGet" )
	util.AddNetworkString( "ItemUse" )
	util.AddNetworkString( "ItemClear" )

	function meta:GiveRandomItem()

		local itemid = items.GetRandom( self:GetPosition() )
		self:GiveItem( itemid or 1 )

	end

	function meta:GiveItem( itemid )

		local item = items.Get( itemid )
		if !item then return end

		// Give the item
		self:SetItem( itemid )
		self:SetItemUses( item.MaxUses or 1 )
		self:SetItemReady( false )

		// Start the animation
		net.Start( "ItemGet" )
			net.WriteInt( itemid, 8 )
		net.Send( self )

		// Play a sound
		local kart = self:GetKart()
		if IsValid( kart ) then
			kart:EmitSound( "GModTower/sourcekarts/effects/powerup_get.wav" )
		end

	end

	net.Receive( "ItemReady", function( len, ply )
		MsgN( ply, "READY!")
		ply:SetItemReady( true )
	end )

	function meta:ClearItems()

		net.Start( "ItemClear" )
		net.Send( self )

		self:SetItem( 0 )
		self:SetItemUses( 0 )
		self:SetItemReady( false )
		self:SetActiveItem( 0 )
		self:RemoveSpawnedItem()

	end

	function meta:UseItem( dir, power )

		local item = items.Get( self:GetItem() )
		if !item then return end

		local kart = self:GetKart()
		if !IsValid( kart ) then return end
		if self:IsGhost() then return end

		if !self:CanUseItem() /*|| kart:IsSpinning()*/ then return end

		// Check if the item can be used right now
		if item.CanStart && !item:CanStart( self, kart ) then
			return
		end

		// Reduce item use
		if self:GetItemUses() then self:SetItemUses( self:GetItemUses() - 1 ) end

		// Shoot direction
		self.ItemDir = dir

		// Start item
		item:Start( self, kart, power )

		// Network
		net.Start( "ItemUse" )
		net.Send( self )

		// End item
		if item.End && item.Length then

			// Set the item to active
			self:SetActiveItem( self:GetItem() )

			// Delay the end
			timer.Simple( item.Length, function()

				if IsValid( self ) && IsValid( kart ) then
					item:End( self, kart )
					self:SetActiveItem( 0 )
				end

			end )

		else
			self:SetActiveItem( 0 )
		end

		// Remove item as its been used
		if !self:GetItemUses() || self:GetItemUses() <= 0 then
			self:SetItem( 0 )
		end

		// Effects
		self:EmitSound( "GModTower/sourcekarts/effects/powerup.wav", 100, 50 )

	end

	function meta:GetShootItemSpawn( kart, dir, forward, up )
		return kart:GetPos() + ( kart:GetForward() * ( ( forward or 48 ) * ( dir or 1 ) ) ) + kart:GetUp() * ( up or 32 )
	end

	function meta:CheckShootItem( kart )

		local spawnpos = self:GetShootItemSpawn( kart, self.ItemDir )
		local trace = util.TraceLine( { start = kart:GetPos(), endpos = spawnpos, filter = kart } )
		if trace.HitWorld then
			return false
		end

		return true

	end

	function meta:ShootItem( class, force, target )

		local kart = self:GetKart()
		if !IsValid(kart) then return end

		local ent = ents.Create( class )
		if !IsValid(ent) then return end

		local angles = kart:GetAngles()

		if self.ItemDir == -1 then
			angles:RotateAroundAxis( angles:Right(), 180 )
		end

		ent:SetPos( self:GetShootItemSpawn( kart, self.ItemDir ) )
		ent:SetAngles( angles )
		ent:SetOwner( self )
		ent:SetPhysicsAttacker( self )
		ent:Spawn()
		ent:Activate()

		--ent:RemoveTime()

		// Push forward
		local phys = ent:GetPhysicsObject()
		local vel = kart:GetVelocity():Length()
		local dir = kart:GetForward() * ( self.ItemDir or 1 )
		local force = force or 1000

		if IsValid( target ) then
			ent:SetTarget( target )
			dir = ent:GetTargetAngles():Forward()
		end

		if IsValid( phys ) then
			dir.p = 0
			phys:SetVelocity( dir * ( force + vel ) )
		end

	end

	function meta:DropItem( class )

		local kart = self:GetKart()
		if !IsValid(kart) then return end

		local ent = ents.Create( class )
		if !IsValid(ent) then return end

		ent:SetPos( self:GetShootItemSpawn( kart, 1, -80, 8 ) )
		ent:SetAngles( kart:GetAngles() )
		ent:SetOwner( self )
		ent:SetPhysicsAttacker( self )
		ent:Spawn()
		ent:Activate()

		--ent:RemoveTime()

		return ent

	end

	function meta:FlingItem( class, force )

		local kart = self:GetKart()
		if !IsValid(kart) then return end

		local ent = ents.Create( class )
		if !IsValid(ent) then return end

		ent:SetPos( self:GetShootItemSpawn( kart, 1, -80, 8 ) )
		ent:SetAngles( kart:GetAngles() )
		ent:SetOwner( self )
		ent:SetPhysicsAttacker( self )
		ent:Spawn()
		ent:Activate()

		--ent:RemoveTime()

		// Fling
		local phys = ent:GetPhysicsObject()
		local force = force or 200
		local dir = kart:GetForward() * ( force * 1.5 ) + kart:GetUp() * ( force / 2 )

		if IsValid( phys ) then
			phys:SetVelocity( dir )
		end

	end

	function meta:SpawnItem( class )

		local kart = self:GetKart()
		if !IsValid(kart) then return end

		local ent = ents.Create( class )
		if !IsValid(ent) then return end

		ent:SetPos( kart:GetPos() )
		ent:SetAngles( kart:GetAngles() )

		ent:SetParent( kart )

		ent:SetOwner( self )
		ent:Spawn()
		ent:Activate()

		if ent.SetDirection then
			ent:SetDirection( kart, self.ItemDir )
		end

		if IsValid( self.SpawnedEntity ) then
			self.SpawnedEntity:Remove()
		end

		self.SpawnedEntity = ent

	end

	function meta:RemoveSpawnedItem()

		if IsValid( self.SpawnedEntity ) then
			self.SpawnedEntity:Remove()
			self.SpawnedEntity = nil
		end

	end

	function meta:GetSpawnedItem()

		if IsValid( self.SpawnedEntity ) then
			return self.SpawnedEntity
		end

	end

	concommand.Add( "sk_useitem", function( ply, cmd, args )

		if !IsValid( ply ) || !ply:Alive() then return end

		ply:UseItem( tonumber( args[1] or 1 ), tonumber( args[2] or 0 ) )

	end )

	concommand.Add( "sk_item", function( ply, cmd, args )

		if !DEBUG || !ply:IsAdmin() then return end
		ply:GiveItem( tonumber( args[1] or 1 ) )

	end )

end

function meta:CanUseItem()
	return self:GetItem() and self:IsItemReady() and not self:HasActiveItem() and not IsValid( self.SpawnedEntity )
end

function meta:GetItem()
	return self:GetNWInt("Item")
end
function meta:SetItem( item ) self:SetNWInt("Item", item) end

function meta:IsHoldingItem( name )
	if self:GetItem() == 0 then return end
	local item = items.Get( self:GetItem() )

	return item.Name == name
end

function meta:IsActiveItem( name )
	if not self:HasActiveItem() then return end
	local item = self:GetActiveItem()

	return item.Name == name
end

function meta:HasActiveItem()
	return self:GetNWInt("ActiveItem") != 0
end

function meta:GetActiveItem()
	if not self:HasActiveItem() then return end
	return items.Get( self:GetNWInt("ActiveItem") )
end
function meta:SetActiveItem( item ) self:SetNWInt("ActiveItem", item) end

function meta:GetItemUses() return self:GetNWInt("ItemUses") or 0 end
function meta:SetItemUses( uses ) self:SetNWInt("ItemUses", uses) end

function meta:IsItemReady() return self:GetNWBool("ItemReady") or false end
function meta:SetItemReady( ready ) self:SetNWBool("ItemReady", ready) end


module( "items", package.seeall )

Folder = string.sub( GM.Folder, 11 ) .. "/gamemode/items/"
List = {}
MaxDuplicateClasses = 2

COMMON = 0
UNCOMMON = 1
RARE = 2

UNCOMMON_CHANCE	= 0.80 // % for an uncommon pickup
RARE_CHANCE		= 0.50 // % for a rare pickup

local function IsLua( name )
	return string.sub( name, -4 ) == ".lua"
end

local function ValidName( name )
	return name != "." && name != ".." && name != ".svn"
end

function Load()

	local fileList = file.Find( Folder .. "*.lua", "LUA" )

	for _, name in pairs( fileList ) do

		local loadName = "items/" .. name

		if !IsLua( loadName ) then continue end
		if !ValidName( loadName ) then continue end

		if SERVER then
			AddCSLuaFile( loadName )
		end

		include( loadName )

	end

end

function Register( class )
	local id = table.insert( List, class )
	//MsgN( "Registered item #" .. id .. ": " .. class.Name )
end

function Get( id )
	return List[ id ]
end

function GetRandom( pos, tbl )

	tbl = tbl or List

	local rand = math.Rand( 0, 1 )
	local tier = COMMON

	if rand <= RARE_CHANCE then
		tier = RARE
	elseif rand <= UNCOMMON_CHANCE then
		tier = UNCOMMON
	else
		tier = COMMON
	end

	local tieredItems = {}
	for id, item in pairs( tbl ) do

		//MsgN( pos, " ", item.MaxPos, " ", pos >= item.MaxPos )

		// BATTLE ITEMS ONLY
		if GAMEMODE:GetState() == STATE_BATTLE then
			if !item.Battle then
				continue
			end

		// RACE POSITION
		else
			if pos < item.MaxPos then
				continue
			end
		end

		if ( ( item.Chance or COMMON ) <= tier ) then
			table.insert( tieredItems, id )
		end

	end

	/*for _, itemid in pairs( tieredItems ) do
		MsgN( Get( itemid ).Name )
	end*/

	return table.Random( tieredItems )

end
Load()

local function GetTierName( tier )

	if tier == RARE then return "R" end
	if tier == UNCOMMON then return "UC" end
	if tier == COMMON then return "C" end

end

local devcvar = GetConVar("developer")
hook.Add( "HUDPaint", "ShowItemList", function()

	if !DEBUG then return end
	if !devcvar:GetBool() then return end

	// Maps
	local items = items.List
	local off = 300

	surface.SetFont( "ChatFont" )
	for id, item in pairs( items ) do

		local tw, th = surface.GetTextSize( item.Name )
		local tier = GetTierName( item.Chance )

		draw.SimpleText( id .. ". " .. item.Name .. " | " .. tier .. " | <=" .. item.MaxPos, "ChatFont", 50, off, color_white, color_black, TEXT_ALIGN_LEFT, nil, 1 )
		off = off + 15

	end

end )
