
module( "Scoreboard.Appearance", package.seeall )

// TAB
surface.CreateFont( "GTowerHUDMainTiny", { font = "Oswald", size = 16, weight = 400 } )
hook.Add( "ScoreBoardItems", "AppearanceTab", function()
	return vgui.Create( "AppearancePlayersTab" )
end )

TAB = {}
TAB.Order = 4
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

	surface.PlaySound( "ui/buttonclickrelease.wav" ) 

	if IsLobby then
		--Msg2( T("PlayerModelUpdated") )
		Msg2("Model is going to be updated once you respawn")
	else
		--Msg2( T("PlayerModelUpdatedLater") )
		Msg2("Model is going to be updated once you respawn")
	end

	RunConsoleCommand( "cl_playermodel", icon.ModelName )
	RunConsoleCommand( "gmt_updateplayermodel" )

end

local function IconSetHatModel( icon )

	surface.PlaySound( "ui/buttonclickrelease.wav" )
	--RunConsoleCommand( "gmt_sethat", icon.HatID )
	RunConsoleCommand( "gmt_sethat", GTowerHats.Hats[ icon.HatID ].unique_Name )

end

local ModelSizeX = 300
local ModelSizeY = 425
local CameraZPos = 38
local ModelPanelSize = 250
local ViewAngles = Vector(0, 0, CameraZPos)

APPEARANCE = {}

function APPEARANCE:NewCategory( Name, cookie )

	local Category = vgui.Create( "ScoreboardSettingsCategory", self )
	Category:SetLabel( Name )
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
	--local ModelSelection, CategoryList = self:NewCategory( "Player Models", "GTSetModelListOpen" )
	--self.Groups["ModelSelection"] = ModelSelection

	// Hats
	//local HatModelSelectionHead, HatCategoryListHead = self:NewCategory( "Hats - Head", "GTSetHatModelListHeadOpen" )
	//self.Groups["HatModelSelectionHead"] = HatModelSelectionHead

	local HatModelSelectionFace, HatCategoryListFace = self:NewCategory( "Hats", "GTSetHatModelListFaceOpen" )
	self.Groups["HatModelSelectionFace"] = HatModelSelectionFace

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
	--local modelName = LocalPlayer():GetTranslatedModel()
	local modelName = LocalPlayer():GetModel()

	util.PrecacheModel( modelName )

	// Set the model
	self.ModelPanel:SetModel( modelName, LocalPlayer():GetSkin() )

	// Set the hats
	--self.ModelPanel:SetModelWearables( LocalPlayer() )

	// Set color and materials
	--self.ModelPanel.Entity:SetPlayerProperties( LocalPlayer() )

end

local matHover = Material( "vgui/spawnmenu/hover" )

