
ITEM.Name = "Alcohol Bottle"
ITEM.Description = "Get drunk."
ITEM.Model = "models/gmod_tower/boozebottle.mdl"
ITEM.ClassName = "alcohol_bottle"
ITEM.UniqueInventory = false
ITEM.DrawModel = true
ITEM.CanUse = true
ITEM.MoveSound = "glass"

ITEM.StoreId = GTowerItems.BarStoreId
ITEM.StorePrice = 8

if SERVER then
	function ITEM:OnUse()

		if IsValid( self.Ply ) && self.Ply:IsPlayer() then
			self.Ply:Drink()

			return GTowerItems:CreateById( ITEMS.empty_bottle, self.Ply )
		end

		return self
	end
end
