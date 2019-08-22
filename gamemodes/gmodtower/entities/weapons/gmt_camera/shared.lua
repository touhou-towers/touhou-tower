

-----------------------------------------------------
if SERVER then

	AddCSLuaFile( "shared.lua" )



	function SWEP:Deploy()

		self.Owner:DrawViewModel( false )

	end



	function SWEP:DoRotateThink() end

else

	SWEP.DrawAmmo			= false

	SWEP.DrawCrosshair		= false

end



SWEP.PrintName		= "Camera"

SWEP.Base			= "weapon_base"

SWEP.ViewModel		= "models/weapons/v_pistol.mdl"

SWEP.WorldModel		= "models/MaxOfS2D/camera.mdl"



SWEP.Primary.ClipSize		= -1

SWEP.Primary.DefaultClip	= -1

SWEP.Primary.Automatic		= false

SWEP.Primary.Ammo			= "none"



SWEP.Secondary.ClipSize		= -1

SWEP.Secondary.DefaultClip	= -1

SWEP.Secondary.Automatic	= true

SWEP.Secondary.Ammo			= "none"



SWEP.ShootSound				= "NPC_CScanner.TakePhoto"



SWEP.CameraZoom				= 80

SWEP.Roll					= 0

SWEP.WeaponSafe = true

function SWEP:Initialize()

	self:SetWeaponHoldType( "camera" )

end



function SWEP:Precache()

	util.PrecacheSound( self.ShootSound )

end



function SWEP:Reload()



	self.Owner:SetFOV( 80, 0 )

	self.CameraZoom = 80

	self.Roll = 0



end



function SWEP:DoShootEffect()



	self.Weapon:EmitSound( self.ShootSound	)

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )



	local vPos = self.Owner:GetShootPos()

	local vForward = self.Owner:GetAimVector()



	local trace = {}

		trace.start = vPos

		trace.endpos = vPos + vForward * 256

		trace.filter = self.Owner



	tr = util.TraceLine( trace )



	local effectdata = EffectData()

		effectdata:SetOrigin( tr.HitPos )

	util.Effect( "camera_flash", effectdata, true )



end



function SWEP:PrimaryAttack()



	self:DoShootEffect()



	if !CLIENT || !IsFirstTimePredicted() then return end



	self.Owner:ConCommand( "jpeg" )



end



function SWEP:SecondaryAttack() end



function SWEP:Think()



	local cmd = self.Owner:GetCurrentCommand()



	self.LastThink = self.LastThink or 0

	local fDelta = (CurTime() - self.LastThink)

	self.LastThink = CurTime()



	self:DoZoomThink( cmd, fDelta )

	self:DoRotateThink( cmd, fDelta )



end



function SWEP:DoZoomThink( cmd, fDelta )



	// Right held down

	if ( !self.Owner:KeyDown( IN_ATTACK2 ) ) then return end



	self.CameraZoom = math.Clamp( self.CameraZoom + cmd:GetMouseY() * 3 * fDelta, 5, 120 )



	self.Owner:SetFOV( self.CameraZoom, 0 )



end



function SWEP:CanSecondaryAttack()

	return true

end



if SERVER then return end



function SWEP:FreezeMovement()



	if ( self.m_fFreezeMovement ) then



		if ( self.m_fFreezeMovement > RealTime() ) then return true end



		self.m_fFreezeMovement = nil



	end



	// Don't aim if we're holding the right mouse button

	if ( self.Owner:KeyDown( IN_ATTACK2 ) || self.Owner:KeyReleased( IN_ATTACK2 ) ) then return true end

	return false



end



