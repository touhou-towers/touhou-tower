

-----------------------------------------------------
if string.StartWith( game.GetMap(), "gmt_build" ) then return end

module( "Scoreboard.Payouts", package.seeall )

// TAB

hook.Add( "ScoreBoardItems", "PayoutsTab", function()
	return vgui.Create( "ScoreboardPayoutsTab" )
end )

TAB = {}
TAB.Order = 2

function TAB:GetText()
	return "PAYOUTS"
end

function TAB:OnOpen()
end

function TAB:CreateBody()
	return vgui.Create( "ScoreboardPayouts", self )
end

vgui.Register( "ScoreboardPayoutsTab", TAB, "ScoreboardTab" )

// PAYOUTS

/**
	Main payout panel that holds all the payouts
*/
local PAYOUTS = {}
PAYOUTS.Height = 48

function PAYOUTS:Init()

	self.Grid = vgui.Create( "DGrid", self )
	self.Grid:SetCols( 2 )
	self.Grid:SetRowHeight( PAYOUTS.Height + 2 )

	for id, payout in pairs( payout.Payouts ) do
		self:AddPayout( payout )
	end

	self:InvalidateLayout()

end

function PAYOUTS:AddPayout( payout )

	local panel = vgui.Create( "ScoreboardPayout", self )
	panel:SetPayout( payout )

	self.Grid:AddItem( panel )

end

function PAYOUTS:PerformLayout()

	local width = self:GetWide() / 2 - 1 

	self.Grid:SetColWide( width )

	for _, panel in pairs( self.Grid.Items ) do
		panel:SetWide( width - 2 )
		panel:InvalidateLayout()
	end

	local Padding = 2

	if self.Grid then

		self.Grid:SetPos( Padding, 4 )
		self.Grid:SetWide( self:GetWide() - Padding * 2 )	
		self.Grid:InvalidateLayout( true )

		self:SetTall( self.Grid:GetTall() + Padding * 2 + 4 )

	end

end

function PAYOUTS:OnOpenTab()

end

function PAYOUTS:Paint( w, h )

	surface.SetDrawColor( Scoreboard.Customization.ColorDark )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

end

vgui.Register( "ScoreboardPayouts", PAYOUTS, "PanelList" )



/**
	A single payout "block"
*/
local PAYOUT = {}
PAYOUT.Padding = 6
PAYOUT.DescriptionColor = Color( 210, 210, 210, 255 )

function PAYOUT:Init()

	self:SetTall( PAYOUTS.Height )

	self.Title = Label("", self)
	self.Title:SetFont("SCPayoutTitle")
	self.Title:SetTextColor( Scoreboard.Customization.ColorFont )
	self.Title:SetZPos( 0 )

	self.Description = Label("", self)
	self.Description:SetFont("SCPayoutDescription")
	self.Description:SetTextColor( Scoreboard.Customization.ColorAwardsDescription )

	self.GMC = Label("", self)
	self.GMC:SetFont("SCPayoutGMC")
	self.GMC:SetTextColor( Scoreboard.Customization.ColorAwardsDescription )

	self.Pays = Label("PAYS", self)
	self.Pays:SetFont("SCPayoutGMCSmall")
	self.Pays:SetTextColor( Scoreboard.Customization.ColorAwardsDescription )

end

function PAYOUT:SetPayout( payout )

	self.Title:SetText( payout.Name )
	self.Description:SetText( string.gsub( payout.Desc, "\n", " " ) )

	if payout.GMC > 0 then
		self.GMC:SetText( payout.GMC .. " GMC" )
	else
		self.Pays:SetVisible( false )
	end

	self:InvalidateLayout()

end

function PAYOUT:PerformLayout()

	self.Title:SizeToContents()
	self.Description:SizeToContents()
	self.GMC:SizeToContents()
	self.Pays:SizeToContents()

	self.Title:CenterVertical( .3 )
	self.Description:CenterVertical( 0.73 )
	self.Title:AlignLeft( self.Padding )
	self.Description:AlignLeft( self.Padding )

	self.Pays:AlignRight( self.GMC:GetWide() + 3 + self.Padding )
	self.GMC:AlignRight( self.Padding )

	self.Pays.y = self.Description.y + 4
	self.GMC.y = self.Description.y

end

function PAYOUT:Paint( w, h )

	surface.SetDrawColor( Scoreboard.Customization.ColorBackground )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

end

vgui.Register("ScoreboardPayout", PAYOUT )