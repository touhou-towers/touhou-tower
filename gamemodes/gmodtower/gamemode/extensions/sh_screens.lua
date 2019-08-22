

-----------------------------------------------------
G_3DSCREENS = G_3DSCREENS or {}
--G_3DSCREENS = {}

module( "screen", package.seeall )
UniqueID = UniqueID or 1

local SCR = {}
SCR.__index = SCR

local function checkColor(color)
	if type(color) ~= "table" or
		type(color.r) ~= "number" or
		type(color.g) ~= "number" or
		type(color.b) ~= "number" then
		return false
	end
	if type(color.a) ~= "number" then color.a = 255 end
	return true
end

local function Render3DScreens(translucent)
	if translucent then
		table.sort(G_3DSCREENS, function(a,b) return a:GetViewerDistance() > b:GetViewerDistance() end)
	end

	for k,v in pairs(G_3DSCREENS) do
		if v.autodraw then
			if v.translucent ~= translucent then
				v:Draw()
			end
		end
	end
end

local function Think3DScreens()
	for k,v in pairs(G_3DSCREENS) do
		v:Think()
	end
end

local function LocalScreenHasFocus()
	for k,v in pairs(G_3DSCREENS) do
		if v:HasFocus() then return true, v end
	end
	return false
end

function New(...) return setmetatable({}, SCR):Init(...) end
function SCR:Init(func, pos, ang, w, h, scrw, scrh)
	self.w = 100
	self.h = 100
	self.scrw = 100
	self.scrh = 100
	self.scrx = 0
	self.scry = 0
	self.maxusedist = 300
	self.pos = Vector(0,0,0)
	self.mtx1 = Matrix()
	self.dirty0 = true
	self.dirty1 = true
	self.cull = false
	self.legacy = false
	self.bgwidth = 0
	self.bgcolor = Color(0,0,0)
	self.startfade = 0
	self.endfade = 0
	self.facade_material = nil
	self.facade_color = Color(0,0,0)
	self.translucent = false
	self.enableInput = false
	self.mouseLatch = {}

	if type(func) == "function" then self:SetDrawFunc(func) end
	if isvector(pos) then self:SetPos(pos) end
	if isangle(ang) then self:SetAngles(ang) else self:SetAngles(Angle(0,0,0)) end
	if type(w) == "number" and type(h) == "number" then
		self.w = w
		self.h = h
		self.scrw = w
		self.scrh = h
	end
	if type(scrw) == "number" and type(scrh) == "number" then
		self.scrw = scrw
		self.scrh = scrh
	end
	self.index = UniqueID
	UniqueID = UniqueID + 1

	return self
end

----------------------------------------
--Material *MUST* have $ignorez set to 1
----------------------------------------
function SCR:SetFacadeMaterial(mat)
	self.facade_material = mat
	return self
end

function SCR:SetFacadeColor(color)
	if not checkColor(color) then return self end
	self.facade_color = color
	return self
end

function SCR:SetFade(startFade, endFade)
	if startFade > endFade then return self end
	self.startfade = tonumber(startFade)
	self.endfade = tonumber(endFade)
	return self
end

function SCR:SetBorder(width, color)
	self.bgwidth = width
	if checkColor(color) then self.bgcolor = color end
	return self
end

--WARNING: Legacy mode only supports square resolutions
function SCR:SetLegacyMode(legacy)
	self.legacy = legacy
	return self
end

function SCR:SetSize(w,h)
	self.w = tonumber(w)
	self.h = tonumber(h)
	self.dirty0 = true
	return self
end

function SCR:SetOffset(scrx,scry)
	self.scrx = tonumber(scrx)
	self.scry = tonumber(scry)
	self.dirty0 = true
	return self
end

function SCR:SetRes(scrw,scrh,vw,vh)
	self.scrw = tonumber(scrw)
	self.scrh = tonumber(scrh)
	if vw then self.vw = tonumber(vw) end
	if vh then self.vh = tonumber(vh) end
	self.dirty0 = true
	return self
end

function SCR:GetRes()
	return self.scrw, self.scrh
end

function SCR:SetPos(pos)
	if isvector(pos) then
		self.pos = pos
		self.dirty1 = true
	end
	return self
