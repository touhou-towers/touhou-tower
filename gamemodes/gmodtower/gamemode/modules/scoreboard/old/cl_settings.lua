
GtowerScoreBoard.SettingPanel = nil

local PANEL = {}

local function IconSetModel( icon )
	Msg2("Model is going to be updated once you respawn")
	surface.PlaySound( "ui/buttonclickrelease.wav" ) 
	RunConsoleCommand( "cl_playermodel", icon.ModelName ) 
end

function PANEL:NewCatergory( Name )
	
	local Category = vgui.Create("DCollapsibleCategory", self)
	Category:SetLabel( Name )
	
	local Canvas = vgui.Create( "DPanelList", Category )
	Canvas:SetAutoSize( true )
	Canvas:EnableHorizontal( true )
	Canvas:EnableVerticalScrollbar( true )
	Canvas:SetSpacing( 2 )
	Canvas:SetPadding( 2 )
	Canvas:EnableVerticalScrollbar()
	
	Category:SetContents( Canvas )
	
	return Category, Canvas
	
end

function PANEL:NewSetting( control, parent, text, convar )

	local Control = vgui.Create( control, parent )
	Control:SetConVar( convar )
	Control:SetText( text )
	Control:SetWidth( 300 )
	
	return Control
	
end

function PANEL:Init()

	GtowerScoreBoard.SettingPanel = self
	
	self.Groups = {}
	
	
	/*=========
		Main Settings
	============*/
	
	local MainSettings, MainCanvas = self:NewCatergory( "General Settings" )

	MainCanvas:EnableHorizontal( false )
	MainCanvas:SetSpacing( 4 )
	MainCanvas:SetPadding( 4 )


	local EnableGodmodeSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Enable Godmode?", "gmt_enablegod" )
	MainCanvas:AddItem( EnableGodmodeSetting )

	local VolumeSetting = self:NewSetting( "DNumSlider", MainCanvas, "Volume", Volume.Var )
	VolumeSetting:SetMinMax( 0, 100 )
	VolumeSetting:SetDecimals( 1 )
	MainCanvas:AddItem( VolumeSetting )

	local IgnoreEmitSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Ignore Music Streams", "gmt_ignoreemitstream" )
	MainCanvas:AddItem( IgnoreEmitSetting )

	local SoundSpamSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Allow Sound Spam", "gmt_allowSoundSpam" )
	MainCanvas:AddItem( SoundSpamSetting )

	local BloodSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Allow Chainsaw Blood", "gmt_allowblood" )
	MainCanvas:AddItem( BloodSetting )

	/*local FogSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Disable Fog", "gmt_removefog" )
	MainCanvas:AddItem( FogSetting )*/

	local HUDSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Enable HUD", "gmt_hud" )
	MainCanvas:AddItem( HUDSetting )

	local HUDLocSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Enable HUD Location", "gmt_hud_location" )
	MainCanvas:AddItem( HUDLocSetting )

	local ThirdPersonDistSetting = self:NewSetting( "DNumSlider", MainCanvas, "Third Person Camera Distance", "gmt_SetThirdPersonDist" )
	ThirdPersonDistSetting:SetMinMax( 35, 150 )
	ThirdPersonDistSetting:SetDecimals( 1 )
	MainCanvas:AddItem( ThirdPersonDistSetting )
	
	local DlightSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Dynamic Firework Lights", "gmt_fireworkdlight" )
	MainCanvas:AddItem( DlightSetting )
	
	local SoundScapeSetting = self:NewSetting( "DCheckBoxLabel", MainCanvas, "Enable Soundscapes", "gmt_soundscapes_enable" )
	MainCanvas:AddItem( SoundScapeSetting )

	local SSVolSetting = self:NewSetting( "DNumSlider", MainCanvas, "Soundscape Volume", "gmt_soundscapes_volume" )
	SSVolSetting:SetMinMax( 0, 100 )
	SSVolSetting:SetDecimals( 1 )
	MainCanvas:AddItem( SSVolSetting )
	
	self.Groups["MainSettings"] = MainSettings

	
	/*=========
		Model selection
	============*/
	
	local ModelSelection, CategoryList = self:NewCatergory( T("PlayerModel") )	
	ModelSelection.ModelCategory = CategoryList
	ModelSelection:SetCookieName( "GTSetModelListOpen" )	
	self.Groups["ModelSelection"] = ModelSelection
	
	self:GenerateModelSelection()
	
end

function PANEL:GenerateModelSelection()

	local UsedModels = {}
	local CategoryList = self.Groups["ModelSelection"].ModelCategory
	
	CategoryList:Clear( true )
	
	local function AddSpawnIcon( Name, model, skin )
	
		if table.HasValue( UsedModels, Name ) then
			return
		end
		
		local icon = vgui.Create( "SpawnIcon", self )
		icon:SetModel( model, skin )
		icon.ModelName = Name
		icon.DoClick = IconSetModel
		icon:SetSize( 64,64 )
		icon:InvalidateLayout( true )
			
		CategoryList:AddItem( icon )
		table.insert( UsedModels, model )
		
	end
	
	for Name, model in pairs( player_manager.AllValidModels() ) do		
		if hook.Call( "AllowModel", GAMEMODE, LocalPlayer(), Name ) != false then
			AddSpawnIcon( Name, model, skin )
		end
	end
	
	hook.Call("ClientExtraModels", GAMEMODE, AddSpawnIcon )

end

function PANEL:OnMousePressed()
    GtowerMenu:CloseAll()
end

function PANEL:Removing()
end

function PANEL:Think()

end

function PANEL:Paint()

end



function PANEL:PerformLayout()
	
	local SumHeight = 2
	
	for _, v in pairs( self.Groups ) do
		v:SetWide( self:GetWide() - 6 )
		v:SetPos(3, SumHeight)
		
		SumHeight = SumHeight + v:GetTall() + 2
	end
	
	self.ItemParent:SetTargetTall( SumHeight, self )
	self:SetTall( SumHeight )
	
end



vgui.Register("ScoreBoardSettings",PANEL, "Panel")
