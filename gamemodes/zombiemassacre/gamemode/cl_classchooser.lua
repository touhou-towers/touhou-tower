module("ClassSelection", package.seeall)

surface.CreateFont("ClassSelectExtraLarge", {font = "Kerberos Fang", size = 68, weight = 400})
surface.CreateFont("ClassSelectName", {font = "Oswald", size = 48, weight = 400})
surface.CreateFont("ClassSelectHeader", {font = "Oswald", size = 28, weight = 400})
surface.CreateFont("ClassSelectDescription", {font = "Oswald", size = 18, weight = 400})

CLASSSCREEN = {}

function CLASSSCREEN:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetZPos(-1)

	self.Title = Label("SELECT A CLASS", self)
	self.Title:SetFont("ClassSelectExtraLarge")
	self.Title:SetTextColor(Color(255, 255, 255, 255))

	self.ClassSelect = vgui.Create("ClassSelect", self)
	self.ClassSelect:InvalidateLayout()

	self.ConfirmButton = vgui.Create("ConfirmButton", self)
	self.ConfirmButton:InvalidateLayout()
end

function CLASSSCREEN:PerformLayout()
	self.Title:SizeToContents()
	self.Title:SetPos(0, ScrH() * .05)
	self.Title:CenterHorizontal()

	self.ConfirmButton:SetPos(0, ScrH() - (self.ConfirmButton:GetTall() * 2))
	self.ConfirmButton:CenterHorizontal()
end

function CLASSSCREEN:Paint(w, h)
end
vgui.Register("ClassSelectScreen", CLASSSCREEN)

CLASSSELECT = {}
CLASSSELECT.Padding = 10
CLASSSELECT.TopPadding = 30

function CLASSSELECT:Init()
	self:SetSize(ScrW(), ScrH() * .65)
	self:SetZPos(1)

	self:Center()

	self.ClassPanels = {}

	for _, class in pairs(classmanager.List) do
		local panel = vgui.Create("ClassPanel", self)

		panel:SetClass(class)
		table.insert(self.ClassPanels, panel)
	end
end

function CLASSSELECT:PerformLayout()
	local position = self.Padding
	local num = #self.ClassPanels

	for _, panel in pairs(self.ClassPanels) do
		panel:SetTall(self:GetTall() - self.TopPadding)
		panel:SetWide((ScrW() - (self.Padding * (num + 1))) / num)
		panel:InvalidateLayout(true)

		panel:SetPos(position, self.TopPadding / 2)
		position = position + panel:GetWide() + self.Padding
	end
end

function CLASSSELECT:Paint(w, h)
	surface.SetDrawColor(Color(0, 0, 0, 200))
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
end
vgui.Register("ClassSelect", CLASSSELECT)

CLASS = {}
CLASS.Padding = 10
CLASS.AvatarSize = 32
CLASS.PlayerOne = nil
CLASS.PlayerTwo = nil

