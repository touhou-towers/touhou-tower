

-----------------------------------------------------
/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DNumberWang2: GMT Edition

*/

local PANEL = {}

/*---------------------------------------------------------
	
---------------------------------------------------------*/
function PANEL:Init()
	
	self.Slider = vgui.Create( "DSlider", self )
	self.Slider:SetLockY( 0.5 )
	self.Slider.TranslateValues = function( slider, x, y ) return self:TranslateSliderValues( x, y ) end
	self.Slider:SetTrapInside( true )

	self.Slider.Knob:SetSize( 4, 10 )
	self.Slider.Knob.Paint = function( panel, w, h )
		local color = Color( 255, 255, 255, 255 )
		if panel:IsHovered() then color = Color( 150, 150, 150, 255 ) end
		surface.SetDrawColor( color )
		surface.DrawRect( 0, 1, w, h )
	end
	
	self:SetTall( 20 )

end


/*---------------------------------------------------------
	SetMinMax
---------------------------------------------------------*/
function PANEL:SetMinMax( min, max )

	self:SetMin( min )
	self:SetMax( max )

end

/*---------------------------------------------------------
	SetMin
---------------------------------------------------------*/
function PANEL:SetMin( min )
	self.m_numMin = tonumber( min )
end

/*---------------------------------------------------------
	SetMax
---------------------------------------------------------*/
function PANEL:SetMax( max )
	self.m_numMax = tonumber( max )
end

/*---------------------------------------------------------
	GetFloatValue
---------------------------------------------------------*/
function PANEL:GetFloatValue( max )

	if ( !self.m_fFloatValue ) then m_fFloatValue = 0 end

	return tonumber( self.m_fFloatValue ) or 0

end

/*--------------------------------------------------------	-
   Name: SetValue
---------------------------------------------------------*/
function PANEL:SetValue( val )

	if ( val == nil ) then return end
	
	local OldValue = val
	val = tonumber( val )
	val = val or 0
	
	if ( self.m_iDecimals == 0 ) then

		val = Format( "%i", val )
	
	elseif ( val != 0 ) then
	
		val = Format( "%."..self.m_iDecimals.."f", val )
			
		// Trim trailing 0's and .'s 0 this gets rid of .00 etc
		val = string.TrimRight( val, "0" )		
		val = string.TrimRight( val, "." )

	end
	
	self.Value = val
	self:UpdateConVar()

end

/*---------------------------------------------------------
   Name: GetValue
---------------------------------------------------------*/
function PANEL:GetValue()

	return tonumber( self.Value ) or 0

end

/*---------------------------------------------------------
   Name: SetConVar
---------------------------------------------------------*/
function PANEL:SetConVar( cvar )

	self.ConVar = cvar

end

/*---------------------------------------------------------
   Name: UpdateConVar
---------------------------------------------------------*/
function PANEL:UpdateConVar()

	if self.ConVar then
		RunConsoleCommand( self.ConVar, self.Value )
	end

end

/*---------------------------------------------------------
	Name: SetDecimals
---------------------------------------------------------*/
function PANEL:SetDecimals( num )

	self.m_iDecimals = num

end

/*---------------------------------------------------------
   Name: GetDecimals
---------------------------------------------------------*/
function PANEL:GetDecimals()
	return self.m_iDecimals
end

/*---------------------------------------------------------
   Name: GetFraction
---------------------------------------------------------*/
function PANEL:GetFraction( val )

	local Value = val or self:GetValue()
	local Fraction = ( Value - self.m_numMin ) / (self.m_numMax - self.m_numMin)

	return Fraction

end

/*---------------------------------------------------------
   Name: SetFraction
---------------------------------------------------------*/
function PANEL:SetFraction( val )

	local Fraction = self.m_numMin + ( (self.m_numMax - self.m_numMin) * val )
	self:SetValue( Fraction )

end

function PANEL:PerformLayout()

	self:ResizeSliderToTitle()
	self.Slider:SetSlideX( self:GetFraction() )

end

function PANEL:Think()

	if self.ConVar then

		if GetConVarNumber( self.ConVar ) != self.Value then
			self.Value = GetConVarNumber( self.ConVar )
			self.Slider:SetSlideX( self:GetFraction() )
		end

	end

end

function PANEL:Paint( w, h )

	local val = self:GetValue()
	local title = self:GetText()

	local vardesc = tostring(self.m_numMax)

	if self.m_iDecimals > 0 then
		vardesc = Format( "%."..self.m_iDecimals.."f", vardesc )
	end

	if self.Descriptions then
		val = self.Descriptions[val+1]
		vardesc = val
	end

	if self.Type then
		val = val .. " " .. self.Type
	end

	if not self.NoText then

		surface.SetFont( "small" )
		local w, h = surface.GetTextSize( vardesc )
		surface.SetTextColor( 255, 255, 255, 255 )

		// Value
		--[[surface.SetTextPos( self:GetWide() - w, 0 )
		surface.DrawText( val )]]

		// Title
		surface.SetTextPos( 0, 0 )
		surface.DrawText( title )

	end

	// Line
	//surface.SetDrawColor( 85, 167, 221, 150 )
	local size = self.Slider:GetWide()
	local color = self.SliderColor or Scoreboard.Customization.ColorDark or Color( 85, 85, 85, 80 )

	surface.SetDrawColor( colorutil.Brighten( color, 1.25 ) )
	surface.DrawRect( self.Slider.x, 6, size, 2 )

	surface.SetDrawColor( colorutil.Brighten( color, 1.85 ) )
	surface.DrawRect( self.Slider.x, 6, size*self:GetFraction(), 2 )

end

function PANEL:SetText( text )
	if self.Text == text then return end
	self.Text = text
	self:ResizeSliderToTitle()
end

function PANEL:SetSliderColor( color )
	self.SliderColor = color
end

function PANEL:GetText()
	return self.Text or ""
end

function PANEL:ResizeSliderToTitle()
	surface.SetFont( "small" )

	local vardesc = tostring(self.m_numMax)

	if self.Descriptions then
		val = self.Descriptions[self:GetValue()+1]
		vardesc = val
	end

	local w = surface.GetTextSize( self:GetText() )
	local w2 = surface.GetTextSize( vardesc ) + 6

	self.Slider:SetPos( w + 4, 0 )
	self.Slider:SetSize( self:GetWide() - w - 4, 13 )	
end

/*---------------------------------------------------------
   Name: ValueChanged
---------------------------------------------------------*/
function PANEL:ValueChanged( val )

	self.Slider:SetSlideX( self:GetFraction( val ) )
	self:UpdateConVar()

end

/*---------------------------------------------------------

---------------------------------------------------------*/
function PANEL:TranslateSliderValues( x, y )

	self:SetFraction( x )
	
	return self:GetFraction(), y

end

derma.DefineControl( "DNumSlider2", "A simple slider", PANEL, "Panel" )