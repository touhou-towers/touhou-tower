

-----------------------------------------------------
local string = string
local table = table
local surface = surface
local ipairs = ipairs
local setmetatable = setmetatable
local math = math
local Color = Color
local SysTime = SysTime
local tostring = tostring
local print = print
local PrintTable = PrintTable
local pcall = pcall
local bit = bit

module("richformat", package.seeall)

surface.CreateFont( "ChatVerdana18", { font = "Verdana", size = 18, weight = 700 } )
surface.CreateFont( "ChatVerdana16", { font = "Verdana", size = 16, weight = 700 } )
surface.CreateFont( "ChatUrlVerdana16", { font = "Verdana", size = 16, weight = 700, underline = true } )

local OutlineText = CreateClientConVar( "gmt_chat_outline", 0, true, false )
local OutlineTextAmt = CreateClientConVar( "gmt_chat_outlineamt", 1, true, false )
local CharWidth = {}
local RichObject = {}

local ColorUrl = Color(27,142,224)

local STYLE_NONE = 1
local STYLE_MATERIAL = 2

function RichObject:Create(w,h,lc)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	o.buffer = ""
	o.styles = {}
	o.parsedstyles = {}
	o.lines = nil

	o.width, o.height = w, h
	o.totalheight = 0
	o.maxlines = lc

	o.numlines = 0

	o.X, o.Y = 0, 0
	o.scroll = 0

	o.cfilter = 0

	o.drawbounds = {0, 0}

	o.selection = {}

	return o
end

function RichObject:BuildWidthCache(font)
	if !CharWidth[font] then
		CharWidth[font] = {}
		surface.SetFont(font)
		for i=1,127 do
			local c = string.char(i)
			CharWidth[font][c] = surface.GetTextSize(c)
		end
		CharWidth[font]["&"] = CharWidth[font]["^"] // & is 0 width
	end
end

function RichObject:CalcTextSizeEx(buffer)
	local buff = string.gsub(buffer, "&", "^")
	return surface.GetTextSize(buff)
end

function RichObject:CalcCharWidthExtended(font, str, pos, maxpos)
		local c = string.sub(str, pos, pos)

		if CharWidth[font] and CharWidth[font][c] then
			return CharWidth[font][c], c, pos
		end

		local byte = string.byte(c)
		if byte < 194 || byte > 244 || pos == maxpos then
			return 0, c, pos
		end

		pos = pos + 1
		local c2 = string.sub(str, pos, pos)
		byte = string.byte(c2)

		while byte >= 128 && byte <= 191 do
			c = c .. c2
			pos = pos + 1
			if pos > maxpos then break end

			c2 = string.sub(str, pos, pos)
			byte = string.byte(c2)
		end

		if CharWidth[font][c] then
			return CharWidth[font][c], c, pos-1
		end

		surface.SetFont(font)
		CharWidth[font][c] = surface.GetTextSize(c)
		return CharWidth[font][c], c, pos-1
end

function RichObject:BuildStyle(pos, length, color, font, time, onclick, onclickref, filter, newline)
	local style = {}

	style.pos = pos 
	style.length = length

	style.color = color or Color(255, 255, 255)
	style.font = font or "ChatVerdana16"
	style.time = time or SysTime()
	style.newline = newline

	style.onclick = onclick
	style.onclickref = onclickref

	style.filter = filter or 0
	surface.SetFont(style.font)

	local buffer = string.sub(self.buffer, pos, pos + length - 1)
	buffer = string.Replace(buffer, "\n", "")

	style.xwidth, style.yheight = self:CalcTextSizeEx(buffer)

	return style
end