function CLASS:Init()
	-- ==PLAYER SETUP==
	self.PlayerOneAvatar = vgui.Create("PlayerAvatarName", self)
	self.PlayerOneSilhouette = vgui.Create("PlayerModelSilhouette", self)
	self.PlayerOneSilhouette:SetZPos(-2)
	self.PlayerOneSilhouette:SetupLighting(Color(0, 0, 0))
	self.PlayerOneSilhouette.LookAt = Vector(0, 0, 64)
	self.PlayerOneSilhouette.CamPos = Vector(0, 20, 55)

	self.PlayerTwoAvatar = vgui.Create("PlayerAvatarName", self)
	self.PlayerTwoSilhouette = vgui.Create("PlayerModelSilhouette", self)
	self.PlayerTwoSilhouette:SetZPos(-3)
	self.PlayerTwoSilhouette:SetupLighting(Color(0, 0, 0))
	self.PlayerTwoSilhouette.LookAt = Vector(0, 0, 64)
	self.PlayerTwoSilhouette.CamPos = Vector(0, 20, 55)

	-- ==CLASS INFORMATION==
	-- CLASS NAME
	self.Title = Label("", self)
	self.Title:SetFont("ClassSelectName")
	self.Title:SetTextColor(Color(255, 255, 255, 255))

	-- SPECIAL ITEM
	self.SISubTitle = Label("EQUIPMENT", self)
	self.SISubTitle:SetFont("ClassSelectDescription")
	self.SISubTitle:SetTextColor(Color(255, 255, 255, 100))

	self.SIHead = Label("", self)
	self.SIHead:SetTextColor(Color(255, 255, 255, 255))
	self.SIHead:SetFont("ClassSelectHeader")

	self.SIDesc = vgui.Create("DTextEntry", self)
	self.SIDesc:SetFont("ClassSelectDescription")
	self.SIDesc:SetTextColor(Color(255, 255, 255, 200))
	self.SIDesc:SetMultiline(true)
	self.SIDesc:SetEditable(false)
	self.SIDesc:SetDrawBackground(false)
	self.SIDesc:SetDrawBorder(false)

	-- COMBO POWER
	self.CPSubTitle = Label("COMBO POWER", self)
	self.CPSubTitle:SetFont("ClassSelectDescription")
	self.CPSubTitle:SetTextColor(Color(255, 255, 255, 100))

	self.CPHead = Label("", self)
	self.CPHead:SetFont("ClassSelectHeader")
	self.CPHead:SetTextColor(Color(255, 255, 255, 255))

	self.CPDesc = vgui.Create("DTextEntry", self)
	self.CPDesc:SetFont("ClassSelectDescription")
	self.CPDesc:SetTextColor(Color(255, 255, 255, 200))
	self.CPDesc:SetMultiline(true)
	self.CPDesc:SetEditable(false)
	self.CPDesc:SetDrawBackground(false)
	self.CPDesc:SetDrawBorder(false)
end

function CLASS:SetClass(class)
	self.Class = class
	self.ClassName = class.Name

	self.Title:SetText(string.upper(class.Name))

	self.SIHead:SetText(string.upper(class.SpecialItemName))
	self.SIDesc:SetText(class.SpecialItemDesc)

	self.CPHead:SetText(string.upper(class.PowerName))
	self.CPDesc:SetText(class.PowerDesc)
end

function CLASS:PlayerIsClass(ply)
	return IsValid(ply) and classmanager.IsClass(ply, self.ClassName)
end

function CLASS:IsFull()
	return #classmanager.FindByClass(self.ClassName) >= 2
end

function CLASS:PerformLayout()
	self.Title:SizeToContents()
	self.Title:SetPos(0, 10)
	self.Title:CenterHorizontal()

	local itemsY = 80

	-- SPECIAL ITEM
	self.SISubTitle:SizeToContents()
	self.SISubTitle:SetPos(0, itemsY)
	self.SISubTitle:AlignLeft(self.Padding)

	self.SIHead:SizeToContents()
	self.SIHead:SetPos(0, itemsY + 14)
	self.SIHead:AlignLeft(self.Padding)

	self.SIDesc:SetSize(self:GetWide() - (self.Padding * 2), 75)
	self.SIDesc:SetPos(self.Padding - 2, itemsY + 42)

	local items2Y = self.SIDesc.y + self.SIDesc:GetTall() + 5

	-- COMBO POWER
	self.CPSubTitle:SizeToContents()
	self.CPSubTitle:SetPos(0, items2Y)
	self.CPSubTitle:AlignLeft(self.Padding)

	self.CPHead:SizeToContents()
	self.CPHead:SetPos(0, items2Y + 14)
	self.CPHead:AlignLeft(self.Padding)

	self.CPDesc:SetSize(self:GetWide() - (self.Padding * 2), 75)
	self.CPDesc:SetPos(self.Padding - 2, items2Y + 42)

	-- ==PLAYER SETUP==
	self.PlayerOneAvatar:SetPos(0, self:GetTall() - self.AvatarSize - self.Padding)
	self.PlayerOneAvatar:AlignLeft(self.Padding)

	self.PlayerOneSilhouette:SetSize(self:GetWide(), self:GetWide())
	self.PlayerOneSilhouette:SetPos(0, self:GetTall() - self:GetWide())
	self.PlayerOneSilhouette:CenterHorizontal()

	self.PlayerTwoAvatar:SetPos(0, self:GetTall() - (self.AvatarSize * 2) - (self.Padding * 2) - 10)
	self.PlayerTwoAvatar:AlignLeft(self.Padding)

	self.PlayerTwoSilhouette:SetSize(self:GetWide(), self:GetWide())
	self.PlayerTwoSilhouette:SetPos(0, self:GetTall() - self:GetWide())
	self.PlayerTwoSilhouette:CenterHorizontal()
