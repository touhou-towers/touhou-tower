local WeaponPistols = {
	"weapon_9mm",
	"weapon_flakhandgun",
	"weapon_scifihandgun",
	"weapon_silencers"
}

local WeaponRifles = {
	"weapon_plasmaautorifle",
	"weapon_tommygun",
	"weapon_rcp120"
}

local WeaponShotguns = {
	"weapon_doublebarrel",
	"weapon_sonicshotgun"
}

local WeaponSpecial = {
	"weapon_sniperrifle",
	"weapon_tnt"
}

local weaponTable = {}
local StartWeapon

function GM:GetSelectedWeapons()
	table.Empty(weaponTable)

	StartWeapon = table.Random(WeaponPistols)

	table.insert(weaponTable, "weapon_adrenaline")
	table.insert(weaponTable, StartWeapon)
	table.insert(weaponTable, WeaponPistols[math.random(1, 4)])
	table.insert(weaponTable, WeaponRifles[math.random(1, 3)])
	table.insert(weaponTable, WeaponShotguns[math.random(1, 2)])
	table.insert(weaponTable, WeaponSpecial[math.random(1, 2)])

	return weaponTable
end

function GM:GetStartWeapon()
	return StartWeapon
end