function RichObject:Add(text, color, font, time, onclick, onclickref, filter, newline)
	if !text then return end
	if !color then color = Color(255, 255, 255) end
	if !font then font = "ChatVerdana18" end
	if !time then time = SysTime() end
	if !filter then filter = 0 end

	self:BuildWidthCache(font)

	local p = 1 -- position in text

	if !newline then
		-- Iterate through each character in text
		for i = 1, #text do
			-- Split text into multiple lines if we find a newline character
			if string.sub(text, i, i) == "\n" then
				self:Add(string.sub(text, p, i), color, font, time, onclick, onclickref, filter, true)
				p = i + 1 -- set position past newline position
			end
		end
	else
		self.numlines = self.numlines + 1
	end

	-- Max number of lines reached, remove top line before continuing
	if self.numlines > self.maxlines then

		local blk
		repeat
			blk = table.remove(self.styles, 1)
		until blk.newline == true

		local pos = blk.pos + blk.length - 1
		self.buffer = string.sub(self.buffer, pos + 1)

		for k, v in ipairs(self.styles) do
			v.pos = v.pos - pos
		end
	
		local s, e = self:GetSelection()
		if s > 0 && e > 0 then
			self.selection[1], self.selection[2] = s-pos, e-pos
		end

		self.numlines = self.numlines - 1
	end

	-- Get current text segment; this is the same if we didn't find a newline char
	text = string.sub(text, p)

	-- Ignore empty text; possibly caused by newline
	if #text == 0 then return end

	local pos = #self.buffer + 1 		-- new position in char buffer
	self.buffer = self.buffer .. text 	-- append new text

	-- Build new style from added text
	local style = self:BuildStyle(pos, #text, color, font, time, onclick, onclickref, filter, newline)

	-- Store style for text segment
	table.insert(self.styles, style)

	-- Parse added text, handle word wrapping, etc.
	self:Parse()
end

function RichObject:AddURL(url, color, font, time, filter, newline)
	color = color or ColorUrl
	font = font or "ChatUrlVerdana16"

	self:Add( url, color, font, time, function()
		browser.OpenURL(url, url)
	end, nil, filter, newline)

end

function RichObject:AddMaterial(material, w, h, text)
	if not material then return end
	w = w or 16
	h = h or 16
	text = text or " "

	-- Max number of lines reached, remove top line before continuing
	if self.numlines > self.maxlines then

		local blk
		repeat
			blk = table.remove(self.styles, 1)
		until blk.newline == true

		local pos = blk.pos + blk.length - 1
		self.buffer = string.sub(self.buffer, pos + 1)

		for k, v in ipairs(self.styles) do
			v.pos = v.pos - pos
		end
	
		local s, e = self:GetSelection()
		if s > 0 && e > 0 then
			self.selection[1], self.selection[2] = s-pos, e-pos
		end

		self.numlines = self.numlines - 1
	end

	local pos = #self.buffer + 1 		-- new position in char buffer
	self.buffer = self.buffer .. text 	-- append new text

	-- Build new style from added text
	-- local filter = bit.bor(GTowerChat.ChatFilters.Server,GTowerChat.ChatFilters.Emotes)
	local filter = bit.bor(1,16)
	local style = self:BuildStyle(pos, #text, nil, nil, nil, nil, nil, filter, false)
	style.type = STYLE_MATERIAL
	style.material = material
	style.xwidth = w
	style.yheight = h

	-- Store style for text segment
	table.insert(self.styles, style)

	-- Parse added text, handle word wrapping, etc.
	self:Parse()
end

function RichObject:AddPanel(panel, w, h, newline)
	-- TODO: implement the ability to add panels
end

function RichObject:NewLine(ypos)
	local nl = {firststyle=nil, ypos=ypos, xwidth=0, yheight=0}
	table.insert(self.lines, nl)

	return nl
end

function RichObject:SetLineStyle(line, style_index)
	line.firststyle = style_index
end

function RichObject:AssociateStyleWithLine(style, line)

	style.line = line
	style.xpos = line.xwidth

	table.insert(self.parsedstyles, style)
	local index = #self.parsedstyles

	//print(style, line, index, #self.parsedstyles)

	if !line.firststyle then
		self:SetLineStyle(line, index)
	end

	line.yheight = math.max(line.yheight, style.yheight)
	line.xwidth = line.xwidth + style.xwidth

	if style.newline then
		return self:NewLine(line.ypos + line.yheight)
	end

	return line
end

function RichObject:Parse()

	self.parsedstyles = {}
	self.lines = {}

	local currentline = self:NewLine(0)

	for k, v in ipairs(self.styles) do

		if !( bit.band(v.filter , self.cfilter ) > 0 ) then

		if currentline.xwidth + v.xwidth <= self.width then

			if currentline.xwidth + v.xwidth == self.width then
				v = table.Copy(v)
				v.newline = true
			end

			currentline = self:AssociateStyleWithLine(v, currentline)

		elseif v.type == STYLE_MATERIAL then

			currentline = self:NewLine(currentline.ypos + currentline.yheight)
			currentline = self:AssociateStyleWithLine(v, currentline)

		else

			local cw = currentline.xwidth
			local pos = v.pos

			local i, lte = 0, v.length - 1
			while i <= lte do
				local cpos = v.pos + i
				local c, ch, cpos = self:CalcCharWidthExtended(v.font, self.buffer, cpos, v.pos + lte)
				i = cpos - v.pos

				local chc = cw + c

				local wordwrap = false

				if ch == " " then
					local wpos = string.find(self.buffer, " ", cpos + 1)
					if !wpos then
						wpos = v.pos + lte
					end

					local width = self:GetPixelOffsetPos(v, wpos, true, i)

					if cw + width > self.width then
						cpos = cpos + 1
						wordwrap = true
					end
				end

				if chc <= self.width && !wordwrap then
					cw = chc
				else
					local style = self:BuildStyle(pos, cpos - pos, v.color, v.font, v.time, v.onclick, v.onclickref, v.filter, true)

					currentline = self:AssociateStyleWithLine(style, currentline)

					pos = cpos
					cw = c
				end

				i = i + 1
			end

			if pos < v.pos + v.length then
				local style = self:BuildStyle(pos, (v.pos + v.length) - pos, v.color, v.font, v.time, v.onclick, v.onclickref, v.filter, v.newline)

				currentline = self:AssociateStyleWithLine(style, currentline)
			end

		end

		end
	end

	if !currentline.firststyle then
		local l = table.remove(self.lines, table.maxn(self.lines))
		self.totalheight = l.ypos
	else
		self.totalheight = currentline.ypos + currentline.yheight
	end

	self:CalcDraw()
end

function RichObject:CalcDraw()
	self.drawbounds[1], self.drawbounds[2] = 0, 0

	if !self.lines || #self.lines == 0 then return end

	for k,l in pairs(self.lines) do

		if !l.firststyle then continue end

		if self.drawbounds[1] == 0 && l.ypos + l.yheight > self.scroll then
			self.drawbounds[1] = l.firststyle
		elseif l.ypos > (self.height + self.scroll) then
			self.drawbounds[2] = l.firststyle - 1
			break
		end
	end

	if self.drawbounds[2] <= 0 then
		self.drawbounds[2] = #self.parsedstyles
	end
end

function RichObject:SetFilter(x)
	self.cfilter = x
	self:Parse()
end

function RichObject:GetFilter()
	return self.cfilter
end

function RichObject:SetSize(w, h)
	if w == self.width && h == self.height then return end
	self.width, self.height = w, h
	self:Parse()
end

function RichObject:SetPos(x, y)
	self.X, self.Y = x,y
end

function RichObject:SetScroll(scroll)
	if scroll < 0 then scroll = 0 end
	self.scroll = scroll

	self:CalcDraw()
end

function RichObject:GetTotalHeight()
	return self.totalheight
end

function RichObject:GetPixelOffsetPos(block, pos, endof, start)
	local w = 0
	if !start then start = 0 end

	local i, lte = start, block.length - 1
	while i <= lte do
		local p = block.pos + i

		if !endof && p == pos then break end

		local c, ch, n = self:CalcCharWidthExtended(block.font, self.buffer, p, block.pos + lte)
		i = n - block.pos

		w = w + c

		if endof && p == pos then break end
		i = i + 1
	end
	return w
end

function RichObject:DrawSelection(block)
	local s, e = self:GetSelection()
	if s > block.pos + block.length - 1 || e < block.pos then
		return
	end

	local start = 0
	local endpx = block.xwidth

	if s >= block.pos && s <= block.pos + block.length - 1 then
		start = self:GetPixelOffsetPos(block, s)
	end
	if e >= block.pos && e <= block.pos + block.length - 1 then
		endpx = self:GetPixelOffsetPos(block, e, true)
	end

	surface.SetDrawColor( Color( 255, 255, 255, 84 ) )
	surface.DrawRect( self.X + block.xpos + start, self.Y + block.line.ypos - self.scroll, endpx - start, block.yheight )
end

function RichObject:Draw(fade)
	local stay = 20
	local curtime = SysTime()

	if self.drawbounds[1] == 0 || self.drawbounds[2] == 0 then return end
 
	for i=self.drawbounds[1] or 1, self.drawbounds[2] do
		local block = self.parsedstyles[i]

		if !block then
			//PrintTable(self.drawbounds)
			//PrintTable(self.parsedstyles)
			Error("tried to draw")
			return
		end

		local buffer = string.sub(self.buffer, block.pos, block.pos + block.length - 1)

		local s, e = self:GetSelection()

		local a = block.color.a

		if fade && curtime > block.time + stay then
			local delta = (curtime - (block.time + stay))
			if delta <= 1 then
				a = 255 * (1 - delta)
			else
				a = 0
			end
		end

		if a > 0 then

			local x, y = self.X + block.xpos, self.Y + block.line.ypos - self.scroll

			if block.type == STYLE_MATERIAL then

				surface.SetDrawColor( block.color.r, block.color.g, block.color.b, a )
				surface.SetMaterial( block.material )
				surface.DrawTexturedRect( x, y, block.xwidth, block.yheight ) 

			else

				if OutlineText:GetBool() then
					local boldness = math.Fit( OutlineTextAmt:GetInt() or 50, 0, 100, 255, 50 )
					draw.SimpleTextOutlined( buffer, block.font, x, y, Color( block.color.r, block.color.g, block.color.b, a ), nil, nil, 1, Color( 0, 0, 0, math.Clamp( a - boldness, 0, 255 ) ) )
				else
					surface.SetFont(block.font)
					surface.SetTextColor( 0, 0, 0, math.Clamp( a - 150, 0, 255 ) )
					surface.SetTextPos( x + 1, y + 1 )
					surface.DrawText( buffer )

					surface.SetTextColor( block.color.r, block.color.g, block.color.b, a )
					surface.SetTextPos( x, y )
					surface.DrawText( buffer )
				end

			end

		end

		if s > 0 && e > 0 then
			self:DrawSelection(block)
		end

	end
end

function RichObject:GetStyleForPosition(pos, exact)
	local bestblock = 0

	if self.drawbounds[1] == 0 || self.drawbounds[2] == 0 then return nil, 0 end

	if pos.y < self.Y then pos.y = self.Y end
	if pos.x < self.X then pos.x = self.X end

	for i=self.drawbounds[1] or 1, self.drawbounds[2] do
		local block = self.parsedstyles[i]

		local bypos = self.Y + block.line.ypos - self.scroll
		local bxpos = self.X + block.xpos

		if pos.y >= bypos && pos.x >= bxpos && (!exact || pos.y <= bypos + block.yheight) then
			bestblock = i
		end
	end

	if bestblock == 0 then return nil, 0 end

	local bblock = self.parsedstyles[bestblock]
	local cw = self.X + bblock.xpos

	local i, lte = 0, bblock.length-1
	while i <= lte do
		local p = bblock.pos + i

		local c, ch, n = self:CalcCharWidthExtended(bblock.font, self.buffer, p, bblock.pos + lte)
		i = n - bblock.pos

		if pos.x >= cw && pos.x <= cw + c then
			return bblock, p
		end

		cw = cw + c
		i = i + 1
	end

	return bblock, bblock.pos + bblock.length - 1
end

function RichObject:DoClick(pos)
	local block, pos = self:GetStyleForPosition(pos, true)

	if block && block.onclick then
		pcall(block.onclick, string.sub(self.buffer, block.pos, block.pos + block.length - 1), block.onclickref)
	end
end

function RichObject:GetCursor(pos)
	local block, pos = self:GetStyleForPosition(pos, true)

	if block && block.onclick then
		return "hand"
	end
	return "beam"
end

function RichObject:ClearSelection()
	self.selection[1], self.selection[2] = 0, 0
end

function RichObject:SetSelectionStart(pos)
	local block, pos = self:GetStyleForPosition(pos)
	self.selection[1] = pos
	self.selection[2] = 0
end

function RichObject:SetSelectionEnd(pos)
	local block, pos = self:GetStyleForPosition(pos)
	self.selection[2] = pos
end

function RichObject:GetSelection()
	if !self.selection[1] || !self.selection[2] then return 0,0 end

	if self.selection[1] > self.selection[2] then
		return self.selection[2], self.selection[1]
	end
	return self.selection[1], self.selection[2]
end

function RichObject:GetSelectedText()
	local s, e = self:GetSelection()
	if s == 0 || e == 0 then return "" end

	local buffer = ""

	for i=self.drawbounds[1] or 1, self.drawbounds[2] do
		local block = self.parsedstyles[i]
		
		if s <= block.pos + block.length - 1 && e >= block.pos then
			local start = block.pos
			local endpos = start + block.length - 1

			if s >= block.pos && s <= block.pos + block.length - 1 then
				start = s
			end

			if e >= block.pos && e <= block.pos + block.length - 1 then
				local c, ch, p = self:CalcCharWidthExtended(block.font, self.buffer, e, block.pos + block.length - 1)
				endpos = p
			end

			buffer = buffer .. string.sub(self.buffer, start, endpos)
		end
	end

	return buffer
end

function New(w,h, lc)
	return RichObject:Create(w,h,lc)
end