end

function CLASS:Think()
	self:UpdatePlayers()

	-- self.PlayerTwoSilhouette.LookAt = Vector( lx:GetInt(), ly:GetInt(), lz:GetInt() )
	-- self.PlayerTwoSilhouette.CamPos = Vector( mx:GetInt(), my:GetInt(), mz:GetInt() )

	if self:PlayerIsClass(LocalPlayer()) or LocalPlayer():GetNWBool("Upgraded") then
		self:SetCursor("default")
	else
		self:SetCursor("hand")
	end
end

function CLASS:Paint(w, h)
	local alpha = 150

	if LocalPlayer():GetNWBool("Upgraded") then
		alpha = 50
	end

	-- BG
	surface.SetDrawColor(Color(50, 50, 50, alpha))
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())

	-- Dividers
	-- surface.SetDrawColor( Color( 80, 80, 80, alpha ) )
	-- surface.DrawRect( 5, self.SISubTitle.y, self:GetWide() - 10, self.SISubTitle:GetTall() + self.SIHead:GetTall() - 6 )
	-- surface.DrawRect( 5, self.CPSubTitle.y, self:GetWide() - 10, self.CPSubTitle:GetTall() + self.CPHead:GetTall() - 6 )

	-- Border
	if
		(self:IsMouseInWindow() and not self:IsFull() and not LocalPlayer():GetNWBool("Upgraded")) or
			self:PlayerIsClass(LocalPlayer())
	 then
		surface.SetDrawColor(Color(255, 180, 35, SinBetween(0, alpha, CurTime() * 10)))

		if self:PlayerIsClass(LocalPlayer()) then
			surface.SetDrawColor(Color(255, 180, 35, alpha))
		end

		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end

	-- Inner BG
	surface.SetDrawColor(Color(50, 50, 50, alpha))

	if
		(self:IsMouseInWindow() and not self:IsFull() and not LocalPlayer():GetNWBool("Upgraded")) or
			self:PlayerIsClass(LocalPlayer())
	 then
		surface.SetDrawColor(Color(80, 80, 80, alpha))
	end

	surface.DrawRect(5, 5, self:GetWide() - 10, self:GetTall() - 10)
end

function CLASS:IsMouseInWindow()
	local x, y = self:CursorPos()

	return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()
end

function CLASS:OnMousePressed(mc)
	if self:IsFull() or self:PlayerIsClass(LocalPlayer()) or LocalPlayer():GetNWBool("Upgraded") then
		return
	end

	if mc == MOUSE_RIGHT then
		return
	end

	RunConsoleCommand("zm_setclass", string.lower(self.ClassName))

	surface.PlaySound(self.Class.PowerGotSound)
end

function CLASS:UpdatePlayers()
	for _, ply in pairs(player.GetAll()) do
		if self:HasPlayer(ply) then
			if not self:PlayerIsClass(ply) then
				self:ClearPlayer(ply)
			end
		else
			if self:PlayerIsClass(ply) then
				self:SetPlayer(ply)
			end
		end
	end
