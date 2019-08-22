
GTowerItems.ToolTip = nil
GTowerItems.ToolTipPanel = nil

function GTowerItems:ShowTooltip( title, description, panel )
	
	if !GTowerItems.ToolTip then
		GTowerItems.ToolTip = vgui.Create("InvToolTip")
	else
		GTowerItems.ToolTip:SetHidding( false )
	end
	
	GTowerItems.ToolTipPanel = panel
	
	GTowerItems.ToolTip:SetText( title, description )

end

function GTowerItems:HideTooltip()
	
	if GTowerItems.ToolTip then
		GTowerItems.ToolTip:SetHidding( true )
	end

end

function GTowerItems:RemoveTooltip()
	
	if GTowerItems.ToolTip then
		GTowerItems.ToolTip:Remove()
	end
	
	GTowerItems.ToolTip = nil

end

hook.Add("GtowerHideMenus", "HideInvToolTip", function()
	if GTowerItems then GTowerItems:HideTooltip() end
end )