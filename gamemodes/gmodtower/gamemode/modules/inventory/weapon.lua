
local function WeaponOverride( ply )
	return hook.Call("WeaponOverride", GAMEMODE, ply )
end

hook.Add( "PlayerLoadout", "GiveWeaponsInv", function( ply )

	if WeaponOverride( ply ) == true then
		return
	end

	local ItemList = ply:GetEquipedItems()

	for _, Item in pairs( ItemList ) do
		GTowerItems:GiveWeapon( ply, Item )	
	end
	
	ply:GiveAmmo(100, "slam", true )

end )

concommand.Add("gmt_selwep", function( ply, command, args )

	if !ply:Alive() || #args != 1 || WeaponOverride( ply ) == true then
		return
	end
	
	local WeaponId = tonumber( args[1] )
	
	if !WeaponId || !GTowerItems:IsEquipSlot( WeaponId )  then
		return
	end
	
	local Slot = GTowerItems:NewItemSlot( ply, WeaponId )
	local Item = Slot:Get()

	if Item && Item:IsWeapon() then
		GTowerItems:GiveWeapon( ply, Item, true ) 
	end	
	
end )

function GTowerItems:CanHaveWeapon( ply, ClassName )
	if !ClientSettings || ply:IsAdmin() then return true end
	
	if ClassName == "weapon_physgun" then
		return ClientSettings:Get( ply, "GTAllowPhysGun" )
	end
	
	if ClassName == "weapon_physcannon" && ClientSettings:Get( ply, "GTAllowGravGun" ) == true then
		return true
	end
	
	if ClientSettings.DEBUG then
		Msg(ply, " can have ".. ClassName .. ": " , ClientSettings:Get( ply, "GTAllowWeapons" ) , "\n")
	end
	
	if ClientSettings:Get( ply, "GTAllowWeapons" ) == false then
		return false
	end
	
	if hook.Call("AllowWeapons", GAMEMODE, ply ) == false then
		return false
	end
	
	return true
end

function GTowerItems:GiveWeapon( ply, item, select )
	
	if IsValid( ply:GetVehicle() ) then
		return
	end
	
	if !item:IsWeapon() then
		return
	end
	
	local ClassName = item.ClassName
	
	if !ClassName || (item.WeaponSafe == false && GTowerItems:CanHaveWeapon( ply, ClassName ) == false) then
		return
	end	
	
	ply.CanPickupWeapons = true
	
	if !ply:HasWeapon( ClassName ) then
		ply:Give( ClassName )
	end

	if select == true then
		ply:SelectWeapon( ClassName )
	end
	
	local Weapon = ply:GetWeapon( ClassName )
	
	if IsValid( Weapon ) then
		Weapon.InventoryItem = item
	end
	
	ply.CanPickupWeapons = false
	
end


local function PlayerCheckWeapons( ply )

	if !ply.SQL || WeaponOverride( ply ) == true then
		return
	end
	
	local PosibleWeapons = {}
	local ItemList = ply:GetEquipedItems()
	
	for _, Item in ipairs( ItemList ) do
		if Item:IsWeapon() then
			table.insert( PosibleWeapons, Item.ClassName )
		end
	end
	
	for _, v in pairs(ply:GetWeapons()) do
		local Class = v:GetClass()
		
		if !table.HasValue( PosibleWeapons, Class ) || GTowerItems:CanHaveWeapon( ply, Class ) == false then
			v:Remove()
		end
		
	end
	
end

hook.Add("InvSwap", "CheckWeaponsSwap", PlayerCheckWeapons )
hook.Add("InvDrop", "CheckWeaponsDrop", PlayerCheckWeapons )
hook.Add("InvRemove", "CheckWeaponRemove", PlayerCheckWeapons )

hook.Add("ClientSetting", "GTCheckWeapons", function( ply, id, val )
	
	local Name = ClientSettings:GetName( id )
	
	if Name == "GTAllowGravGun" || Name == "GTAllowPhysGun" || Name == "GTAllowWeapons" then
		PlayerCheckWeapons( ply )
	end

end )

hook.Add( "PlayerCanPickupWeapon", "ShouldGrabWeapon", function(ply, wep)
	
	if ply.CanPickupWeapons == true || wep._CanPickUpWeapon == false then
		return
	end

	timer.Create( "PlyCheckWeapons"..ply:EntIndex(), 0.1, 1, function() PlayerCheckWeapons( ply ) end)
	if ply:InvGrabEnt( wep, nil ) != false then
		wep:Remove()
		wep._CanPickUpWeapon = false
	end
	
	return false
end )
