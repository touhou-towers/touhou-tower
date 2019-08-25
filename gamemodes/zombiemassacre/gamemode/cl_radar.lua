local OFFSCREEN = {}
OFFSCREEN.AvatarSize = 32
OFFSCREEN.Padding = 4
OFFSCREEN.ArrowSize = 12
OFFSCREEN.HealthSize = 5

function OFFSCREEN:Init()
	self:SetSize(self.AvatarSize + self.Padding, self.AvatarSize + self.Padding + self.HealthSize)
	self:SetZPos(1)
	self:SetMouseInputEnabled(false)

	self.Avatar = vgui.Create("AvatarImage", self)
	self.Avatar:SetSize(self.AvatarSize, self.AvatarSize)
	self.Avatar:SetZPos(-1)
end

function OFFSCREEN:SetPlayer(ply)
	self.Player = ply

	if ply:IsHidden() then
		self.Avatar:SetPlayer(nil)
	else
		self.Avatar:SetPlayer(ply, self.AvatarSize)
	end
end

function OFFSCREEN:Think()
	if not IsValid(self.Player) then
		self:Remove()
		return
	end

	local size = self.AvatarSize

	if not self.Player:Alive() then
		size = SinBetween(self.AvatarSize, self.AvatarSize * 1.5, RealTime() * 10)
	end

	self:SetSize(size + self.Padding, size + self.Padding)
	self.Avatar:SetSize(size, size)
end

function OFFSCREEN:PerformLayout()
	local half = self.Padding / 2
	local offsetX, offsetY = half, half

	self.Avatar:SetPos(offsetX, offsetY)
end

function OFFSCREEN:Paint(w, h)
	if not IsValid(self.Player) then
		self:Remove()
		return
	end

	-- BG
	surface.SetDrawColor(50, 50, 50, 255)

	if not self.Player:Alive() then
		surface.SetDrawColor(Color(SinBetween(50, 255, CurTime() * 20), 0, 0, 255))
	end

	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())

	-- Health BG
	surface.SetDrawColor(255, 50, 50, 150)
	surface.DrawRect(0, self.AvatarSize, self:GetWide(), self.HealthSize)

	-- Health bar
	local healthwide = (self.Player:Health() / 100) * self:GetWide()

	surface.SetDrawColor(50, 255, 50, 150)
	surface.DrawRect(0, self.AvatarSize, healthwide, self.HealthSize)
end
vgui.Register("ZMOffscreenPlayer", OFFSCREEN)

local function CreatePlayerBox(ply, pos)
	if ValidPanel(ply._RadarAvatar) then
		return
	end

	ply._RadarAvatar = vgui.Create("ZMOffscreenPlayer")
	ply._RadarAvatar:SetPos(pos.x, pos.y)
	ply._RadarAvatar:SetPlayer(ply)
end

local function IsOffScreen(pos)
	if pos.x > ScrW() or pos.x < 0 then
		return true
	end

	if pos.y > ScrH() or pos.y < 0 then
		return true
	end

	return false
end

function GM:DrawRadar()
	for _, ply in pairs(player.GetAll()) do
		if ply == LocalPlayer() then
			local pos = ply:GetPos():ToScreen()

			if IsOffScreen(pos) then
				CreatePlayerBox(ply, pos)
			end

			if ValidPanel(ply._RadarAvatar) then
				ply._RadarAvatar:SetVisible(IsOffScreen(pos) and GAMEMODE:IsPlaying())

				local size = ply._RadarAvatar:GetSize()
				local x, y = math.ScreenRadialClamp(pos.x, pos.y)

				ply._RadarAvatar:SetPos(x, y)

				if not ply:Alive() then
					draw.SimpleText(
						"HELP!",
						"ZomNorm",
						x + 20,
						y - 15,
						Color(SinBetween(50, 255, CurTime() * 20), 0, 0, 255),
						TEXT_ALIGN_CENTER,
						TEXT_ALIGN_CENTER,
						1
					)
				end
			end
		end
	end
end
