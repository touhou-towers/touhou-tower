
ITEM.Name = "Painkillers"
ITEM.Description = "Heal all your wounds. Damage, drunk, fire, freeze."
ITEM.Model = "models/props_lab/jar01a.mdl"
ITEM.ClassName = "gmt_painkiller"
ITEM.UniqueInventory = false
ITEM.DrawModel = true
ITEM.CanUse = true

ITEM.StoreId = 21
ITEM.StorePrice = 15

if SERVER then
	function ITEM:OnUse()
		if IsValid( self.Ply ) && self.Ply:IsPlayer() then
			self.Ply:Extinguish()
			self.Ply:SetHealth( 100 )
			self.Ply:Freeze( false )
			self.Ply:UnDrunk()
			PostEvent( self.Ply, "ppainkiller" )
			self.Ply:AddAchivement( ACHIVEMENTS.PILLSHERE, 1 )

			return nil
		end
		return self
	end
end
