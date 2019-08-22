
function GTowerItems.OnRemoveEquip( Slot, Item )

	if Item.OnUnEquip then
		SafeCall( Item.OnUnEquip, Item, Slot )
	end

	if Item.UniqueEquippable then
		Slot.Ply:SetEquipment( Item.EquipType, nil )
	end

	Item:RemoveEquipEntity()

	GTowerItems.CheckEquipEntityItems( Slot.Ply )

end

function GTowerItems.OnEquip( Slot, Item )

	if Item.OnEquip then
		SafeCall( Item.OnEquip, Item, Slot )
	end

	if Item.UniqueEquippable then
		Slot.Ply:SetEquipment( Item.EquipType, Item )
	end

	GTowerItems.CheckEquipEntityItems( Slot.Ply )

end

local function DelayedCheck( ply )

	if GAMEMODE.AllowEquippables != true then
		return
	end

	//Player SQL has not yet been loaded
	if !ply.SQL || !ply.SQL.Connected then
		return
	end

	local List = ply:GetEquipedItems()

	//First check if the there is any OnlyEquippable
	for _, item in pairs( List ) do

		if item.EquippableEntity == true && item.OnlyEquippable == true then

			//Hur... Remove everything else, just leave this
			//First check if the entity is created
			item:CheckEquipEntity()

			local Ent = item:GetEquipEntity()

			//It exists! Remvoe everything else
			if IsValid( Ent ) then

				for _, item2 in pairs( List ) do
					if item2.EquippableEntity == true && item2 != item then

						if item2.OverrideOnlyEquippable == true then
							item:CheckEquipEntity()
						else
							item2:RemoveEquipEntity()
						end
					end
				end

				return
			end

		end

	end

	//Now that we checked that, let's go through everything else
	for _, item in pairs( List ) do

		if item.EquippableEntity && item.OnlyEquippable != true then
			item:CheckEquipEntity()
		end

	end

end

function GTowerItems.CheckEquipEntityItems( ply )
	timer.Simple( 0, function() DelayedCheck( ply ) end)
end

hook.Add("PlayerDeath", "CheckEquipItems", GTowerItems.CheckEquipEntityItems )
hook.Add("PlayerSilentDeath", "CheckEquipItems", GTowerItems.CheckEquipEntityItems )
hook.Add("Location", "CheckEquipItems", GTowerItems.CheckEquipEntityItems )
hook.Add("PlayerSpawn", "CheckEquipItems", GTowerItems.CheckEquipEntityItems )

hook.Add("PlayerDisconnected", "RemoveFlame", function( ply )

	if !ply._InvEquipItems then
		return
	end

	for _, Item in pairs( ply._InvEquipItems ) do

		local Ent = Item:GetEquipEntity()

		if IsValid( Ent ) then
			Ent:Remove()
		end

	end

end )

concommand.Add("gmt_debugequip", function( ply, cmd, args )

	local List = ply:GetEquipedItems()

	for k, v in pairs( List ) do

		print( k .. ". " .. v.Name )
		print( "\t Ent: " ..tostring( v:GetEquipEntity() ) )

	end

end )
