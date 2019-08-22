
//local ActTitleName = "ChatFont"
//local ActDescName = "Default"
local BackItem = surface.GetTextureID( "gmt_room_tv/tv_back" )

local AchivedColor = Color( 85, 167, 221 )
local UnAchivedColor = Color( 47, 93, 130 )

local PANEL = {}
PANEL.DEBUG = false

function PANEL:Init()
	
	self.Id = nil
	self.BackColor = UnAchivedColor
	
	self.TitleLabel = Label( "", self )
	self.DescriptionLabel = Label( "", self )
	
	self.TitleLabel:SetFont("ChatFont")
	
	self.ProgressValue = 0
end

function PANEL:SetId( id )
	self.Id = id
end

function PANEL:GetAchivement()
	return GtowerAchivements:Get( self.Id )
end

	
function PANEL:OnMouseReleased()

	GtowerMenu:CloseAll()
	
	/*
	local AchiTbl = GtowerAchivements.Achivements[ self.Id ]
	
	if AchiTbl == nil then return end
	if AchiTbl.hasvalues == false then return end
	
	local tabl = {
		{
			["type"] = "text",
			["Name"] = "Awards",
			["closebutton"] = true
		}
	}
	 
	for k, v in pairs( AchiTbl.values ) do
		
		table.insert( tabl, {
			["icon"] = GtowerIcons:GetIcon( AchiTbl.val >= v and 'checkmark' or 'cancel' ),
			["Name"] = "Level " .. k .. ": " .. v
		} )
	
	end

	GtowerMenu:OpenMenu( tabl )
	*/
end

function PANEL:Paint()

	local w, h = self:GetSize()
	local Progess = math.floor( w * self.ProgressValue )
	
	if Progess != w then
		surface.SetDrawColor( UnAchivedColor.r, UnAchivedColor.g, UnAchivedColor.b, 255 )
		surface.DrawRect( Progess, 0, w - Progess, h )	
	end

	if Progess != 0 then
		surface.SetDrawColor( AchivedColor.r, AchivedColor.g, AchivedColor.b, 255 )
		surface.DrawRect( 0, 0, Progess, h )	
	end
	


end

function PANEL:PerformLayout()
	
	if !self.Id then return end
	
	local Achivement = self:GetAchivement()
	
	if !Achivement then return end
	
	self.TitleLabel:SetText( Achivement.Name )
	self.DescriptionLabel:SetText( Achivement.Description )
	
	self.TitleLabel:SizeToContents()
	self.DescriptionLabel:SizeToContents()
	
	local MaxValue = Achivement.Value
	local Value = GtowerAchivements:GetValue( self.Id )
	
	if Achivement.GetMaxValue then
		MaxValue = Achivement.GetMaxValue()
	end
	
	//If it is not a boolean value
	local DrawProcessBar = MaxValue != 1
	
	self.TitleLabel:SetPos( 2, 2 )
	self.DescriptionLabel:SetPos( 6, 2 + self.TitleLabel:GetTall() + 2 )	
	self:SetTall( self.DescriptionLabel.y + self.DescriptionLabel:GetTall() + 2 )
	
	if DrawProcessBar then
		if !self.ProcessText then
			self.ProcessText = Label( "", self )
			self.ProcessText:SetFont( "small" )
		end
		
		self.ProgressValue = math.Clamp( Value / MaxValue, 0, 1 )
		
		self.ProcessText:SetText( Value .. "/" .. MaxValue )
		self.ProcessText:SizeToContents()
		
		self.ProcessText:SetPos( self:GetWide() - self.ProcessText:GetWide() - 3, self:GetTall() - self.ProcessText:GetTall() - 3 )
	else
		if Value == true then
			self.ProgressValue = 1
		else
			self.ProgressValue = 0
		end
	end
	
	if self.DEBUG then Msg(  Achivement.Name .. " - process value: " .. self.ProgressValue .. " ("..tostring(Value).."/"..MaxValue..")\n" ) end
	
end

vgui.Register("GtowerAchivItem", PANEL )