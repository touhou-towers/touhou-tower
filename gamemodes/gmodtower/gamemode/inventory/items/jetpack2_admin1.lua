
ITEM.Name = "Admin Jetpack (10)"
ITEM.Base = "jetpack1"
ITEM.Description = ""
ITEM.Model = "models/gmod_tower/jetpack.mdl"
ITEM.DrawModel = true

ITEM.IsJetpack = true
ITEM.JetpackPower = 10
ITEM.JetpackFuel = 300.0
ITEM.JetpackRecharge = 0.01
ITEM.JetpackStartRecharge = 0.01
ITEM.ExtraOnFloor = 25 //Amount of force the player has extra when jumping from the floor

ITEM.StoreId = false

function ITEM:IsMyEnt()
	return false
end
