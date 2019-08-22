

-----------------------------------------------------
local PANEL = {}
PANEL.Cols = 6
PANEL.Padding = 2
PANEL.IconSize = 16
PANEL.IconSpacing = 2

local EmotesFolder = "materials/icon16/"
local Emotes = {
	"emoticon_happy",
	"emoticon_evilgrin",
	"emoticon_wink",
	"emoticon_grin",
	"emoticon_smile",
	"emoticon_surprised",
	"emoticon_tongue",
	"emoticon_unhappy",
	"emoticon_waii",
	"stop",
	"star",
	"heart",
	"monkey",
	"wrench",
	"eye",
	"music",
	"car",
	"bug",
}

function PANEL:Init()

	self.Emotes = {}

	for _, icon in ipairs( Emotes ) do
		self:AddEmote( icon )
	end

	self:InvalidateLayout()

end

function PANEL:SetOwner( panel )
	self.Panel = panel
end

function PANEL:AddEmote( icon )

	local emote = vgui.Create( "DImageButton", self )
	emote:SetSize( self.IconSize, self.IconSize )
	emote:SetImage( EmotesFolder .. icon .. ".png" )
	emote.Think = function( self )
		if self:IsMouseOver( self ) then
			self:SetAlpha( 50 )
			--self.CurrentIcon = icon
		else
			self:SetAlpha( 255 )
		end
	end
	emote.DoClick = function()

		// Add to input panel
		local OldText = self.Panel.inputpanel:GetText()
		local NewText = OldText .. ":" .. icon .. ":"
		self.Panel.inputpanel:SetText(NewText)
		self.Panel.inputpanel:SetCaretPos(string.len(NewText))

		// Close
		self:Remove()
		self.Panel.EmoteGUI = nil
	end

	table.insert( self.Emotes, emote )

end

function PANEL:PerformLayout()

	local row, col = 0, 0
	local size = self.IconSize + self.IconSpacing

	for _, panel in pairs( self.Emotes ) do

		panel:SetPos( self.Padding + ( col * size ), self.Padding + ( row * size ) )

		col = col + 1
		if col >= self.Cols then
			col = 0
			row = row + 1
		end

	end

	self.IconsHeight = self.Padding + ( row * size )
	self:SetSize( self.Padding + ( self.Cols * size ), self.IconsHeight ) --+ ( 16 + self.Padding ) )

end
function PANEL:IsMouseOver()



	local x,y = self:CursorPos()

	return x >= 0 && y >= 0 && x <= self:GetWide() && y <= self:GetTall()



end

function PANEL:Paint( w, h )
	local color = colorutil.Brighten( GTowerChat.BGColor, .75 )
	draw.RoundedBox( 6, 0, 0, w, h, Color( color.r, color.g, color.b, 255 ) )

	--[[if self.CurrentIcon and self.IconsHeight then
		draw.SimpleText( ":" .. self.CurrentIcon .. ":", "small", self.Padding, self.IconsHeight + ( self.Padding / 2 ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end]]--
end

derma.DefineControl( "GTowerChatEmotes", "", PANEL, "DPanel" )
