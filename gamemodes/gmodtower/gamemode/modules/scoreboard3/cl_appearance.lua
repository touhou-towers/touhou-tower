
-----------------------------------------------------
module( "Scoreboard.Appearance", package.seeall )



// TAB



hook.Add( "ScoreBoardItems", "AppearanceTab", function()

	return vgui.Create( "AppearancePlayersTab" )

end )



TAB = {}

TAB.Order = 2

TAB.HideForGamemode = true



function TAB:GetText()

	return "OUTFIT"

end



function TAB:CreateBody()

	return vgui.Create( "ScoreboardAppearance", self )

end



function TAB:OnOpen()

	if ValidPanel( self.Body ) then

		self.Body:OnOpen()

	end

end



vgui.Register( "AppearancePlayersTab", TAB, "ScoreboardTab" )



// APPEARANCE



local function IconSetModel( icon )



	--surface.PlaySound( "ui/buttonclickrelease.wav" ) 



	if IsLobby && !IsValid( LocalPlayer():GetVehicle() ) then

		Msg2( T("PlayerModelUpdated") )

	else

		Msg2( T("PlayerModelUpdatedLater") )

	end



	RunConsoleCommand( "cl_playermodel", icon.ModelName )



	if !IsValid( LocalPlayer():GetVehicle() ) then

		RunConsoleCommand( "gmt_updateplayermodel" )

	end



end



local function IconSetHatModel( icon )



	surface.PlaySound( "ui/buttonclickrelease.wav" ) 

	--RunConsoleCommand( "gmt_sethat", icon.HatID, icon.HatSlot )
	RunConsoleCommand( "gmt_sethat", GTowerHats.Hats[ icon.HatID ].unique_Name )



end



local ModelSizeX = 300

local ModelSizeY = 425

local CameraZPos = 38

local ModelPanelSize = 250

local ViewAngles = Vector(0, 0, CameraZPos)



APPEARANCE = {}



function APPEARANCE:NewCategory( name, cookie )

	

	local Category = vgui.Create( "ScoreboardSettingsCategory", self )

	Category:SetLabel( name )

	Category.OnMouseWheeled = function( Category, dlta )

		Scoreboard.ParentMouseWheeled( self, dlta )

	end

	

	local Canvas = vgui.Create( "ScoreboardSettingsList", Category )

	Canvas:SetAutoSize( true )

	Canvas:EnableHorizontal( true )

	Canvas:EnableVerticalScrollbar( true )

	Canvas:SetSpacing( 2 )

	Canvas:SetPadding( 2 )

	Canvas:EnableVerticalScrollbar()

	Canvas.OnMouseWheeled = function( Canvas, dlta )

		Scoreboard.ParentMouseWheeled( self, dlta )

	end

	

	Category:SetContents( Canvas )

	Category.Category = Canvas

	Category:SetCookieName( cookie )

	

	return Category, Canvas

	

end



function APPEARANCE:Init()



	self.Groups = {}



	// Preview

	self.ModelPanel = vgui.Create( "DModelPanelWearables", self )

	self.ModelPanel:SetAnimated( true )

	self.ModelPanel:SetZPos( 2 )



	local gradient = surface.GetTextureID( "VGUI/gradient_up" )

	self.ModelPanel.BackgroundDraw = function()

		surface.SetDrawColor( 0, 0, 0, 200 )

		surface.SetTexture( gradient )

		surface.DrawTexturedRect( 0, 0, self.ModelPanel:GetSize() )

	end



	// Player models

	local ModelSelection = self:NewCategory( "Default Player Models", "GTSetModelListOpen" )

	self.Groups[1] = ModelSelection



	// GMT player models

	local ModelSelection = self:NewCategory( "Player Models", "GTSetModelGMTListOpen" )

	self.Groups[2] = ModelSelection



	// Hats

	local HatModelSelection = self:NewCategory( "Hats - Head", "GTSetHatModelListHeadOpen" )

	self.Groups[3] = HatModelSelection



	local HatModelSelection = self:NewCategory( "Hats - Face", "GTSetHatModelListFaceOpen" )

	self.Groups[4] = HatModelSelection



	// Update everything

	self:GenerateModelSelection()

	self:GenerateColorSelection()

	self:UpdateModelPanel()



	self:SetScrollBarColors( Scoreboard.Customization.ColorNormal, Scoreboard.Customization.ColorBackground )

	self:InvalidateLayout()



end



