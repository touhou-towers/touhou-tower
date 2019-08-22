
include('shared.lua')

surface.CreateFont( "GTowerNPC", { font = "Oswald", size = 100, weight = 600 } )

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Draw()
	self:DrawModel()
	self:DrawTranslucent()
	if self.PrintName == "Particle Store" then
		self:DrawParticles()
	end
end

function ENT:DrawTranslucent()
	local NPCNAME = self.PrintName

	if NPCNAME == "Basical's Goods" or NPCNAME == "Particle Store" or NPCNAME == "Homeless Mac" then
		self.NewStore = true
	end

	local offset = Vector( 0, 0, 90 )
	local TextColor = Color(255,255,255,255)

	if NPCNAME == "Rabbit Merchant" then
		offset = Vector( 0, 0, 125 )
	end
	
	if NPCNAME == "Toys and Gizmos Store" then
		offset = Vector( 0, 0, 100 )
	end

	if NPCNAME == "Homeless Mac" then
		offset = Vector( 0, 0, 75 )
	end

	if NPCNAME == "Nature Store" then
		NPCNAME = ""
	end

	if NPCNAME == "Money Giver" then
		TextColor = Color(255,215,0)
	end

	if NPCNAME == "Hat Store" then
		offset = Vector( 0, 0, 100 )
	end

	if ( NPCNAME == "PVP Battle Store" || NPCNAME == "Ball Race Store" ) then
		offset = Vector( 0, 0, 110 )
	end

	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + offset + ang:Up() * ( math.sin( CurTime() ) * 4 )

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
	if self:GetNWBool("Sale") then
		surface.SetDrawColor(Color(255,255,255))
		surface.SetMaterial( Material("gmod_tower/lobby/sale" ) )
		local IconPos = surface.GetTextSize(NPCNAME) / 1.9
		surface.DrawTexturedRectRotated( 0, 50, 400, 200, math.sin(CurTime()*4)*4 )

		draw.DrawText( NPCNAME, "GTowerNPC", 2, -102, Color( 0, 0, 0, 225 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.DrawText( NPCNAME, "GTowerNPC", 0, -100, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	else
		draw.DrawText( NPCNAME, "GTowerNPC", 2, 2, Color( 0, 0, 0, 225 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.DrawText( NPCNAME, "GTowerNPC", 0, 0, TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

		if self.NewStore then
		surface.SetDrawColor(Color(255,255,255))
		surface.SetMaterial( Material("gmod_tower/icons/new_large.png" ) )
		local IconPos = surface.GetTextSize(NPCNAME) / 1.9
		surface.DrawTexturedRect( IconPos, 0, 75, 75 )
		end

	cam.End3D2D()
end

function ENT:DrawParticles()

	if not self.Emitter then
		self.Emitter = ParticleEmitter( self:GetPos() )
	end

	if !self.NextParticle then
		--return
	end

	if self.Emitter then

		local pos = self:GetPos() + ( self:GetForward() * 0 )

		//local angle = Angle( SinBetween( -240, -190, CurTime() * 2 ), 0, 0 )
		//local angle = Angle( 0, SinBetween( -240, -120, CurTime() * 2 ), 0 )
		//local angle = Angle( 0, SinBetween( -360, 360, CurTime() * 2 ), 0 )
		local angle = Angle( 0, 0, SinBetween( -360, 360, CurTime() * 2 ) )
		local pitch = angle.p
		local yaw = angle.y

		for i=1, 10 do

			//local flare = Vector( 0, math.random( -10, 10 ), 0 )
			//local flare = Vector( 0, 0, math.random( -25, 25 ) )
			local size = 32
			local flare = Vector( CosBetween( -size, size, CurTime() * 2 ), SinBetween( -size, size, CurTime() * 2 ), size )
			local particle = self.Emitter:Add( "sprites/powerup_effects", pos + flare )

			if particle then

				//particle:SetVelocity( ( angle:Forward() * 50 ) )
				particle:SetVelocity( ( angle:Up() * 150 ) )
				//particle:SetDieTime( math.Rand( 2, 6 ) )
				particle:SetDieTime( math.Rand( .25, .75 ) )
				particle:SetStartAlpha( 150 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.random( 8, 16 ) )
				particle:SetEndSize( 0 )
				particle:SetGravity( ( Vector(math.sin(CurTime()*8)*32,math.sin(CurTime()*6)*32,math.sin(CurTime()*4)*16) * 50 * -1 ) /*- ( flare / 3 )*/ )
				particle:SetGravity( ( angle:Up() * 25 * -1 ) /* - ( flare / 3 ) */ )

				local color = colorutil.Smooth( .25 )
				particle:SetColor( color.r, color.g, color.b, 255 )

				particle:SetCollide( true )
				//particle:SetBounce( 1 )

			end
		end

		self.NextParticle = CurTime() + .001

	end

end


hook.Add("OnEntityCreated", "NPCSpawn", function(ent)
	if IsValid(ent) && ent:IsNPC() then
		GTowerNPCSharedInit(ent)
	end
end)