end
function SCR:GetPos()
	return self.pos
end

function SCR:SetParent( ent )

	if IsValid( ent ) then

		self.parentedTo = {
			Entity = ent,
			Pos = ent:WorldToLocal( self:GetPos() ),
			Ang = ent:WorldToLocalAngles( self:GetAngles() ),
		}

	else

		self.parentedTo = nil

	end
	return self

end

function SCR:GetViewerDistance(ply)
	if CLIENT then ply = ply or LocalPlayer() end
	return (self.pos - LocalPlayer():EyePos()):LengthSqr()
end

function SCR:SetMaxDist(dist)
	self.maxusedist = tonumber(dist)
	return self
end

function SCR:CanUse(ply)
	if CLIENT then ply = ply or LocalPlayer() end

	local eyepos = ply:EyePos()

	if self.cull and (eyepos - self.pos):Dot(self.forward) < 0 then return false end
	if self.maxusedist ~= 0 then
		--check along each axis
		if math.abs(self.forward:Dot(eyepos) - self.forward:Dot(self.pos)) > self.maxusedist then return false end
		if math.abs(self.right:Dot(eyepos) - self.right:Dot(self.pos)) > self.maxusedist + self.w/2 then return false end
		if math.abs(self.up:Dot(eyepos) - self.up:Dot(self.pos)) > self.maxusedist + self.h/2 then return false end
	end
	return true
end

local __identAngle = Angle(0,0,0)
function SCR:GetMouse(ply)
	if CLIENT then ply = ply or LocalPlayer() end
	if not self:CanUse(ply) then return 0,0,false end

	self:CalcMatrix()

	local pos = ply:EyePos() --ply:GetShootPos()
	local aim = ply:EyeAngles():Forward() --ply:GetAimVector()

	if CLIENT and not self.viewmouse then
		aim = GetMouseAimVector()
	end

	local a = (self.pos - pos):Dot(self.forward)
	local b = aim:Dot(self.forward)
	local v = pos + aim * ( a / b )

	v = WorldToLocal(v, __identAngle, self.pos, self.angle)

	local x = v.y / self.mtx0:GetField(2,1) - self.mtx0:GetField(2,4) / self.mtx0:GetField(2,1)
	local y = v.z / self.mtx0:GetField(3,2) - self.mtx0:GetField(3,4) / self.mtx0:GetField(3,2)

	return x,y,
	(x>0 and x<(self.vw or self.scrw)) and
	(y>0 and y<(self.vh or self.scrh))
end

function SCR:SetViewMouseOnly(b_viewmouse)
	self.viewmouse = b_viewmouse
	return self
end

function SCR:SetAngles(ang)
	if isangle(ang) then
		self.angle = ang
		self.right = ang:Right()
		self.up = ang:Up()
		self.forward = ang:Forward()
		self.dirty1 = true
	end
	return self
end
function SCR:GetAngles()
	return self.angle
end

function SCR:SetDrawFunc(func)
	if type(func) == "function" then self.func = func end
	return self
end

function SCR:SetCull(cull)
	self.cull = cull
	return self
end

function SCR:CalcMatrix()
	if self.dirty0 then
		local sx = self.w/self.scrw
		local sy = -self.h/self.scrh
		local v = {
			{0, 0, 1, 0},
			{sx, 0, 0, -self.w/2 - self.scrx*sx},
			{0, sy, 0, self.h/2 - self.scry*sy},
			{0, 0, 0, 1},
		}

		self.mtx0 = Matrix(v)
	end

	if self.dirty1 then
		self.mtx1:Identity()
		self.mtx1:Translate( self.pos )
		self.mtx1:Rotate( self.angle )
	end

	if self.dirty0 or self.dirty1 then
		if self.legacy then
			self.mtx2 = self.mtx0
		else
			self.mtx2 = self.mtx1 * self.mtx0
		end
	end

	self.dirty0 = false
	self.dirty1 = false

	return self.mtx2
end

function SCR:AddToScene(autodraw)
	self.autodraw = autodraw
	G_3DSCREENS[self] = self
	return self
end

