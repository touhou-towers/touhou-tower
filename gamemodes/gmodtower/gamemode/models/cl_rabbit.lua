
GTowerModels.RabbitMenu = nil

local function ButtonClick( panel )
	if ValidPanel( GTowerModels.RabbitMenu ) then
		GTowerModels.RabbitMenu:Remove()
	end
	RunConsoleCommand("gmt_rabbit", panel.RabbitId)
end

function GTowerModels.ShowRabbitMenu()

	if ValidPanel( GTowerModels.RabbitMenu ) then
		GTowerModels.RabbitMenu:Remove()
	end

	local MainPanel = vgui.Create("DFrame")
	GTowerModels.RabbitMenu = MainPanel
	MainPanel:SetSize( 600, 600 )
	MainPanel:Center()
	MainPanel:SetTitle( "RABBIT CHOOSER!")
	
	local CategoryList = vgui.Create( "DPanelList", MainPanel )
	CategoryList:SetAutoSize( false )
	CategoryList:EnableHorizontal( true )
	CategoryList:EnableVerticalScrollbar()
	CategoryList:SetSpacing( 2 )
	CategoryList:SetPadding( 2 )
	CategoryList:SetPos( 0, 25 )
	CategoryList:SetSize( MainPanel:GetWide(), MainPanel:GetTall() - 30 )
	
	for _, v in pairs( RabbitItems ) do
		
		local ModelPanel = vgui.Create("DModelPanel2" )
		ModelPanel.CheckParentLimit = CategoryList
		
		ModelPanel:SetModel(v.Model, v.ModelSkinId )
		ModelPanel:SetLookAt( Vector(0,0,64) )
		ModelPanel:SetCamPos( Vector(-64,0,64) )
		ModelPanel:SetSize( 190, 190 )
		
		local button = vgui.Create("DButton", ModelPanel )
		button:SetText( v.Name )
		button:SizeToContents()
		button:CenterHorizontal()
		button:AlignTop( 5 )
		button.RabbitId = v.MysqlId
		button.DoClick = ButtonClick
		
		CategoryList:AddItem( ModelPanel )
		
	end

	CategoryList:InvalidateLayout()
	
end