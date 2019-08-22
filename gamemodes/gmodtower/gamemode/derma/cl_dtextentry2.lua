

-----------------------------------------------------
/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 
 
	DTextEntry2: GMT Edition
 
	In Engine Commands:
 
	self:SetMultiline( bool )
	self:IsMultiline()
 
*/
 
PANEL = {}
 
local strAllowedNumericCharacters = "1234567890.-"
 
AccessorFunc( PANEL, "m_bAllowEnter", 		"EnterAllowed" )
AccessorFunc( PANEL, "m_bUpdateOnType", 	"UpdateOnType" )	// Update the convar as we type
AccessorFunc( PANEL, "m_bNumeric", 			"Numeric" )
 
AccessorFunc( PANEL, "m_bBorder", 			"DrawBorder" )
AccessorFunc( PANEL, "m_bBackground", 		"DrawBackground" )
 
AccessorFunc( PANEL, "m_colText", 			"TextColor" )
AccessorFunc( PANEL, "m_colHighlight", 		"HighlightColor" )
AccessorFunc( PANEL, "m_colCursor", 		"CursorColor" )
 
 
Derma_Install_Convar_Functions( PANEL )
 
/*---------------------------------------------------------
 
---------------------------------------------------------*/
function PANEL:Init()
 
	//
	// We're going to draw these ourselves in 
	// the skin system - so disable them here.
	// This will leave it only drawing text.
	//
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackgroundEnabled( false )
 
	//
	// These are Lua side commands
	// Defined above using AccessorFunc
	//
	self:SetDrawBorder( true )
	self:SetDrawBackground( true )
	self:SetEnterAllowed( true )
	self:SetUpdateOnType( false )
	self:SetNumeric( false )
 
 
	// Nicer default height
	self:SetTall( 20 )
 
	// Clear keyboard focus when we click away
	self.m_bLoseFocusOnClickAway = true
 
	// Beam Me Up Scotty
	self:SetCursor( "beam" )
 
	// Apply scheme settings now, allow the user to override them later.
	derma.SkinHook( "Scheme", "TextEntry", self )
 
end
 
 
/*---------------------------------------------------------
 
---------------------------------------------------------*/
function PANEL:OnKeyCodeTyped( code )
 
	if ( code == KEY_ENTER && !self:IsMultiline() && self:GetEnterAllowed() ) then
 
		self:FocusNext()
		self:OnEnter()
 
	end
 
end
 
/*---------------------------------------------------------
 
---------------------------------------------------------*/
function PANEL:CreateUnEditableLabel( code )
 
	if ( code == KEY_ENTER && !self:IsMultiline() && self:GetEnterAllowed() ) then
 
		self:FocusNext()
		self:OnEnter()
 
	end
 
end
 
/*---------------------------------------------------------
	OnTextChanged
---------------------------------------------------------*/
function PANEL:OnTextChanged()
 
	if ( self:GetUpdateOnType() ) then
		self:UpdateConvarValue()
	end
 
end
 
/*---------------------------------------------------------
	Think
---------------------------------------------------------*/
function PANEL:Think()
 
	self:ConVarStringThink()
 
end
 
/*---------------------------------------------------------
	OnEnter
---------------------------------------------------------*/
function PANEL:OnEnter()
 
	// For override
 
	self:UpdateConvarValue()
 
end
 
/*---------------------------------------------------------
	UpdateConvarValue
---------------------------------------------------------*/
function PANEL:UpdateConvarValue()
 
	// This only kicks into action if this variable has
	// a ConVar associated with it.
	self:ConVarChanged( self:GetValue() )
 
end
 
 
/*---------------------------------------------------------
	Paint
---------------------------------------------------------*/
function PANEL:Paint()
 
	derma.SkinHook( "Paint", "TextEntry", self )
	return false
 
end
 
/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
 
	derma.SkinHook( "Layout", "TextEntry", self )
 
end
 
 
/*---------------------------------------------------------
   Name: SetValue ( A simple redirect for the ConVar stuff )
---------------------------------------------------------*/
function PANEL:SetValue( strValue )
 
	local CaretPos = self:GetCaretPos()
 
	self:SetText( strValue )
	self:OnValueChange( strValue )
 
	self:SetCaretPos( CaretPos )
 
end
 
 
/*---------------------------------------------------------
   Name: For Override
---------------------------------------------------------*/
function PANEL:OnValueChange( strValue )
 
end
 
/*---------------------------------------------------------
   Name: CheckNumeric
---------------------------------------------------------*/
function PANEL:CheckNumeric( strValue )
 
	// Not purely numeric, don't run the check
	if ( !self:GetNumeric() ) then return false end
 
	// God I hope numbers look the same in every language
	if ( !string.find ( strAllowedNumericCharacters, strValue ) ) then
 
		// Noisy Error?
		return true
 
	end
 
	return false	
 
end
 
/*---------------------------------------------------------
   Name: AllowInput
---------------------------------------------------------*/
function PANEL:AllowInput( strValue )
 
	// This is layed out like this so you can easily override and 
	// either keep or remove this numeric check.
	if ( self:CheckNumeric( strValue ) ) then return true end
 
end
 
/*---------------------------------------------------------
   Name: SetEditable
---------------------------------------------------------*/
function PANEL:SetEditable( b )
 
	self:SetKeyboardInputEnabled( b )
	self:SetMouseInputEnabled( b )
 
end
 
/*---------------------------------------------------------
   Name: OnGetFocus
---------------------------------------------------------*/
function PANEL:OnGetFocus()
 
	//
	// These hooks are here for the sake of things like the spawn menu
	//  which don't have key focus until you click on one of the text areas.
	//
	// If you make a control for the spawnmenu that requires keyboard input
	// You should have these 3 functions in your panel, so it can handle it.
	//
 
	hook.Call( "OnTextEntryGetFocus", nil, self )
 
end
 
/*---------------------------------------------------------
   Name: OnLoseFocus
---------------------------------------------------------*/
function PANEL:OnLoseFocus()
 
	self:UpdateConvarValue()
 
	hook.Call( "OnTextEntryLoseFocus", nil, self )
 
end
 
/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:OnMousePressed( mcode )
 
	self:OnGetFocus()
 
end
 
/*---------------------------------------------------------
   Name: GenerateExample
---------------------------------------------------------*/
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )
 
	local ctrl = vgui.Create( ClassName )
		ctrl:SetText( "Edit Me!" )
		ctrl:SetWide( 150 )
 
		ctrl.OnEnter = function( self ) Derma_Message( "You Typed: "..self:GetValue() ) end
 
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )
 
end
 
 
derma.DefineControl( "DTextEntry2", "A simple TextEntry control", PANEL, "TextEntry" )
 
 
/*---------------------------------------------------------
   Clear the focus when we click away from us..
---------------------------------------------------------*/
function TextEntryLoseFocus( panel, mcode )
 
	local pnl = vgui.GetKeyboardFocus()
	if ( !pnl ) then return end
	if ( pnl == panel ) then return end
	if ( !pnl.m_bLoseFocusOnClickAway ) then return end
 
	pnl:FocusNext()
 
end
 
hook.Add( "VGUIMousePressed", "TextEntryLoseFocus", TextEntryLoseFocus )
 