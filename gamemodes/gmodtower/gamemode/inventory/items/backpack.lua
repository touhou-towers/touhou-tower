
ITEM.Name = "Backpack"
ITEM.Description = "Get access to your trunk at any place"
ITEM.Model = "models/gmod_tower/backpack.mdl"
ITEM.DrawModel = true
ITEM.Equippable = true
ITEM.CanUse = true
ITEM.UseDesc = "Open"

ITEM.UniqueEquippable = true
ITEM.EquipType = "Backpack"
ITEM.EquippableEntity = true

ITEM.StoreId = 8
ITEM.StorePrice = 2500

if SERVER then

	function ITEM:CreateEquipEntity()

		local JetpackEnt = ents.Create("gmt_jetpack")

		if IsValid( JetpackEnt ) then
			JetpackEnt:SetModel( self.Model )
			JetpackEnt:SetOwner( self.Ply )
			JetpackEnt:SetParent( self.Ply )
			JetpackEnt.Owner = self.Ply
			JetpackEnt._GTInvSQLId = false

			JetpackEnt:SetPos( self.Ply:GetPos() + Vector(0,0,32) )
			JetpackEnt:Spawn()
		end

		return JetpackEnt

	end

	/*function ITEM:OnEquip()
		if ClientSettings then
			self.Ply:SetSetting( "GTAllowPortableTrunk", true )
		end
	end

	function ITEM:OnUnEquip()
		if ClientSettings then
			self.Ply:SetSetting( "GTAllowPortableTrunk", false )
		end
	end*/

	function ITEM:OnUse()

		if ClientSettings then

			if IsValid( self.Ply ) && self.Ply:IsPlayer() then
				/*if !self.Ply:GetSetting( "GTAllowPortableTrunk" ) then
					self.Ply:MsgT( "BackpackShouldEquip" )
					return true
				end*/

				if self.Ply:AllowBank() then
					GTowerItems:OpenBank( self.Ply )
				end

			end

		end

		return true
	end
end
