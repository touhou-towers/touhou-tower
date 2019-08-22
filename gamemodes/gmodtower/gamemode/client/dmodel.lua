
/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

*/
local PANEL = {}
local DEBUG = false

AccessorFunc( PANEL, "m_fAnimSpeed", 	"AnimSpeed" )
AccessorFunc( PANEL, "Entity", 			"Entity" )
AccessorFunc( PANEL, "vCamPos", 		"CamPos" )
AccessorFunc( PANEL, "fFOV", 			"FOV" )
AccessorFunc( PANEL, "vLookatPos", 		"LookAt" )
AccessorFunc( PANEL, "colAmbientLight", "AmbientLight" )
AccessorFunc( PANEL, "colColor", 		"Color" )
AccessorFunc( PANEL, "bAnimated", 		"Animated" )


/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Entity = nil
	self.LastPaint = 0
	self.DirectionalLight = {}
	
	self:SetCamPos( Vector( 50, 50, 50 ) )
	self:SetLookAt( Vector( 0, 0, 40 ) )
	self:SetFOV( 70 )
	
	self:SetText( "" )
	self:SetAnimSpeed( 0.5 )
	self:SetAnimated( false )
	
	self:SetAmbientLight( Color( 50, 50, 50 ) )
	
	self:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255 ) )
	self:SetDirectionalLight( BOX_FRONT, Color( 255, 255, 255 ) )
	
	self:SetColor( Color( 255, 255, 255, 255 ) )

end

/*---------------------------------------------------------
   Name: SetDirectionalLight
---------------------------------------------------------*/
function PANEL:SetDirectionalLight( iDirection, color )
	self.DirectionalLight[iDirection] = color
end

/*---------------------------------------------------------
   Name: OnSelect
---------------------------------------------------------*/
function PANEL:SetModel( strModelName, skin, CreateNow )
	
	if DEBUG then
		print("Setting model for: ", strModelName, skin )
	end
	
	if skin && IsValid( self.Entity ) then
		self.SkinId = skin
		self.Entity:SetSkin( skin )
	end

	// Note - there's no real need to delete the old 
	// entity, it will get garbage collected, but this is nicer.
	if ( IsValid( self.Entity ) ) then
		self.Entity:Remove()
		self.Entity = nil		
	end
	
	// Note: Not in menu dll
	if ( !ClientsideModel ) then return end
	
	if !strModelName then
		ErrorNoHalt( debug.traceback() )
		Error("Invalid model! Report!")
	end
	
	self.ModelName = strModelName
	self.SkinId = skin

/*	
	if CreateNow then
		self:CreateModel( true )
	end
end

function PANEL:CreateModel( force )
	
	//Do not attempt every frame for something that does not exist
	if force != true && (!self.ModelName || (self.NextCreateAttempt && CurTime() < self.NextCreateAttempt)) then
		return
	end
	self.NextCreateAttempt = CurTime() + 1.0
*/

	if IsValid( self.Entity ) then
		return
	end
	
	if DEBUG then
		print("\tCreating new model" )
	end
	
	self.Entity = ClientsideModel( self.ModelName, RENDER_GROUP_OPAQUE_ENTITY )
	if ( !IsValid(self.Entity) ) then return end
	
	self.Entity:SetNoDraw( true )
	
	if self.SkinId then
		self.Entity:SetSkin( self.SkinId )
	end
	
	// Try to find a nice sequence to play
	local iSeq = self.Entity:LookupSequence( "walk_all" );
	if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
	if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end
	
	if (iSeq > 0) then self.Entity:ResetSequence( iSeq ) end
	
	self:OnModelCreated()
	
end

function PANEL:OnModelCreated()

end

function PANEL:BackgroundDraw()
	
end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:Paint( w, h )

	self:BackgroundDraw()
	
	local x, y = self:LocalToScreen( 0, 0 )
	local w, h = self:GetWide(), self:GetTall()

	if ( !IsValid( self.Entity ) ) then
		//self:CreateModel()
		return
	end
	
	if self.CheckParentLimit then
	
		local Parent = self.CheckParentLimit
		
		local px, py = Parent:LocalToScreen( 0, 0 )
		local pw, ph = Parent:GetWide(), Parent:GetTall()
			
		if y < py then
			h = self:GetTall() - (py - y)
			y = py
		end
		
		if y + h > py + ph then
			h = py + ph - y
		end
	
	end
	
	local errorString = "MISSING CONTENT!"
	
	if !util.IsValidModel( self.ModelName ) then
		
		surface.SetFont( "mikubig" )
		
		local tWid, tHei = surface.GetTextSize( errorString )
		
		local tX = ( self:GetWide() / 2 ) - ( tWid / 2 )
		local tY = ( self:GetTall() / 2 ) - ( tHei / 2 ) - 50
		
		surface.SetTextColor( 255, 0, 0, 255 )
		surface.SetTextPos( tX, tY )
		
		surface.DrawText( errorString )
		
	else
	
		self:LayoutEntity( self.Entity )
		
		cam.Start3D( self.vCamPos, (self.vLookatPos-self.vCamPos):Angle(), self.fFOV, x, y, w, h )
		cam.IgnoreZ( true )
		
		render.SuppressEngineLighting( true )
		render.SetLightingOrigin( self.Entity:GetPos() )
		render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
		render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
		render.SetBlend( self.colColor.a/255 )
		
		for i=0, 6 do
			local col = self.DirectionalLight[ i ]
			if ( col ) then
				render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
			end
		end
		
		self.Entity:DrawModel()
		
		render.SuppressEngineLighting( false )
		cam.IgnoreZ( false )
		cam.End3D()
	
	end
	
	self.LastPaint = RealTime()
	
end

/*---------------------------------------------------------
   Name: RunAnimation
---------------------------------------------------------*/
function PANEL:RunAnimation()
	self.Entity:FrameAdvance( (RealTime()-self.LastPaint) * self.m_fAnimSpeed )	
end

/*---------------------------------------------------------
   Name: LayoutEntity
---------------------------------------------------------*/
function PANEL:LayoutEntity( Entity )

	//
	// This function is to be overriden
	//

	if ( self.bAnimated ) then
		self:RunAnimation()
	end
	
	Entity:SetAngles( Angle( 0, RealTime()*10,  0) )

end

/*---------------------------------------------------------
   Name: GenerateExample
---------------------------------------------------------*/
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		ctrl:SetSize( 300, 300 )
		ctrl:SetModel( "models/error.mdl" )
		
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "DModelPanel2", "A panel containing a model", PANEL, "DButton" ) 