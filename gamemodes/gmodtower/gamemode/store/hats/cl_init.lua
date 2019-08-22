
include('shared.lua')

hook.Add("GTowerStoreLoad", "AddHats", function()
	for _, v in pairs( GTowerHats.Hats ) do

		if v.unique_Name then

			local NewItem = {}

			NewItem.storeid = v.storeid || GTowerHats.StoreId
			NewItem.Name = v.Name
			NewItem.description = v.description
			NewItem.prices = { v.price }
			NewItem.unique_Name = v.unique_Name
			NewItem.model = v.model
			NewItem.drawmodel = true
			NewItem.ModelSkin = v.ModelSkin

			GTowerStore:SQLInsert( NewItem )

		end

	end
end )

function GTowerHats:GetTranslation( hat, model )
	if HatTranslations[model] && HatTranslations[model][hat] then
		return HatTranslations[model][hat]
	end

	return GTowerHats.DefaultValue
end

local DEBUG = false

GTowerHatAdmin = {}
GTowerHatAdmin.PlayerModel = {}
GTowerHatAdmin.HatModel = {}
GTowerHatAdmin.CanUpdate = false
GTowerHatAdmin.CopyData = GTowerHats.DefaultValue

GTowerHatAdmin.MainPanel = nil
GTowerHatAdmin.HatsNodes = nil
GTowerHatAdmin.ModelNodes = nil
GTowerHatAdmin.ModelPanel = nil
GTowerHatAdmin.ValuesList = {}

usermessage.Hook("HatAdm", function( um )

	local HatId = um:ReadString()
	local ModelId = um:ReadString()
	local x = um:ReadFloat()
	local y = um:ReadFloat()
	local z = um:ReadFloat()
	local ap = um:ReadFloat()
	local ay = um:ReadFloat()
	local ar = um:ReadFloat()
	local sc = um:ReadFloat()

	if GTowerHatAdmin.CanUpdate == false then
		return
	end

	local Translation = GTowerHatAdmin:GetTranslation()

	GTowerHatAdmin.CanUpdate = false
	for k, v in pairs( Translation ) do
		GTowerHatAdmin.ValuesList[ k ]:SetValue( v )
	end
	GTowerHatAdmin.CanUpdate = true

end )

hook.Add("CanCloseMenu", "GTowerHatAdmin", function()
	if GTowerHatAdmin.MainPanel then
		return false
	end
end )

hook.Add("GTowerAdminMenus", "AdminHatOffsets", function()
	return {
		["Name"] = "Hat Offsets",
		["function"] = function() GTowerHatAdmin:Open() end
	}
end )

function GTowerHatAdmin:RequestUpdate()

	if GTowerHatAdmin.CanUpdate == false then
		return
	end

	local HatName = GTowerHatAdmin:GetHatName() or "Invalid Hat"
	local ModelName = GTowerHatAdmin:GetPlayerName()

	if GTowerHats:Admin( LocalPlayer() ) then
		timer.Create("Hat" .. HatName .. "|" .. ModelName, 0.3, 1, function() GTowerHatAdmin.ForceUpdate( GTowerHatAdmin, HatName, ModelName ) end)
	end

	if !HatTranslations[ModelName] then
		HatTranslations[ModelName] = {}
	end

	if !HatTranslations[ModelName][HatName] then
		HatTranslations[ModelName][HatName] = {}
	end

	HatTranslations[ModelName][HatName] = {
		GTowerHatAdmin.ValuesList[1]:GetValue(),
		GTowerHatAdmin.ValuesList[2]:GetValue(),
		GTowerHatAdmin.ValuesList[3]:GetValue(),
		GTowerHatAdmin.ValuesList[4]:GetValue(),
		GTowerHatAdmin.ValuesList[5]:GetValue(),
		GTowerHatAdmin.ValuesList[6]:GetValue(),
		GTowerHatAdmin.ValuesList[7]:GetValue()
	}
end

function GTowerHatAdmin:ForceUpdate( HatName, ModelName )

	if GTowerHatAdmin.CanUpdate == false then
		return
	end

	local Values = GTowerHats:GetTranslation( HatName, ModelName )

	RunConsoleCommand("gmt_admsethatpos",
		HatName,
		ModelName,
		Values[1],
		Values[2],
		Values[3],
		Values[4],
		Values[5],
		Values[6],
		Values[7]
	)

