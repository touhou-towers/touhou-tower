
include('shared.lua')
ENT.RenderGroup = RENDERGROUP_BOTH

function string.FormatNumber( num )
	local formatted = num

	while true do
		formatted, k = string.gsub( formatted, "^(-?%d+)(%d%d%d)", '%1,%2' )
		if ( k == 0 ) then
			break
		end
	end

	return formatted
end

Casino.SlotsLocalPlaying = nil
Casino.SlotsSettingBet = false

local oldGuiEnable = gui.EnableScreenClicker

IsClickerEnabled = false

function gui.EnableScreenClicker( bool )
	oldGuiEnable( bool )
	IsClickerEnabled = bool
end

function gui.ScreenClickerEnabled()
	return IsClickerEnabled
end

function GetMouseVector()
	return gui.ScreenToVector( gui.MousePos() )
end

function GetMouseAimVector()
	if gui.ScreenClickerEnabled() then
		return GetMouseVector()
	else
		return LocalPlayer():GetAimVector()
	end
end

/*---------------------------------------------------------
	Basics
---------------------------------------------------------*/
function ENT:Initialize()

	self.SpinRotation = -180
	self.Spinners = { false, false, false }
	self.SelectedIcons = { getRand(), getRand(), getRand() }
	--PrintTable(self.SelectedIcons)
	self:SendAnim( self:GetPitch(1), self:GetPitch(2), self:GetPitch(3) )

	//self.GameSound = CreateSound( self, Casino.SlotGameSound )
	//self.GameSound:Play()

end

local matLight = Material( "sprites/pickup_light" )

function ENT:Draw()

	if !self.Light then
		self.Light = ClientsideModel( self.LightModel )
	end

	if IsValid( self.Light ) then

		self.Light:SetModelScale( .5, 0 )
		self.Light:SetPos( self:GetPos() + self:GetUp() * 80 + self:GetForward() * -5 )

		local ang = self:GetAngles()
		local spin = 0

		if self.LightTime && self.LightTime > CurTime() then
			spin = CurTime() * 600
		end

		local toang = Angle( 1, spin, ang.r )
		self.Light:SetAngles( toang )

		self.Light:DrawModel()
	end

	self:DrawModel()


	if !self.LightTime || self.LightTime < CurTime() then return end

	local size = SinBetween( 20, 30, CurTime() * 15 )

	local LightPos = self:GetPos()
	if IsValid( self.Light ) then
		LightPos = self.Light:GetPos()
	end

	local color = Color( 255, 0, 0 )

	render.SetMaterial( matLight )
	render.DrawSprite( LightPos, size, size, color )
	render.DrawSprite( LightPos, size*0.4, size*0.4, color )

	if IsValid( self.Light ) then
		local dlight = DynamicLight( self:EntIndex() )
		if dlight then
			dlight.Pos = self.Light:GetPos() + Vector( 0, 0, 5 )
			dlight.r = 255
			dlight.g = 0
			dlight.b = 0
			dlight.Brightness = SinBetween( 3, 5, CurTime() * 15 )
			dlight.Size = SinBetween( 128, 256, CurTime() * 15 )
			dlight.Decay =  80 * 5
			dlight.DieTime = CurTime() + .1
		end
	end

end

function ENT:OnRemove()

	if IsValid( self.Light ) then
		self.Light:Remove()
	end

end

function ENT:Think()

	//if !LocalPlayer():InVehicle() then
	//	Casino.SlotsLocalPlaying = nil
	//end

	self:Spin()
	self:NextThink( RealTime() )

end

/*---------------------------------------------------------
	Slot Machine Related Functions
---------------------------------------------------------*/
function ENT:IsSpinning(spinner)
	return self.Spinners[spinner]
end


function ENT:GetPitch(spinner)
	return self.IconPitches[self.SelectedIcons[spinner]]
end


