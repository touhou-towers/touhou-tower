
ClientSettings.AdminGUI = nil
ClientSettings.AdminPly = nil
ClientSettings.AdminAllowSend = true

local function TimerCaller( PlyId, id, value )
	RunConsoleCommand( "gmt_clientset", PlyId, id, value )
end
	
function ClientSettings:OpenAdmin( ply )

	ClientSettings:CloseAdmin()
	
	if !IsValid( ply ) then	
		return
	end
	
	local PlyId = ply:EntIndex()
	ClientSettings.AdminPly = ply
	
	GtowerMainGui:GtowerShowMenus()
	
	self.AdminGUI = vgui.Create("DFrame")
	self.AdminGUI:SetSize( 300, 500 )
	self.AdminGUI:SetPos( ScrW() - self.AdminGUI:GetWide() * 1.1, 100 )
	self.AdminGUI:SetVisible( true )
	self.AdminGUI:SetTitle("Settings - " .. ply:GetName())
	self.AdminGUI.Close = function()
		ClientSettings:CloseAdmin()
	end
	
	local Form = vgui.Create("DForm", self.AdminGUI )
	Form:SetName( ply:Name() )
	Form:SetPos( 5, 30 )
	Form:SetWide( self.AdminGUI:GetWide() - 10 )
	
	local CheckBoxes = {}
	local Wangs = {}
	local Input = {}
	
	if self.DEBUG then Msg("Adding items to menu: ", ply, "\n") end
	
	for k, v in ipairs( ClientSettings.Items ) do
	
		if v.Disabled != true then
			if self.DEBUG then Msg("\tAdding ", v.Name, " (".. k .. ")\n") end
		
			if v.NWType == "Bool" then
				table.insert( CheckBoxes, k )
			elseif ClientSettings:IsNumber( v.NWType ) && v.MinValue && v.MaxValue then
				table.insert( Wangs, k )
			else
				table.insert( Input, k )
			end
		end
	
	end
	
	local function SortingItems( a, b)
		local ItemA = ClientSettings.Items[ a ].Order
		local ItemB = ClientSettings.Items[ b ].Order
		
		if ItemA then
			if ItemB then
				if ItemA == ItemB then
					return a < b
				end
			
				return ItemA < ItemB
			end
			return true
		end
		return a < b
	end
	
	table.sort( CheckBoxes, SortingItems )
	table.sort( Wangs, SortingItems )
	table.sort( Input, SortingItems )
	
	for _, id in ipairs( CheckBoxes ) do
		
		local Item = self:GetItem( id )
		local checkbox = Form:CheckBox( Item.Name )
		
		checkbox:SetValue( ClientSettings:Get( ply, id ) )
		checkbox.OnChange = function( _, value )
			if ClientSettings.AdminAllowSend == true then
				RunConsoleCommand( "gmt_clientset", PlyId, id, tostring(value) )
			end
		end	
		Item.Panel = checkbox
		Item.PanelUpdateFunc = "SetValue"
		
	end
	
	for _, id in ipairs( Wangs ) do
		
		local Item = self:GetItem( id )
		local Wang = Form:NumSlider( Item.Name, nil, Item.MinValue, Item.MaxValue, Item.Decimals or 2 )

		Wang:SetValue( ClientSettings:Get( ply, id ) )
		Wang.OnValueChanged = function( _, value )
			if ClientSettings.AdminAllowSend == true then
				timer.Create(id .. "-ClientSettingAdminWang", 0.3, 1, TimerCaller, PlyId, id, tostring(value) )
			end
		end	
		Item.Panel = Wang
		Item.PanelUpdateFunc = "SetValue"
	
	end
	
	for _, id in ipairs( Input ) do
		
		local Item = self:GetItem( id )
		local button = Form:Button( Item.Name .. ": " .. ClientSettings:Get( ply, id ) )
		
		button.DoClick = function() Derma_StringRequest(  ply:Name() , 
			Item.Name, 
			ClientSettings:Get( ply, id ),
			function( out ) RunConsoleCommand( "gmt_clientset", PlyId, id, out ) end,
			nil,
			"Update", 
			"Cancel" 
		) end
		Item.Panel = button
		Item.PanelUpdateFunc = "SetText"
		
	end
	
	
	local ResetButton = Form:Button( "RESET" )
	ResetButton:SetFont( "smalltitle" )
	ResetButton.DoClick = function() 
		Derma_Query( 
			"Are you sure you want to reset " .. ply:GetName() .. " settings?",
			"RESET " .. ply:GetName(),
			"Yes", function() RunConsoleCommand( "gmt_clientreset", ply:EntIndex() ) end,
			"No", EmptyFunction
		)
	end
	
	
	Form:InvalidateLayout( true )
	self.AdminGUI:SetTall( Form:GetTall() + 35 )
	
end

function ClientSettings:CloseAdmin()

	for k, v in pairs( ClientSettings.Items ) do
		if v.Panel then
			v.Panel:Remove()
			v.Panel = nil
		end
	end

	if self.AdminGUI then
		self.AdminGUI:Remove()
	end
	
	self.AdminGUI = nil
	GtowerMainGui:GtowerHideMenus()	
end

hook.Add("CanCloseMenu", "AdminTheater", function()
	if ClientSettings.AdminGUI then
		return false
	end
end )	

hook.Add("ClientSetting", "UpdateAdminPanel", function( ply, id, val )

	if ply != ClientSettings.AdminPly then
		return
	end

	local Item = ClientSettings:GetItem( id )

	ClientSettings.AdminAllowSend = false
	if IsValid( Item.Panel ) && Item.PanelUpdateFunc then
		if Item.PanelUpdateFunc == "SetText" then
			Item.Panel[ Item.PanelUpdateFunc ]( Item.Panel, Item.Name .. ": " .. val )
		else
			Item.Panel[ Item.PanelUpdateFunc ]( Item.Panel, val )
		end
	end
	ClientSettings.AdminAllowSend = true
	
end )

hook.Add("PlyDoubleClick", "OpenAdminPanel", function( ply )
	if !IsValid(ply) then return end

	if LocalPlayer():IsAdmin() && (!ply:IsAdmin() || ply == LocalPlayer() ) then
		ClientSettings:OpenAdmin( ply )
		return true
	end
end )