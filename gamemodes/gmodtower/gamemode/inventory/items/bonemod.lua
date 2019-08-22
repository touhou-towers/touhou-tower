
-----------------------------------------------------
ITEM.Name = "Bone Normalizer"
ITEM.Description = "Normalize your bones back to their normal state."
ITEM.Model = "models/weapons/w_vir_adrenaline.mdl"
ITEM.DrawModel = true
ITEM.Equippable = true
ITEM.EquipType = "Bonemod"
ITEM.UniqueEquippable = true
ITEM.CanUse = false
ITEM.DrawName = true
ITEM.CanEntCreate = false

ITEM.StorePrice = 200

ITEM.BoneModID = BONEMOD_NORMAL

BONEMOD_NORMAL = 0
BONEMOD_CUTE = 1
BONEMOD_FAT = 2
BONEMOD_SKINNY = 3
BONEMOD_DKMODE = 4
BONEMOD_SMALLHEAD = 5
BONEMOD_BIGHEAD = 6
BONEMOD_FLAT = 7
BONEMOD_ALIEN = 8
BONEMOD_ADDICT = 9
BONEMOD_BOUNCER = 10
BONEMOD_BIGFOOT = 11
BONEMOD_CARTOON = 12
BONEMOD_PINHEAD = 13
BONEMOD_LADY = 14
BONEMOD_HANDY = 15
BONEMOD_HEADLESS = 16
BONEMOD_BIGPANTS = 17
BONEMOD_STICK = 18

if SERVER then
	function ITEM:OnEquip( locationchange )
		if BoneMod then
			BoneMod.SetBoneMod( self.Ply, self.BoneModID )
			if self.BoneModID == 4 /*and not locationchange*/ then

				if !self.Ply._DKModeSoundDelay || CurTime() > self.Ply._DKModeSoundDelay then
					self.Ply:EmitSound( "GModTower/inventory/use_dkmode.wav", 50 )
					self.Ply._DKModeSoundDelay = CurTime() + 5
				end

			end
		end
	end

	function ITEM:OnUnEquip()
		if BoneMod then
			BoneMod.SetBoneMod( self.Ply, BONEMOD_NORMAL )
		end
	end
end
