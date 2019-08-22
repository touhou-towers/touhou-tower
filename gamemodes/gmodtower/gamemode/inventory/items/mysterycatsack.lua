
ITEM.Name = "Mysterious Cat Sack"
ITEM.Description = "An admin has passed this mysterious cat sack along to you.... what could be inside it?"
ITEM.Model = "models/gmod_tower/catbag.mdl"
ITEM.ClassName = "mysterycatsack"
ITEM.UniqueInventory = false
ITEM.DrawModel = true
ITEM.CanUse = true

ITEM.StoreId = 8
ITEM.StorePrice = 100

ITEM.Nyan = {	"GModTower/lobby/catsack/nyan1.wav",
		"GModTower/lobby/catsack/nyan2.wav",
		"GModTower/lobby/catsack/nyan3.wav" }
if SERVER then
	function ITEM:OnUse()
		if IsValid( self.Ply ) && self.Ply:IsPlayer() then
			self.Ply:EmitSound( self.Nyan[math.random(1, #self.Nyan)] )
			self.Ply:AddAchivement( ACHIVEMENTS.CURIOUSCAT, 1 )

			return GTowerItems:CreateById( GTowerItems.CreateMysteryItem(self.Ply), self.Ply )
		end
		
		return self
	end
end