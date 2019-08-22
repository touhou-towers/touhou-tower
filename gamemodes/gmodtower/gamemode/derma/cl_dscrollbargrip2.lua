

-----------------------------------------------------
/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DScrollBarGrip2: GMT Edition

*/

local PANEL = {}

PANEL.Color = Color( 65, 148, 207 )

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()
end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed()

	self:GetParent():Grip( 1 )

end

function PANEL:IsMouseOver()

	local x,y = self:CursorPos()
	return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint( w, h )

	local color = self.Color

	if self:IsMouseOver() then
		color = Color( color.r + 20, color.g + 20, color.b + 20 )
	end
	
	//derma.SkinHook( "Paint", "ScrollBarGrip", self )
	draw.RoundedBox( 0, 0, 0, self:GetWide(), self:GetTall(), color )

	return true
	
end

derma.DefineControl( "DScrollBarGrip2", "A Scrollbar Grip", PANEL, "Panel" )