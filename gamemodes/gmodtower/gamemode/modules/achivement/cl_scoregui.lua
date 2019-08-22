
hook.Add("GTowerScoreBoard", "AddAchivements", function()

	return {
		["Name"] = "Awards",
		["vgui"] = "GTowerAchivMain"
	}

end)



local PANEL = {}

//local IsSectionOpen = {}
local localScoreGui = nil

function PANEL:Init()

	localScoreGui = self
	self.Groups = {}

	for k, v in pairs( GTowerAchivements.Achivements ) do

		local Group = v.Group or "Lobby"

		if !self.Groups[ Group ] then
			self.Groups[ Group ] = vgui.Create("DCollapsibleCategory", self)
			self.Groups[ Group ]:SetLabel( Group )

			local CategoryList = vgui.Create( "DPanelList", panel )
			CategoryList:SetAutoSize( true )
			CategoryList:EnableHorizontal( true )
			CategoryList:EnableVerticalScrollbar( true )
			CategoryList:SetSpacing( 6 )
			CategoryList:SetPadding( 3 )

			self.Groups[ Group ]:SetContents( CategoryList )

		end

		local NewItem = vgui.Create( "GTowerAchivItem" )
		NewItem:SetId( k )

		v.panel = NewItem
		self.Groups[ Group ].Contents:AddItem( NewItem )

	end

	for k, v in pairs( self.Groups ) do
		v:SetCookieName( k .. ".AchiTabOpen" )
	end

	self.CloseAllButton = vgui.Create("DButton", self )
	self.CloseAllButton:SetText( T("closeall") )
	self.CloseAllButton:SizeToContents()
	self.CloseAllButton:SetSize( self.CloseAllButton:GetWide() + 6, self.CloseAllButton:GetTall() + 3 )
	self.CloseAllButton.DoClick = self.CloseAll

	//Time check on the function
	self.NextUpdate = CurTime() + 1.0
	GTowerAchivements:RequestUpdate()
end

function PANEL:ScoreboardOpen()
	GTowerAchivements:RequestUpdate()
	self.NextUpdate = CurTime() + 1.0
end

function PANEL:Think()
	if CurTime() > self.NextUpdate then
		GTowerAchivements:RequestUpdate()
		self.NextUpdate = CurTime() + 1.0
	end
end

function PANEL:CloseAll( btn )
	if ValidPanel( localScoreGui ) then

		for _, v in pairs( localScoreGui.Groups ) do
			if v:GetExpanded() == true then
				v:Toggle()
				v:InvalidateLayout()
			end
		end

		self:InvalidateLayout()
	end
end

function PANEL:Removing()

end


function PANEL:PerformLayout()

	local CurY = 3

	for k, v in pairs( self.Groups ) do

		v:SetPos( 3, CurY )
		v:SetWide( self:GetWide() - 6 )
		v:InvalidateLayout(true)

		CurY = CurY + v:GetTall() + 2
	end

	for _, v in pairs( GTowerAchivements.Achivements ) do

		if ValidPanel( v.panel ) then
			v.panel:SetWidth( self:GetWide() / 2 - 10 )
		end

	end

	self.CloseAllButton:SetPos( self:GetWide() - self.CloseAllButton:GetWide() - 5, CurY )


	CurY = CurY + self.CloseAllButton:GetTall() + 2

	self:SetSize( self:GetWide(), CurY )
	self.ItemParent:SetTargetTall( CurY, self )

	GTowerAchivements:RequestUpdate()

end

vgui.Register("GTowerAchivMain", PANEL )


hook.Add("AchivementUpdate", "GTowerUpdateGUI", function()

	/*for _, v in pairs( GTowerAchivements.Achivements ) do
		if ValidPanel( v.panel ) then
			v.panel:InvalidateLayout()
		end
	end*/

end )
