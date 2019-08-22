
PvpBattle.MainPanel = nil
PvpBattle.ModelPanels = {}
PvpBattle.HighestWidth = 100
PvpBattle.CreateTime = 0

PvpBattle.PvpLabel = nil
PvpBattle.WhiteBox = nil
PvpBattle.SelectLabel = nil

local DEBUG = false

local function PanelDrawBackgroundSel( self )
	draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(),  Color(136, 200, 106, 255) )
	draw.RoundedBox( 8, 2, 2, self:GetWide()-4, self:GetTall()-4,  Color(49, 119, 171, 255) )
end

local function PanelDrawBackground( self )
	draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(),  Color(49, 119, 171, 255) )
end

local function PanelDrawBackgroundInvalid( self )
	draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(),  Color( 140, 65, 90, 255) )
end

local function PanelDrawBlur( self )
	Derma_DrawBackgroundBlur( self, PvpBattle.CreateTime )
	draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), Color(14,31,41,150) )
end

local function PanelWhiteSquare( self )
	surface.SetTexture ( 0 )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() )
end

function PvpBattle:CloseSelection()

	if self.MainPanel then self.MainPanel:Remove() end
	if self.PvpLabel then self.PvpLabel:Remove() end
	if self.WhiteBox then self.WhiteBox:Remove() end
	if self.SelectLabel then self.SelectLabel:Remove() end


	self.MainPanel = nil
	self.PvpLabel = nil
	self.WhiteBox = nil
	self.SelectLabel = nil

	GtowerMainGui:GtowerHideMenus()

end

function PvpBattle:OpenSelection()

	PvpBattle:CloseSelection()

	gui.EnableScreenClicker( true )

	self.MainPanel = vgui.Create("DPanel")
	PvpBattle.ModelPanels = {}
	PvpBattle.HighestWidth = 100
	PvpBattle.CreateTime = SysTime()

	self.MainPanel:SetSize( ScrW() * 0.45, ScrH() * 0.5 )
	self.MainPanel:SetPos( ScrW() * 0.3 - self.MainPanel:GetWide() * 0.5, ScrH() * 0.4 - self.MainPanel:GetTall() * 0.4 )
	self.MainPanel:SetVisible( true )
	self.MainPanel.Paint = PanelDrawBlur

	self.MainPanel.PanelList = vgui.Create("DPanelList", self.MainPanel )
	self.MainPanel.PanelList:SetPos( 4, 28 )
	self.MainPanel.PanelList:SetSpacing( 0 )
	self.MainPanel.PanelList:SetPadding( 0 )
	self.MainPanel.PanelList.Paint = EmptyFunction


	for k, v in pairs( self.WeaponList ) do

		local NewPanel = vgui.Create("Panel")
		local CurX = 2

		for _, UName in pairs( v ) do

			local Item = GTowerStore:Get( UName )

			local ModelPanel = vgui.Create("DModelPanel2", NewPanel)
			ModelPanel:SetModel( Item.model )
			ModelPanel:SetSize( 71, 71 )
			ModelPanel:SetMouseInputEnabled( true )
			ModelPanel:SetPos( CurX, 2 )
			ModelPanel.OnMousePressed = function()
				if DEBUG then Msg("CLICKING: " .. UName .. "\n" ) end
				RunConsoleCommand("gmt_pvpselwep", UName )
			end
			ModelPanel.CheckParentLimit = self.MainPanel.PanelList
			ModelPanel.BackgroundDraw = PanelDrawBackgroundInvalid
			ModelPanel.BackgroundColor = Color(0,0,0,0)

			if IsValid( ModelPanel.Entity ) then
				local RenderMin, RenderMax = ModelPanel.Entity:GetRenderBounds()

				ModelPanel:SetLookAt( (RenderMin+RenderMax) / 2 )
				ModelPanel:SetCamPos( RenderMax * 1.5 )
			end

			local TextLabel = Label( Item.Name, ModelPanel )
			TextLabel:SizeToContents()

			if TextLabel:GetWide() > ModelPanel:GetWide() then //Do not allow for the text to be bigger than the box, create two labels
				local FirstSpace = string.find( Item.Name, " " ) //Find first space

				if !FirstSpace then
					FirstSpace = string.find( Item.Name, "-" ) //If no space is found, find a  "-"
				end

				if FirstSpace then
					local FirstPiece = string.sub( Item.Name, 1, FirstSpace )
					local SecondPiece = string.sub( Item.Name, FirstSpace + 1 )

					TextLabel:SetText( SecondPiece )
					TextLabel:SizeToContents()

					local SecondTextLabel = Label( FirstPiece, ModelPanel ) //Create a second label to be places on top
					SecondTextLabel:SizeToContents()

					SecondTextLabel:SetPos(
						ModelPanel:GetWide() / 2 - SecondTextLabel:GetWide() / 2,
						2
					)

				else
					Msg("ERROR: Could not break down string: " .. Item.Name .. "\n") //If all fails, give an error message
				end
			end

			TextLabel:SetPos(
				ModelPanel:GetWide() / 2 - TextLabel:GetWide() / 2,
				ModelPanel:GetTall() - TextLabel:GetTall() - 5
			)

			PvpBattle.ModelPanels[ UName ] = ModelPanel

			CurX = CurX + ModelPanel:GetWide() + 2
		end

		NewPanel:SetSize( CurX, 75 )

		if CurX > PvpBattle.HighestWidth then
			PvpBattle.HighestWidth = CurX
		end

		self.MainPanel.PanelList:AddItem( NewPanel )

	end

	local BigFrameButton = vgui.Create("Panel")
	BigFrameButton:SetSize( PvpBattle.HighestWidth, 50 )
	local Closebutton = vgui.Create("PvpBtClose", BigFrameButton )
	self.MainPanel.PanelList:AddItem( BigFrameButton )


	local SelWeaponLabel = vgui.Create("DLabel")
	SelWeaponLabel:SetFont("GTowerhuge")
	SelWeaponLabel:SetText("Select Weapons")
	SelWeaponLabel:SizeToContents()
	SelWeaponLabel:SetPos( 0, self.MainPanel.y - SelWeaponLabel:GetTall() - 10 )
	SelWeaponLabel:CenterHorizontal()
	SelWeaponLabel:SetColor( Color(255,255,255,255) )
	SelWeaponLabel:SetVisible( true )
	SelWeaponLabel:SetZPos( 10 )

	local SmallWhiteBox = vgui.Create("DPanel")
	SmallWhiteBox.Paint = PanelWhiteSquare
	SmallWhiteBox:SetSize( SelWeaponLabel:GetWide() / 2, 2 )
	SmallWhiteBox:SetPos( 0, SelWeaponLabel.y - SmallWhiteBox:GetTall() - 4 )
	SmallWhiteBox:CenterHorizontal()
	SmallWhiteBox:SetZPos( 10 )

	local PvpBattleLabel = vgui.Create("DLabel")
	PvpBattleLabel:SetFont("GTowerbig")
	PvpBattleLabel:SetText("PVP Battle")
	PvpBattleLabel:SizeToContents()
	PvpBattleLabel:SetPos( 0, SmallWhiteBox.y - PvpBattleLabel:GetTall() - 4 )
	PvpBattleLabel:CenterHorizontal()
	PvpBattleLabel:SetColor( Color(255,255,255,255) )
	PvpBattleLabel:SetVisible( true )
	PvpBattleLabel:SetZPos( 10 )

	self.PvpLabel = PvpBattleLabel
	self.WhiteBox = SmallWhiteBox
	self.SelectLabel = SelWeaponLabel

	PvpBattle:UpdateItems()

