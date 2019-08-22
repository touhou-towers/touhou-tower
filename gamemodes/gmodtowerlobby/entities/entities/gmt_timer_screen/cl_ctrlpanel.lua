
-----------------------------------------------------

local Cursor2D = surface.GetTextureID( "cursor/cursor_default.vtf" )

local a_c = TEXT_ALIGN_CENTER

function ENT:SetupControlPanel()

	local sc = screen.New()
	sc:SetPos( self:LocalToWorld( self.PanelPos ) )
	local ang = self:GetAngles()
	ang:RotateAroundAxis( ang:Up(), 180 )
	sc:SetAngles( ang )
	sc:SetSize( 30, 30 )
	sc:SetMaxDist( 128 )
	sc:SetRes( 512, 512 )
	sc:SetCull( true )
	sc:SetFade( 500, 600 )
	sc:EnableInput( true )
	sc:TrapMouseButtons( true )
	sc:SetParent( self )
	sc:SetDrawFunc( function( scr, w, h )

		local mx, my, visible = sc:GetMouse()
		local mouseDown = input.IsMouseDown( MOUSE_LEFT ) or LocalPlayer():KeyDown( IN_USE )

		local function mouseon( x, y, w, h )

			if !visible then return false end
			local x2, y2 = x + w, y + h
			return mx > x and mx < x2 and my > y and my < y2

		end
		local function outbox( corner, x, y, wide, high, col, thick, bcol )
			draw.RoundedBox( corner, x, y, wide, high, bcol or Color( 0, 0, 0 ) )
			draw.RoundedBox( corner, x + thick, y + thick, wide - thick * 2, high - thick * 2, col )
		end

		local function outlinetext( text, font, x, y, col, ax, ay, thick, bcol )

			for x2 = x - thick, x + thick do
				for y2 = y - thick, y + thick do
					if x2 == x and y2 == y then continue end
					draw.DrawText( text, font, x2, y2, bcol or Color( 0, 0, 0 ), ax, ay )
				end
			end
			draw.DrawText( text, font, x, y, col, ax, ay )

		end
		local OnButton = false
		local function button( x, y, w, h, col, tcol, text, font, corner, bcol, bsize, func )

			local isOn = mouseon( x, y, w, h )
			if isOn then
				sc.PressedButton = func
				OnButton = true
			end
			if isOn and !mouseDown then
				col.r = col.r * 0.7
				col.g = col.g * 0.7
				col.b = col.b * 0.7
			elseif isOn and mouseDown then
				col.r = col.r * 0.9
				col.g = col.g * 0.9
				col.b = col.b * 0.9
			end
			outbox( corner or 0, x, y, w, h, col, bsize or 0, bcol or Color( 0, 0, 0 ) )
			if text then
				surface.SetFont( font or "default" )
				local w2, h2 = surface.GetTextSize( text, font or "default" )
				draw.DrawText( text, font or "default", x + w / 2, y + h / 2 - h2 / 2, tcol or Color( 255, 255, 255 ), a_c )
			end
		end

		draw.RoundedBox( 16, 0, 0, w, h, self:GetPower() and !self:GetLocked() and Color( 255, 255, 255 ) or Color( 50, 50, 50 ) )
		if !self:GetPower() then
			local size = 256
			button( w / 2 - size/2, h / 2 - size/2, size, size, Color( 0, 0, 0 ), Color( 150, 0, 0 ), "ON", "GTowerTimerHuge", 32, Color( 150, 0, 0 ), 8, function()
				net.Start( "gmt_timer_net" )
					net.WriteEntity( self )
					net.WriteInt( self.Net.POWER, 8 )
				net.SendToServer()
			end )
		elseif !self:GetLocked() then

			local Remaining = math.abs( self:GetRemaining() )

			Remaining = {
				sec = math.floor( Remaining % 60 ),
				min = math.floor( Remaining / 60 % 60 ),
				hour = math.floor( Remaining / 60 / 60 )
			}
			draw.DrawText( "TIMER:", "GTowerTimerMain", w / 2, 5, Color( 0, 0, 0 ), a_c )
			outlinetext( string.format( "%02i:%02i:%02i", Remaining.hour, Remaining.min, Remaining.sec ), "GTowerTimerLarge", w / 2, 40, Color( 255, 255, 255 ), a_c, nil, 2, Color( 0, 0, 0 ) )

			button(
				60,
				22,
				70,
				32,
				Color( 100, 100, 100 ),
				Color( 255, 255, 255 ),
				"LOCK",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				2,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.LOCK, 8 )
					net.SendToServer()
				end
			)
			local w2 = 120
			button(
				w - 60 - w2,
				22,
				w2,
				32,
				Color( 100, 0, 0 ),
				Color( 255, 0, 0 ),
				"POWER OFF",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				2,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.POWER, 8 )
					net.SendToServer()
				end
			)

			local px = 200
			local spacing = 5
			button(
				w / 2 - px,
				100,
				px * 2,
				60,
				self:GetIsNewYears() and Color( 0, 200, 0 ) or Color( 200, 0, 0 ),
				Color( 255, 255, 255 ),
				"New Year's Mode",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.NEWYEAR, 8 )
					net.SendToServer()
				end
			)
			button(
				w / 2 - px,
				170,
				px/2 - spacing,
				60,
				self:GetRealTime() and Color( 0, 200, 0 ) or Color( 200, 0, 0 ),
				Color( 255, 255, 255 ),
				"Real\nTime",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.REALTIME, 8 )
					net.SendToServer()
				end
			)
			button(
				w / 2 - spacing - ( px/2 - spacing ),
				170,
				px/2 - spacing,
				60,
				self:GetTimerMode() and Color( 0, 200, 0 ) or Color( 200, 0, 0 ),
				Color( 255, 255, 255 ),
				"Timer\nMode",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.TIMER_MODE, 8 )
					net.SendToServer()
				end
			)
			button(
				w / 2 - px,
				240,
				px - spacing,
				60,
				Color( 0, 0, 200 ),
				Color( 255, 255, 255 ),
				"Set Timer",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					if !LocalPlayer():IsAdmin() or !self:GetTimerMode() then return end
					local time = string.FormattedTime( self:GetTimerLength() )
					Derma_StringRequest(
						"Set Timer",
						"Enter time to put on timer.No greater than 100 hrs.\n(HH:MM:SS)",
						string.format( "%02i:%02i:%02i", time.h, time.m, time.s ),
						function( text )
							local f1, f2 = text:find( "%d%d:%d%d:%d%d", 1 )
							if !f1 then
								Derma_Message( "Invalid entry", "Error", "OK" )
								return
							end
							if string.find(text:sub( 1, 3 ),":") == nil then
								local sec = 2160000000
								net.Start( "gmt_timer_net" )
									net.WriteEntity( self )
									net.WriteInt( self.Net.TIMER_TIME, 8 )
									net.WriteUInt( sec, 19 )
								net.SendToServer()
								return
							end
							local hr = tonumber( text:sub( 1, 2 ) )
							hr = math.min( 99, hr )
							local min = tonumber( text:sub( 4, 5 ) )
							min = math.min( 59, min )
							local sec = tonumber( text:sub( 7, 8 ) )
							sec = math.min( 59, sec )
							sec = sec + min * 60 + hr * 60 * 60
							net.Start( "gmt_timer_net" )
								net.WriteEntity( self )
								net.WriteInt( self.Net.TIMER_TIME, 8 )
								net.WriteUInt( sec, 19 )
							net.SendToServer()
						end,function()end,
						"Enter"
					)
				end
			)
			button(
				w / 2 - px,
				310,
				px - spacing,
				60,
				Color( 0, 200, 0 ),
				Color( 255, 255, 255 ),
				"Start Timer",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.TIMER_START, 8 )
					net.SendToServer()
				end
			)
			button(
				w / 2 - px,
				380,
				px - spacing,
				60,
				Color( 200, 200, 0 ),
				Color( 255, 255, 255 ),
				"Pause Timer",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.TIMER_PAUSE, 8 )
					net.SendToServer()
				end
			)
			button(
				w / 2 - px,
				380 + 60 + 10,
				px - spacing,
				60,
				Color( 200, 0, 0 ),
				Color( 255, 255, 255 ),
				"Stop Timer",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.TIMER_STOP, 8 )
					net.SendToServer()
				end
			)


			button(
				w / 2 + spacing,
				170,
				px - spacing,
				60,
				Color( 0, 0, 200 ),
				Color( 255, 255, 255 ),
				"Target Time & Date",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					if !LocalPlayer():IsAdmin() then return end
					Derma_StringRequest(
						"Target Time & Date",
						"Enter a time and date for the clock to count down to.\nHH:MM:SS mm-dd-yyyy",
						self:GetTargetTime(),
						function(text)

							local found = text:find( "%d%d:%d%d:%d%d %d%d%-%d%d%-%d%d%d%d", 1 )
							if !found then Derma_Message( "Invalid entry", "Error", "OK" ) return end
							local time = {}
							time.hour = math.min( tonumber( text:sub( 1, 2 ) ), 99 )
							time.min = math.min( tonumber( text:sub( 4, 5 ) ), 59 )
							time.sec = math.min( tonumber( text:sub( 7, 8 ) ), 59 )
							time.month = math.Clamp( tonumber( text:sub( 10, 11 ) ), 1, 12 )
							time.day = math.Clamp( tonumber( text:sub( 13, 14 ) ), 1, 31 )
							time.year = tonumber( text:sub( 16, 19 ) )
							net.Start( "gmt_timer_net" )
								net.WriteEntity( self )
								net.WriteInt( self.Net.TARGET_TIME, 8 )
								net.WriteString( string.format( "%02i:%02i:%02i %02i-%02i-%04i", time.hour, time.min, time.sec, time.month, time.day, time.year ) )
							net.SendToServer()

						end)
				end
			)
			button(
				w / 2 + spacing,
				170 + 70 * 1,
				px - spacing,
				60,
				self:GetLocal() and Color( 0, 200, 0 ) or Color( 200, 0, 0 ),
				Color( 255, 255, 255 ),
				"Local Time",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.LOCAL, 8 )
					net.SendToServer()
				end
			)
			button(
				w / 2 + spacing,
				170 + 70 * 2,
				px / 2 - spacing,
				60,
				Color( 0, 0, 200 ),
				Color( 255, 255, 255 ),
				"Title",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					if !LocalPlayer():IsAdmin() then return end
					Derma_StringRequest(
						"Title",
						"Enter a title for the countdown.\nTitle is displayed on the front.",
						self:GetTitle(),
						function(text)
							net.Start( "gmt_timer_net" )
								net.WriteEntity( self )
								net.WriteInt( self.Net.TITLE, 8 )
								net.WriteString( text )
							net.SendToServer()
						end,
						nil,
						"Set"
					)
				end
			)
			button(
				w / 2 + spacing + px/2,
				170 + 70 * 2,
				px / 2 - spacing,
				60,
				Color( 0, 0, 200 ),
				Color( 255, 255, 255 ),
				"Description",
				"GTowerTimerTiny",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					if !LocalPlayer():IsAdmin() then return end
					Derma_StringRequest(
						"Description",
						"Enter a description for the countdown.\n\\n for multiple lines.\nDescription is displayed on the front.",
						self:GetDescription(),
						function(text)
							net.Start( "gmt_timer_net" )
								net.WriteEntity( self )
								net.WriteInt( self.Net.DESC, 8 )
								net.WriteString( text )
							net.SendToServer()
						end,
						nil,
						"Set"
					)
				end
			)
			button(
				w / 2 + spacing,
				170 + 70 * 3,
				px - spacing,
				60,
				self:GetCeleb() and Color( 0, 200, 0 ) or Color( 200, 0, 0 ),
				Color( 255, 255, 255 ),
				"Music",
				"GTowerTimerSmall",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.CELEB, 8 )
					net.SendToServer()
				end
			)
			button(
				w / 2 + spacing,
				170 + 70 * 4,
				px - spacing,
				60,
				self:GetNoPlus() and Color( 0, 200, 0 ) or Color( 200, 0, 0 ),
				Color( 255, 255, 255 ),
				"Stop after expiry\n(Timer Mode only)",
				"GTowerTimerTiny",
				0,
				Color( 0, 0, 0 ),
				4,
				function()
					net.Start( "gmt_timer_net" )
						net.WriteEntity( self )
						net.WriteInt( self.Net.NOPLUS, 8 )
					net.SendToServer()
				end
			)

		else
			draw.SimpleTextOutlined( "Panel locked.", "GTowerTimerHuge", w / 2, 5, Color( 255, 255, 255 ), a_c, nil, 4, Color( 0, 0, 0 ) )

			local size = 256
			button( w / 2 - size/2, h / 2 - size/2, size, size, Color( 0, 0, 0 ), Color( 150, 150, 150 ), "UNLOCK", "GTowerTimerLarge", 32, Color( 150, 150, 150 ), 8, function()
				net.Start( "gmt_timer_net" )
					net.WriteEntity( self )
					net.WriteInt( self.Net.LOCK, 8 )
				net.SendToServer()
			end )
		end


		if !OnButton then
			sc.PressedButton = nil
		end

		local cursorSize = 64
		if mouseDown then

			cursorSize = cursorSize * 0.90625

		end

		local offset = cursorSize / 2

		mx, my = mx - offset + 11 * ( cursorSize / 64 ), my - offset + 16 * ( cursorSize / 64 )

		if visible then
			surface.SetDrawColor( 255, 255, 255 )
			surface.SetTexture( Cursor2D )

			surface.DrawTexturedRect( mx, my, cursorSize, cursorSize )
		end
	end )
	function sc:OnMousePressed( id )
		if self.PressedButton and id == 1 then
			self.PressedButton()
		end
	end
	sc:AddToScene( true )
	self.Panel = sc

end
