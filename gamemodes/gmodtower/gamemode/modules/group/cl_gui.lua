
function GTowerGroup:RefreshGui()
	
	if GTowerGroup.MainGui == nil then
		GTowerGroup.MainGui = vgui.Create("Panel")
	end
	
	
	local AvatarSize = 32
	local HealthSize = 250
	local Spacing = 3
	local CurY = 0
	
	for _, ply in pairs( player.GetAll() ) do
		if ply._GroupUI && !table.HasValue( GTowerGroup.GroupMembers, ply ) then
			ply._GroupUI:Remove()
			ply._GroupUI = nil
		end
	end
	
	for _, ply in pairs(GTowerGroup.GroupMembers) do
		if IsValid( ply ) && ply != LocalPlayer() then
			
			if !ValidPanel( ply._GroupUI ) then
				//Player does not have a gui, make one
				local NewGui = vgui.Create("GtowerGroupPlayer", GTowerGroup.MainGui )
				
				NewGui:SetPlayer( ply )
				NewGui:SetIsOwner( ply == GTowerGroup.GroupOwner )
				
				ply._GroupUI = NewGui
				
			else
				ply._GroupUI:InvalidateLayout()
			end
			
			ply._GroupUI:SetSize( AvatarSize + HealthSize, AvatarSize )
			ply._GroupUI:SetPos( 0, CurY )
			
			CurY = CurY + Spacing + ply._GroupUI:GetTall()
			
		end
	end
	
	//Set the size, and positon
	GTowerGroup.MainGui:SetSize( AvatarSize + HealthSize, CurY - Spacing )	
	GTowerGroup.MainGui:SetPos( Spacing, Spacing )
	
	if GTowerGroup.LeaveBtn then
		GTowerGroup.LeaveBtn:SetPos( GTowerGroup.MainGui.x, GTowerGroup.MainGui.y + GTowerGroup.MainGui:GetTall() + Spacing )
	end
end