function ENT:SendAnim( spin1, spin2, spin3 )

	if spin1 then
		self:SetPoseParameter( "spinner1_pitch", spin1 )
	end

	if spin2 then
		self:SetPoseParameter( "spinner2_pitch", spin2 )
	end

	if spin3 then
		self:SetPoseParameter( "spinner3_pitch", spin3 )
	end

end


function ENT:Spin()
	// Hacky, but pose parameters don't go over a certain angle D:
	if self.SpinRotation >= 180 then self.SpinRotation = -179 end

	local speed = 10
	self.SpinRotation = self.SpinRotation + speed

	if self:IsSpinning(1) then
		self:SendAnim( self.SpinRotation )
	else
		self:SendAnim( self:GetPitch(1) )
	end

	if self:IsSpinning(2) then
		self:SendAnim( nil, self.SpinRotation )
	else
		self:SendAnim( nil, self:GetPitch(2) )
	end

	if self:IsSpinning(3) then
		self:SendAnim( nil, nil, self.SpinRotation )
	else
		self:SendAnim( nil, nil, self:GetPitch(3) )
	end

end


usermessage.Hook( "slotsPlaying", function ( um )

	local ent = ents.GetByIndex( um:ReadShort() )
	if IsValid( ent ) then
		Casino.SlotsLocalPlaying = ent
		//RunConsoleCommand( "gmod_vehicle_viewmode", 0 ) // fix third person
	else
		Casino.SlotsLocalPlaying = nil
	end

end )

usermessage.Hook( "slotsWin", function ( um )

	local self = ents.GetByIndex( um:ReadShort() )
	if !IsValid( self ) then return end

	local jackpot = um:ReadBool()
	local time = 1
	if jackpot then
		time = 20
	end

	self.LightTime = CurTime() + time

end )

usermessage.Hook( "slotsResult", function ( um )
	local self = ents.GetByIndex( um:ReadShort() )
	if !IsValid( self ) then return end
	//print(um:ReadShort())
	local num1 = um:ReadShort()
	local num2 = um:ReadShort()
	local num3 = um:ReadShort()
	//print("ic1: " .. num1)
	//print("ic2: " .. num2)
	//print("ic3: " .. num3)
	//print("IS THIS REAL")
	self.Spinners = { true, true, true }
	//print(self.Spinners[1])
	self.SelectedIcons = { num1, num2, num3 }
	//Msg("Results received\n")

	local SpinSnd = PlayEx

	local SpinSnd = CreateSound( self, Casino.SlotSpinSound )
	SpinSnd:PlayEx(0.1, 100 )
	timer.Simple( Casino.SlotSpinTime[1], function()
		if IsValid( self ) then
			//print("FALSE")
			self.Spinners[1] = false
			self:EmitSound( Casino.SlotSelectSound, 75, 100 )
		end
	end )

	timer.Simple( Casino.SlotSpinTime[2], function()
		if IsValid( self ) then
			self.Spinners[2] = false
			self:EmitSound( Casino.SlotSelectSound, 75, 100 )
		end
	end )

	timer.Simple( Casino.SlotSpinTime[3], function()
		if IsValid( self ) then
			self.Spinners[3] = false
			self:EmitSound( Casino.SlotSelectSound, 75, 100 )
		end
		SpinSnd:Stop()
	end )

end )

/*---------------------------------------------------------
	Console Commands
---------------------------------------------------------*/
concommand.Add( "slotm_setbet", function( ply, cmd, args )

	if !Casino.SlotsSettingBet then
		Casino.SlotsSettingBet = true
		Derma_StringRequest( "Slot Machine", "Set the amount of money you would like to bet. (" .. Casino.SlotsMinBet .. " - " .. Casino.SlotsMaxBet .. ")", Casino.SlotsLocalBet,
						function( strTextOut )
							local amount = tonumber( strTextOut ) or Casino.SlotsLocalBet
							Casino.SlotsLocalBet = math.Clamp( math.Round(amount), Casino.SlotsMinBet, Casino.SlotsMaxBet )
							Casino.SlotsSettingBet = false
						end,
						function( strTextOut )
							Casino.SlotsSettingBet = false
						end,
						"Set Bet", "Cancel" )
	end
end )

