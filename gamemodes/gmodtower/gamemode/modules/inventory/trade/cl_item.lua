
function GTowerTrade:UpdateMyItem( PANEL )

	function PANEL:GetItem()
		return self.ActualItem
	end
	
	function PANEL:GetCommandId()
		Error("Function should not called" .. debug.traceback() )
	end
	
	function PANEL:OnMousePressed( mc )
		if mc != MOUSE_RIGHT then
			self.OldActualItem:OnMousePressed( mc )
		end
		
		GTowerTrade:RemoveItem( self.OldCommandId )
	end

	function PANEL:OnStopDrag()
		if GTowerItems.DropInvPanel then
			GTowerItems.DropInvPanel:CheckClose()
		end
	end
	
	function PANEL:ForcePosition()
		
	end
	
	function PANEL:UpdateDrawBackground()
		self.CanDrawBackground = true
	end

	function PANEL:Equippable()
		return false
	end

	function PANEL:GetOriginalParent()
		if GTowerTrade.Gui && GTowerTrade.Gui.MyList then
			return GTowerTrade.Gui.MyList:GetCanvas()		
		end
	end

end

function GTowerTrade:UpdateOtherItem( PANEL )

	function PANEL:GetItem()
		return self.ActualItem
	end
	
	function PANEL:GetCommandId()
		Error("Function should not called" .. debug.traceback() )
	end
	
	function PANEL:OnMousePressed( mc )
		return
	end

	function PANEL:OnStopDrag()
		return
	end
	
	function PANEL:ForcePosition()
		
	end
	
	function PANEL:UpdateDrawBackground()
		self.CanDrawBackground = true
	end

	function PANEL:Equippable()
		return false
	end
	
	function PANEL:AllowPosition()
		return false
	end

	function PANEL:GetOriginalParent()
		if GTowerTrade.Gui && GTowerTrade.Gui.OtherList then
			return GTowerTrade.Gui.OtherList:GetCanvas()		
		end
	end

end