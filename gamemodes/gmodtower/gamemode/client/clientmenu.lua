
GtowerMenu = {}
GtowerMenu.PanelList = {}


local MenuOpen = nil

local ArrowSizeX = 24
local ArrowSizeY = 24

local HoveredColor = Color(111, 124, 132)
local UnHoveredColor = Color(86,86,86)
local BackGround = Color(80,80,80)

/*
Data to create a menu:

Table{
	"1" = {
		"Name" = "Item 1"
		"extra" = nil
		"function" = function() end
		"order" = 0
	}

	"2" = {
		"Name" = "Item 2"
		"function" = nil
		"extra" = nil
		"order" = 1
		"sub" = {
			"1" = {
				"Name" = "Item 3"
				"extra" = nil
				"function" = function() end
			}
		}
	}

	"3" = {
		"type" = "break" // Line separating two sections
		"order" = 0
	}

	"4" = {
		"Name" = "Item 4"
		"type" = "text"
		"order" = 0
	}
}
*/

function GtowerMenu:OpenMenu( OriginTable, x, y )

	if MenuOpen then return end

	local TempPosX, TempPosY = gui.MousePos()

	if x == nil then x = TempPosX + 1 end //So it does not get right in front of the mouse
	if y == nil then y = TempPosY end

	self:CloseAll()

	local panel = vgui.Create("GtowerMenuMain")
	panel:SetPos( x , y )

	panel:SetTable( OriginTable )
	panel:SetZPos(10)

	MenuOpen = panel

end

function GtowerMenu:GetPanelName( typ )

	if typ == nil || typ == "button" then
		return "GtowerMenuButton"
	end

	if typ == "break" then return "GtowerMenuBreak" end
	if typ == "text" then return "GtowerMenuText" end

	return "GtowerMenuText"

end

function GtowerMenu:IsOpen()
	return tobool( MenuOpen )
end

function GtowerMenu:CloseAll()

	if MenuOpen != nil then
		MenuOpen:CloseTree( true )
		MenuOpen = nil
	end

end

hook.Add( "GTowerHideMenus", "HideAllMenus", GtowerMenu.CloseAll )






local PANEL = {}
function PANEL:Init()

	self.OriginTable = nil
	self.ChildPanels = {}

	self.MaxWide = 10

	self.MainPanel = nil
	self.SubMenuParent = nil

end

function PANEL:SetTable( OriginTable )

	if OriginTable == self.OriginTable then return end

	self.OriginTable = OriginTable
	self:InvalidateLayout()

end

function PANEL:Paint( w, h )
end

function PANEL:PaintOver()

	// BG
	color = Color( 16, 70, 101 )
	surface.SetDrawColor( color.r, color.g, color.b, self.Alpha )


	/*surface.DrawRect( 0, 12, 3, self:GetTall() - 24 )
	surface.DrawRect( self:GetWide() - 3 , 12, 3, self:GetTall() - 24 )

	surface.DrawRect( 12, 0, self:GetWide() - 24, 3 )
	surface.DrawRect( 12, self:GetTall() - 3, self:GetWide() - 24, 3 )

	//Side textures
	surface.SetTexture( Border4 )
	surface.DrawTexturedRect( 0 , 12, 3, self:GetTall() - 24 )
	surface.DrawTexturedRect( self:GetWide() - 3 , 12, 3, self:GetTall() - 24 )

	//top/button textures
	surface.SetTexture( Border8 )
	surface.DrawTexturedRect( 12 , 0, self:GetWide() - 24, 3 )
	surface.DrawTexturedRect( 12, self:GetTall() - 3, self:GetWide() - 24, 3 )*/


end

function PANEL:Think()

	local SortedTable = {}

	for _, panel in pairs( self.OriginTable ) do
		table.insert( SortedTable, panel )
	end

	table.sort( SortedTable, function(a,b)
		if a["order"] == nil then return false end
		if b["order"] == nil then return true end

		return a["order"] < b["order"]
	end )

	local YPos = 3
	local MaxWide = 0

	for k, v in pairs( SortedTable ) do
		local panel = self:ChildWithTable( v )

		if panel == nil then
			panel = vgui.Create( GtowerMenu:GetPanelName( v["type"] ), self )
			panel:SetTable( v )

			if !table.HasValue( self.ChildPanels, panel ) then
				table.insert( self.ChildPanels, panel )
			end
		end

		if panel:GetWide() > MaxWide then
			MaxWide = panel:GetWide()
		end

		panel:SetPos(3, YPos)

		YPos = YPos + panel:GetTall()
	end

	self:SetSize( MaxWide + 6 , YPos + 3 )

end

function PANEL:SetMainPanel( panel )
	self.MainPanel = panel
end

function PANEL:GetMainPanel()
	if self.MainPanel != nil then
		return self.MainPanel
	end

	return self //No lower levels
end

function PANEL:GetExtra()
	if self.SubMenuParent != nil then
		return self.SubMenuParent:GetExtra()
	end

	return nil
end

function PANEL:SetSubMenuParent( panel )
	self.SubMenuParent = panel
end

