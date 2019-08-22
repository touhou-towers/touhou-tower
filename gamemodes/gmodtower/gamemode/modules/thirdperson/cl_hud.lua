
local PANEL = {}
local OpenTime = 2 / 0.5 // 0.5 seconds
ThirdPersonHud = {}
ThirdPersonHud.Enabled = CreateClientConVar( "gmt_thirdpersonbutton", 1, true, false )
function PANEL:Init()

	self.TargeYPos = 0
	self.CurYPos = self.TargeYPos

	self:SetSize( 75, 32 )
	
	self.Button = vgui.Create( "DButton", self )
	self.Button:SetText( "Third Person" )
	self.Button:SetConsoleCommand( "gmt_thirdperson" )
	
end

function PANEL:ChangingThink()
if !ThirdPersonHud.Enabled:GetBool() then return end
	local NewYPos = math.Approach( self.CurYPos, self.TargeYPos, FrameTime() * self:GetTall() * OpenTime )
	
	if NewYPos == self.TargeYPos then
		self.Think = EmptyFunction
		
		if NewYPos < 0 then
			self:SetVisible( false )
		end
	end
	
	self:SetPos( self.x, NewYPos - 6 )
	self.CurYPos = NewYPos

end

function PANEL:Paint()
if !ThirdPersonHud.Enabled:GetBool() then return end
	//surface.SetDrawColor( 255, 0, 0, 255 )
	//surface.DrawOutlinedRect( 0,0, self:GetWide(), self:GetTall() )
end

function PANEL:PerformLayout()
	
	self:SetPos( ( ScrW() / 2 ) - 400, self.CurYPos - 6 )
	self:SetZPos( 2 )
	
	self.Button:SetSize( self:GetWide() - 4, self:GetTall() - 4 )
	self.Button:SetPos( 0, 0 )
		
end


/*===========================
 == External functions
=============================*/

function PANEL:Open()
	
	self.IsOpen = true
	self:UpdateChangingThink()
	self.TargeYPos = 0
	
	self:SetVisible( true )

end

function PANEL:Close()

	self.IsOpen = false
	self:UpdateChangingThink()
	self.TargeYPos = -self:GetTall()
	
end

function PANEL:ForceClose()
	self.CurYPos = self:GetTall() * -1
	self:SetPos( self.x, self.CurYPos - 6 )
	self:SetVisible( false )
end


/*===========================
 == Internal functions
=============================*/

function PANEL:UpdateChangingThink()
	self.Think = self.ChangingThink
end

vgui.Register( "GThirdPersonPanel", PANEL, "Panel" )


function ThirdPerson.ShowMenu()
	
	if !ThirdPerson.Panel then
	
		ThirdPerson.Panel = vgui.Create( "GThirdPersonPanel" )
		ThirdPerson.Panel:ForceClose()
	end
	
	ThirdPerson.Panel:Open()
	ThirdPerson.Panel:InvalidateLayout()
	
end

function ThirdPerson.CloseMenu()

	if ThirdPerson.Panel then
		ThirdPerson.Panel:Close()
	end
	
end


hook.Add( "GtowerShowMenus", "OpenTPPanel", function()
	ThirdPerson.ShowMenu()
end )

hook.Add( "GtowerHideMenus", "CloseTPPanel", function()
	ThirdPerson.CloseMenu()
end )