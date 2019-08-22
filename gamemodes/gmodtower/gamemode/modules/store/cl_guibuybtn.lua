
local PANEL = {}
local SmallFont = "GTowerHUDMainSmall"
local DermaSkin = derma:GetDefaultSkin()

function PANEL:Init()
	self.ItemLevel = 0
	self.ItemMaxLevel = 0
	self.MaxItemWide = 0
	self.MaxHeight = 0

	self.ItemLevels = {}
	self.ItemWidth = {}
	//self.ItemXStart = {}
	//self.ItemWidth = {}
end

function PANEL:GetItemX( id )
	return self.MaxItemWide * (id-1)
end

function PANEL:HoveringItem( id, MouseX )
	return
end

function PANEL:Paint( w, h )

	surface.SetFont( SmallFont )

	local MouseX, MouseY = self:CursorPos()

	if self.Confirm then

		local ypos = 3
		local w = self:GetWide()

		draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), DermaSkin.bg_color_dark )

		if self.Hovered && MouseX > 0 && MouseX < w/3 then
			draw.RoundedBox( 8, 0, 0, w/3, self:GetTall(), Color( 50, 150, 50, 255 ) )
		end

		if self.Hovered && MouseX > w/3 && MouseX < w then
			draw.RoundedBox( 8, w/3, 0, w/1.5, self:GetTall(), Color( 150, 50, 50, 255 ) )
		end

		surface.SetTextPos( 0 + 5, ypos )
		surface.DrawText( "BUY" )

		surface.SetTextPos( w/3 + 5, ypos )
		surface.DrawText( "CANCEL" )

		return

	end

	for k, v in pairs( self.ItemLevels ) do

		local ItemX = self:GetItemX( k )

		if self.Hovered && MouseX > ItemX && MouseX < (ItemX + self.MaxItemWide) then //Mouse is hovering this one
			draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 150, 50, 255 ) )
		elseif !self.Hovered && k == self.ItemLevel then
			draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 150, 50, 255 ) )
		elseif k <= self.ItemMaxLevel then //Player has already bough item
			draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), Color( 15, 200, 50, 255 ) )
		else
			draw.RoundedBox( 8, 0, 0, self:GetWide(), self:GetTall(), DermaSkin.bg_color_dark )
		end

		//surface.DrawRect( ItemX, 0, self.MaxItemWide, self:GetTall() )

		local w = self.ItemWidth[ k ]
		local xtextpos = ItemX + (self.MaxItemWide / 2) - (w/2)
		local pricestr = v
		local ypos = 3

		if GTowerStore.StoreDiscount != 0 then
			local hhalf = (self.MaxHeight / 2)

			surface.SetTextPos( xtextpos, ypos )
			surface.DrawText( pricestr )

			local liney = ypos + hhalf / 2 - 0.5

			surface.SetDrawColor(215, 215, 215, 255)
			surface.DrawLine(xtextpos, liney, xtextpos + w, liney)

			local p = tonumber(v)
			pricestr = tostring(math.Round(p - (p * GTowerStore.StoreDiscount)))

			ypos = ypos + hhalf
		end

		surface.SetTextPos( xtextpos, ypos )
		surface.DrawText( string.FormatNumber( pricestr ) )
	end

	//surface.SetDrawColor( 255, 255, 255, 255 )
	//surface.DrawOutlinedRect( 0, 0, self:GetWide(), self:GetTall() )

end

function PANEL:OnMouseReleased()

	local MouseX, MouseY = self:CursorPos()
	local ItemID = self:GetParent().Id
	local w = self:GetWide()

	for k, v in pairs( self.ItemLevels ) do

		if self.Confirm then

			if MouseX > 0 && MouseX < w/3 then
				GTowerStore:PromptToBuy( ItemID, k )
				self.Confirm = false
			end

			if MouseX > w/3 && MouseX < w then
				self.Confirm = false
			end

			return

		end

		local ItemX = self:GetItemX( k )

		if MouseX > ItemX && MouseX < (ItemX + self.MaxItemWide) && k != self.ItemMaxLevel then
			//GTowerStore:PromptToBuy( ItemID, k )
			self.Confirm = true
		end
	end

end

function PANEL:GetItem()
	local Parent = self:GetParent()
	return Parent:GetItem()
end

function PANEL:GetFirstPrice()
	local Item = self:GetItem()

	if Item.prices then
		return Item.prices[1] or 0
	end

	return 0
end

function PANEL:PerformLayout()

	local Item = self:GetItem()

	if !Item then
		return
	end

	self.ItemLevels = Item.prices
	self.ItemLevel = Item.level
	self.ItemMaxLevel = Item.maxlevel


	surface.SetFont( SmallFont )

	local MaxHeight = 0
	self.MaxItemWide = 0

	for k, v in pairs( self.ItemLevels ) do
		local w,h = surface.GetTextSize( v )

		if h > MaxHeight then
			MaxHeight = h
		end

		if w > self.MaxItemWide then
			self.MaxItemWide = w
		end

		self.ItemWidth[ k ] = w
	end

	if GTowerStore.StoreDiscount != 0 then
		MaxHeight = MaxHeight * 2
	end

	self.MaxHeight = MaxHeight

	if self.MaxItemWide * #self.ItemLevels < 100 then
		self.MaxItemWide = math.floor( 100 / #self.ItemLevels )
	end

	self.MaxItemWide = self.MaxItemWide + 5

	self:SetSize( self.MaxItemWide * #self.ItemLevels + 1 , MaxHeight + 6 )

end

vgui.Register("GTowerStoreBuyButton", PANEL, "Panel")