function APPEARANCE:UpdateModelPanel()

	

	if !ValidPanel( self.ModelPanel ) then return end

		

	self.ModelPanel:SetSize( ModelSizeX, ModelSizeY )

	self.ModelPanel:SetPos( 0, 0 )



	self.ModelPanel:SetLookAt( ViewAngles )

	self.ModelPanel:SetCamPos( Vector(40,0,CameraZPos) )



	// Get proper model

	local modelname = LocalPlayer():GetTranslatedModel()



	util.PrecacheModel( modelname )



	// Set the model

	self.ModelPanel:SetModel( modelname, LocalPlayer():GetSkin() )



	// Set the hats

	--self.ModelPanel:SetModelWearables( LocalPlayer() )



	// Set color and materials

	self.ModelPanel.Entity:SetPlayerProperties( LocalPlayer() )

	

end



local matHover = Material( "vgui/spawnmenu/hover" )

net.Receive('gmt_models', function()
	local tbl = net.ReadTable()
	
	LocalPlayer()._ModelTable = tbl
	
end)

function APPEARANCE:GenerateModelSelection()



	if !IsLobby then return end

	RunConsoleCommand( "gmt_requesthatstoreupdate" )
	RunConsoleCommand( "gmt_requestmodelupdate" )



	local UsedModels = {}

	local UsedHats = {}

	local CategoryList = self.Groups[1].Category

	local CategoryGMTList = self.Groups[2].Category

	local HatCategoryListHead = self.Groups[3].Category

	local HatCategoryListFace = self.Groups[4].Category

	

	CategoryList:Clear( true )

	CategoryGMTList:Clear( true )

	HatCategoryListHead:Clear( true )

	HatCategoryListFace:Clear( true )



	local function AddSpawnIcon( name, model, skin, onclick, category, hatid, hatSlot, description, bettername )



		if !hatid && table.HasValue( UsedModels, model ) then return end

	

		if hatid != 0 then



			if table.HasValue( UsedHats, hatid ) then

				return

			end



			table.insert( UsedHats, hatid )



		else



			if hatid != 0 && table.HasValue( UsedModels, model ) then

				return

			end



		end



		local dvgui = "SpawnIcon"



		-- Custom icon support

		local path = "materials/gmod_tower/icons/" .. string.StripExtension( model )

		if name == "Cap Reversed" then path = path .. "_backwards" end

		if skin and skin > 0 then path = path .. "_skin" .. skin end -- Skin support

		path = path .. ".png"



		if category != CategoryList then

			dvgui = "DImageButton"

		end



		local icon = vgui.Create( dvgui, self )



		-- Old model icon

		if dvgui == "SpawnIcon" then

			icon:SetModel( model, skin )

		end



		-- New custom icons

		if dvgui == "DImageButton" then

			icon:SetSize( 64, 64 )



			icon:SetImage( path )

		end



		icon:SetTooltip( false )

		if category == CategoryList then

			icon:SetSize( 40, 40 )

		end



		//icon:SetIconSize( 64 )

		icon.HatID = hatid

		icon.HatSlot = hatSlot

		icon.Model = model

		icon.ModelName = name

		icon.BetterName = bettername or name

		icon.Description = description or ""



		icon.DoRightClick = function() end

		icon.OpenMenu = function() end



		icon.IsMouseOver = function()

			local x,y = icon:CursorPos()

			return x >= 0 and y >= 0 and x <= icon:GetWide() and y <= icon:GetTall()

		end



		icon.OnCursorEntered = function()

			if GTowerItems then GTowerItems:ShowTooltip( icon.BetterName, icon.Description, self ) end

		end



		icon.OnCursorExited = function()

			if GTowerItems then GTowerItems:HideTooltip() end

		end



		icon.PaintOver = function( self, w, h )



			//icon:DrawSelections()

			--[[local name = string.upper( tostring( icon.ModelName ) )



			if string.find( name, "-" ) then

				name = string.sub( name, 0, -3 )

			end



			name = string.gsub( name, "_", " " )



			surface.SetFont( "GTowerToolTip" )

			surface.SetTextPos( 1, 0 )]]



			if ( icon.Model == LocalPlayer():GetTranslatedModel() ) || ( icon.HatID != 0 && GTowerHats:IsWearing(LocalPlayer(),icon.Model)/*GTowerHats.IsWearingID( LocalPlayer(), icon.HatID )*/ ) then

				

				--[[surface.SetDrawColor( 255, 255, 255, 150 )

				surface.DrawRect( 2, 2, w - 4, 16 )



				surface.SetTextColor( 0, 0, 0, 255 )

				surface.DrawText( name )]]



				draw.RectBorder( 0, 0, w, h, 4, Color( 200, 200, 255 ) )

				//surface.DrawRect( 0, 0, icon:GetSize() )

				//surface.SetMaterial( matHover )

				//icon:DrawTexturedRect()

				return

			end



			if !icon:IsMouseOver() then return end



			--[[surface.SetDrawColor( 0, 0, 0, 150 )

			surface.DrawRect( 2, 2, w - 4, 16 )



			surface.SetTextColor( 255, 255, 255, 255 )

			surface.DrawText( name )]]



			draw.RectBorder( 0, 0, w, h, 4, Scoreboard.Customization.ColorDark )

			//surface.SetMaterial( matHover )

			//icon:DrawTexturedRect()



		end

		

		icon.DoClick = onclick



		if ValidPanel( category ) then

			category:AddItem( icon )

		end



		icon:InvalidateLayout( true )



		table.insert( UsedModels, model )

		

	end



	// PLAYER MODELS



	for name, model in pairs( player_manager.AllValidModels() ) do

		if !LocalPlayer()._ModelTable then LocalPlayer()._ModelTable = {} end

		if GTowerModels.NormalModels[name] && table.HasValue( LocalPlayer()._ModelTable, model ) then 
			AddSpawnIcon( name, model, skin, IconSetModel, CategoryGMTList, 0, 0, "A standard player model." )
			continue 
		end

		--AddSpawnIcon( name, model, skin, IconSetModel, CategoryList, 0, 0, "A standard player model." )

	end



	hook.Call( "ClientExtraModels", GAMEMODE, AddSpawnIcon, IconSetModel, CategoryGMTList )



	// HATS



	// Hat remove

	AddSpawnIcon( GTowerHats.Hats[0].name, GTowerHats.Hats[0].model, 0, IconSetHatModel, HatCategoryListHead, 0, 1, "Remove head hat." )

	AddSpawnIcon( GTowerHats.Hats[0].name, GTowerHats.Hats[0].model, 0, IconSetHatModel, HatCategoryListFace, 0, 2, "Remove face hat." )



	-- Store original hat ids

	for hatid, hat in pairs( GTowerHats.Hats ) do

		hat.hatid = hatid

	end



	-- Sort by ABC

	local HatsSorted = table.Copy( GTowerHats.Hats )

	table.sort( HatsSorted, function( a, b )

		return a.Name < b.Name

	end )



	-- Add the icons

	for id, hat in pairs( HatsSorted ) do

		if hook.Call( "CanWearHat", GAMEMODE, LocalPlayer(), hat.unique_Name ) == 1 then

			if hat.slot == 1 then

				AddSpawnIcon( hat.name, hat.model, hat.ModelSkinId, IconSetHatModel, HatCategoryListHead, hat.hatid, hat.slot, hat.description )

			else

				AddSpawnIcon( hat.name, hat.model, hat.ModelSkinId, IconSetHatModel, HatCategoryListFace, hat.hatid, hat.slot, hat.description )

			end



		end



	end



