AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

function SWEP:BulletCallback( att, tr, dmginfo )

	if tr.MatType == MAT_GLASS then return end

	if IsValid(tr.Entity) && tr.Entity:IsPlayer() then

		if !IsFirstTimePredicted() then return end
	
		if self.HitEffect then
			local hfx = EffectData()
				hfx:SetEntity( tr.Entity )
			util.Effect( eff, hfx, true, true )
		end

	end

	if tr.MatType != MAT_FLESH then

		if self.TraceHit then
			local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetNormal( tr.HitNormal )
			util.Effect( self.TraceHit, effectdata )
		end

		if self.TraceDecal then
			util.Decal( self.HitDecal, tr.HitPos + tr.HitNormal, tr.HitPos + tr.HitNormal * -20 + VectorRand() * 15 )
		end

	end

	if self.Ricochet then

		self:RicochetCallback( att, tr, dmginfo, 0 )

	end
	
end

function SWEP:RicochetCallback( att, tr, dmginfo, num )

	if tr.HitNonWorld || tr.HitSky then return end

	local fx = EffectData()
		fx:SetOrigin( tr.HitPos )
		fx:SetNormal( tr.HitNormal )
	util.Effect( "StunstickImpact", fx, true )
	
	if self.TraceHit then
		local effectdata = EffectData()
			effectdata:SetOrigin( tr.HitPos )
			effectdata:SetNormal( tr.HitNormal )
		util.Effect( self.TraceHit, effectdata )
	end

	if self.TraceDecal then
		util.Decal( self.HitDecal, tr.HitPos + tr.HitNormal, tr.HitPos + tr.HitNormal * -20 + VectorRand() * 15 )
	end

	sound.Play( "GModTower/virus/weapons/Ricochets/ricochet" .. math.random( 1, 4 ) .. ".wav", tr.HitPos )

	if num > self.Ricochet then return end

	local DotProduct = tr.HitNormal:Dot( tr.Normal * -1 )

	local bullet = {}

	bullet.Num			= 1
	bullet.Src			= tr.HitPos
	bullet.Dir			= ( 2 * tr.HitNormal * DotProduct ) + tr.Normal
	bullet.Spread 		= Vector( 0, 0, 0 )
	bullet.Tracer		= 1

	if self.Trace then
		bullet.TracerName 	= self.Trace
	end

	bullet.Force		= 1
	bullet.Damage		= 30 * ( num * 5 + 1 )
	bullet.AmmoType		= self.Primary.Ammo
	bullet.Callback		= function( a, b, c )
		if IsValid(self) && self.RicochetCallback then
			self:RicochetCallback( a, b, c, num + 1 )
		end
	end
	
	if self.Owner then
		timer.Simple( 0.03 * num, function()
			self.Owner:FireBullets(bullet,false)
		end )
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