
local PANEL = {}
local PanelHeight = 64
local DermaSkin = derma:GetDefaultSkin()
local EmptyMarkup = markup.Parse("")
local DEBUG = false

local CompactMode = CreateClientConVar( "gmt_compactstores", "0", true, false )

surface.CreateFont( "GTowerShopTitle", {
	font = "Oswald", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 25,
	weight = 450,
	shadow = false,
	outline = false,
} )
surface.CreateFont( "GTowerShopPrice", {
	font = "Oswald", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 18,
	weight = 400,
	shadow = false,
	outline = false,
} )

local TitleFont = "GTowerShopTitle"
local SmallFont = "Default"

local function OnModelCreated( self )

	local RenderMin, RenderMax = self.Entity:GetRenderBounds()
	local WeaponSize = RenderMin:Length() + RenderMax:Length()

	self:SetLookAt( (RenderMin+RenderMax) / 2 )
	self:SetCamPos( RenderMax * 2 )

end

function PANEL:Init()

	self.Id = 0
	DermaSkin = derma:GetDefaultSkin()

	self.TitleText = ""
	//self.DescriptionText = ""
	self.DescriptionMarkup = EmptyMarkup
	self.CurLevel = 1
	self.Price = 0

	self.PriceY = 0
	self.PriceX = 0

	self.TitleY = 0
	self.DescriptionY = 0

	self.LastLevel = 0

	self.BuyButton = vgui.Create("GTowerStoreBuyButton", self )
	self.TextStartX = 10

end

function PANEL:EnableModelPanel()

	self.ModelPanel = vgui.Create("DModelPanel2", self )
	self.ModelPanel.CheckParentLimit = GTowerStore.StoreGUI.PanelList
	self.ModelPanel.OnModelCreated = OnModelCreated

	self.TextStartX = 66

	self:InvalidateLayout()

end

function PANEL:SetId( id )
	self.Id = id
end

function PANEL:GetItem()
	return GTowerStore.Items[ self.Id ]
end

function PANEL:GetFirstPrice()
	return self.BuyButton:GetFirstPrice()
end

function PANEL:Paint()

	if self.Hovered then
		SetDrawColor( DermaSkin.control_color_active )
	else
		SetDrawColor( DermaSkin.bg_color )
	end

	//SetDrawColor( DermaSkin.bg_color )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )

	surface.SetTextColor( 255, 255, 255, 255 )

	surface.SetFont( TitleFont )
	surface.SetTextPos( self.TextStartX, self.TitleY )
	surface.DrawText( self.TitleText )

	--New items
	if self:GetItem().IsNew then
		surface.SetMaterial(Material("gmod_tower/icons/new.png"))
		surface.SetDrawColor(255,255,255)
		local IconPos = self.TextStartX + surface.GetTextSize(self.TitleText) + 5
		surface.DrawTexturedRect(IconPos, self.TitleY,25,25)
	end

	self.DescriptionMarkup:Draw( self.TextStartX, self.DescriptionY )

end

function PANEL:OnCursorEntered()
	GTowerStore.ModelStoreMouseEntered( self )
end

function PANEL:PerformLayout()

	if self.Id == 0 then
		//Nothing to see here
		self:SetSize( 0, 0 )
		return
	end

	local Parent = self:GetParent()
	local Wide = Parent:GetWide() - 5
	local Tall = 10


	self.BuyButton:InvalidateLayout(true)

	local Item = self:GetItem()

	if Item then

		//Make sure the model exist and that the model panel is valid
		//To add the model icon
		if Item.model && self.ModelPanel then

			self.ModelPanel:SetModel( Item.model, Item.ModelSkin )
			self.ModelPanel:SetSize( 62, 62 )

			if DEBUG then
				Msg("Created panel with: " .. tostring(Item.Name) .. "\n")
			end

		elseif DEBUG then
			Msg("Could not find model: " .. tostring(Item.model) .. " (".. tostring(Item.Name) ..")\n")
		end

		if self.LastLevel != 0 && self.LastLevel != Item.level then
			//Make cool effect
		end

		self.LastLevel = Item.Level
		self.TitleText = Item.Name //.. " (" .. Item.level .. "/" .. #Item.prices .. ")"
		self.DescriptionText = Item.description

		surface.SetFont( TitleFont )
		local w,h = surface.GetTextSize( self.TitleText )
		self.TitleY = 4

		self.DescriptionMarkup = markup.Parse( Item.description, Wide - self.TextStartX - self.BuyButton:GetWide() - 5 )
		self.DescriptionY = self.TitleY + h + 4

		Tall = Tall + h + self.DescriptionMarkup:GetHeight()

	end

	if CompactMode:GetBool() then
		self:SetSize( Wide , math.max( Tall, PanelHeight ) /2 )
	else
		self:SetSize( Wide , math.max( Tall, PanelHeight ) )
	end

	self.BuyButton:SetPos(
		self:GetWide() - self.BuyButton:GetWide() - 5,
		self:GetTall() - self.BuyButton:GetTall() - 5
	)

	if self.ModelPanel then
		self.ModelPanel:SetPos( 2, self:GetTall() / 2 - self.ModelPanel:GetTall() / 2 )
	end

end

vgui.Register("GTowerStoreItem", PANEL, "Panel")