end

function CLASS:SetPlayer(ply)
	if not IsValid(self.PlayerOne) then
		self.PlayerOne = ply

		self.PlayerOneAvatar:SetPlayer(ply)
		self.PlayerOneAvatar:InvalidateLayout()

		self.PlayerOneSilhouette:SetPlayer(ply)
		self.PlayerOneSilhouette:InvalidateLayout()
	elseif not IsValid(self.PlayerTwo) then
		self.PlayerTwo = ply

		self.PlayerTwoAvatar:SetPlayer(ply)
		self.PlayerTwoAvatar:InvalidateLayout()

		self.PlayerTwoSilhouette:SetPlayer(ply)
		self.PlayerTwoSilhouette:InvalidateLayout()
	end
end

function CLASS:ClearPlayer(ply)
	if IsValid(self.PlayerOne) and self.PlayerOne == ply then
		self.PlayerOne = nil

		self.PlayerOneAvatar:ClearPlayer()
		self.PlayerOneAvatar:InvalidateLayout()

		self.PlayerOneSilhouette:ClearPlayer()
		self.PlayerOneSilhouette:InvalidateLayout()
	end

	if IsValid(self.PlayerTwo) and self.PlayerTwo == ply then
		self.PlayerTwo = nil

		self.PlayerTwoAvatar:ClearPlayer()
		self.PlayerTwoAvatar:InvalidateLayout()

		self.PlayerTwoSilhouette:ClearPlayer()
		self.PlayerTwoSilhouette:InvalidateLayout()
	end

	self:HandleSwap()
end

function CLASS:HandleSwap()
	if not IsValid(self.PlayerOne) and IsValid(self.PlayerTwo) then
		-- Remove
		local ply = self.PlayerTwo

		self.PlayerTwo = nil

		self.PlayerTwoAvatar:ClearPlayer()
		self.PlayerTwoAvatar:InvalidateLayout()

		self.PlayerTwoSilhouette:ClearPlayer()
		self.PlayerTwoSilhouette:InvalidateLayout()

		-- Set
		self.PlayerOne = ply

		self.PlayerOneAvatar:SetPlayer(ply)
		self.PlayerOneAvatar:InvalidateLayout()

		self.PlayerOneSilhouette:SetPlayer(ply)
		self.PlayerOneSilhouette:InvalidateLayout()
	end
end

function CLASS:HasPlayer(ply)
	return (IsValid(self.PlayerOne) and self.PlayerOne == ply) or (IsValid(self.PlayerTwo) and self.PlayerTwo == ply)
end
vgui.Register("ClassPanel", CLASS)

PLAYERAVATAR = {}
PLAYERAVATAR.Padding = 10
PLAYERAVATAR.AvatarSize = 32

function PLAYERAVATAR:Init()
	self:MouseCapture(false)
	self:SetMouseInputEnabled(false)

	-- PLAYER AVATAR
	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:SetSize(self.AvatarSize, self.AvatarSize)
	self.Avatar:SetVisible(false)

	-- PLAYER NAME
	self.PlayerName = Label("", self)
	self.PlayerName:SetFont("ClassSelectHeader")
	self.PlayerName:SetTextColor(Color(255, 255, 255, 255))

	self.PlayerNameShadow = Label("", self)
	self.PlayerNameShadow:SetFont("ClassSelectHeader")
	self.PlayerNameShadow:SetTextColor(Color(0, 0, 0, 255))
	self.PlayerNameShadow:SetZPos(-1)
end

function PLAYERAVATAR:PerformLayout()
	-- PLAYER NAME
	self.PlayerName:SizeToContents()
	self.PlayerName:CenterVertical()
	self.PlayerName:AlignLeft(self.Avatar:GetWide() + (self.Padding / 2))

	self.PlayerNameShadow:SizeToContents()
	self.PlayerNameShadow.x = self.PlayerName.x + 2
	self.PlayerNameShadow.y = self.PlayerName.y + 2

	self:SetSize(self.Avatar:GetWide() + self.PlayerName:GetWide() + self.Padding, self.Avatar:GetTall())