function PANEL:CloseTree( delete )
	for _, v in pairs( self.ChildPanels ) do
		if v:IsButton() then
			v:CloseChilds()
		end
	end

	if delete == true then
		if self == MenuOpen then
			MenuOpen = nil
		end

		self:Remove()
	end
end

function PANEL:IsMouseOver()
	for _, v in pairs( self.ChildPanels ) do
		if v:IsMouseOver() then
			return true
		end
	end

	local x,y = self:CursorPos()

	return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()
end

function PANEL:ChildWithTable( CheckTable )

	for _, v in pairs( self.ChildPanels ) do
		if v:GetTable() == CheckTable then
			return v
		end
	end

	return nil

end

function PANEL:GetMaxWide( wide )
	if wide != nil then
		if wide > self.MaxWide then
			self.MaxWide = wide
		end
	end

	return self.MaxWide
end

function PANEL:PerformLayout()


	if ( self.y + self:GetTall() ) > ScrH() then
		self:SetPos( self.x, ScrH() - self:GetTall() )
	end

	if ( self.x + self:GetWide() ) > ScrW() then

		if self.SubMenuParent then
			local ItemParent = self.SubMenuParent:GetParent()

			self:SetPos( ItemParent.x - self:GetWide() + 1, self.y )
		else
			self:SetPos( ScrW() - self:GetWide() - 1, self.y )
		end
	end

end
vgui.Register( "GtowerMenuMain", PANEL, "Panel")





local PANEL = {}
function PANEL:Init()
	self.OriginTable = nil

	self.Text = ""
	self.TextX = 0
	self.TextY = 0

	self.ArrowX = 0
	self.ArrowY = 0

	self.SubMenu = nil
	self.HasSubMenu = false

end

function PANEL:SetTable( OriginTable )
	if OriginTable == self.OriginTable then return end

	self.OriginTable = OriginTable
	self:ExecSize()
	self:InvalidateLayout()
end

function PANEL:GetTable()
	return self.OriginTable
end

function PANEL:CheckEnabled()
	if self.OriginTable.checkenabled then
		return self.OriginTable.checkenabled()
	end
end

function PANEL:Paint( w, h )

	local col = Color(52 - 25, 137 - 25, 195 - 25)
	surface.SetDrawColor( col.r, col.g, col.b, 225 )

	if self:IsMouseOver() then
		surface.SetDrawColor( col.r - 25, col.g - 25, col.b - 25, 255 )
	end

	surface.DrawRect( 0,0, self:GetWide(), self:GetTall() )

	// Divider
	surface.SetDrawColor( 16, 70, 101, 100 )
	surface.DrawRect( 0,0, self:GetWide(), 1 )

	// Text
	surface.SetFont("small")
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( self.TextX, self.TextY )
	surface.DrawText( self.Text )

	if self.HasSubMenu then
		surface.SetDrawColor( 255, 255, 255, 255 )

		surface.SetMaterial( GTowerIcoons.GetIcoon("next") )
		surface.DrawTexturedRect( self.ArrowX, self.ArrowY, ArrowSizeX, ArrowSizeY )
	end

end

function PANEL:CloseChilds()

	if self.SubMenu != nil then
		self.SubMenu:CloseTree( true )
		self.SubMenu = nil
	end

end

function PANEL:IsMouseOver()

	if self.SubMenu != nil then
		if self.SubMenu:IsMouseOver() then
			return true
		end
	end

	local x,y = self:CursorPos()

	return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()

end

function PANEL:OnCursorEntered()

	local parent = self:GetParent()

	parent:CloseTree( false )

	if self.HasSubMenu && self.SubMenu == nil then

		self.SubMenu = vgui.Create( "GtowerMenuMain" )

		if type( self.OriginTable["sub"] ) == "function" then
			self.SubMenu:SetTable( self.OriginTable["sub"]( self.OriginTable["extra"] ) )
		else
			self.SubMenu:SetTable( self.OriginTable["sub"] )
		end

		self.SubMenu:SetMainPanel( parent:GetMainPanel() )
		self.SubMenu:SetSubMenuParent( self )
		self.SubMenu:SetZPos(20)
		self.SubMenu:SetPos( parent.x + self.x + self:GetWide() - 3, parent.y + self.y + (self:GetTall() * 0.25 ) )

	end

end

function PANEL:OnCursorExited()

	if self.SubMenu != nil && !self:IsMouseOver() then
		self.SubMenu:Remove()
		self.SubMenu = nil
	end

end

function PANEL:GetExtra()

	if self.OriginTable["extra"] != nil then
		return self.OriginTable["extra"]
	end

	return self:GetParent():GetExtra()

end

function PANEL:OnMouseReleased( mc )

	if self.OriginTable["function"] != nil && type(self.OriginTable["function"]) == "function" then
		self.OriginTable["function"] ( self:GetExtra() )
	end

	if mc == MOUSE_LEFT || self.OriginTable["canclose"] != true then
		self:GetParent():GetMainPanel():CloseTree( true )
	end

end

function PANEL:Think()

end

