
-----------------------------------------------------
function EFFECT:Init(data)

	self.Weapon = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.Normal = data:GetNormal()
	self.ShellType = data:GetScale() or 0  //0 normal, 1 shotgun, 2 rifles

	if !( IsValid( self.Weapon )&& self.Weapon:IsWeapon() ) then return end

	if self.Weapon:IsCarriedByLocalPlayer() && GetViewEntity() == LocalPlayer() then 

		local view = LocalPlayer():GetViewModel()
		if !IsValid( view ) then return end

		self.Eject = view:GetAttachment( self.Attachment )
		if !self.Eject then return end

		self.Angle = self.Eject.Ang
		self.Forward = self.Angle:Forward()
		self.Pos = self.Eject.Pos

	else

		self.Eject = self.Weapon:GetAttachment( self.Attachment )
		if !self.Eject then return end
	
		self.Forward = self.Normal:Angle():Right()
		self.Angle = self.Forward:Angle()
		self.Pos = self.Eject.Pos - ( 0.5 * self.Weapon:BoundingRadius() ) * self.Eject.Ang:Forward()	
		
	end

	local add_vel = self.Weapon:GetOwner():GetVelocity()
	
	//Setup the type, yo.
	local shell_fx = "ShellEject"

	if self.ShellType == 1 then

		shell_fx = "ShotgunShellEject"

	elseif self.ShellType == 2 then

		shell_fx = "RifleShellEject"

	end

	//Eject the shell.
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Pos )
		effectdata:SetAngles( self.Angle )
		effectdata:SetEntity( self.Weapon )
	util.Effect( shell_fx, effectdata )

	//Smoke them.
	local emitter = ParticleEmitter( self.Pos )
	for i=1,2 do

		local particle = emitter:Add( "particle/particle_smokegrenade", self.Pos )
		particle:SetVelocity( math.Rand( 5, 9 ) * i * self.Forward + 1.02 * add_vel )
		particle:SetStartAlpha( math.Rand( 50, 60 ) )
		particle:SetStartSize( math.Rand( 1, 2 ) )

		if self.ShellType == 0 then

			particle:SetEndSize( math.Rand( 2, 3 ) * i )
			particle:SetDieTime( math.Rand( 0.33, 0.35 ) )

		elseif self.ShellType == 1 then

			particle:SetGravity( math.Rand( 5, 9 ) * VectorRand() + Vector( 0, 0, -10 ) )
			particle:SetEndSize( math.Rand( 3, 4 ) )
			particle:SetDieTime( math.Rand( 1, 1.2 ) )

		elseif self.ShellType == 2 then

			particle:SetEndSize( math.Rand( 3, 4 ) * i )
			particle:SetDieTime( math.Rand( 0.36, 0.38 ) )

		end

		particle:SetRoll( math.Rand( 180, 480 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( 245, 245, 245 )
		particle:SetLighting( true )
		particle:SetAirResistance( 40 )

	end

	//Rifles have a unique flash.
	if self.ShellType == 2 then

		if math.random( 1, 4 ) == 1 then
			for i=1,2 do
				local particle = emitter:Add( "effects/muzzleflash" .. math.random( 1, 4 ), self.Pos )
				particle:SetVelocity( 30 * i * self.Forward + add_vel )
				particle:SetGravity( add_vel )
				particle:SetDieTime( 0.1 )
				particle:SetStartAlpha( 150 )
				particle:SetStartSize( 0.5 * i )
				particle:SetEndSize( 3 * i )
				particle:SetRoll( math.Rand( 180, 480 ) )
				particle:SetRollDelta( math.Rand( -1, 1 ) )
				particle:SetColor( 255, 255, 255 )	
			end
		end

	end

	emitter:Finish()

end
function EFFECT:Think() return false end
function EFFECT:Render() end