end

function PLAYERAVATAR:SetPlayer(ply)
	self.Player = ply

	if ply:IsHidden() then
		self.Avatar:SetPlayer(nil)
	else
		self.Avatar:SetPlayer(ply, self.AvatarSize)
	end

	self.Avatar:SetVisible(true)

	self.PlayerName:SetText(ply:GetName())
	self.PlayerNameShadow:SetText(ply:GetName())
end

function PLAYERAVATAR:SetColor(color)
	self.PlayerName:SetTextColor(color)
end

function PLAYERAVATAR:ClearPlayer()
	self.Avatar:SetVisible(false)

	self.PlayerName:SetText("")
	self.PlayerNameShadow:SetText("")
	self.Player = nil
end

function PLAYERAVATAR:Think()
	if self.Player and self.Player:GetNWBool("Upgraded") then
		self:SetColor(Color(0, 255, 0, 255))
	else
		self:SetColor(Color(255, 255, 255, 255))
	end
end

function PLAYERAVATAR:Paint(w, h)
	surface.SetDrawColor(Color(80, 80, 80, 80))
	surface.DrawRect(0, 0, self.Avatar:GetWide(), self.Avatar:GetTall())
end
vgui.Register("PlayerAvatarName", PLAYERAVATAR)

PLAYERMODEL = {}

function PLAYERMODEL:Init()
	self.MPanel = vgui.Create("DModelPanelZM", self)
	self.MPanel:SetVisible(false)
	self.MPanel:SetAnimated(true)
	self.MPanel.m_fAnimSpeed = 4

	self:MouseCapture(false)
	self:SetMouseInputEnabled(false)

	self.MPanel:MouseCapture(false)
	self.MPanel:SetMouseInputEnabled(false)
end

function PLAYERMODEL:SetupLighting(color)
	self.MPanel:SetupLighting(color)
end

function PLAYERMODEL:Think()
	self.MPanel:MouseCapture(false)
	self.MPanel:SetMouseInputEnabled(false)

	if IsValid(self.Player) then
		local model = self.Player:GetTranslatedModel()

		self.MPanel:SetVisible(true)
		self.MPanel:SetModel(model, 1, GTowerModels.GetScale(model))
		self.MPanel:SetSize(self:GetParent():GetWide(), self:GetParent():GetWide())
		self.MPanel:SetPos(0, 0)
		self.MPanel:SetLookAt(self.LookAt)
		self.MPanel:SetCamPos(self.CamPos)
	else
		self.MPanel:SetVisible(false)
	end
end

function PLAYERMODEL:Paint(w, h)
	-- surface.SetDrawColor( Color( 120, 120, 120, 80 ) )
	-- surface.DrawRect( 0, 0, self.MPanel:GetWide(), self.MPanel:GetTall() )
end

function PLAYERMODEL:SetPlayer(ply)
	self.Player = ply
end

function PLAYERMODEL:ClearPlayer()
	self.Player = nil
end
vgui.Register("PlayerModelSilhouette", PLAYERMODEL)

CONFIRM = {}

function CONFIRM:Init()
	self:SetCursor("hand")
	self:SetSize(300, 50)

	self.Title = Label("READY", self)
	self.Title:SetFont("ClassSelectName")
	self.Title:SetTextColor(Color(255, 255, 255, 255))
end

function CONFIRM:Think()
	if LocalPlayer():GetNWBool("Upgraded") then
		self:SetCursor("default")
	end
end

function CONFIRM:PerformLayout()
	self.Title:SizeToContents()
	self.Title:Center()
end

