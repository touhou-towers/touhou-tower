

-----------------------------------------------------
local PANEL = {}

function PANEL:Init()
	
	self:SetCursor("sizewe")
	self.OriginalPos = 0
	self.OriginalSize = 0
	self.DefaultValue = 0
	self.SettingName = nil
	self.IsBothSides = false
	
	self.MinValue = nil
	self.MaxValue = nil
	
	self:SetZPos( -2 )
	self:ResetThink()
	
	self.OnChangeFunc = nil
end

function PANEL:BothSides( state )
	self.IsBothSides = state
end

function PANEL:SetMinMax( min, max )
	self.MinValue = min
	self.MaxValue = max
end

function PANEL:IsOnLeft()
	local x,y = self:CursorPos()
	
	return x < (self:GetWide() * 0.5)
end

function PANEL:OnMousePressed()
	if self.Think != EmptyFunction then
		return
	end

	self.OriginalPos = gui.MouseX()
	self.OriginalSize = cookie.GetNumber(self.SettingName) or self.DefaultValue
	self:MouseCapture( true )
	
	if self.IsBothSides == true && self:IsOnLeft() then
		self.Think = self.MovingThinkLeft
	else
		self.Think = self.MovingThinkRight
	end
end

function PANEL:ResetThink()
	self.Think = EmptyFunction
end

function PANEL:OnMouseReleased()
	self:ResetThink()
	self:MouseCapture( false )
end

function PANEL:SetSettingName( name )
	self.SettingName = name
end

function PANEL:OnChange( func )
	self.OnChangeFunc = func
end

function PANEL:NewSize( val )
	if self.MinValue && self.MaxValue then
		val = math.Clamp( val, self.MinValue, self.MaxValue )
	end

	cookie.Set( self.SettingName, val )
	
	if self.OnChangeFunc then
		self.OnChangeFunc( val )
	end
end

function PANEL:MovingThinkRight()
	self:NewSize( self.OriginalSize + gui.MouseX() - self.OriginalPos )
end

function PANEL:MovingThinkLeft()
	self:NewSize( self.OriginalSize - gui.MouseX() + self.OriginalPos )
end

vgui.Register("GTowerResizer",PANEL, "Panel")