end

function GTowerHatAdmin:Open()

	GTowerHatAdmin:Close()
	GtowerMainGui:GtowerShowMenus()

	self.MainPanel = vgui.Create("DFrame")
	self.MainPanel:SetSize( 1200, 600 )
	self.MainPanel:SetTitle("Set hat offset")
	self.MainPanel:SetDeleteOnClose( true )
	self.MainPanel.Close = GTowerHatAdmin.Close



	//=======================================
	// == Panel list of models
	//=======================================
	self.ModelNodes = vgui.Create( "DTree", self.MainPanel )
	self.ModelNodes:SetPos( 5, 25 )
	self.ModelNodes:SetSize( 150, self.MainPanel:GetTall() - 25 - 150 )
	self.ModelNodes.DoClick = function( self, node )
		if DEBUG then Msg("Select model: ", node.ModelName, "\n" ) end
		GTowerHatAdmin:UpdateModelPanels()
	end

	self.HatsNodes = vgui.Create( "DTree", self.MainPanel )
	self.HatsNodes:SetPos( 5, 25 + self.ModelNodes:GetTall() + 3 )
	self.HatsNodes:SetSize( 150, self.MainPanel:GetTall() - 25 - self.ModelNodes:GetTall() - 5 )
	self.HatsNodes.DoClick = function( self, node )
		if DEBUG then Msg("Select hat: ", node.HatId, "\n" ) end
		GTowerHatAdmin:UpdateModelPanels()
	end

	local FirstNode = nil
	for k, v in pairs( GTowerHats:GetModelPlayerList()  ) do
		local node = self.ModelNodes:AddNode( k )
		node.ModelName = k
		node.ModelPath = v

		if !FirstNode then
			FirstNode = node
		end
	end
	self.ModelNodes:SetSelectedItem( FirstNode )



	FirstNode = nil
	for k, v in pairs( GTowerHats.Hats ) do
		local node = self.HatsNodes:AddNode( v.Name )
		node.HatId = k

		if !FirstNode then
			FirstNode = node
		end
	end
	self.HatsNodes:SetSelectedItem( FirstNode )


	//=======================================
	// == MODEL PANEL
	//=======================================

	self.ModelPanel = vgui.Create("DModelPanelHat", self.MainPanel )
	self.ModelPanel:SetPos( 160, 25 )

	if GTowerHats:Admin( LocalPlayer() ) then
		self.ModelPanel:SetSize( 500, 500 )
	else
		self.ModelPanel:SetSize( 570, 570 )
	end

	if GTowerHats:Admin( LocalPlayer() ) then
		//=======================================
		// == SLIDERS
		//=======================================

		local TextValues = {"XPos", "YPos", "ZPos", "PAng", "YAng", "RAng", "Scale" }

		for i=1, 7 do

			local panel = vgui.Create("DNumSlider", self.MainPanel )
			panel:SetWide( 430 )
			panel:SetPos( 665, 50 * i )
			panel:SetText( TextValues[ i ] )
			panel.OnValueChanged = GTowerHatAdmin.RequestUpdate

			if i <= 3 then
				panel:SetMinMax( -50, 50 )
				panel:SetDecimals( 1 )
			elseif i == 7 then
				panel:SetMinMax( 0, 8 )
				panel:SetDecimals( 2 )
			else
				panel:SetMinMax( -180, 180 )
				panel:SetDecimals( 0 )
			end

			self.ValuesList[i] = panel

		end

		//=======================================
		// == COPY PASTE
		//=======================================

		local Copy = vgui.Create("DButton", self.MainPanel )
		Copy:SetText("COPY")
		Copy:SetSize( 100, 50 )
		Copy:SetPos( 200, 600 - 60 )
		Copy.DoClick = function()
			GTowerHatAdmin.CopyData = table.Copy( GTowerHatAdmin:GetTranslation() )
		end

		local Paste = vgui.Create("DButton", self.MainPanel )
		Paste:SetText("PASTE")
		Paste:SetSize( 100, 50 )
		Paste:SetPos( 310, 600 - 60 )
		Paste.DoClick = function()
			for k, v in pairs( 	GTowerHatAdmin.CopyData ) do
				GTowerHatAdmin.ValuesList[ k ]:SetValue( v )
			end
		end
	end

	//=======================================
	// == SORT ITEMS BY Name
	//=======================================

	print(self.ModelNodes)
	/*local Items = self.ModelNodes:GetItems()
	table.sort( Items, function( a, b )
		return a.ModelName < b.ModelName
	end )*/


	GTowerHatAdmin.CanUpdate = GTowerHats:Admin( LocalPlayer() )
	self:UpdateModelPanels()