function SWEP:CalcView( ply, origin, angles, fov )



	if ( self.Roll != 0 ) then

		angles.Roll = self.Roll

	end



	if (!self.TrackEntity || !self.TrackEntity:IsValid()) then return origin, angles, fov end



	local AimPos = self.TrackEntity:GetPos()



	self.LastAngles = self.LastAngles or angles



	if ( self.TrackOffset ) then



		local Distance = AimPos:Distance( self.Owner:GetShootPos() )



		AimPos = AimPos + Vector(0,0,1) * self.TrackOffset.y * 256

		AimPos = AimPos + self.LastAngles:Right() * self.TrackOffset.x * 256



	end



	local AimNormal = AimPos - self.Owner:GetShootPos()

	AimNormal = AimNormal:GetNormal()



	angles = AimNormal:Angle() //LerpAngle( 0.1, self.LastAngles, AimNormal:Angle() )



	// Setting the eye angles here makes it so the player is actually aiming in this direction

	// Rather than just making their screen render in this direction.

	self.Owner:SetEyeAngles( Angle( angles.Pitch, angles.Yaw, 0 ) )



	self.LastAngles = angles



	if ( self.Roll != 0 ) then

		angles.Roll = self.Roll

	end



	return origin, angles, fov



end



function SWEP:DoRotateThink( cmd, fDelta )



	// Think isn't frame rate independant on the client.

	// It gets called more per frame in single player than multiplayer

	// So we will have to make it frame rate independant ourselves



	// Right held down

	if ( self.Owner:KeyDown( IN_ATTACK2 ) ) then



		self.Roll = self.Roll + cmd:GetMouseX() * 0.5 * fDelta



	end



	// Right released

	if ( self.Owner:KeyReleased( IN_ATTACK2 ) ) then



		// This stops the camera suddenly jumping when you release zoom

		self.m_fFreezeMovement = RealTime() + 0.1



	end



	// We are tracking an entity. Trace mouse movement for offsetting.

	if ( self.TrackEntity && self.TrackEntity != NULL && !self.Owner:KeyDown( IN_ATTACK2 ) ) then



		self.TrackOffset = self.TrackOffset or Vector(0,0,0)



		local cmd = self.Owner:GetCurrentCommand()

		self.TrackOffset.x = math.Clamp( self.TrackOffset.x + cmd:GetMouseX() * 0.005 * fDelta, -0.5, 0.5 )

		self.TrackOffset.y = math.Clamp( self.TrackOffset.y - cmd:GetMouseY() * 0.005 * fDelta, -0.5, 0.5 )



	end



	// If we're pressing use scan for an entity to track.

	if ( self.Owner:KeyDown( IN_USE ) && !self.TrackEntity ) then



		self.TrackEntity = self.Owner:GetEyeTrace().Entity

		if ( self.TrackEntity && !self.TrackEntity:IsValid() ) then



			self.TrackEntity = nil

			self.LastAngles = nil

			self.TrackOffset = nil



		end



	end



	// Released use. Stop tracking.

	if ( self.Owner:KeyReleased( IN_USE ) ) then



		self.TrackEntity = nil

		self.LastAngles = nil

		self.TrackOffset = nil



	end



	// Reload isn't called on the client, so fire it off here.

	if ( self.Owner:KeyPressed( IN_RELOAD ) ) then



		self:Reload()



	end



end



function SWEP:TranslateFOV( current_fov )



	return self.CameraZoom



end



function SWEP:AdjustMouseSensitivity()



	if ( self.Owner:KeyDown( IN_ATTACK2 )  ) then return 1 end



	return 1 * ( self.CameraZoom / 80 )



end



