
local PANEL = {}



function PANEL:Init()

	self.Text = richformat.New(self:GetWide(), self:GetTall(), 50)



	self.LastClick = 0



	self.ScrollBar = vgui.Create( "SlideBar2", self )

	self.ScrollBar:SetZPos( 0 )



	self:SetFade(false)

end



function PANEL:OnMouseWheeled( dlta )

	self.ScrollBar:AddVelocity( dlta )

end



function PANEL:SetFade(val)

	self.Fade = val



	self.ScrollBar:SetVisible(!val)



	if val then

		self.Text:ClearSelection()

	end

end



function PANEL:GetFilter()

	return self.Text:GetFilter()

end



function PANEL:SetFilter(x)

	self.Text:SetFilter(x)

end



function PANEL:Copy()

	SetClipboardText(self.Text:GetSelectedText())

	self.Text:ClearSelection()



	self:GetParent():GetInputPanel():RequestFocus()

end



function PANEL:OnKeyCodePressed(kc)

	if kc == KEY_C && input.IsKeyDown(KEY_LCONTROL) then

		self:Copy()

	end

end



function PANEL:OnMousePressed(mc)

	self:MouseCapture(true)

	self:RequestFocus()



	if mc == MOUSE_LEFT then

		local x, y = self:CursorPos()

		local pos = {x=x, y=y}



		if SysTime() < self.LastClick + 0.3 then

			self.Text:ClearSelection()

			self.Text:DoClick(pos)

		else

			self.Text:SetSelectionStart(pos)

		end



		self.LastClick = SysTime()

	elseif mc == MOUSE_RIGHT then

		self:Copy()

	end

end



function PANEL:OnMouseReleased(mc)

	self:MouseCapture(false)



	local s, e = self.Text:GetSelection()

	if s == 0 || e == 0 then

		self:GetParent():GetInputPanel():RequestFocus()

	end

end

function PANEL:OnCursorMoved()

	local x, y = self:CursorPos()

	local pos = {x=x,y=y}



	self:SetCursor(self.Text:GetCursor(pos))



	if input.IsMouseDown(MOUSE_LEFT) && SysTime() > self.LastClick then

		self.Text:SetSelectionEnd(pos)

	end

end



function PANEL:Think()

	if self.ScrollBar:Changed() then

		self.Text:SetScroll(self.ScrollBar:Value() * (self.Text:GetTotalHeight() - self:GetTall()) )

	end

end



function PANEL:PerformLayout()

	local w,h = self:GetSize()



	self.ScrollBar:SetPos( w - 12, 0 )

	self.ScrollBar:SetSize( 12, h )



	self.Text:SetPos(0,0)

	self.Text:SetSize(w,h)



	local height = self.Text:GetTotalHeight()



	if self.ScrollBar:Value() == 0 then

		self.ScrollBar:SetScroll(1)

	end



	if height > h then

		self.Text:SetSize(w - 18,h)

		height = self.Text:GetTotalHeight()

	end





	self.ScrollBar:SetBarScale( (height / h) )



	local page = self.Text:GetTotalHeight() - self:GetTall()



	if self.Fade then

		self.ScrollBar:SetScroll(1)

		self.Text:SetScroll(page)

	else

		self.Text:SetScroll(self.ScrollBar:Value() * page)

	end

end



function PANEL:Paint( w, h )

	self.Text:Draw(self.Fade)

end



vgui.Register( "DRichText", PANEL, "DPanel" )