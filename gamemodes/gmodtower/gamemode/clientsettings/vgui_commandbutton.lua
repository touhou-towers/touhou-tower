
--Thanks to overv for this (and garry ofcourse)
local PANEL = {}

AccessorFunc( PANEL, "m_bAlt", 			"Alt" )
AccessorFunc( PANEL, "m_bSelected", 	"Selected" )

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	self:SetContentAlignment( 4 )
	self:SetTextInset( 5, 0 )
	self:SetTall( 15 )

end

function PANEL:Paint( w, h )

	if ( !self:GetSelected() ) then
		if ( !self.m_bAlt ) then return end
		surface.SetDrawColor( 255, 255, 255, 10 )
	else
		surface.SetDrawColor( 50, 150, 255, 250 )
	end

	if self.CheckBoolean ~= nil and self.Checkbox ~= nil then
		if ClientSettings:GetSelectedPlayer() == nil then
			self.Checkbox:SetValue( false )
		else
				self.Checkbox:SetValue( ClientSettings:Get( ClientSettings:GetSelectedPlayer(), self.id ) )
		end
	end

	if self.Input then self:SetText(self.Text..": "..ClientSettings:Get( ClientSettings:GetSelectedPlayer(), self.id )) end

	self:DrawFilledRect()

end

/*---------------------------------------------------------
   Name: OnMouseMoved
---------------------------------------------------------*/
function PANEL:OnCursorMoved(  )

	self:ResetFocus( self )

end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed(  )
    --Maybe you will need this on gmt
	if !ClientSettings.AdminAllowSend then return nil end
	if ClientSettings:GetSelectedPlayer() == nil then return nil end
	if ClientSettings:GetSelectedPlayer() == LocalPlayer() and !LocalPlayer():IsSuperAdmin() then
		Derma_Message("You are not allowed to edit yourself", "ERROR", "Ok")
		return nil
	end
	if self.ResetPlayer != nil then
		Derma_Query(
			"Are you sure you want to reset " .. ClientSettings:GetSelectedPlayer():GetName() .. " settings?",
			"RESET " .. ClientSettings:GetSelectedPlayer():GetName(),
			"Yes", function() RunConsoleCommand( "gmt_clientreset", ClientSettings:GetSelectedPlayer():EntIndex() ) end,
			"No", EmptyFunction
		)
	return end

	if self.Input != nil then
	Derma_StringRequest( ClientSettings:GetSelectedPlayer():Name(),
			self.Text,
			ClientSettings:Get( ClientSettings:GetSelectedPlayer(), self.id ),
			function( out ) RunConsoleCommand( "gmt_clientset", ClientSettings:GetSelectedPlayer():EntIndex(), self.id, out ) end,
			nil,
			"Update",
			"Cancel"
	)
	return end

	if self.CheckBoolean == nil or !self.Checkbox:GetChecked() then
		RunConsoleCommand( "gmt_clientset", ClientSettings:GetSelectedPlayer():EntIndex(), self.id, tostring(self.Command) )
	else
	-- maybe i should use just "false" instead of tostring(false)?
		RunConsoleCommand( "gmt_clientset", ClientSettings:GetSelectedPlayer():EntIndex(), self.id, tostring(false) )
	end

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:OnSelect()

	// Override

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:PerformLayout()

	if ( self.Checkbox ) then

		self.Checkbox:AlignRight( 4 )
		self.Checkbox:CenterVertical()

	end

end

function PANEL:AddCheckBox()

	if ( !self.Checkbox ) then
		self.Checkbox = vgui.Create( "DCheckBox", self )
		self.Checkbox.OnMousePressed = function() self:OnMousePressed() end
	end

	self:InvalidateLayout()

end

function PANEL:ResetFocus()
	for _, v in pairs(ClientSettings.PlayerMenuItems) do
	if !v.Control.IgnoreResetFocus then
		if v.Control ~= self then
			v.Control:SetSelected( false )
		else
			v.Control:SetSelected( true )
		end
	end
	end
end

function PANEL:GetSelfItem()
	for _, v in pairs(ClientSettings.PlayerMenuItems) do
		if v.Control == self then
			return v
		end
	end
end

vgui.Register( "CommandButton", PANEL, "DButton" )