function SCR:RemoveFromScene()
	if self.OnRemove then pcall(self.OnRemove, self) end
	G_3DSCREENS[self] = nil
end

function SCR:SetTranslucent(t)
	self.translucent = t
end

function SCR:DrawBorder()
	local bw = self.bgwidth / self.mtx0:GetField(2,1)
	local bh = self.bgwidth / -self.mtx0:GetField(3,2)
	local x = self.scrx + 1
	local y = self.scry + 1
	local w = self.scrw - 2
	local h = self.scrh - 2
	render.OverrideDepthEnable( true, true )
	surface.SetDrawColor(self.bgcolor)
	surface.DrawRect(x-bw,y-bh,w+bw*2,bh)
	surface.DrawRect(x-bw,y+h,w+bw*2,bh)
	surface.DrawRect(x+w,y-bh,bw,h+bh*2)
	surface.DrawRect(x-bw,y-bh,bw,h+bh*2)
	render.OverrideDepthEnable( false, false )
end

function SCR:CalcFade()
	if self.startfade == 0 and self.endfade == 0 then return 0 end
	local dist = math.sqrt(self:GetViewerDistance())
	if dist > self.startfade then
		return math.min((dist - self.startfade) / (self.endfade - self.startfade), 1)
	end
	return 0
end

function SCR:DrawFacade(fading, depthoverride)
	local c = Color(self.facade_color.r, self.facade_color.g, self.facade_color.b, 255 * fading)
	if depthoverride then render.OverrideDepthEnable( true, true ) end
	if self.facade_material then
		surface.SetMaterial(self.facade_material)
		surface.SetDrawColor(c)
		surface.DrawTexturedRect(0,0,self.scrw,self.scrh)
	else
		surface.SetDrawColor(c)
		surface.DrawRect(0,0,self.scrw,self.scrh)
	end
	if depthoverride then render.OverrideDepthEnable( false, false ) end
end

function SCR:DrawFrontFacade(fade)
	self:DrawFacade(fade, false)
end

function SCR:DrawBackFacade()
	self:DrawFacade(1, true)
end

function SCR:Halt( b_halted )
	self.halt = b_halted
end

function SCR:GetMatrix()
	return self:CalcMatrix()
end

