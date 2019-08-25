-----------------------------------------------------
local colorList = {
	Color(136, 0, 21),
	Color(237, 28, 36),
	Color(255, 127, 39),
	Color(255, 242, 0),
	Color(34, 177, 76),
	Color(0, 162, 232),
	Color(63, 72, 204),
	Color(174, 40, 247),
	Color(238, 57, 162),
	Color(255, 255, 255),
	Color(50, 50, 50)
}

local function ToggleCursor(bool)
	if bool then
		if not gui.ScreenClickerEnabled() then
			gui.EnableScreenClicker(true)
			RestoreCursorPosition()
			ClickerForced = true
		end
	else
		if ClickerForced then
			RememberCursorPosition()
			gui.EnableScreenClicker(false)
			ClickerForced = false
		end
	end
end

function GM:DisplayCustomizer(enable, remove)
	if RADIAL and ValidPanel(RADIAL) then
		ToggleCursor(false)
		RADIAL:Remove()
		RADIAL = nil
	end

	if not enable then
		return
	end

	ToggleCursor(true)

	RADIAL = vgui.Create("DRadialMenu")
	RADIAL:SetSize(ScrH(), ScrH())
	RADIAL:SetRadiusScale(0.2)
	RADIAL:SetAllowInput(true)
	RADIAL:SetRemoveOnSelect(remove)
	--RADIAL:SetCursor( "blank" )
	RADIAL:Center()
	RADIAL:ForceSelect()
	RADIAL:SetPaintSelectColor(Color(255, 255, 255, 255))
	-- RADIAL:SetPaintSaveSelectColor( Color( 255, 150, 150, 255 ) )
	-- RADIAL:SetSave( true )
	-- RADIAL:SetPaintDebug( true )
	-- RADIAL:SetDegreeOffset( 90 )
	-- RADIAL:SetAlignMode( RADIAL_ALIGN_CENTER )

	local color = Color(255, 255, 255)

	local cp = vgui.Create("DImageButton")
	cp:SetSize(128, 128)
	cp:SetImage("gmod_tower/minigolf/hud_golf_big.png")
	cp:SetColor(color)
	RADIAL:SetCenterPanel(cp)

	-- Add items
	for id, color in pairs(colorList) do
		local p = vgui.Create("DImageButton")

		p:SetSize(48, 48)
		p:SetImage("gmod_tower/minigolf/hud_golf_small.png")
		p:SetColor(color)
		--p:SetCursor( "blank" )
		p.OriginalColor = color
		p.CenterPanel = cp
		p.DoClick = function(self)
			RunConsoleCommand(
				"minigolf_color",
				math.Round(color.r / 255, 3) .. " " .. math.Round(color.g / 255, 3) .. " " .. math.Round(color.b / 255, 3)
			)
			ToggleCursor(false)
			RADIAL.Hovered = false
			-- LocalPlayer()._ColorID = id
		end

		p.Think = function(self)
			if not gui.ScreenClickerEnabled() then
				RADIAL.Hovered = false
			end

			if self.Hovered then
				self.CenterPanel:SetColor(self.OriginalColor)
				--self.CenterPanel:SetCursor( "blank" )
				RADIAL.Hovered = true
			else
				if LocalPlayer().GetBallColor and not RADIAL.Hovered then
					local plycolor = LocalPlayer():GetBallColor() * 255
					plycolor = Color(plycolor.r, plycolor.g, plycolor.b)
					self.CenterPanel:SetColor(plycolor)
				end
			end
		end

		RADIAL:AddItem(p)
	end
end

local oldGuiEnable = gui.EnableScreenClicker
IsClickerEnabled = false

function gui.EnableScreenClicker(bool)
	oldGuiEnable(bool)
	IsClickerEnabled = bool
end

function gui.ScreenClickerEnabled()
	return IsClickerEnabled
end

function GetMouseVector()
	return gui.ScreenToVector(gui.MousePos())
end

function GetMouseAimVector()
	if gui.ScreenClickerEnabled() then
		return GetMouseVector()
	else
		return LocalPlayer():GetAimVector()
	end
end

usermessage.Hook(
	"ShowCustomizer",
	function(um)
		local bool = um:ReadBool()

		GAMEMODE:DisplayCustomizer(bool)
		gui.EnableScreenClicker(bool)
	end
)
