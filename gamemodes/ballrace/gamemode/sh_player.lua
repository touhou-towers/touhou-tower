local meta = FindMetaTable("Player")

if not meta then
	return
end

function meta:SetColorAll(color)
	self:SetColor(color)

	if color.a < 255 then
		self:SetRenderMode(RENDERMODE_TRANSALPHA)
	else
		self:SetRenderMode(RENDERMODE_NORMAL)
	end

	-- equipment color
	if not self.CosmeticEquipment then
		return
	end

	for k, v in pairs(self.CosmeticEquipment) do
		if IsValid(v) then
			v:SetColor(color)
			if color.a < 255 then
				v:SetRenderMode(RENDERMODE_TRANSALPHA)
			else
				v:SetRenderMode(RENDERMODE_NORMAL)
			end
		end
	end
end
