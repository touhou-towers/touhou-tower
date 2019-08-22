AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

include("shared.lua")


function SWEP:Think()

	if self:Clip1() == 0 || self.Durability == 0 then
		self.Owner:StripWeapon( self:GetClass() )
	end
	
end

function SWEP:BulletCallback( att, tr, dmginfo )
	if IsValid(tr.Entity) && tr.Entity:IsNPC() then
		if !IsFirstTimePredicted() then return end

		local snd = self.Primary.HitSound
		local eff = self.Primary.HitEffect
	
		if snd then
			
			if type( snd ) == "table" then
				snd = snd[math.random( 1, #snd )]
			end

			self:EmitSound( snd )
			tr.Entity:EmitSound( snd )
		end

		if eff then
			local hfx = EffectData()
				hfx:SetEntity( tr.Entity )
			util.Effect( eff, hfx, true, true )
		end
	end
	
	if tr.MatType != MAT_METAL then
		 if tr.MatType != MAT_FLESH then

			local effectdata = EffectData()
				effectdata:SetOrigin( tr.HitPos )
				effectdata:SetNormal( tr.HitNormal )
				effectdata:SetScale( dmginfo:GetDamage() / 10000 )
			util.Effect( "hitsmoke", effectdata )

			if self.Primary.HitDecal then
				util.Decal( self.Primary.HitDecal, tr.HitPos + tr.HitNormal, tr.HitPos + tr.HitNormal * -20 + VectorRand() * 15 )
			end
		end
	end
end