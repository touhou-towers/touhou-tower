local meta = FindMetaTable("Player")

if not meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:IsHidden()
	return false
end

function meta:GetTranslatedModel()
	return util.TranslateToPlayerModel(self:GetModel())
end

function meta:PowerStart()
	if self:GetNWBool("IsPowerCombo") then
		self:AddAchivement(ACHIVEMENTS.ZMCOMBO, 1)
		local CLASS = classmanager.Get(string.lower(self:GetNWString("ClassName")))
		CLASS:PowerStart(self)
	end
end

function meta:UseItem()
	local CLASS = classmanager.Get(string.lower(self:GetNWString("ClassName")))

	if not IsValid(self.SpecialItem) and math.floor(self:GetNWInt("LastItem") - CurTime()) <= 0 then
		self.SpecialItem = ents.Create(CLASS.SpecialItem)
		self.SpecialItem:SetPos(self:GetPos())
		self.SpecialItem:SetOwner(self)
		self.SpecialItem:Spawn()
		self:SetNWInt("LastItem", CurTime() + 60)
	end
end

function meta:IsHealthFull()
	return self:Health() >= self:MaxHealth()
end

function meta:MaxHealth()
	return 100
end

function meta:AddPoints(sum)
	self:SetNWInt("Points", (self:GetNWInt("Points") + sum))
	umsg.Start("HUDNotes")
	umsg.Char(2)
	umsg.Short(sum)
	umsg.Short(self:EntIndex())
	umsg.End()
end

function meta:AddCombo()
	self:SetNWInt("Combo", (self:GetNWInt("Combo") + 1))
	self.ComboTime = CurTime() + 5
end

function meta:GetBackWeapon()
	local weps = self:GetWeapons()
	for _, wep in pairs(weps) do
		if wep ~= self:GetActiveWeapon() then
			return wep
		end
	end
end

function meta:SpeedUp()
	self:SetLaggedMovementValue(2)
end

function meta:ResetSpeeds()
	self:SetLaggedMovementValue(1)
end

function meta:StripAllInventory()
	self:StripWeapons()
	self:Give("weapon_zm_handgun")
end