function PANEL:ExecSize()

	surface.SetFont("small")
	self.Text = self.OriginTable["Name"] or "Unnamed"

	local w, h = surface.GetTextSize( self.Text )

	self:SetSize( self:GetParent():GetMaxWide( w + 20 + ArrowSizeX * 1.5 ) , 26 )

	self.TextX = 10
	self.TextY = self:GetTall() / 2 - h / 2

	self.ArrowX = self:GetWide() - ArrowSizeX - 5
	self.ArrowY = self:GetTall() / 2 - ArrowSizeY / 2

end

function PANEL:PerformLayout()

	if self.OriginTable == nil then
		self:SetSize(0,0)
		return
	end

	self:ExecSize()

	local SubType = type( self.OriginTable["sub"] )

	self.HasSubMenu = self.OriginTable["sub"] != nil && ( SubType == "table" || SubType == "function" )

end

function PANEL:IsButton()
	return true
end
vgui.Register("GtowerMenuButton",PANEL, "Panel")





local PANEL = {}
function PANEL:Init()

	self.OriginTable = nil

	self.Text = ""
	self.TextX = 0
	self.TextY = 0

	self.CloseButton = nil

end

function PANEL:SetTable( OriginTable )

	if OriginTable == self.OriginTable then return end

	self.OriginTable = OriginTable

	if OriginTable["closebutton"] == true then

		self.CloseButton = vgui.Create("GtowerMenuCloseButton", self)

		self.CloseButton:SetFunction( function()
			self:GetParent():GetMainPanel():CloseTree( true )
		end )

	end

	self:ExecSize()
	self:InvalidateLayout()

end

function PANEL:GetTable()
	return self.OriginTable
end

function PANEL:Paint( w, h )

	derma.SkinHook( "Paint", "ClientMenuTitle", self, w, h )

	surface.SetDrawColor( 42 - 50, 114 - 50, 169 - 50, 255 )

	//SetDrawColor( BackGround )
	surface.DrawRect( 0,0, self:GetWide(), self:GetTall() )

	surface.SetFont("smalltitle")
	//surface.SetTextColor( 255, 255, 255, 255 )

	surface.SetTextPos( self.TextX, self.TextY )

	surface.DrawText( self.Text )

end

function PANEL:IsMouseOver()
	local x,y = self:CursorPos()

	return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()
end

function PANEL:OnCursorEntered()
	local parent = self:GetParent()

	parent:CloseTree( false )
end

function PANEL:OnCursorExited()
end

function PANEL:OnMousePressed()
end

function PANEL:Think()
end

function PANEL:ExecSize()

	surface.SetFont("smalltitle")
	self.Text = self.OriginTable["Name"] or "Unnamed"

	local w, h = surface.GetTextSize( self.Text )

	self:SetSize( self:GetParent():GetMaxWide( w + 35 + ArrowSizeX * 1.5 ), h + 6 )

	self.TextX = 5
	self.TextY = self:GetTall() / 2 - h / 2

	if self.CloseButton != nil then
		self.CloseButton:SetPos(self:GetWide() - 20, -1)
	end

end

function PANEL:PerformLayout()

	if self.OriginTable == nil then
		self:SetSize(0,0)
		return
	end

	self:ExecSize()

end

function PANEL:IsButton()
	return false
end
vgui.Register( "GtowerMenuText", PANEL, "Panel")







local PANEL = {}
function PANEL:Init()

	self.Function = nil
	self:SetSize(23,23)

	local icon = GTowerIcoons.GetIcoon("cancel")

	self.Icon = icon

end

function PANEL:SetFunction( func )
	self.Function = func
end

function PANEL:Paint( w, h )

	derma.SkinHook( "Paint", "ClientMenuClose", self, w, h )

	surface.SetMaterial( self.Icon )

	if self:IsHovered() then
		surface.SetDrawColor( 0,0,0,100 )
		surface.DrawRect( 0,0, w, h )
	end

	surface.SetDrawColor( 255,255,255,255 )
	surface.DrawTexturedRect( -2, 2, w, h )

end

function PANEL:OnMouseReleased()
	if self.Function != nil then
		self.Function()
	end
end

vgui.Register( "GtowerMenuCloseButton", PANEL, "Panel" )








local PANEL = {}
function PANEL:Init()
	self.OriginTable = nil
end

function PANEL:SetTable( OriginTable )

	if OriginTable == self.OriginTable then return end

	self.OriginTable = OriginTable
	self:ExecSize()
	self:InvalidateLayout()

end

function PANEL:GetTable()
	return self.OriginTable
end

function PANEL:Paint( w, h )

	surface.SetDrawColor( 80, 80, 80, 255 )
	surface.DrawRect( 6,2, self:GetWide() - 12, self:GetTall() - 4 )

end

function PANEL:IsMouseOver()
	local x,y = self:CursorPos()
	return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()
end


function PANEL:ExecSize()
	self:SetSize( self:GetParent():GetMaxWide( 5 ) , 7 )
end

function PANEL:PerformLayout()

	if self.OriginTable == nil then
		self:SetSize(0,0)
		return
	end

	self:ExecSize()

end

function PANEL:IsButton()
	return false
end
vgui.Register( "GtowerMenuBreak", PANEL, "Panel" )
