
-----------------------------------------------------
local PANEL = {}
PANEL.CardModel = "models/gmod_tower/casino/cards/cards_"
local gradient = Material( "VGUI/gradient_down" )

AccessorFunc( PANEL, "Entity", 			"Entity" )
AccessorFunc( PANEL, "vCamPos", 		"CamPos" )
AccessorFunc( PANEL, "fFOV", 			"FOV" )
AccessorFunc( PANEL, "vLookatPos", 		"LookAt" )
AccessorFunc( PANEL, "colAmbientLight", "AmbientLight" )
AccessorFunc( PANEL, "colColor", 		"Color" )

function PANEL:Init()

	self:SetSize( 512, 512 )

	self.CurAngle = 90
	self.Speed = 480

	self.Bright = 1
	self.Entity = nil
	self.LastPaint = 0
	self.DirectionalLight = {}
	
	self:SetCamPos( Vector( 0, 90, 40 ) )
	self:SetLookAt( Vector( 0, 0, 40 ) )
	self:SetFOV( 70 )

	self:SetAmbientLight( Color( 50, 50, 50 ) )

	self:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255 ) )
	self:SetDirectionalLight( BOX_LEFT, Color( 255, 255, 255 ) )
	self:SetDirectionalLight( BOX_RIGHT, Color( 255, 255, 255 ) )
	
	self:SetColor( Color( 255, 255, 255, 255 ) )

end

function PANEL:SetDirectionalLight( iDirection, color )
	self.DirectionalLight[iDirection] = color
end

local SuitModels = {
	[1] = "d",
	[2] = "h",
	[3] = "c",
	[4] = "s"
}

function PANEL:SetCard( suit, val )

	local model = SuitModels[suit] or "c"
	self:SetModel( self.CardModel .. model .. "1.mdl", val - 1, 25 )

end

function PANEL:SetModel( strModelName, skin, scale )

	if self.ModelName == strModelName then

		if skin && IsValid( self.Entity ) then
			self.SkinId = skin
			self.Entity:SetSkin( skin or 1 )
		end	
		return

	end

	// Note - there's no real need to delete the old 
	// entity, it will get garbage collected, but this is nicer.
	if IsValid( self.Entity ) then
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

	if IsValid( self.Entity ) then return end

	self.Entity = ClientsideModel( self.ModelName, RENDER_GROUP_OPAQUE_ENTITY )
	if IsValid( self.Entity ) then

		self.Entity:SetNoDraw( true )
	
		if self.SkinId then
			self.Entity:SetSkin( self.SkinId or 1 )
		end

		// Set scale
		self.Entity.Scale = scale or 1

		self:OnModelCreated()

	end
	
end

function PANEL:OnModelCreated()

end

function PANEL:BackgroundDraw( w, h )

	/*surface.SetDrawColor( 255, 0, 0, 50 )
	surface.DrawRect( 0, 0, w, h )*/

end

function PANEL:SetBright( x )

	self.Bright = x or 1

end

function PANEL:Paint( w, h )

	self:BackgroundDraw( w, h )
	
	local x, y = self:LocalToScreen( 0, 0 )
	local w, h = self:GetWide(), self:GetTall()

	if !IsValid( self.Entity ) then
		return
	end

	self:LayoutEntity( self.Entity )

	cam.Start3D( self.vCamPos - Vector( 31.6, 0, 0 ), (self.vLookatPos-self.vCamPos):Angle(), self.fFOV, x, y, w, h )
	cam.IgnoreZ( false )
	
	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )

	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( self.colColor.a/255 )
	
	for i=0, 6 do
		local col = self.DirectionalLight[ i ]

		if col then
			render.SetModelLighting( i, col.r * self.Bright /255, col.g * self.Bright /255, col.b * self.Bright /255 )
		end
	end

	self.Entity:SetModelScale( self.Entity.Scale, 0 )
	self.Entity:DrawModel()
	
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
	
	self.LastPaint = RealTime()
	
end

function PANEL:SetReveal( bool )

	if bool && !self.IsRevealed then
		timer.Simple( math.Rand( .25, .5 ), function()
			surface.PlaySound( "GModTower/casino/cards/cardflip" .. math.random( 1, 5 ) .. ".wav" )
		end )
	end

	self.IsRevealed = bool
	//self.RevealTime = RealTime()
end

function PANEL:IsFullyRevealed()
	return self.CurAngle == -90
end

function PANEL:LayoutEntity( Entity )

	local angle = 90

	if self.IsRevealed then
		angle = -90
	end

	/*local percent = ( self.CurAngle - angle ) * ( self.RevealTime - 5 )
	self.CurAngle = self.CurAngle * math.EaseInOut( percent, .5, .5 )*/

	self.CurAngle = math.Approach( self.CurAngle, angle, FrameTime() * self.Speed )
	Entity:SetAngles( Angle( 0, self.CurAngle, 0 ) )

end

derma.DefineControl( "DModelCard", "Card Panel", PANEL )