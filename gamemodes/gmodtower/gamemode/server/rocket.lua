
local ValidExplodeRockets = {}

local function MakeRocketDoDamage( ent )
	
	if ent:GetClass() != "rpg_missile" then
		return
	end
	
	for k, v in ipairs( ValidExplodeRockets ) do
		
		if !IsValid( v ) then
			table.remove( ValidExplodeRockets, k )
		
		elseif ent == v then
			
			table.remove( ValidExplodeRockets, k )
			
			util.BlastDamage( ent, ent.EntityOwner, ent:GetPos(), ent.Damage * 2, ent.Damage )
			
		end
		
	end
	
	if #ValidExplodeRockets == 0 then
		hook.Remove("EntityRemoved", "ExplodeRocket" )
	end	
	
end

concommand.Add("gmt_firerocket", function( ply, cmd, args )
	
	if !ply:IsAdmin() then
		return
	end
	
	local aim = ply:GetAimVector()
	local aimangle = aim:Angle()
	local pos = ply:GetShootPos()  +
		aimangle:Forward() * 12 +
		aimangle:Right()   * 6  +
		aimangle:Up()      * -3
	
	for _, v in ipairs( ents.FindInBox( pos - Vector(4,4,4), pos + Vector(4,4,4) ) ) do
		if v:GetClass() == "rpg_missile" then
			return
		end
	end
	
	local missile = ents.Create("rpg_missile")
	missile:SetOwner( ply )
	missile:SetPos( pos	)
	missile:SetAngles( aimangle )
	missile:SetVelocity( aim * 256 )
	missile.EntityOwner = ply
	
	missile:Spawn()
	missile:DrawShadow( false )
	
	missile.Damage = math.Clamp(tonumber( args[1] ) or 50, 1, 5000)  

	table.insert( ValidExplodeRockets, missile )
	hook.Add("EntityRemoved", "ExplodeRocket", MakeRocketDoDamage )

end )