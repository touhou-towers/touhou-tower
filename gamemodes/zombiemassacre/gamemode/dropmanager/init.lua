AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

DropManager.DropTypes = { "zm_item_points", "zm_item_weapon" }

DropManager.DROP_CHANCE		= 0.20 // 20% chance to drop either points or a weapon

DropManager.RARE_CHANCE		= 0.05 // %5 for a rare weapon
DropManager.UNCOMMON_CHANCE	= 0.20 // %20 for an uncommon weapon

DropManager.WeaponTable = {}
DropManager.WeaponTable[ DropManager.COMMON ] = {}
DropManager.WeaponTable[ DropManager.UNCOMMON ] = {}
DropManager.WeaponTable[ DropManager.RARE ] = {}

// sets up our tiered weapons
function DropManager.Initialize()

	for k, v in pairs( weapons.GetList() ) do

		if ( v.Base == "weapon_zm_base" && v.ClassName != "weapon_zm_handgun" && v.ClassName != "weapon_zm_special_focus" ) then

			local tier = v.Tier or DropManager.COMMON

			DropManager.Debug( "Adding weapon '" .. tostring( v.Classname ) .. "' to tier: " .. tostring( tier ) .. "\n" )

			table.insert( DropManager.WeaponTable[ tier ], v )

		end

	end
end

// logarithmic funciton that will determine the chance to drop a weapon based on the number of players
// obtained via curve fitting of data:
// players -> chance
// 1 -> .10
// 4 -> .25
// 8 -> .30
function DropManager.DropFunc( numPlayers )
	return 0.0978972 * math.log( 2.88049 * numPlayers )
end

// determines if we should drop anything at all
function DropManager.ShouldDrop( pos )

	local r = math.Rand( 0, 1 )

	local chance = DropManager.DropFunc( #player.GetAll() )

	DropManager.Debug( "ShouldDrop r: " .. tostring( r ) .. " chance: " .. tostring( chance ) .. "\n" )

	if r <= chance then
		return true
	end

	return false

end

// determines if an item or weapon should drop, then drops it
function DropManager.RandomDrop( pos )

	if ( !DropManager.ShouldDrop( pos ) ) then return end

	return DropManager.Drop( pos )

end

// forcefully drop a random item (points or weapon)
function DropManager.Drop( pos )

	local max = #DropManager.DropTypes
	local rand = math.random( 1, max )

	local drop = DropManager.DropTypes[ rand ]

	DropManager.Debug( "Drop rand: " .. tostring( rand ) .. " drop: " .. tostring( drop ) .. " pos: " .. tostring( pos ) .. "\n" )

	// if we specify a position, lets spawn it
	if ( pos ) then

		local ent = ents.Create( drop )

		ent:SetPos( pos )
		ent:Spawn()

	else
		// otherwise lets just tell the caller what it should drop
		return drop
	end

end

// gets a random weapon based on the tier system
// guaranteed to give a weapon
function DropManager.GetRandomWeapon()

	local rand = math.Rand( 0, 1 )
	local tier = DropManager.COMMON


	if ( rand <= DropManager.RARE_CHANCE ) then
		tier = DropManager.RARE
	elseif ( rand <= DropManager.UNCOMMON_CHANCE ) then
		tier = DropManager.UNCOMMON
	else
		tier = DropManager.COMMON
	end
	--print("TIER: "..tier)
	local wepRand = math.random( 1, #DropManager.WeaponTable[ tier ] )

	local wep = DropManager.WeaponTable[ tier ][ wepRand ]
	--print(wep.Classname)
	--DropManager.Debug( "GetRandomWeapon rand: " .. tostring( rand ) .. " tier: " .. tostring( tier ) )
	--DropManager.Debug( " wepRand: " .. tostring( wepRand ) .. " wep: " .. tostring( wep.Classname ) .. "\n" )

	return wep

end