function APPEARANCE:GenerateModelSelection()

	//if !IsLobby then return end

	local UsedModels = {}
	local UsedHats = {}
	--local CategoryList = self.Groups["ModelSelection"].Category
	//local HatCategoryListHead = self.Groups["HatModelSelectionHead"].Category
	local HatCategoryListFace = self.Groups["HatModelSelectionFace"].Category

	--CategoryList:Clear( true )
	//HatCategoryListHead:Clear( true )
	HatCategoryListFace:Clear( true )

	local function AddSpawnIcon( Name, model, skin, onclick, category, hatid, hatSlot, iconsize )

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

		local icon = vgui.Create( "SpawnIcon", self )
		icon:SetModel( model, skin )
		icon:SetTooltip( false )
		icon:SetSize( 48, 48 )
		icon.HatID = hatid
		icon.HatSlot = hatSlot
		icon.Model = model
		icon.ModelName = Name

		icon.DoRightClick = function() end
		icon.OpenMenu = function() end

		icon.IsMouseOver = function()
			local x,y = icon:CursorPos()
			return x >= 0 and y >= 0 and x <= icon:GetWide() and y <= icon:GetTall()
		end

		/*icon.Think = function()

			WasLeftClickHeld = IsLeftClickHeld
			IsLeftClickHeld = input.IsMouseDown( MOUSE_LEFT )

			if icon:IsMouseOver() && IsLeftClickHeld && !WasLeftClickHeld then
				icon:DoClick()
			end

		end*/

		icon.PaintOver = function( w, h )

			//icon:DrawSelections()
			local Name = string.upper( tostring( icon.ModelName ) )
			local w, h = icon:GetWide(), icon:GetTall()

			if string.find( Name, "-" ) then
				Name = string.sub( Name, 0, -3 )
			end

			Name = string.gsub( Name, "_", " " )

			surface.SetFont( "GTowerHUDMainTiny" )
			surface.SetTextPos( 1, 0 )

			if !icon:IsMouseOver() then return end

			surface.SetDrawColor( 0, 0, 0, 150 )
			surface.DrawRect( 2, 2, w - 4, 16 )

			surface.SetTextColor( 255, 255, 255, 255 )
			surface.DrawText( Name )

			--icon:DrawBorder( 2 )
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

	/*for Name, model in pairs( player_manager.AllValidModels() ) do
		if hook.Call( "AllowModel", GAMEMODE, LocalPlayer(), Name ) then
			AddSpawnIcon( Name, model, skin, IconSetModel, CategoryList, 0, 0, 48 )
		end
	end
	hook.Call( "ClientExtraModels", GAMEMODE, AddSpawnIcon, IconSetModel, CategoryList, 0, 0, 28 )*/

	// HATS

	// Hat remove
	//AddSpawnIcon( GTowerHats.Hats[0].Name, GTowerHats.Hats[0].model, 0, IconSetHatModel, HatCategoryListHead, 0, 1 )
	//AddSpawnIcon( GTowerHats.Hats[0].Name, GTowerHats.Hats[0].model, 0, IconSetHatModel, HatCategoryListFace, 0, 2 )

	for hatid, hat in pairs( GTowerHats.Hats ) do

		//if hook.Call( "CanWearHat", GAMEMODE, LocalPlayer(), hat.unique_Name ) == 1 then

			if hat.slot == 1 then
				//print(hat.Name)
				//AddSpawnIcon( hat.Name, hat.model, hat.ModelSkinId, IconSetHatModel, HatCategoryListHead, hatid, hat.slot )
			else
				AddSpawnIcon( hat.Name, hat.model, hat.ModelSkinId, IconSetHatModel, HatCategoryListFace, hatid, hat.slot )
			end

		//end

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
	PlayerColor:SetPalette( true )
	PlayerColor:SetSize( ModelSizeX - 10, 150 )
	PlayerColor.NextConVarCheck = SysTime()
	PlayerColor:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) )
	PlayerColor.ValueChanged = function()
		RunConsoleCommand( "cl_playercolor", tostring( PlayerColor:GetVector() ) )
	--	RunConsoleCommand( "gmt_updateplayercolor" ) -- shit dont work
		LocalPlayer():SetPlayerColor(PlayerColor:GetVector())
	end

	local function UpdateFromConvars()
		PlayerColor:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) )
	end

	PlayerColor.OnActivePanelChanged = function() timer.Simple( 0.1, UpdateFromConvars() ) end
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

	local colorPanel = 150
	local minY = 2 + ModelSizeY + ( colorPanel + 30 ) // padding + model panel + color panel
	local curY = 2

	for id, category in pairs( self.Groups ) do

		category:SetWide( self:GetWide() - 6 - ModelSizeX )
		category:SetPos( ModelSizeX + 3, curY )

		curY = curY + category:GetTall() + 2

	end

	if self.ColorSelection then
		self.ColorSelection:SetSize( ModelSizeX, colorPanel )
		self.ColorSelection:SetPos( 0, ModelSizeY )
	end

	if self.GlowColorSelection then
		self.GlowColorSelection:SetSize( ModelSizeX, colorPanel )
		self.GlowColorSelection:SetPos( 0, ModelSizeY + ( colorPanel + 30 ) )
		minY = minY + ( colorPanel + 30 )
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
