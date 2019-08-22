
module( "Scoreboard.Awards", package.seeall )

// TAB

hook.Add( "ScoreBoardItems", "AwardsTab", function()
	return vgui.Create( "ScoreboardAwardsTab" )
end )

TAB = {}
TAB.Order = 2

function TAB:GetText()
	return "AWARDS"
end

function TAB:OnOpen()
	/*if ValidPanel( self.Body ) then
		self.Body:OnOpen()
	end*/
end

function TAB:CreateBody()
	return vgui.Create( "ScoreboardAwards", self )
end

vgui.Register( "ScoreboardAwardsTab", TAB, "ScoreboardTab" )

// AWARDS

MATERIALS = 
{
	Award = Scoreboard.GenTexture( "ScoreboardAward", "bg_award" ),
	AwardAchieved = Scoreboard.GenTexture( "ScoreboardAwardAchieved", "bg_award_achieved" ),
	TrophyIcon = surface.GetTextureID( "icons/trophy" ),
}


local function RequestUpdate()
	RunConsoleCommand("gmt_reqachi")
end

/**
	Main awards panel that holds all the categories
*/
AWARDS = {}

AWARDS.LineHeight = 64
AWARDS.GroupNames = {
	[1] = "General",
	//[20] = "Holiday",
	[2] = "Milestones",
	[3] = "Suite",
	[4] = "Arcade",
	[5] = "Minigames",
	[6] = "Ball Race",
	[7] = "PVP Battle",
	[8] = "Virus",
	[9] = "UCH",
	//[10] = "Zombie Massacre",
	[11] = "Monotone",
	//[12] = "Minigolf",
}

AWARDS.GamemodeNames = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil,
	[6] = "ballrace",
	[7] = "pvpbattle",
	//[8] = "virus",
	//[9] = "ultimatechimerahunt",
	//[10] = "zombiemassacre",
	[11] = "monotone",
	//[12] = "minigolf",
}

AWARDS.NextUpdate = 0
AWARDS.Tabs = {}

function AWARDS:Init()

	self.ActiveTab = nil
	local firstTab = nil

	self.Groups = {}

	for id, Name in pairs( self.GroupNames ) do

		local tab = vgui.Create( "ScoreboardTabInner", self )
		local group = vgui.Create( "ScoreboardAwardCategoryTab", tab )

		tab:SetBody( group )
		tab:SetText( Name )
		
		if self.GamemodeNames[id] && gamemode.Get( self.GamemodeNames[id] ) then
			tab:SetOrder( 0 )
			firstTab = tab
		else

			if id == 20 then // Override for holiday tab
				tab:SetOrder( 1 )
			else
				tab:SetOrder( id )
			end

			if id == 1 then
				firstTab = tab
			end
		end

		self:AddTab( tab )
		self.Groups[ id ] = group

	end
    for k, v in pairs( GtowerAchivements.Achivements ) do
        if v.Group then
            self.Groups[ v.Group ]:AddAchievement( v )
        else
            self.Groups[ 1 ]:AddAchievement( v )
        end
    end

	// Find the first tab
	if firstTab then
		self:SetActiveTab( firstTab )
	end

	RequestUpdate()
	self.NextUpdate = CurTime() + 1.0

end

function AWARDS:AddTab( tab )

	table.insert( self.Tabs, tab )
	tab:SetParent( self )

end

/*function AWARDS:OnMouseWheeled( dlta )

	if ( self.ActiveTab.VBar ) then
		return self.ActiveTab.VBar:OnMouseWheeled( dlta )
	end
	
end*/

function AWARDS:SetActiveTab( tab )
	
	if ValidPanel( self.ActiveTab ) then

		self.ActiveTab:SetActive( false )
		local oldBody = self.ActiveTab:GetBody()
		
		oldBody:SetParent( nil )
		oldBody:SetVisible( false )

	end
	
	local newBody = tab:GetBody()
	
	self.ActiveTab = tab
	self.ActiveTab:SetActive( true )
	
	newBody:SetParent( self )
	newBody:SetVisible( true )
	newBody:OnOpenTab()

	RequestUpdate()
	
	self:InvalidateLayout()

end

function AWARDS:PerformLayout()
	
	local position = 5
	local width = 0

	// Sort their order
	table.sort( self.Tabs, function( a, b )
		if a.Order == b.Order then
			return a:GetText() > b:GetText()
		end

		return a.Order < b.Order
	end )

	// Get widest tab
	for _, tab in pairs( self.Tabs ) do
		width = 140
	end
	
	// Set their positions and size
	for _, tab in pairs( self.Tabs ) do
		tab:SetTall( 24 )
		tab:InvalidateLayout( true )
		
		tab:SetPos( self:GetWide() - tab:GetWide() - 10, position )
		tab:AlignLeft( self:GetWide() - width )
		tab:SetWide( width )

		position = position + tab:GetTall()
	end

	self.TabHeight = position + 4
	self.TabWidth = width

	// Layout active tab
	if ValidPanel( self.ActiveTab ) then
		local body = self.ActiveTab:GetBody()
		body:InvalidateLayout( true )
		body:SetPos( 0, 4 )
		body:SetWide( self:GetWide() - width )
		body:AlignLeft()
	end

	RequestUpdate()

