AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:PowerUpOn( ply )
	ply.PowerUp = CurTime() + self.ActiveTime

	ply:SetColor( Color(232, 45, 74, 255) )
	PostEvent( ply, "puheadphones_on" )
	
	local edata = EffectData()
		edata:SetEntity( ply )
	util.Effect( "musicnotes", edata, true, true )

	ply:SetWalkSpeed( 350 )
	
	self:Heal( ply )
	timer.Simple( 0.8, function()
		ply:SetWalkSpeed( 450 )
	end )
end

function ENT:Heal( ply )
	if IsValid(ply) && ply.PowerUp > 0 then
		if ( ply:Health() < 100 && ply:Alive() ) then
			ply:SetHealth( ply:Health() + 1 )
		end
		timer.Simple( 0.15, function() if !IsValid(self) then return end self:Heal( ply ) end )
	end
end

function ENT:PowerUpOff( ply )
	ply.PowerUp = 0
	ply:SetColor( Color(255, 255, 255, 255) )
	PostEvent( ply, "puheadphones_off" )
end