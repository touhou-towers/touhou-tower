-- misc things that shouldn't really be touched much

hook.Add(
	"AllowSpecialAdmin",
	"DisallowGodmode",
	function()
		return false
	end
)

-- no anti-tranquility on gamemodes
hook.Add(
	"AntiTranqEnable",
	"GamemodeAntiTranq",
	function()
		return false
	end
)

function GM:PlayerSwitchFlashlight(ply, on)
	if ply:IsAdmin() then
		return
	end

	if on == true then
		return false
	end
end
function GM:GTCanNoClip(ply)
	return ply:IsAdmin()
end

function GM:CanPlayerSuicide(ply)
	return ply:IsAdmin()
end

function GM:PlayerDeathSound()
	return true
end

function GM:EntityTakeDamage(target, dmginfo)
	if target:IsPlayer() then
		if dmginfo:IsFallDamage() then
			dmginfo:ScaleDamage(0)
		elseif dmginfo:IsExplosionDamage() and not target.IsVirus then
			dmginfo:ScaleDamage(0)
		else
			-- players now take 30% damage (from viruses when they get guns)
			dmginfo:ScaleDamage(0.2)
		end
	end
end