/*---------------------------------------------------------
	3D2D Drawing
---------------------------------------------------------*/
function ENT:DrawTranslucent()

	self:DrawDisplay()

	if Casino.SlotsLocalPlaying != self then return end
	//self:DrawCombinations()
	self:DrawControls()

end

local tblFonts = {

	["ScoreboardText"] = {

		font = "Tahoma",

		size = 16,

		weight = 1000,

		antialias = true,

	}

}

for k,v in SortedPairs( tblFonts ) do

	surface.CreateFont( k, tblFonts[k] )

end

function ENT:DrawDisplay()

	local attachment = self:GetAttachment( self:LookupAttachment("display") )
	if !attachment then return end

	local pos, ang = attachment.Pos, attachment.Ang
	local scale = 0.1

	local dist = pos:Distance( LocalPlayer():GetShootPos() )
	if dist > 1024 then return end

	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )

	cam.Start3D2D( pos, ang, scale )

		//draw.RoundedBox(8, 10, 7, 64, 32, Color( 200,200,255,75) )
		//if LocalPlayer():IsAdmin() then
			draw.SimpleText( "Jackpot: " .. string.FormatNumber( self:GetJackpot() ), "ScoreboardText", 10, 7, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			//draw.SimpleText( "Jackpot: 800", "ScoreboardText", 10, 14, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		//end

		if Casino.SlotsLocalPlaying == self then
			draw.SimpleText( "Bet Amount: " .. Casino.SlotsLocalBet, "ScoreboardText", 10, 96, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
		end

	cam.End3D2D()

end


function ENT:DrawCombinations()

	local attachment = self:GetAttachment( self:LookupAttachment("winnings") )
	local pos, ang = attachment.Pos, attachment.Ang

	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )

	local Scale = 0.25

	cam.Start3D2D( pos, ang, Scale )

		//draw.RoundedBox(8, -32, -16, 64, 32, Color( 200,200,255,75) )
		draw.SimpleText( "Winnings", "ScoreboardText", 45, 25, Color(255,255,255,255), 1, 1 )

	cam.End3D2D()

end

/*---------------------------------------------------------
	3D2D Buttons
---------------------------------------------------------*/
ENT.Controls = {

	[1] = {
		text = "BET",
		x = -40,
		col = Color(255,0,0,255),
		bcol = Color(128,0,0,255),
		selected = false,
		cmd = "slotm_setbet"
	},

	[2] = {
		text = "SPIN",
		x = 40,
		col = Color(0,0,255,255),
		bcol = Color(0,0,160,255),
		selected = false,
		cmd = "slotm_spin"
	},

}

surface.CreateFont( "Buttons", { font = "coolvetica", size = 22, weight = 200 } )
local ButtonTexture = surface.GetTextureID( "models/gmod_tower/casino/button" )
local CursorTexture = surface.GetTextureID( "cursor/cursor_default.vtf" )
function ENT:DrawControls()
	local attachment = self:GetAttachment( self:LookupAttachment("controls") )
	local pos, ang = attachment.Pos, attachment.Ang
	local scale = 0.1

	ang:RotateAroundAxis( ang:Up(), 90 )
	ang:RotateAroundAxis( ang:Forward(), 90 )

	local function IsMouseOver( x, y, w, h )
		mx, my = self:GetCursorPos( pos, ang, scale )

		if mx && my then
			return ( mx >= x && mx <= (x+w) ) && (my >= y && my <= (y+h))
		else
			return false
		end
	end

	cam.Start3D2D( pos, ang, scale )

		// Draw buttons
		for _, btn in ipairs( self.Controls ) do
			local x, col, text = btn.x, btn.col, btn.text
			local y, w, h = 2, 48, 30

			if IsMouseOver(x - (w/2), y - (h/2), w, h) then
				btn.selected = true
				btn.col = Color(col.r,col.g,col.b,120)
			else
				btn.selected = false
				btn.col = Color(col.r,col.g,col.b,40)
			end

			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture( ButtonTexture )
			surface.DrawTexturedRect( x - (w/2), y - (h/2), w, h )

			draw.RoundedBox( 0, x - (w/2), y - (h/2), w, h, btn.col ) // Color button texture

			draw.SimpleText(text, "Buttons", x, y + 1, btn.bcol, 1, 1)
		end

		// Draw small cursor
		local mx, my = self:GetCursorPos( pos, ang, scale )
		if IsMouseOver( -190/2, -35/2, 190, 35 ) then
			self:DrawCursor( mx, my )
			vgui.GetWorldPanel():SetCursor( "blank" )
			/*surface.SetDrawColor(255, 0, 0, 255)
			surface.DrawRect( mx - 2, my - 2, 4, 4 )*/
		else
			vgui.GetWorldPanel():SetCursor( "default" )
		end

	cam.End3D2D()

end

hook.Add( "KeyPress", "KeyPressedHook", function( ply, key )
	if Casino.SlotsLocalPlaying && key == IN_ATTACK then
		if Casino.SlotsLocalPlaying.Controls != nil then
			for _, btn in ipairs( Casino.SlotsLocalPlaying.Controls ) do
				if btn.selected then
					//Msg( "[" .. Casino.SlotsLocalPlaying:EntIndex() .. "] " .. LocalPlayer():Name() .. " has pressed the " .. btn.text .. " button.\n" )
					RunConsoleCommand( btn.cmd, Casino.SlotsLocalBet )
				end
			end
		end
	end
end )

/*---------------------------------------------------------
	Mind Blowing 3D2D Cursor Math -- Thanks BlackOps!
---------------------------------------------------------*/
ENT.Width = 190 / 2
ENT.Height = 35 / 2

local function RayQuadIntersect(vOrigin, vDirection, vPlane, vX, vY)
	local vp = vDirection:Cross(vY)

	local d = vX:DotProduct(vp)

	if (d <= 0.0) then return end

	local vt = vOrigin - vPlane
	local u = vt:DotProduct(vp)
	if (u < 0.0 or u > d) then return end

	local v = vDirection:DotProduct(vt:Cross(vX))
	if (v < 0.0 or v > d) then return end

	return Vector(u / d, v / d, 0)
end

function ENT:MouseRayInteresct( pos, ang )
	local plane = pos + ( ang:Forward() * ( self.Width / 2 ) ) + ( ang:Right() * ( self.Height / -2 ) )

	local x = ( ang:Forward() * -( self.Width ) )
	local y = ( ang:Right() * ( self.Height ) )

	return RayQuadIntersect( EyePos(), GetMouseAimVector(), plane, x, y )
end

function ENT:GetCursorPos( pos, ang, scale )

	local uv = self:MouseRayInteresct( pos, ang )

	if uv then
		local x,y = (( 0.5 - uv.x ) * self.Width), (( uv.y - 0.5 ) * self.Height)
		return (x / scale), (y / scale)
	end
end

function ENT:DrawCursor( cur_x, cur_y )

	local cursorSize = 26

	surface.SetTexture( CursorTexture )

	if input.IsMouseDown( MOUSE_LEFT ) then
		cursorSize = 23
		surface.SetDrawColor( 255, 150, 150, 255 )
	else
		surface.SetDrawColor( 255, 255, 255, 255 )
	end

	local offset = cursorSize / 2
	surface.DrawTexturedRect( cur_x - offset + 5, cur_y - offset + 7, cursorSize, cursorSize )
end
