hook.Add(
	"InitPostEntity",
	"GolfAddCameraLocations",
	function()
		-- Circle around the hole
		camsystem.AddFunctionLocation(
			"Preview",
			function(ply, origin, ang, fov)
				local ang = Angle(50, CurTime() * 5, 0)

				if GAMEMODE.CurrentHolePos then
					origin = GAMEMODE.CurrentHolePos
				end

				return {
					origin = origin + ang:Forward() * -300,
					angles = ang,
					fov = fov
				}
			end
		)

		camsystem.AddFunctionLocation(
			"Pocket",
			function(ply, origin, ang, fov)
				local ang = Angle(50, CurTime() * 5, 0)
				local origin = ply:GetPos()

				local ball = ply:GetGolfBall()

				if IsValid(ball) then
					origin = ball:GetPos()

					if ball.Launching then
						origin = origin + Vector(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
					end
				end

				return {
					origin = origin + ang:Forward() * -300,
					angles = ang,
					fov = fov
				}
			end
		)
	end
)

CamUp = 150
CamUpWant = 150
CamRot = 0

local function CalcViewPlaying(ply, origin, angles, fov)
	local ball = ply:GetGolfBall()

	if IsValid(ply.Spectating) and LocalPlayer():IsPocketed() then
		ball = ply.Spectating:GetGolfBall()
	end

	if IsValid(ball) then
		local center = ball:GetPos() + Vector(0, 0, CamUp * 1.5)
		local dist = CamUp

		-- Trace for walls
		local tr =
			util.TraceLine(
			{
				start = center,
				endpos = center + (angles:Forward() * -dist * 0.95),
				filter = ball
			}
		)

		if (tr.HitWorld or tr.HitNoDraw) and tr.Fraction < 1 then
			dist = dist * (tr.Fraction * .85)
		end

		-- Final pos
		local Pos = center + (angles:Forward() * -dist * 0.95)

		-- Ease
		if not LastPos then
			LastPos = Pos
		end

		local ease = 150

		if ply:CanPutt() and not IsRightClickHeld then
			ease = 50
		end

		LastPos.x = ApproachSupport2(LastPos.x, Pos.x, ease)
		LastPos.y = ApproachSupport2(LastPos.y, Pos.y, ease)
		LastPos.z = ApproachSupport2(LastPos.z, Pos.z, ease)

		return {
			origin = LastPos,
			angles = Angle(math.Clamp(angles.p + (CamUp / 4), 35, 150), angles.y, 0),
			fov = 90
		}
	end

	return {
		origin = origin,
		angles = angles,
		fov = fov
	}
end

function GM:InitPostEntity()
	camsystem.AddFunctionLocation("Playing", CalcViewPlaying)
end

function GM:OnReloaded()
	camsystem.AddFunctionLocation("Playing", CalcViewPlaying)
end

function GM:AdjustMouseSensitivity()
	if camsystem.IsTweening(LocalPlayer()) then
		return 0.001 -- hack
	end

	if not LocalPlayer():CanPutt() then
		return .8
	end
end

function GM:CreateMove(cmd)
	local ball = LocalPlayer():GetGolfBall()

	if IsValid(ball) then
		if not LocalPlayer():CanPutt() or IsRightClickHeld then
			CamRot = cmd:GetViewAngles().y
		end

		cmd:SetViewAngles(Angle(0, CamRot, 0))

		return true
	end
end

function ZoomCam(ply, bind, pressed)
	local amt = 5

	if bind == "invnext" then
		CamUpWant = CamUpWant + amt
	elseif bind == "invprev" then
		CamUpWant = CamUpWant - amt
	end
end

function ZoomThink()
	CamUpWant = math.Clamp(CamUpWant, 10, 250)
	CamUp = math.Approach(CamUp, CamUpWant, 150 * FrameTime())
end

hook.Add("PlayerBindPress", "ZoomCam", ZoomCam)
hook.Add("Think", "ZoomThink", ZoomThink)