function CONFIRM:Paint(w, h)
	-- BG
	surface.SetDrawColor(Color(50, 50, 50, 150))
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())

	-- Border
	if self:IsMouseInWindow() or LocalPlayer():GetNWBool("Upgraded") then
		surface.SetDrawColor(Color(255, 180, 35, SinBetween(0, 150, CurTime() * 10)))

		if LocalPlayer():GetNWBool("Upgraded") then
			surface.SetDrawColor(Color(255, 180, 35, 150))
		end

		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end

	-- Inner BG
	surface.SetDrawColor(Color(50, 50, 50, 150))

	if self:IsMouseInWindow() and not LocalPlayer():GetNWBool("Upgraded") then
		surface.SetDrawColor(Color(80, 80, 80, 150))
	end

	surface.DrawRect(5, 5, self:GetWide() - 10, self:GetTall() - 10)
end

function CONFIRM:IsMouseInWindow()
	local x, y = self:CursorPos()

	return x >= 0 and y >= 0 and x <= self:GetWide() and y <= self:GetTall()
end

function CONFIRM:OnMousePressed(mc)
	if mc == MOUSE_RIGHT then
		return
	end

	if LocalPlayer():GetNWBool("Upgraded") then
		LocalPlayer():SetNWBool("Upgraded", false) --??? -zak
		RunConsoleCommand("zm_upgradeunfinish")
		return
	end

	RunConsoleCommand("zm_upgradefinish")
	RunConsoleCommand("-attack")

	LocalPlayer():SetNWBool("Upgraded", true) --??? -zak

	surface.PlaySound("GModTower/zom/powerups/powerup_mercenary.wav") -- todo
end
vgui.Register("ConfirmButton", CONFIRM)

CURSORDRAW = {}
function CURSORDRAW:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetZPos(100)
	self:SetMouseInputEnabled(false)
end

function CURSORDRAW:Paint(w, h)
	GAMEMODE:PaintCursors()
	--surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
	--surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
end
vgui.Register("CursorDraw", CURSORDRAW)
function Create()
	if ValidPanel(Gui) then
		return
	end
	Gui = vgui.Create("ClassSelectScreen")
	GuiDraw = vgui.Create("CursorDraw")
end

function Open()
	if not ValidPanel(Gui) then
		Create()
	end

	Gui:InvalidateLayout()
	Gui:SetVisible(true)

	GuiDraw:SetVisible(true)

	LocalPlayer():SetNWBool("Upgraded", false) --??? -zak

	if GTowerChat and GTowerChat.Chat then
		GTowerChat.Chat:SetSize(400, 125)
		GTowerChat.Chat:SetPos(ScrW() - GTowerChat.Chat:GetWide() - 20, ScrH() - GTowerChat.Chat:GetTall() - 20)
		GTowerChat.Chat:InvalidateLayout()
	end
end

function Close()
	if ValidPanel(Gui) then
		Gui:SetVisible(false)
	end

	if ValidPanel(GuiDraw) then
		GuiDraw:SetVisible(false)
	end

	if GTowerChat and GTowerChat.Chat then
		GTowerChat.Chat:SetSize(cookie.GetNumber("gui_chatbox_width", 440), 235)
		GTowerChat.Chat:SetPos(GTowerChat.XOffset, ScrH() - GTowerChat.YOffset)
		GTowerChat.Chat:InvalidateLayout()
	end
end

function ClassSelectionWindow(hide)
	if hide == false then
		ClassSelection.Close()
	elseif hide == true then
		ClassSelection.Open()
	end
end

usermessage.Hook(
	"ZMClassSelector",
	function(um)
		local hide = um:ReadBool()

		ClassSelectionWindow(hide)
	end
)

concommand.Add(
	"zm_openclass",
	function(ply)
		if not ply:IsAdmin() then
			return
		end

		ClassSelection.Open()
	end
)

concommand.Add(
	"zm_closeclass",
	function(ply)
		ClassSelection.Close()
	end
)
