

-----------------------------------------------------
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

function PANEL:SetDirectionalLight( iDirection, color )
	self.DirectionalLight[iDirection] = color
end

function PANEL:SetModel( strModelName, skin, CreateNow, scale, color )
	
	if DEBUG then
		print("Setting model for: ", strModelName, skin )
	end
	
	if !util.IsValidModel( strModelName ) && !self.OverrideError then
		if DEBUG then
			print("Invalid model model for: ", strModelName, skin )
		end
		strModelName = "models/error.mdl"
	end
	
	if self.ModelName == strModelName then
		if skin && IsValid( self.Entity ) then
			self.SkinId = skin
			self.Entity:SetSkin( skin or 1 )
		end
		
		if DEBUG then
			print("\tSame model found" )
		end
	
		return
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
	self.ModelColor = color or Color( 255, 255, 255 )

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
		self.Entity:SetSkin( self.SkinId or 1 )
	end
	
	// Try to find a nice sequence to play
	local iSeq = self.Entity:LookupSequence( "walk_all" )
	if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
	if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end
	if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "idle" ) end
	if (iSeq <= 0) then iSeq = self.Entity:LookupSequence( "idle1" ) end
	
	if (iSeq > 0) then self.Entity:ResetSequence( iSeq ) end

	// Set scale
	self.Entity.Scale = scale or 1

	self:OnModelCreated()
	
end

function PANEL:OnModelCreated()

end

function PANEL:BackgroundDraw()
	
end

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
	
	if !util.IsValidModel( self.ModelName ) && !self.OverrideError then
		
		surface.SetFont( "GTowerbig" )
		
		local tWid, tHei = surface.GetTextSize( errorString )
		
		local tX = ( self:GetWide() / 2 ) - ( tWid / 2 )
		local tY = ( self:GetTall() / 2 ) - ( tHei / 2 ) - 50
		
		surface.SetTextColor( 255, 0, 0, 255 )
		surface.SetTextPos( tX, tY )
		
		surface.DrawText( errorString )
		
	else
	
		self:LayoutEntity( self.Entity )
		
		cam.Start3D( self.vCamPos, (self.vLookatPos-self.vCamPos):Angle(), self.fFOV, x, y, w, h )
		cam.IgnoreZ( false )
		
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

		self.Entity:SetModelScale( self.Entity.Scale, 0 )
		self.Entity:SetColor( self.ModelColor )
		self.Entity:DrawModel()
		
		render.SuppressEngineLighting( false )
		cam.IgnoreZ( false )
		cam.End3D()
	
	end
	
	self.LastPaint = RealTime()
	
end

function PANEL:RunAnimation()
	self.Entity:FrameAdvance( (RealTime()-self.LastPaint) * self.m_fAnimSpeed )	
end

function PANEL:LayoutEntity( Entity )

	if ( self.bAnimated ) then
		self:RunAnimation()
	end
	
	if !self.Dragging then
		local div = 500000
		if self:IsHovered() then div = 50000 end
		Entity:SetAngles( Entity:GetAngles() + Angle( 0, RealTime() / div,  0) )
	else

		if self.RightDrag then

			local diffX = gui.MouseX() - self.Dragging.x
			Entity:SetAngles( Entity:GetAngles() + Angle( 0, diffX / 100, 0 ) )

		end

	end

end

function PANEL:OnMousePressed( mousecode )

	self.Dragging = { x = gui.MouseX(), y = gui.MouseY() }

	self:MouseCapture( true )
	self.RightDrag = mousecode == MOUSE_LEFT

	MouseDrag.Enable( true, gui.MouseX(), gui.MouseY(), true )

end

function PANEL:OnMouseReleased()

	self.Dragging = nil
	self:MouseCapture( false )
	MouseDrag.Enable( false )

end

derma.DefineControl( "DModelPanel2", "A panel containing a model", PANEL, "DButton" )