end

function AWARDS:Paint( w, h )

	//surface.SetDrawColor( Scoreboard.Customization.ColorDark )
	//surface.DrawRect( 0, 0, self:GetWide(), 24 )

	local color = Scoreboard.Customization.ColorDark
	surface.SetDrawColor( color )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

	surface.SetDrawColor( color.r - 5, color.g - 5, color.b - 5 )
	surface.DrawRect( self:GetWide() - self.TabWidth, 4, 4, self:GetTall() )

end

function AWARDS:Think()

	if CurTime() > self.NextUpdate then

		RequestUpdate()
		self:InvalidateLayout()
		self.NextUpdate = CurTime() + 1.0

	end

	local current = self:GetTall()
	local targetHeight = 24

	// Resize for tab
	if ValidPanel( self.ActiveTab ) then

		local body = self.ActiveTab:GetBody()
		targetHeight = targetHeight + body:GetTall() - 4

		targetHeight = math.max( targetHeight, self.TabHeight )

	end

	self:SetTall( math.Approach( current, targetHeight, math.max( math.abs( (current-targetHeight) * FrameTime() * 15 ) ), 1 ) )
	self:Center()

end

vgui.Register("ScoreboardAwards", AWARDS )




/**
	A single collapsable category that holds all the achievements
*/
/*AWARDSCATEGORY = {}

function AWARDSCATEGORY:Init()

	self:SetLabel( "Unknown" )
	self:SetLabelFont( Scoreboard.Customization.CollapsablesFont, false )
	self:SetTabCurve( 4 )

	self:SetColors( 
		Scoreboard.Customization.ColorDark, 
		Scoreboard.Customization.ColorBackground, 
		Scoreboard.Customization.ColorBackground, 
		Scoreboard.Customization.ColorBackground
	)

	self:SetPadding( 2 )

	local grid = vgui.Create("DGrid", self)
	grid:SetCols( 2 )
	grid:SetRowHeight( AWARD.Height + 2 )

	self:SetContents( grid )

end

function AWARDSCATEGORY:SetAsGamemode()

	self.IsGamemode = true
	self.NoCollapse = true

	self:SetExpanded( true )
	self:SetMouseInputEnabled( false )

	self:SetColors( 
		Scoreboard.Customization.ColorBackground, 
		Scoreboard.Customization.ColorBackground, 
		Scoreboard.Customization.ColorBackground, 
		Scoreboard.Customization.ColorBackground
	)

end

function AWARDSCATEGORY:AddAchievement( achievement )

	local panel = vgui.Create("ScoreboardAward", self)
	panel:SetAchievement( achievement )

	self.Contents:AddItem( panel )

end

function AWARDSCATEGORY:PerformLayout()

	local width = self:GetWide() / 2 - 1 

	self.Contents:SetColWide( width )

	for _, panel in pairs( self.Contents.Items ) do
		panel:SetWide( width - 2 )
		panel:InvalidateLayout()
	end

	self.BaseClass.PerformLayout( self )

end

function AWARDSCATEGORY:OnOpenTab()

	for _, panel in pairs( self.Contents.Items ) do
		panel:ResetCollapsableScroll()
	end

end

vgui.Register( "ScoreboardAwardCategory", AWARDSCATEGORY, "DCollapsibleCategory2" )*/




local AWARDSCATEGORYTAB = {}

function AWARDSCATEGORYTAB:Init()

	local grid = vgui.Create( "DGrid", self)
	grid:SetCols( 2 )
	grid:SetRowHeight( AWARD.Height + 2 )

	self:SetContents( grid )

end

function AWARDSCATEGORYTAB:SetContents( contents )

	self.Contents = contents
	self.Contents:SetParent( self )
	self:InvalidateLayout()

end

function AWARDSCATEGORYTAB:SetAsGamemode()

	self.IsGamemode = true

end

function AWARDSCATEGORYTAB:AddAchievement( achievement )

	local panel = vgui.Create( "ScoreboardAward", self )
	panel:SetAchievement( achievement )

	self.Contents:AddItem( panel )

end