function SCR:Draw()

	if not self.func then return false end
	if self.cull and (LocalPlayer():EyePos() - self.pos):Dot(self.forward) < 0 then return false end

	if self.parentedTo and IsValid( self.parentedTo.Entity ) then

		local ent, pos, ang = self.parentedTo.Entity, self.parentedTo.Pos, self.parentedTo.Ang
		self:SetPos( ent:LocalToWorld( pos ) )
		self:SetAngles( ent:LocalToWorldAngles( ang ) )

	elseif self.parentedTo and !IsValid( self.parentedTo.Entity ) then // our parent is gone

		self:RemoveFromScene()
		return

	end

	local fade = self:CalcFade()
	local fixwidth = 0
	if not self.legacy then
		cam.PushModelMatrix(self:CalcMatrix())

		if self.bgwidth and self.bgwidth > 0 then
			self:DrawBorder()
		end

		if fade == 1 then
			self:DrawBackFacade()
			cam.PopModelMatrix()
			return
		end

		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilReferenceValue( 1 )
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
		render.SetStencilWriteMask( 1 )
		render.SetStencilTestMask( 1 )

		render.OverrideDepthEnable( true, true )
		surface.SetDrawColor(Color(0,0,0,1))
		surface.DrawRect(self.scrx,self.scry,self.scrw,self.scrh)
		render.OverrideDepthEnable( false, false )

		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		cam.IgnoreZ(true)
	else
		local r = self.right
		local u = self.up
		render.PushCustomClipPlane(r, r:Dot(self.pos)-self.w/2)
		render.PushCustomClipPlane(-r, -r:Dot(self.pos)-self.w/2)
		render.PushCustomClipPlane(u, u:Dot(self.pos)-self.h/2)
		render.PushCustomClipPlane(-u, -u:Dot(self.pos)-self.h/2)
		local a = Angle(self.angle.p, self.angle.y+90, self.angle.r+90)
		cam.Start3D2D( self.pos + r * self.w/2 + u * self.h/2, a, math.max(self.w / self.scrw, self.h / self.scrh) )
	end

	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

	--[[
	local b,e = pcall( self.func, self, (self.vw or self.scrw) + fixwidth, self.vh or self.scrh )
	if not b then
		ErrorNoHalt( "Error with screen:\n" .. tostring( e ) )
	end
	]]

	local w, h = ( self.vw or self.scrw ) + fixwidth, self.vh or self.scrh
	local function DrawErr()
		surface.SetDrawColor( 0, 0, 128 )
		surface.DrawRect( 0, 0, w, h )
		surface.SetFont( "default" )
		local _, th = surface.GetTextSize( "a" ) // get a sample text size for spacing
		local row = 0
		local function addLine( ... )
			draw.DrawText( table.concat( {...}, ", " ), "default", 0, row * th, Color( 255, 255, 255 ) )
			row = row + 1
		end
		addLine( "ERROR" )
		addLine( "The error has been printed to the clipboard. (Screen #" .. self.index .. ")" )
		addLine( "Screen execution halted" )
		addLine( "Hold left-click to try and continue screen execution." )
		addLine( "Hold right-click to copy the error message." )

		local ldown, rdown = input.IsMouseDown( MOUSE_LEFT ), input.IsMouseDown( MOUSE_RIGHT )
		local timeHeld = self.Err_Hold and RealTime() - self.Err_Hold or 0
		if self.Err_LastClick and RealTime() - self.Err_LastClick > 0.5 then
			self.Err_LastClick = nil
		end
		if !self.Err_LastClick then
			if timeHeld == 0 and ( ldown or rdown ) then
				self.Err_Hold = RealTime() // when we started holding
				self.Err_Holding = ldown and 0 or 1 // what button we're holding
			elseif timeHeld > 0.5 then
				self.Err_Hold = nil
				if self.Err_Holding == 0 then
					self.halt = false
					self.ErrMessage = nil
				else
					SetClipboardText( self.ErrMessage )
					Msg2( "Error has been copied to clipboard." )
				end
				self.Err_Holding = nil
				self.Err_LastClick = RealTime()
			end
		end

	end

	/*
	local b,e = xpcall(self.func, function( err )

		print( "Screen Error: " .. tostring( err ) )
		debug.Trace()

	end, self, (self.vw or self.scrw) + fixwidth, self.vh or self.scrh)*/

	render.PopFilterMag()
	render.PopFilterMin()

	if not self.legacy then
		if fade ~= 0 then self:DrawFrontFacade(fade) end
		cam.IgnoreZ(false)
		render.SetStencilEnable(false)
		cam.PopModelMatrix()
	else
		cam.End3D2D()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
	end

	if not b then
		//print("Screen Error: " .. tostring(e))
		//debug.Trace()
	end

	return true
end

function SCR:EnableInput(b)
	self.enableInput = b
	return self
end

function SCR:TrapMouseWheel(m)
	self.trapMouseWheel = m
	return self
end

function SCR:TrapMouseButtons(m)
	self.trapMouseButtons = m
	return self
end

function SCR:GainFocus()
	self:OnFocusState(true)
	self.mouseLatch = {}
end

function SCR:LoseFocus()
	self:OnFocusState(false)
	self:EndTextEntry()
end

function SCR:EndTextEntry()
	if self.textEntry then
		if self.textEntry._frame then
			self.textEntry._frame:Remove()
		end
		self.textEntry:Remove()
		self.textEntry = nil
		gui.EnableScreenClicker(false)
		self:OnTextFinished(self.textBuffer)
	end
end

function SCR:StartTextEntry(text, closeOnEnter, selectAll)
	if not self.textEntry then
		local frame = vgui.Create( "DFrame" )
		frame:SetTitle("TextEntry")
		frame:SetDraggable(false)
		frame:SetDrawOnTop(true)
		frame:SetSize(120,40)
		frame:SetPaintedManually(true)

		self.textBuffer = text or ""
		self.textEntry = vgui.Create( "DTextEntry", frame )
		self.textEntry:SetText(self.textBuffer)
		self.textEntry:SetSize(100,30)
		if selectAll then self.textEntry:SelectAllText( true ) end
		self.textEntry:RequestFocus()
		self.textEntry._frame = frame

		if not selectAll then
			self.textEntry:SetCaretPos(string.len(self.textBuffer))
		end

		if closeOnEnter then
			self.textEntry.OnEnter = function()
				self:EndTextEntry()
			end
		end

		frame:MakePopup()
		frame:DoModal()

		gui.EnableScreenClicker(true)
	end
