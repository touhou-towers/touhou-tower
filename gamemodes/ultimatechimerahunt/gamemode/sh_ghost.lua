local meta = FindMetaTable("Player")
if not meta then
	Msg("ALERT! Could not hook Player Meta Table\n")
	return
end

function meta:SetGhost()
	self.IsGhost = true
	self:SetTeam(TEAM_GHOST)

	GAMEMODE:UpdateHull(self)
	self:UpdateSpeeds()

	local rnd = math.random(1, 6)
	if rnd == 1 or self:IsAdmin() then
		self.IsFancy = true
	else
		self.IsFancy = false
	end

	if GAMEMODE:GetGameState() ~= STATUS_WAITING then
		GAMEMODE:SetMusic(self, MUSIC_GHOST)
	end

	self:SetModel("models/UCH/mghost.mdl")

	if self.IsFancy then
		self:SetBodygroup(1, 1)
	else
		self:SetBodygroup(1, 0)
	end

	self:SetCollisionGroup(COLLISION_GROUP_NONE)
end

function meta:UnGhost()
	self.IsGhost = false
	self.IsFancy = false

	GAMEMODE:UpdateHull(self)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end

hook.Add(
	"Move",
	"UC_GhostMove",
	function(ply, move)
		if not ply.IsGhost then
			return
		end

		if not ply:IsOnGround() then
			local vel = ply:GetVelocity()

			if ply:KeyDown(IN_JUMP) then
				local num = math.Clamp(vel.z * -.18, 0, 75)
				num = num * .1

				vel.z = (vel.z + (32 + (5 * num)))
				vel.z = math.Clamp(vel.z, -250, 125)
			end

			if ply:KeyDown(IN_SPEED) and not ply:KeyDown(IN_JUMP) then
				vel.z = 5
			end

			move:SetVelocity(vel)
		end

		return move
	end
)

if SERVER then
	return
end

function DoGhostEffects()
	local ply = LocalPlayer()

	DrawColorModify {
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = (10 / 255) * 4,
		["$pp_colour_addb"] = (30 / 255) * 4,
		["$pp_colour_brightness"] = -.25,
		["$pp_colour_contrast"] = 1.5,
		["$pp_colour_colour"] = .32,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}

	DrawBloom(.75, 1, .65, .65, 3, 0, 0, (72 / 255), 1)
end
