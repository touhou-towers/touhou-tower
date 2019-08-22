
local CurWeapon = 1
local LastWeapon = 1

local function GetOrderWeapon( step )

	local NextItem = CurWeapon
	local Count = 0
	local MaxCount = GTowerItems.EquippableSlots * 2

	while Count < MaxCount do
		//Msg("looking at: " .. NextItem .. "\n")

		NextItem = NextItem + step
		local Item = GTowerItems:GetItem( NextItem )

		if Item && Item:IsWeapon() then
			return NextItem
		end

		if NextItem == CurWeapon then
			return // No weapon found
		end

		if NextItem >= GTowerItems.EquippableSlots then
			NextItem = 0
		end

		if NextItem <= 1 then
			NextItem = GTowerItems.EquippableSlots + 1
		end

		Count = Count + 1
	end

end

local function ChangeToWeapon( id )

	if !GTowerItems:IsEquipSlot( id ) then
		return
	end

	if hook.Call("CanMousePress", GAMEMODE ) == false then
		return
	end

	LastWeapon = CurWeapon
	CurWeapon = id

	RunConsoleCommand("gmt_selwep", CurWeapon )

end

hook.Add("PlayerBindPress", "WeaponChange", function( ply, bind, pressed)
    local weapon = ply:GetActiveWeapon()
    local weapon_class = ""
    if IsValid(weapon) then
        weapon_class = weapon:GetClass()
    end

    if string.sub( bind, 1, 4 ) == "slot" then

        ChangeToWeapon( tonumber( string.sub( bind, 5 ) ) )
        return

    end
end )
