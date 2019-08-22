
function GTowerItems:UpdateBankGuiItem( PANEL )

	function PANEL:GetItem()
		return self.Id && GTowerItems:GetBankItem( self.Id )
	end

	function PANEL:GetCommandId()
		return self.Id .. "-2"
	end

	function PANEL:AllowPosition( panel )
		return true
	end

	function PANEL:IsEquipSlot()
		return false // none of the bank slots are equip slots
	end
	PANEL.Equippable = PANEL.IsEquipSlot

	function PANEL:OnStopDrag()
		if GTowerItems.DropInvPanel then
			GTowerItems.DropInvPanel:CheckClose()
		end
	end

	function PANEL:ForcePosition()
		GTowerItems:InvalidateBankLayout()
	end

	function PANEL:UpdateDrawBackground()
		self.CanDrawBackground = true
	end

	function PANEL:Equippable()
		return false
	end

	function PANEL:GetOriginalParent()
		if GTowerItems.BankMainGui && GTowerItems.BankMainGui.ItemList then
			return GTowerItems.BankMainGui.ItemList:GetCanvas()
		end
	end

end
