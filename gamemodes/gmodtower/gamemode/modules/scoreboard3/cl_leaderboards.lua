
if !string.StartWith( game.GetMap(), "gmt_ballracerr" ) then return end
module( "Scoreboard.News", package.seeall )

// TAB

hook.Add( "ScoreBoardItems", "AboutTab", function()
	return vgui.Create( "AboutTab" )
end )

TAB = {}
TAB.Order = 7

function TAB:GetText()
	return "RECORDS"
end

function TAB:CreateBody()
	return vgui.Create( "ScoreboardAbout", self )
end

vgui.Register( "AboutTab", TAB, "ScoreboardTab" )

// ABOUT


ABOUT = {}
ABOUT.Website = "http://74.91.116.176/leaderboards/index.php?map="


function ABOUT:Init()

	self.HTML = vgui.Create( "HTML", self )
	self.HTML:SetPos( 4, 25 )
	self.HTML:SetSize( self:GetWide(), ScrH() * 0.5 )

	local url = self.Website .. game.GetMap()
	self.HTML:OpenURL( url )

	self.HTML:Dock( FILL )

	self:SetTall( 24 + ( ScrH() * 0.5 ) - 4 )

	//self:Center()
	self:InvalidateLayout()

end

function ABOUT:Think()

end

vgui.Register( "ScoreboardAbout", ABOUT )
