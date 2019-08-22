
hook.Add("LoadInventory","LoadSizeChangingPotion", function()

	local Potions = {
		{ "Tiny Potion", 				0.1, 0, nil, Color( 0, 255, 255 ) },
		{ "Smaller Potion", 			0.25, 0, 1000, Color( 0, 0, 255 ) },
		{ "Small Potion", 				0.5,  1, 600, Color( 255, 0, 255 ) },
		{ "Medium Potion", 				0.75, 1, 350, Color( 0, 255, 0 ) },
		{ "Normal Potion", 				1,  2, 150, Color( 255, 255, 0 ) },
		{ "Slightly Bigger Potion", 	1.2,  2, 500, Color( 10, 140, 255 ) },
		{ "Large Potion", 				1.6, 3, nil, Color( 255, 0, 0 ) }
	}

	local ITEM = {}

	if SERVER then
		function ITEM:ApplyScale( temp, defaultsize )

			if not string.StartWith(game.GetMap(),"gmt_build") then return end

			local size = defaultsize or self.PlayerChangeSize

			if self.Ply:Alive() && not self.Ply:InVehicle() then

				-- No need to apply this
				if GTowerModels.Get( self.Ply ) == size then
					return false
				end

				local plyPos = self.Ply:GetPos() + Vector(0,0,5) -- Add 5 to ignore the ground a bit

				-- Trace
				local tr = util.TraceHull( {
					start = plyPos,
					endpos = plyPos,
					maxs = (Vector( 16,  16,  72 ) * size) + Vector(2, 2, 2), -- Make our bounding box a bit bigger
					mins = (Vector( -16, -16, 0 ) * size) - Vector(2, 2, 0), -- Make our bounding box a bit bigger
					filter = self.Ply
				} )

				if not tr.HitWorld then

						GTowerModels.Set( self.Ply, size )

					self.Ply:EmitSound( "GModTower/inventory/use_potion.wav", 80, math.Clamp( 80, 150, 100 / size ) )
					self._TraceFailed = false

					return true

				else

					if not self._TraceFailedNotified then
						if defaultsize then
							self.Ply:Msg2("You are too close to a wall or ceiling to revert to default size.")
						else
							self.Ply:Msg2("You are too close to a wall to use your "..self.Name..".")
						end
					end

					self._TraceFailedNotified = true

					return false

				end

			end
		end
	end


		function ITEM:OnEquip()
			return self:ApplyScale( true ) -- temp
		end

		function ITEM:OnUnEquip()
			return self:ApplyScale( false, 1 )
		end

		function ITEM:OnUse()
			self:ApplyScale( true ) -- temp
			return true
		end

	ITEM.Model = "models/gmod_tower/aigik/bottle1.mdl"
	ITEM.DrawModel = true
	ITEM.CanUse = true
	ITEM.CanEntCreate = true
	ITEM.DrawName = true
	ITEM.MoveSound = "glass"
	ITEM.Equippable = true
	ITEM.UseDesc = "Drink"
	ITEM.EquipType = "Potion"
	ITEM.UniqueEquippable = true


	for _, potion in pairs( Potions ) do
		local NEWITEM = table.Copy( ITEM )

		NEWITEM.Name = potion[1]
		NEWITEM.PlayerChangeSize = potion[2]
		NEWITEM.ModelSkinId = potion[3]
		NEWITEM.Description = "Change your size to " .. potion[2] .. " the original."

		if potion[2] == 1 then
			NEWITEM.Description = "Change your size back to normal."
		else
			NEWITEM.Description = "Change your size to " .. potion[2] * 100 .. "% of normal."
		end

		NEWITEM.Description = NEWITEM.Description .. " Potions are unlimited use."

		if potion[4] then
			NEWITEM.StoreId = 17
			NEWITEM.StorePrice = potion[4]
		else
			NEWITEM.StoreId = 29
			NEWITEM.StorePrice = 4000 * potion[2]
			NEWITEM.Tradable = false
		end

		GTowerItems.RegisterItem("potion" .. potion[2], NEWITEM )
	end


end )