end



function APPEARANCE:GenerateColorSelection()



	// Color

	local ColorSelection, ColorCategoryList = self:NewCategory( "Color" )

	ColorSelection:SetCookieName( "GTSetColorListOpen" )

	self.ColorSelection = ColorSelection



	ColorCategoryList:Clear( true )



	local PlayerColor = vgui.Create( "DColorMixer", self )

	PlayerColor:SetAlphaBar( false )

	PlayerColor:SetPalette( false )

	PlayerColor:SetWangs( false )

	PlayerColor:SetSize( ModelSizeX - 10, 80 )

	PlayerColor.NextConVarCheck = SysTime()

	PlayerColor:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) )

	PlayerColor.ValueChanged = function()

		RunConsoleCommand( "cl_playercolor", tostring( PlayerColor:GetVector() ) )

		RunConsoleCommand( "gmt_updateplayercolor" )

	end



	local function UpdateFromConvars()

		PlayerColor:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) )

	end



	PlayerColor.OnActivePanelChanged = function() timer.Simple( 0.1, UpdateFromConvars ) end

	ColorCategoryList:AddItem( PlayerColor )



	// Glow Color

	if LocalPlayer().IsVIP && LocalPlayer():IsVIP() then



		local GlowColorSelection, GlowColorCategoryList = self:NewCategory( "Glow Color" )

		GlowColorSelection:SetCookieName( "GTSetGlowColorListOpen" )

		self.GlowColorSelection = GlowColorSelection



		local GlowColor = vgui.Create( "DColorMixer", self )

		GlowColor:SetAlphaBar( false )

		GlowColor:SetPalette( false )

		GlowColor:SetWangs( false )

		GlowColor:SetSize( ModelSizeX - 10, 80 )

		GlowColor.NextConVarCheck = SysTime()

		GlowColor:SetVector( Vector( GetConVarString( "cl_playerglowcolor" ) ) )

		GlowColor.ValueChanged = function()

			RunConsoleCommand( "cl_playerglowcolor", tostring( GlowColor:GetVector() ) )

			LocalPlayer()._NextGlow = CurTime() + 1

		end



		local function UpdateFromConvars()

			GlowColor:SetVector( Vector( GetConVarString( "cl_playerglowcolor" ) ) )

		end



		GlowColor.OnActivePanelChanged = function() timer.Simple( 0.1, UpdateFromConvars ) end

		GlowColorCategoryList:AddItem( GlowColor )



	end