end

function SCR:HasFocus()
	return self.focus
end

function SCR:IsEditingText()
	return self.textEntry ~= nil
end

function SCR:SetCaret(pos)
	if self.textEntry then
		self.textEntry:SetCaretPos(pos)
	end
end

function SCR:GetCaret()
	if self.textEntry then
		return self.textEntry:GetCaretPos()
	end
	return 0
end

function SCR:GetCaretString()
	if self.textEntry then
		local p = self.textEntry:GetCaretPos()
		return string.sub(self.textBuffer,1,p) .. "_" .. string.sub(self.textBuffer,p+1)
	end
	return self.textBuffer
end

function SCR:OnFocusState(state) end
function SCR:OnMousePressed(id) end
function SCR:OnMouseReleased(id) end
function SCR:OnMouseWheel(dir) end
function SCR:OnMouseMoved(x,y,ox,oy) end
function SCR:OnTextFinished(text) end
function SCR:OnTextChanged(old, new) end

function SCR:GetText(default)
	if not self.textEntry then return default or self.textBuffer end
	return self.textBuffer
end

function SCR:MousePressed(id)
	if self.mouseLatch[id] then return end
	self.mouseLatch[id] = true
	self:OnMousePressed(id)
end

function SCR:MouseReleased(id)
	if not self.mouseLatch[id] then return end
	self.mouseLatch[id] = false
	self:OnMouseReleased(id)
end

function SCR:Think()
	if not self.enableInput then return end

	local x,y,focus = self:GetMouse()

	if focus then
		if not self.focus then
			self.focus = true
			self:GainFocus()
		end

		if x ~= self.lastMouseX or y ~= self.lastMouseY then
			self:OnMouseMoved( x, y, self.lastMouseX or x, self.lastMouseY or y )
		end

		self.lastMouseX = x
		self.lastMouseY = y
	else
		if self.focus then
			self.focus = false
			self:LoseFocus()
		end
	end

	if self.textEntry then
		local text = self.textEntry:GetText()
		if text ~= self.textBuffer then
			local caret = self.textEntry:GetCaretPos()
			local ret = self:OnTextChanged(self.textBuffer, text)
			if ret == false then
				self.textEntry:SetText( self.textBuffer )
				self.textEntry:SetCaretPos( caret - 1 )
				return
			end
			self.textBuffer = text
		end
	end
end

