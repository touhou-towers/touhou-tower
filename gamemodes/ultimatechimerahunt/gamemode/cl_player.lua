function GM:ShouldDrawLocalPlayer()
	
	if ( LocalPlayer().IsChimera && LocalPlayer():Alive() ) || LocalPlayer().IsTaunting || LocalPlayer().IsScared then
		return true
	end
	
	return false
	
end

function GM:CreateMove( cmd )

	if cmd:KeyDown( IN_ATTACK ) && !cmd:KeyDown( IN_USE ) && !LocalPlayer().HasSaturn then
		cmd:SetButtons( cmd:GetButtons() + IN_USE ) // how do i bitwise?
	end

end

function GM:PlayerBindPress( ply, bind, pressed ) 

	if bind == "+duck" && !ply:IsPig() then
		return true
	end

	return false

end

local function TauntAngSafeGuard( ply )

	if !ply.TauntAng then

		local ang = ply:EyeAngles()
		ang.p = 45
		ply.TauntAng = ang

	end

end

function GM:InputMouseApply( cmd, x, y, ang )

	local ply = LocalPlayer()
	
	if ply.IsGhost then return end

	if ply.IsTaunting || ply.IsRoaring then

		TauntAngSafeGuard( ply )

		local ang = ply.TauntAng
		
		local y = ( x * -GetConVar( "m_yaw" ):GetFloat() )
		
		ang.y = ang.y + y
		//ang = ang:GetAngle()

		ang.p = 16

		ply.TauntAng = ang

		return true

	end

	if ply.IsBiting || ( ply.IsChimera && !ply:Alive() ) then
		return true
	end
		
	return self.BaseClass:InputMouseApply( self, cmd, x, y, ang )

end

local function ThirdPersonCamera( ply, pos, ang, fov, dis )

	local view = {}
	
	local dir = ang:Forward()
	local tr = util.QuickTrace( pos, ( dir * -dis ), player.GetAll())
	
	local trpos = tr.HitPos
	
	if tr.Hit then
		trpos = ( trpos + ( dir * 20))
	end

	view.origin = trpos
	view.angles = ( ply:GetShootPos() - trpos ):Angle()
	view.fov = fov

	return view

end

function GM:CalcView( ply, pos, ang, fov )

	if ply.IsGhost then

		local num = 3
		local view = {}

		local bob = ( math.sin( CurTime() * num ) * 4 )

		view.origin = Vector( pos.x, pos.y, ( pos.z + bob ) )
		view.angles = ang
		view.fov = fov

		return view

	end
	
	local tang = ply.TauntAng

	if ply.IsTaunting || ply.IsRoaring then
		
		TauntAngSafeGuard( ply )
		tang = ply.TauntAng

		local view = {}
		
		local dir = tang:Forward()
		
		local tr = util.QuickTrace( pos, ( dir * -115 ), player.GetAll() )

		local trpos = tr.HitPos
		
		if ( tr.Hit ) then
			trpos = ( trpos + ( dir * 20 ) )
		end
		
		view.origin = trpos
		
		view.angles = ( ply:GetShootPos() - trpos):Angle()
		
		view.fov = fov

		return view
		
	else

		if tang && ply:Alive() then
			
			if !ply.IsChimera then
				tang.p = 0
			end

			tang.r = 0
			ply:SetEyeAngles( tang )
			
			ply.TauntAng = nil
			
		end
		
		if ply.IsScared then
			return ThirdPersonCamera( ply, pos, ang, fov, 100 )
		end
		
	end
	
	if ply.IsChimera then
		
		if ply:Alive() then
			return ThirdPersonCamera( ply, pos, ang, fov, 125 )
		else

			local followang = ang
		
			local rag = ply:GetRagdollEntity()
			if IsValid( rag ) then
				local pos = ( ply:GetPos() - ( ply:GetForward() * 800 ) )
				followang = ( ( rag:GetPos() - Vector( 0, 0, 100 ) ) - pos ):Angle()
			end
			
			local view = {}
			view.origin = ( pos + Vector( 0, 0, 25 ) )
			view.angles = followang
			view.fov = fov
			
			return view

		end
		
	end

	return { ply, pos, ang, fov }

end

local function RestartAnimation( um )

	local ply = um:ReadEntity()
	ply:AnimRestartMainSequence()

end
usermessage.Hook( "UC_RestartAnimation", RestartAnimation )