end

function GTowerHatAdmin:Close()

	if GTowerHatAdmin.MainPanel then GTowerHatAdmin.MainPanel:Remove() end
	if GTowerHatAdmin.HatsNodes then GTowerHatAdmin.HatsNodes:Remove() end
	if GTowerHatAdmin.ModelNodes then GTowerHatAdmin.ModelNodes:Remove() end
	if GTowerHatAdmin.ModelPanel then GTowerHatAdmin.ModelPanel:Remove() end

	for _, v in pairs( GTowerHatAdmin.ValuesList ) do
		v:Remove()
	end

	GTowerHatAdmin.ValuesList = {}
	GTowerHatAdmin.MainPanel = nil
	GTowerHatAdmin.HatsNodes = nil
	GTowerHatAdmin.ModelNodes = nil
	GTowerHatAdmin.ModelPanel = nil
	GTowerHatAdmin.CanUpdate = false

	GtowerMainGui:GtowerHideMenus()

end

function GTowerHatAdmin:GetPlayerModel()
	return self.ModelNodes:GetSelectedItem().ModelPath
end

function GTowerHatAdmin:GetHatModel()
	local HatId = self.HatsNodes:GetSelectedItem().HatId

	return GTowerHats.Hats[ HatId ].model
end


function GTowerHatAdmin:GetPlayerName()
	return self.ModelNodes:GetSelectedItem().ModelName
end

function GTowerHatAdmin:GetHatName()
	local HatId = self.HatsNodes:GetSelectedItem().HatId

	return GTowerHats.Hats[ HatId ].unique_Name
end

function GTowerHatAdmin:GetTranslation()

	return GTowerHats:GetTranslation(
		GTowerHatAdmin:GetHatName()	,
		GTowerHatAdmin:GetPlayerName()
	)

end


function GTowerHatAdmin:UpdateModelPanels()

	if GTowerHatAdmin.CanUpdate == false then
		return
	end

	self.ModelPanel:SetModel( GTowerHatAdmin:GetPlayerModel() )
	self.ModelPanel:SetModelHat( GTowerHatAdmin:GetHatModel() )

	local Translation = GTowerHatAdmin:GetTranslation()

	for k, v in pairs( Translation ) do
		GTowerHatAdmin.ValuesList[ k ]:SetValue( v )
	end

end

concommand.Add("gmt_openhatmenu", function()
	GTowerHatAdmin:Open()
end )

local PANEL = {}

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
	self.EntityHat = nil
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

	self.ViewAngles = Angle(0, 0, 0)
	self.HeadPos = Vector()
	self.ViewDistance = 20
	self.RightDrag = false
end

/*---------------------------------------------------------
   Name: SetDirectionalLight
---------------------------------------------------------*/
function PANEL:SetDirectionalLight( iDirection, color )
	self.DirectionalLight[iDirection] = color
end

function PANEL:ResetCamera()

	self:SetCamPos( self.ViewAngles:Forward() * self.ViewDistance + self.HeadPos )

end

/*---------------------------------------------------------
   Name: OnSelect
---------------------------------------------------------*/
function PANEL:SetModelHat( strModelName )

	// Note - there's no real need to delete the old
	// entity, it will get garbage collected, but this is nicer.
	if ( IsValid( self.EntityHat ) ) then
		self.EntityHat:Remove()
		self.EntityHat = nil
	end

	// Note: Not in menu dll
	if ( !ClientsideModel ) then return end

	self.EntityHat = ClientsideModel( strModelName, RENDER_GROUP_OPAQUE_ENTITY )
	if ( !IsValid(self.EntityHat) ) then return end

	self.EntityHat:SetNoDraw( true )