end



hook.Add( "PlayerThink", "SyncPlayerGlow", function( ply )



	if LocalPlayer().IsVIP && LocalPlayer():IsVIP() then



		if ply._NextGlow && ply._NextGlow < CurTime() then

			RunConsoleCommand( "gmt_updateglowcolor" )

			ply._NextGlow = nil

		end



	end



end )



function APPEARANCE:OnOpen()



	self:GenerateModelSelection()

	self:InvalidateLayout()



end



function APPEARANCE:Think()



	if !self:IsVisible() then return end



	if !self._NextGenerate || self._NextGenerate < CurTime() then



		self:UpdateModelPanel()

		self:GenerateModelSelection()

		self:InvalidateLayout()



		self._NextGenerate = CurTime() + .5



	end



end



function APPEARANCE:PerformLayout()



	local curY = 2

	

	for id, category in ipairs( self.Groups ) do



		category:SetWide( self:GetWide() - 6 - ModelSizeX )

		category:SetPos( ModelSizeX + 3, curY )

		

		curY = curY + category:GetTall() + 2



	end



	local minY = 2 + ModelSizeY // padding + model panel



	if self.ColorSelection then

		self.ColorSelection:SetWide( ModelSizeX )

		self.ColorSelection:SetPos( 0, ModelSizeY )

		minY = minY + self.ColorSelection:GetTall() + 30

	end



	if self.GlowColorSelection then

		self.GlowColorSelection:SetWide( ModelSizeX )

		self.GlowColorSelection:SetPos( 0, ModelSizeY + self.ColorSelection:GetTall() )

		minY = minY + self.GlowColorSelection:GetTall() + 30

	end



	if curY < minY then

		curY = minY

	end

	

	//self.ItemParent:SetTargetTall( SumHeight, self )

	self:SetTall( curY )



end





local gradient = surface.GetTextureID( "VGUI/gradient_up" )

function APPEARANCE:Paint( w, h )



	surface.SetDrawColor( Scoreboard.Customization.ColorNormal )

	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )



	//self:DrawModelHat( self.ModelPanel.Entity )



end



vgui.Register( "ScoreboardAppearance", APPEARANCE, "DPanelList2" )



/**

	A single collapsable category that holds settings

*/

SETTINGSCATEGORY = {}



function SETTINGSCATEGORY:Init()



	self:SetLabel( "Unknown" )

	self:SetLabelFont( Scoreboard.Customization.CollapsablesFont, false )

	self:SetTabCurve( 0 )



	self:SetColors( 

		Scoreboard.Customization.ColorDark, 

		Scoreboard.Customization.ColorBackground, 

		Scoreboard.Customization.ColorBright, 

		Scoreboard.Customization.ColorBright

	)



	self:SetPadding( 2 )

	//self:EnableVerticalScrollbar( false )



end



vgui.Register( "ScoreboardSettingsCategory", SETTINGSCATEGORY, "DCollapsibleCategory2" )









SETTINGSLIST = {}



function SETTINGSLIST:Paint( w, h )



	surface.SetDrawColor( Scoreboard.Customization.ColorNormal )

	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )



	surface.SetDrawColor( 0, 0, 0, 100 )

	surface.SetTexture( gradient )

	surface.DrawTexturedRect( 0, 0, self:GetSize() )



end



/*function SETTINGSLIST:PreformLayout()



	local width = self:GetWide()

	local itemPerRow = math.Round( width / 64 )

	local itemSize = ( width - 3 ) / itemPerRow



	local x,y = 2, 2



	for _, item in ipairs( self.Items ) do



		item:SetIconSize( itemSize - 2 )

		item:SetPos( x, y )

		item:InvalidateLayout( true )



		x = x + itemSize



		if x + itemSize > width then

			y = y + itemSize

			x = 2

		end



	end



	if x == 2 then

	--	y = y - itemSize 

	end



	self:SetTall( y )



end*/



vgui.Register( "ScoreboardSettingsList", SETTINGSLIST, "DPanelList2" )