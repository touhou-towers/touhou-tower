
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")



function SWEP:Think()
	if self.HideViewModel > 0 && CurTime() > self.HideViewModel then
		self.Owner:DrawViewModel( false )
		self.HideViewModel = 0
	end
end


function SWEP:BulletCallback(att, tr, dmginfo)
	if IsValid(tr.Entity) && tr.Entity:IsPlayer() then

		if self.HitSound && IsFirstTimePredicted() then
			if type(self.HitSound) == "table" then
				local snd = self.HitSound[math.random(1,#self.HitSound)]
				self:EmitSound( snd )
				tr.Entity:EmitSound( snd )
			else
				self:EmitSound( self.HitSound )
				tr.Entity:EmitSound( self.HitSound )
			end
		end

		if self.HitEffect && IsFirstTimePredicted() then
			local hfx = EffectData()
				hfx:SetEntity( tr.Entity )
			util.Effect( self.HitEffect, hfx, true, true )
		end

	end
	
	if self.Ricochet then
		self:RicochetCallback(att, tr, dmginfo, 0)
	end
end


function SWEP:ShootEnt( class, force )
	if CLIENT then return end

	local ent = ents.Create( class )
	if IsValid(ent) then

		ent:SetPos( self.Owner:GetShootPos() )
		ent:SetOwner( self.Owner )
		ent:SetPhysicsAttacker( self.Owner ) 
		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity( self.Owner:GetVelocity() + (self.Owner:GetAimVector() * force) )
		end

	end

end