/*local ring = surface.GetTextureID("effects/select_ring")

function SWEP:DrawHUD()



	if !self.Owner:IsAdmin() then return end

	//local function TakePicture()

	//	render.CapturePixels()

	//end



	// Draw

	local function DrawScreenPixels( spacing, scale, offsetX, offsetY )



		render.CapturePixels()



		local spacing = spacing or 30

		local scale = scale or .3

		local size = spacing * scale



		for x=0, ScrW(), spacing do

			for y=0, ScrH(), spacing do



				local r, g, b = render.ReadPixel( x, y )



				surface.SetDrawColor( r, g, b, 255 )

				surface.DrawRect( offsetX + x*scale, offsetY + y*scale, size, size )



			end

		end



	end



	//DrawScreenPixels( 10, .5, ScrW() / 2 * .5, ScrH() / 2 * .5 )



	local DEBUG = false



	// Determines if they're properly in the frame

	local function IsInFrame( size, max, min )



		local x1, x2, y1, y2 = max.x, min.x, min.y, max.y



		local frame = size or ScreenScale( 50 )

		local frameWidth = ( ScrW() - ( frame * 2 ) )

		local frameHeight = ( ScrH() - ( frame * 2 ) )



		if DEBUG then

			surface.SetDrawColor( 255, 255, 255, 25 )

			//surface.DrawRect( frame, frame, ( ScrW() - ( frame * 2 ) ), ( ScrH() - ( frame * 2 ) ) )

		end



		local function inBounds( min, max, offset, size )

			return ( min > offset && max > offset && min < ( size + offset ) && max < ( size + offset ) )

		end



		return inBounds( min.x, max.x, frame, frameWidth ) && inBounds( min.y, max.y, frame, frameHeight )



	end



	// Returns if we can actually see them in the shot!

	local function InShot( ent, max, min )



		// Framing

		if !IsInFrame( ScreenScale( 50 ), max, min ) then

			return false

		end



		// Dist

		if LocalPlayer():GetPos():Distance( ent:GetPos() ) > 1024 then

			return false

		end



		// Trace

		local tr = util.TraceLine( {

			start = LocalPlayer():EyePos(),

			endpos = util.GetCenterPos( ent ),

			filter = LocalPlayer()

		} )



		if tr.HitWorld then

			return false

		end



		return true



	end



	// Draws a camera ranking

	local function ShowCameraRank( text, x, y, ent )



		local dist = LocalPlayer():GetPos():Distance( ent:GetPos() )

		local ringSize = 100 - ( dist * .1 )

		surface.SetDrawColor( 255, 255, 255, 255 )

		surface.SetTexture( ring )

		surface.DrawTexturedRect( x - ( ringSize / 2 ), y - ( ringSize / 2 ), ringSize, ringSize )



		draw.SimpleText( text, "GTowerHUDMainLarge", x + ( ringSize / 2 ) + 5, y - 20, Color( 255, 255, 255, 255 ) )



	end



	local function GetScrRender( ent )



		local min, max = ent:GetRenderBounds()

		local pos = ent:GetPos()

		min = pos + min

		max = pos + max



		local center = util.GetCenterPos( ent )

		if !center then return end

		local centerScr = center:ToScreen()



		local minScr = min:ToScreen()

		local maxScr = max:ToScreen()



		if DEBUG then

			surface.SetFont( "DebugFixed" )

			surface.DrawRect( minScr.x, maxScr.y, maxScr.x - minScr.x, minScr.y - maxScr.y )



			local function drawXY( x, y, name )

				surface.SetTextPos( x, y )

				surface.DrawText( name .. " X: " .. x .. " Y: " .. y )

			end



			drawXY( maxScr.x, maxScr.y, "max" )

			drawXY( minScr.x, minScr.y, "min" )

		end



		return minScr, maxScr, centerScr



	end



	for _, ply in pairs( ents.GetAll() ) do



		if ply == LocalPlayer() then continue end



		// Get screen render positions...

		local minScr, maxScr, centerScr = GetScrRender( ply )



		if !minScr || !maxScr || !centerScr then continue end



		// They're in the shot!

		if InShot( ply, maxScr, minScr ) then



			if IsInFrame( ScreenScale( 120 ), maxScr, minScr ) then

				ShowCameraRank( "EXCELLENT FRAMING", centerScr.x, centerScr.y, ply )

			elseif IsInFrame( ScreenScale( 80 ), maxScr, minScr ) then

				ShowCameraRank( "NICE FRAMING", centerScr.x, centerScr.y, ply )

			else

				ShowCameraRank( "OKAY FRAMING", centerScr.x, centerScr.y, ply )

			end



		end



	end



end*/
