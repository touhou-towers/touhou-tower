

local PANEL = {}

function PANEL:AddURLTab( Name, url )
	local tab = vgui.Create( "HTML", Categories )
	
	tab:SetPos( 4, 25 )
	tab:SetSize( Categories:GetWide() - 8, Categories:GetTall() - 28 )
	
	tab:OpenURL( url )
	
	Categories:AddSheet( Name, tab, nil, false, false, nil )
end

function PANEL:Init()

	Categories = vgui.Create( "DPropertySheet", self )
	Categories:SetPos( 0, 0 )
	Categories:SetSize( self:GetParent():GetWide(), ScrH() * 0.60 )
	
	local website = "http://www.gmtower.org/"

	self:AddURLTab( "Latest News", website .. "index.php?p=news&app=1" )
	self:AddURLTab( "Change Log", website .. "index.php?p=changelog&app=1" )
	self:AddURLTab( "FAQs", website .. "index.php?p=faqs&app=1" )
	self:AddURLTab( "Stats", website .. "index.php?p=stats&app=1" )
	self:AddURLTab( "GMT Staff", website .. "index.php?p=staff&app=1" )
	
end

function PANEL:OnMousePressed()
end

function PANEL:Removing()
end

function PANEL:Think()
end

function PANEL:Paint()
end

function PANEL:PerformLayout()

	SumHeight = Categories:GetTall()
	
	self.ItemParent:SetTargetTall( SumHeight, self )
	self:SetTall( SumHeight )
	
	Categories:SetWide( self:GetParent():GetWide() )
	
end


vgui.Register( "GtowerInfBoardMain", PANEL, "Panel" )


hook.Add( "GTowerScoreBoard", "AddInfoBoard", function()
	return {
		["Name"] = "Information",
		["vgui"] = "GtowerInfBoardMain"
	}
end )