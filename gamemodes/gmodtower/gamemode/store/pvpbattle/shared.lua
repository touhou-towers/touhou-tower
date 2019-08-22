
PvpBattle = PvpBattle or {}
PvpBattle.StoreId = 3
PvpBattle.WeaponList = {}
PvpBattle.DefaultWeapons = {}
PvpBattle.WeaponsIds = {}

PvpBattle.DEBUG = false

hook.Add("GTowerStoreLoad", "AddPVPBattleWeapons", function()
	
	local WeaponList = weapons.GetList()
	PvpBattle.WeaponList = {}
	PvpBattle.DefaultWeapons = {}
	PvpBattle.WeaponsIds = {}
	
	for _, v in pairs( WeaponList ) do
		
		if v.Base == "weapon_pvpbase" && v.StoreBuyable == true then
			
			local UniqueName = "PVPW" .. string.Replace( v.ClassName, "weapon_", "" )
			
			local NewItemId = GTowerStore:SQLInsert( {
				Name = v.PrintName,
				description = v.Description,
				unique_Name = UniqueName,
				price = v.StorePrice,
				model = v.WorldModel,
				ClientSide = true,
				upgradable = true,
				storeid = PvpBattle.StoreId
			} )
			
			if v.Slot && v.SlotPos then
				local Slot = v.Slot + 1
				local SlotId = v.SlotPos + 1
				
				if !PvpBattle.WeaponList[ Slot ] then
					PvpBattle.WeaponList[ Slot ] = {}
				end
				
				PvpBattle.WeaponList[ Slot ][ SlotId ] = UniqueName
				
				if SERVER && v.StorePrice == 0 then
					PvpBattle.DefaultWeapons[ Slot ] = NewItemId
				end
				
			else
				Msg("NO SLOT FOUND FOR WEAPON: " , v.ClassName , "\n")
			end
			
			if SERVER then
				v.StoreItemId = NewItemId
				PvpBattle.WeaponsIds[ NewItemId ] = v.ClassName
			end
			
		end
		
	end

end )