end

function PANEL:SetModel( strModelName )

	// Note - there's no real need to delete the old
	// entity, it will get garbage collected, but this is nicer.
	if ( IsValid( self.Entity ) ) then
		self.Entity:Remove()
		self.Entity = nil
	end

	// Note: Not in menu dll
	if ( !ClientsideModel ) then return end

	self.Entity = ClientsideModel( strModelName, RENDER_GROUP_OPAQUE_ENTITY )
	if ( !IsValid(self.Entity) ) then return end

	self.Entity:SetNoDraw( true )
	self.Entity:SetBodygroup( 0, 1 ) // hide model hats

	local head = self.Entity:LookupBone("ValveBiped.Bip01_Head1")
	local pos, ang = self.Entity:GetBonePosition(head)

	self.HeadPos = pos

	self:SetLookAt( pos )
	self:ResetCamera()
end

function PANEL:GetTranslation()
	return GTowerHatAdmin:GetTranslation()
end

/*---------------------------------------------------------
   Name: OnMousePressed
---------------------------------------------------------*/
function PANEL:Paint()

	if ( !IsValid( self.Entity ) ) then return end
	if ( !IsValid( self.EntityHat ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )
	//local head = self.Entity:LookupBone("ValveBiped.Bip01_Head1")
	//local pos, ang = self.Entity:GetBonePosition(head)
	local eyes = self.Entity:LookupAttachment( GTowerHats.HatAttachment )
	local EyeTbl = self.Entity:GetAttachment( eyes )
	local pos, ang = EyeTbl.Pos, EyeTbl.Ang
	local trans = self:GetTranslation()

	self:LayoutEntity( self.Entity )

	cam.Start3D( self.vCamPos, (self.vLookatPos-self.vCamPos):Angle(), self.fFOV, x, y, self:GetWide(), self:GetTall() )
	cam.IgnoreZ( true )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( pos + ang:Forward() * 20 )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( self.colColor.a/255 )

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end



	ang:RotateAroundAxis(ang:Right(), trans[4])
	ang:RotateAroundAxis(ang:Up(), trans[5])
	ang:RotateAroundAxis(ang:Right(), trans[6])

	self.Entity:DrawModel()

	self.EntityHat:SetPos( pos +
		(ang:Up() * trans[1]) +
		(ang:Forward() * trans[2]) +
		(ang:Right() * trans[3])
	)
	self.EntityHat:SetAngles( ang )
	self.EntityHat:SetModelScale( trans[7] )

	self.EntityHat:DrawModel()

	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()

	self.LastPaint = RealTime()

end

/*---------------------------------------------------------
   Name: RunAnimation
---------------------------------------------------------*/
function PANEL:RunAnimation()
	//self.Entity:FrameAdvance( (RealTime()-self.LastPaint) * self.m_fAnimSpeed )
end

/*---------------------------------------------------------
   Name: LayoutEntity
---------------------------------------------------------*/
function PANEL:LayoutEntity( Entity )

	//
	// This function is to be overriden
	//

	//if ( self.bAnimated ) then
	//	self:RunAnimation()
	//end

	//Entity:SetAngles( Angle( 0, RealTime()*10,  0) )

end

function PANEL:OnMousePressed( mousecode )
	self.Dragging = { gui.MouseX(), gui.MouseY() }
	self:MouseCapture( true )
	self.RightDrag = mousecode == MOUSE_LEFT
end
function PANEL:OnMouseReleased()
	self.Dragging = nil
	self:MouseCapture( false )
end

function PANEL:Think()

	if self.Dragging then
		if self.RightDrag then
			self.ViewAngles:RotateAroundAxis( self.ViewAngles:Up(), gui.MouseX() - self.Dragging[1] )
			self.ViewAngles:RotateAroundAxis( self.ViewAngles:Right(), self.Dragging[2] - gui.MouseY() )
		else
			self.ViewDistance = self.ViewDistance + (self.Dragging[1] - gui.MouseX()) * 0.1
		end

		self.Dragging = { gui.MouseX(), gui.MouseY() }

		self:ResetCamera()
	end

end

derma.DefineControl( "DModelPanelHat", "A panel containing a model", PANEL, "DButton" )