if CLIENT then

	--[[_GMT_BOARDFRAME3 = _GMT_BOARDFRAME3 or vgui.Create("ScoreboardAbout")

	local frame = _GMT_BOARDFRAME3
	frame:SetPaintedManually(true)
	frame:SetBGColor(Color(0,0,0,140))
	frame:SetPos(0,0)
	frame:SetSize(1920,1080)
	frame:SetVisible( true )
	frame:InvalidateLayout()
	frame:SetAlpha( 140 )

	local function drawX(screen,w,h)
		--surface.SetDrawColor(Color(0,0,0,100))
		--surface.DrawRect(0,0,w,h)

		frame:SetPaintedManually( false )
		frame:PaintAt( 0, 0, w, h )
		frame:SetPaintedManually( true )
	end

	local myScreen = New(drawX):SetPos(Vector(2694,0,-900)):SetRes(604,355):SetOffset(720,90):SetSize(240/8,135/6):AddToScene(false)

	local pdraw = myScreen.Draw
	myScreen.Draw = function(self)
		local p = LocalPlayer():EyePos()
		local a = LocalPlayer():EyeAngles()
		local a2 = Angle(a.p,a.y,a.r)

		p = p + a:Up() * math.cos(CurTime() * 2)

		self:SetPos(p + a:Forward() * 30 + a:Right() * 10 - a:Up() * 10)

		a2:RotateAroundAxis(a2:Up(), 160)
		a2:RotateAroundAxis(a2:Forward(), 5)

		self:SetAngles(a2)

		pdraw(self)
	end
	]]

	--[[local function drawX(screen,w,h)
		surface.SetDrawColor(Color(0,0,0,100))
		surface.DrawRect(0,0,w,h)

		if screen:IsEditingText() then
			local cmsg = screen:GetCaretString()
			draw.SimpleText(cmsg, "AppBarLabel", w/2, h/2, Color(100,255,100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(screen.message or "", "AppBarLabel", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local mx,my,vis = screen:GetMouse()
		if vis then
			surface.SetDrawColor(Color(255,255,255))
			surface.DrawRect(mx-2,my-2,4,4)
		end
	end

	local myScreen = New(drawX):SetPos(Vector(2694,0,-900)):SetRes(640,480):SetSize(160,120):AddToScene(true):SetFade(300,400)
	myScreen:SetBorder(3):EnableInput(true):TrapMouseWheel(true):TrapMouseButtons(true):SetCull(true)
	myScreen.OnMousePressed = function(self, id)
		if id == 2 then
			self:StartTextEntry(self.message, true)
		else
			self:EndTextEntry()
		end
	end
	myScreen.OnTextChanged = function(self, old, new)
		self.message = new
	end
	myScreen.message = "Hello World"]]

	hook.Add("Think", "think3d2dScreens", Think3DScreens )
	hook.Add("PostDrawOpaqueRenderables", "render3d2dScreens", function() Render3DScreens(false) end )
	hook.Add("PostDrawTranslucentRenderables", "render3d2dScreens", function() Render3DScreens(true) end )
	hook.Add("PlayerBindPress", "Z3d2dinputBlock", function( ply, bind, pressed ) --gotta put a 'Z' so this executes first
		local focus, screen = LocalScreenHasFocus()
		if focus then
			if screen.trapMouseWheel then
				if bind == "invprev" and pressed then
					screen:OnMouseWheel(-1)
					return true
				elseif bind == "invnext" and pressed then
					screen:OnMouseWheel(1)
					return true
				end
			end

			if bind == "+attack" or bind == "+attack2" or bind == "+use" then
				if pressed then
					screen:MousePressed( ( bind == "+attack" or bind == "+use" ) and 1 or 2)
				else
					screen:MouseReleased(( bind == "+attack" or bind == "+use" ) and 1 or 2)
				end
				if screen.trapMouseButtons then
					return true
				end
			end
		end
	end)
end

module( "vgui_screen", package.seeall )

--[[for k,v in pairs(G_3DSCREENS) do
	if v.vgui then
		v:RemoveFromScene()
	end
end]]

local function ScreenVGUIDraw( screen, width, height )
	surface.SetDrawColor(Color(0,60,0,100))
	surface.DrawRect(0,0,width,height)

	if screen.gui then
		--screen.gui:SetPos(0,0)
		screen.gui:SetSize(width,height)
		screen.gui:SetPaintedManually( false )
		screen.gui:PaintAt( 0, 0, width, height )
		screen.gui:SetPaintedManually( true )
	end
end

local function Angle3Diff(a,b)
	local p = math.AngleDifference(a.p, b.p)
	local y = math.AngleDifference(a.y, b.y)
	local r = math.AngleDifference(a.r, b.r)
	return Angle(p,y,r)
end

--[[
--Alternative method, not as robust
local function ScreenVGUIMouse( screen, id, pressed, moved )
	local mx,my,vis = screen:GetMouse()
	local recurse = nil
	recurse = function( panel, x, y )
		local px,py = panel:GetPos()
		local pw,ph = panel:GetSize()

		x = x + px
		y = y + py

		local outside = ( x < px or y < py or x > px+pw or y > py+ph )
		if outside and not moved then return end

		if panel.Hovered then

			if moved and outside then
				panel.Hovered = false
				if panel.OnCursorExited then panel:OnCursorExited() end
			end

		else

			if moved and not outside then
				panel.Hovered = true
				if panel.OnCursorEntered then panel:OnCursorEntered() end
			end

		end

		if panel:HasChildren() then
			for k,v in pairs( panel:GetChildren() ) do
				recurse( v, x, y )
			end
		end
		--if panel:HasFocus() then
			if not moved then
				if pressed and panel.OnMousePressed then panel:OnMousePressed( id ) end
				if not pressed and panel.OnMouseReleased then panel:OnMouseReleased( id ) end
			end
		--end
	end

	if moved then

	end

	--if not vis then mx = -9999 end
	--recurse( screen.gui, mx, my )
end]]

local function ScreenVGUIThink( screen )
	local rmx,rmy = gui.MousePos()
	if screen.GUIInUse == true and (rmx ~= screen.LastSMX or rmy ~= screen.LastSMY) then
		--gui.SetMousePos( ScrW()/2, ScrH()/2 )

		local mx,my,vis = screen:GetMouse()
		local panel = screen.gui
		panel:SetPos( rmx - math.Round(mx), rmy - math.Round(my) )
		panel:InvalidateLayout()

		local newAim = gui.ScreenToVector( ScrW()/2 + (rmx - screen.LastSMX), ScrH()/2 + (rmy - screen.LastSMY) ):Angle()
		screen.LastSMX = rmx
		screen.LastSMY = rmy

		--Reset cursor every other frame
		screen.cursorReset = screen.cursorReset + 1
		if screen.cursorReset == 2 then
			screen.cursorReset = 0
			gui.SetMousePos( ScrW()/2, ScrH()/2 )
			screen.LastSMX = ScrW()/2
			screen.LastSMY = ScrH()/2
		end

		if rmy > ScrH() then
			gui.SetMousePos( rmx, 0 )
			screen.LastSMY = 0
		elseif rmy < 0 then
			gui.SetMousePos( rmx, ScrH() )
			screen.LastSMY = ScrH()
		end

		if rmx > ScrW() then
			gui.SetMousePos( 0, rmy )
			screen.LastSMX = 0
		elseif rmx < 0 then
			gui.SetMousePos( ScrW(), rmy )
			screen.LastSMX = ScrW()
		end

		LocalPlayer():SetEyeAngles( newAim )
	end

	screen.gui:SetCursor( "none" )
end

function New(...)
	local scr = screen.New(ScreenVGUIDraw, ...):EnableInput(true):TrapMouseWheel(true):TrapMouseButtons(true):SetCull(true):SetViewMouseOnly(true)
	scr.vgui = true
	scr.gui = vgui.Create("DPanel")
	scr.gui:SetPaintedManually(true)
	scr.gui:InvalidateLayout()
	scr.GetPanel = function( self )
		return self.gui
	end

	scr.OnRemove = function( self )
		if self.gui then self.gui:Remove() end
	end

	--[[scr.OnMousePressed = function( self, id )
		ScreenVGUIMouse( self, id, true, false )
	end

	scr.OnMouseReleased = function( self, id )
		ScreenVGUIMouse( self, id, false, false )
	end

	scr.OnMouseMoved = function( self, x, y, ox, oy )
		ScreenVGUIMouse( self, id, false, true )
	end]]

	scr.GUIInUse = false
	scr.OnFocusState = function( self, state )
		if state == false then
			ScreenVGUIMouse( self, 0, false, true )
		end

		if state == true then
			self.gui:SetVisible( true )
			self.GUIInUse = true
			self.LastSMX = ScrW()/2
			self.LastSMY = ScrH()/2
			self.cursorReset = 0
			gui.SetMousePos( ScrW()/2, ScrH()/2 )
			gui.EnableScreenClicker( true )
		else
			self.gui:SetVisible( false )
			self.GUIInUse = false
			gui.EnableScreenClicker( false )
		end
	end

	local thnk = scr.Think

	scr.Think = function( self )
		thnk( self )
		ScreenVGUIThink( self )
	end

	return scr
end

if CLIENT then
	--EXAMPLE!
	--[[local vguiScreen = vgui_screen.New( Vector(2634.432861, -7.764745, -814.339355) ):SetRes(640,480):SetSize(640/4,480/4):AddToScene(true)
	local panel = vguiScreen:GetPanel()

	local btn = vgui.Create("ScoreboardAbout", panel)
	btn:Dock( FILL )]]
end