function AWARDSCATEGORYTAB:PerformLayout()

	local width = self:GetWide() / 2 - 1 

	self.Contents:SetColWide( width )

	for _, panel in pairs( self.Contents.Items ) do
		panel:SetWide( width - 2 )
		panel:InvalidateLayout()
	end

	local Padding = 2

	if self.Contents then

		self.Contents:SetPos( Padding, 0 )
		self.Contents:SetWide( self:GetWide() - Padding * 2 )	
		self.Contents:InvalidateLayout( true )

		self:SetTall( self.Contents:GetTall() + Padding * 2 + 4 )

	end

end

function AWARDSCATEGORYTAB:OnOpenTab()

	for _, panel in pairs( self.Contents.Items ) do
		panel:ResetCollapsableScroll()
	end

end

function AWARDSCATEGORYTAB:Paint( w, h )

	surface.SetDrawColor( Scoreboard.Customization.ColorDark )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

end

vgui.Register( "ScoreboardAwardCategoryTab", AWARDSCATEGORYTAB, "PanelList" )





/**
	A single achievement "block"
	Holds the collapsble text, is resposible for updating the values, and the progress bar
*/
AWARD = {}
AWARD.Height = 64
AWARD.DescriptionColor = Color( 210, 210, 210, 255 )
AWARD.IsAchieved = false

function AWARD:Init()

	self.CollapseText = vgui.Create("ScoreboardAwardCollapse", self)

	self:SetTall( self.Height )

end

function AWARD:SetAchievement( achievement )
	self.Achievement = achievement

	local maxValue = self.Achievement.Value

	if self.Achievement.GetMaxValue then
		maxValue = self.Achievement.GetMaxValue()
	end

	if maxValue != 1 then
		self.Progress = vgui.Create( "ScoreboardAwardProgressBar", self )
	end
end

function AWARD:GetAchievement()
	return self.Achievement
end

function AWARD:PerformLayout()
	local maxValue = self.Achievement.Value
	local value = self.Achievement.PlyVal or 0
	
	if self.Achievement.GetMaxValue then
		maxValue = self.Achievement.GetMaxValue()
	end

	self.CollapseText:SetText( self.Achievement.Name, self.Achievement.Description )
	self.CollapseText:InvalidateLayout( true )

	self.CollapseText:SetWide( self:GetWide() - 12 )
	self.CollapseText:CenterHorizontal()
	self.CollapseText.y = 2	
	
	//Check if we should draw the progress bar
	if maxValue != 1 then
		
		self.Progress:SetValue( value / maxValue )
		self.CollapseText:SetProgressText( string.FormatNumber( value ) .. " / " .. string.FormatNumber( maxValue ) )

		self.CollapseText:SetTall( self:GetTall() - 16 )
		
		self.Progress:SetSize( self.CollapseText:GetWide(), 10 )
		self.Progress:CenterHorizontal()
		self.Progress:AlignBottom( 6 )

		self.IsAchieved = ( value == maxValue )

	else

		self.IsAchieved = tobool( value )
		self.CollapseText:SetTall( self:GetTall() - 4 )
		self.CollapseText:CenterVertical()

	end

	self:InvalidateLayout()

end

function AWARD:ResetCollapsableScroll()
	self.CollapseText.Display = 0
	if self.Progress then self.Progress.ProgressApproach = 0 end
end

function AWARD:Paint( w, h )

	surface.SetDrawColor( Scoreboard.Customization.ColorBackground )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

	surface.SetDrawColor( 255, 255, 255, 255 )

	if self.IsAchieved then
		surface.SetDrawColor( Scoreboard.Customization.ColorAwardsAchievedIcon )

		surface.SetMaterial( MATERIALS.AwardAchieved )
		surface.DrawTexturedRect( 0, 0, 512, self:GetTall() )
	else
		surface.SetMaterial( MATERIALS.Award )
		surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() )
	end

	// Trophy icon
	local achievement = self:GetAchievement()
	if !achievement then return end

	if achievement.GiveItem then

		local iconWidth = 16
		local iconX = ( self:GetWide() - iconWidth ) - 4
		local iconY = 4

		if self.IsAchieved then
			surface.SetDrawColor( 255, 255, 255, 255 )
		else
			surface.SetDrawColor( 255, 255, 255, 80 )
		end

		surface.SetTexture( MATERIALS.TrophyIcon )
		surface.DrawTexturedRect( iconX, iconY, iconWidth, iconWidth )

	end

end

vgui.Register("ScoreboardAward", AWARD )





/**
	Displays the title of the achievement
	When the mouse is over the parent, move the text to display the description
	And if available, the progress
*/
local AWARDCOLLAPSE = {}

function AWARDCOLLAPSE:Init()

	self.Title = Label("", self)
	self.Title:SetFont("SCAwardTitle")
	self.Title:SetTextColor( Scoreboard.Customization.ColorFont )
	self.Title:SetZPos( 0 )

	self.TitleShadow = Label("", self)
	self.TitleShadow:SetFont("SCAwardTitle")
	self.TitleShadow:SetTextColor( Scoreboard.Customization.ColorFontShadow )
	self.TitleShadow:SetZPos( -1 )

	self.Description = vgui.Create( "ScoreboardAwardDescription", self )

	self:SetMouseInputEnabled( false )

	self.Display = 0.0

