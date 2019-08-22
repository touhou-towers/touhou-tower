
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.BlastRange	= 160

function ENT:PhysicsCollide(data, phys)
	local ent = data.HitEntity

	if ( ent == game.GetWorld() || ( IsValid( ent ) && !ent:IsPlayer() ) ) then

		local HitNormal = data.HitNormal

		local Trace = {}

		Trace.start = self.Entity:GetPos()
		Trace.endpos = Trace.start + (HitNormal * 50)
		Trace.filter = {self.Entity}

		local tr = util.TraceLine(Trace)

		if(tr.HitSky) then
			self.Entity:Remove()
			return
		end

		--timer.Simple(0, constraint.Weld, self.Entity, ent, 0, 0, 0, true)
		timer.Simple(0,function()
			constraint.Weld( self.Entity, ent, 0, 0, 0, true )
		end)

		self.Entity:SetNotSolid(true)

	elseif ( IsValid( ent ) && ent:IsPlayer() ) then

		if ( ent.StickyNades == nil ) then
			ent.StickyNades = {}
		end

		table.insert( ent.StickyNades, self.Entity )

		self.Entity:SetParent( ent )
	--self.Entity:SetCollisionGroup( GROUP_DEBRIS_TRIGGER )

	end
end

function NadePlayerDeath( victim, weapon, killer )

	if ( victim.StickyNades == nil ) then return end

	for _, v in ipairs( victim.StickyNades ) do
		SafeRemoveEntity( v )
	end

	victim.StickyNades = nil

end

hook.Add( "PlayerDeath", "StickyNadePlayerDeath", NadePlayerDeath )
