local weapons = {
	{
		"weapon_9mm",
		"weapon_flakhandgun",
		"weapon_scifihandgun",
		"weapon_silencers"
	},
	{
		"weapon_plasmaautorifle",
		"weapon_tommygun",
		"weapon_rcp120"
	},
	{
		"weapon_doublebarrel",
		"weapon_sonicshotgun"
	},
	{
		"weapon_sniperrifle",
		"weapon_tnt"
	}
}

local weaponTable = {}
local StartWeapon

function GM:GetSelectedWeapons(ply)
	table.Empty(weaponTable)

	table.insert(weaponTable, "weapon_adrenaline")

	StartWeapon = table.Random(WeaponPistols)
	table.insert(weaponTable, StartWeapon)
	for i = 1, 4 do
		if ply.IsVirus then
			if GAMEMODE.virusWeapons[i] then
				local length = #weapons[i]
				table.insert(weaponTable, weapons[i][math.random(1, length)])
			end
		else
			if GAMEMODE.playerWeapons[i] then
				local length = #weapons[i]
				table.insert(weaponTable, weapons[i][math.random(1, length)])
			end
		end
	end

	return weaponTable
end

function GM:GetStartWeapon()
	return StartWeapon
end