end

function AWARDCOLLAPSE:SetText( title, description )

	self.Title:SetText( title )
	self.TitleShadow:SetText( title )
	self.Description:SetText( description )

	self.Title:SizeToContents()
	self.TitleShadow:SizeToContents()

end

function AWARDCOLLAPSE:SetProgressText( text )

	if !ValidPanel( self.Progress ) then
		self.Progress = Label("", self)
		self.Progress:SetFont("SCAwardProgress")
		self.Progress:SetTextColor( Scoreboard.Customization.ColorAwardsDescription )
	end

	self.Progress:SetText( text )
	self.Progress:SizeToContents()

end

function AWARDCOLLAPSE:ShouldDisplay()
	return self:GetParent().Hovered
end

function AWARDCOLLAPSE:Think()

	local target = 1.0 //self:ShouldDisplay() and 1.0 or 0.0

	self.Display = math.Approach( self.Display, target, ( target - self.Display ) * FrameTime() * 3 )

	self.Title:CenterVertical( Lerp( self.Display, 0.5, 0.3 ) )
	self.Description:CenterVertical( Lerp( self.Display, 1.33, 0.73 ) ) //.65

	local w = self.Description:GetWide()
	local maxWide = self:GetWide() - 2

	if ValidPanel( self.Progress ) then

		maxWide = self:GetWide() - self.Progress:GetWide() - 4
		//self.Progress:SetVisible( w < ( self:GetWide() - w2 ) )

		self.Progress.y = self.Description.y

	end

	// Resize description
	self.Description:SetWide( maxWide )

	self.TitleShadow.x = self.Title.x + 2
	self.TitleShadow.y = self.Title.y + 2
	
end

function AWARDCOLLAPSE:PerformLayout()
	if ValidPanel( self.Progress ) then
		self.Progress:AlignRight()
	end
end

vgui.Register( "ScoreboardAwardCollapse", AWARDCOLLAPSE )


local DESCRIPTION = {}

function DESCRIPTION:Init()

	self.Description = Label("", self)
	self.Description:SetFont("SCAwardDescription")
	self.Description:SetTextColor( Scoreboard.Customization.ColorAwardsDescription )

end

function DESCRIPTION:Think()

	local w = self.Description:GetWide()
	local pw = self:GetWide()

	// Marquee scroll text
	if w < pw then return end

	if !self.MarqueeDelay then
		self.MarqueeDelay = CurTime() + math.random( 2, 3 )
	end

	if self.MarqueeDelay > CurTime() then return end
	self.MarqueeDelay = CurTime() + .05

	if self.MarqueeDir == 1 then // Right

		local pos = pw - w - 2

		if self.Description.x != pos then
			self.Description.x = math.Approach( self.Description.x, pos, 1 )
		else
			self.MarqueeDir = 0
			self.MarqueeDelay = CurTime() + math.random( 2, 3 )
		end

	else // Left

		local pos = 0

		if self.Description.x != pos then
			self.Description.x = math.Approach( self.Description.x, pos, 1 )
		else
			self.MarqueeDir = 1
			self.MarqueeDelay = CurTime() + math.random( 2, 3 )
		end

	end

end

function DESCRIPTION:PerformLayout()
	self.Description:SizeToContents()
end

function DESCRIPTION:SetText( text )

	self.Description:SetText( text )
	self:InvalidateLayout()

end

vgui.Register( "ScoreboardAwardDescription", DESCRIPTION )





/**
	Just the white/blue bar showing the progress
*/
PROGRESSBAR = {}
PROGRESSBAR.Progress = 0
PROGRESSBAR.ProgressApproach = 0

function PROGRESSBAR:SetValue( value )
	self.Progress = math.Clamp( value, 0, 1 )
end

function PROGRESSBAR:Paint( w, h )

	local progress = math.ceil( w * self.Progress )

	self.ProgressApproach = math.Approach( self.ProgressApproach, progress, FrameTime() * 600 )

	if self.ProgressApproach != w then
		surface.SetDrawColor( Scoreboard.Customization.ColorAwardsBarNotAchieved )
		surface.DrawRect( self.ProgressApproach, 0, w - self.ProgressApproach, h )	
	end

	if self.ProgressApproach != 0 then
		surface.SetDrawColor( Scoreboard.Customization.ColorAwardsBarAchieved )
		surface.DrawRect( 0, 0, self.ProgressApproach, h )
	end

end

vgui.Register( "ScoreboardAwardProgressBar", PROGRESSBAR ) 