end

function PvpBattle:UpdateItems()

	if !self.MainPanel then
		return
	end

	for UName, v in pairs( PvpBattle.ModelPanels ) do

		local Item = GTowerStore:Get( UName )
		local ItemId = Item.Id

		if IsValid( v ) && Item then

			if DEBUG then Msg("Setting item: " .. UName .. "(".. tostring(ItemId) ..") to " .. tostring(Item.level) .. "\n") end

			if ItemId && table.HasValue( PvpBattle.SelectedItems, ItemId ) then
				v:SetColor( Color(255, 255, 255, 255) )
				//v.BackgroundColor = Color(32, 180, 103, 255)
				v.BackgroundDraw = PanelDrawBackgroundSel
			elseif Item.prices[1] == 0 || Item.level == 1 then
				v:SetColor( Color(255, 255, 255, 255) )
				//v.BackgroundColor = Color( 65, 148, 207, 255)
				v.BackgroundDraw = PanelDrawBackground
			else
				v:SetColor( Color(255, 50, 50, 150) )
				//v.BackgroundColor = Color( 140, 65, 90, 255)
				v.BackgroundDraw = PanelDrawBackgroundInvalid
			end

		end

	end

	self.MainPanel.PanelList:PerformLayout()
	self.MainPanel.PanelList:SizeToContents()
	self.MainPanel.PanelList:SetWide( PvpBattle.HighestWidth )
	self.MainPanel.PanelList:SetPos( 5, 5 )

	self.MainPanel:SetSize(
		self.MainPanel.PanelList:GetWide() + 10,
		self.MainPanel.PanelList:GetTall() + 10
	)

	self.MainPanel:SetPos(
		ScrW() / 2 - self.MainPanel:GetWide() / 2,
		ScrH() / 2 - self.MainPanel:GetTall() / 2
	)


end

hook.Add("PlayerLevel", "GTowerStorePvpBattle", function()
	PvpBattle:UpdateItems()
end )

hook.Add("PvpBattleUpdate", "StoreCheck", function( OpenStore, discount )

	if OpenStore then

		GtowerNPCChat:StartChat({
			Entity = "gmt_npc_pvpbattle",
			Text = "Welcome to the PVPBattle store. What would you like to do?",
			Responses = {
				{
					Response = "Buy Weapons",
					Func = function() GTowerStore:OpenStore( PvpBattle.StoreId, nil, nil, discount ) end
				},
				{
					Response = "Select Weapons",
					Func = function() PvpBattle:OpenSelection() end
				},
				{
					Response = "Bye",
				}
			}
		})

	else
		PvpBattle:UpdateItems()
	end

end )

hook.Add("CanOpenMenu", "GTowerPVPBattle", function()
	if PvpBattle.MainPanel then
		return false
	end
end )

hook.Add("CanCloseMenu", "GTowerPVPBattle", function()
	if PvpBattle.MainPanel then
		return false
	end
end )
