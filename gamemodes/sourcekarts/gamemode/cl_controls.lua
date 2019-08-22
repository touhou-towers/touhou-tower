
-----------------------------------------------------
miniMap = CreateClientConVar( "sk_minimap", 0, true, false )
local horn = CreateClientConVar( "sk_hornnum", 3, true, true )
local cameraMode = CreateClientConVar( "sk_camera", 1, true, false )

local FlingCharge = 0
local DisplayFling = false
local CanFling = false

function GM:PlayerBindPress( ply, bind, pressed )

	if string.sub( bind, 1, 4 ) == "slot" then
		return true
	end

	// Camera Modes
	if bind == "+menu_context" && pressed then
		local val = cameraMode:GetInt() + 1
		if val > 2 then val = 1 end
		RunConsoleCommand( "sk_camera", val )
		return true
	end

	// Reset
	if bind == "+reload" && pressed then
		RunConsoleCommand( "sk_reset" )
		return true
	end

	// Reset
	if bind == "gmod_undo" && pressed then
		local val = miniMap:GetInt()
		if val == 1 then val = 0 else val = 1 end
		RunConsoleCommand( "sk_minimap", val )
		return true
	end

	// Item use
	if bind == "+attack" && pressed then

		if input.IsMouseDown( MOUSE_RIGHT ) then
			RunConsoleCommand( "sk_useitem", -1 )
			return true
		end

		if !CanFling then
			RunConsoleCommand( "sk_useitem", 1 )
		end

	end

	// Jump
	if bind == "+jump" && pressed then
		RunConsoleCommand( "sk_jump" )

		local kart = ply:GetKart()
		if IsValid( kart ) then
			kart:Jump()
		end
	end

	// Horn
	if bind == "+use" && pressed then
		RunConsoleCommand( "sk_horn", horn:GetInt() )
		return true
	end

	// Rev up
	if self:GetState() == STATE_READY then

		if bind == "+forward" && pressed then

			RunConsoleCommand( "sk_rev" )

			local kart = ply:GetKart()
			if IsValid( kart ) then
				kart:Rev()
			end

		end
	end

end

hook.Add( "Think", "FlingThink", function()

	// Get item info
	local item = items.Get( LocalPlayer():GetItem() )
	local charge = 0

	if item && item.Fling && LocalPlayer():CanUseItem() then

		CanFling = true

		if input.IsMouseDown( MOUSE_LEFT ) then
			charge = 1
		end

	else
		DisplayFling = false
		CanFling = false
	end

	// Ease
	FlingCharge = math.Approach( FlingCharge, charge, RealFrameTime() * 1 )
	if FlingCharge > .25 then DisplayFling = true end

	WasLeftClickHeld = IsLeftClickHeld
	IsLeftClickHeld = input.IsMouseDown( MOUSE_LEFT )

	// Fling
	if CanFling && !input.IsMouseDown( MOUSE_RIGHT ) then

		if !IsLeftClickHeld && WasLeftClickHeld then
			RunConsoleCommand( "sk_useitem", 1, FlingCharge )
		end

	end

end )

hook.Add( "DrawKart", "DrawFling", function( self, model )

	if DisplayFling && FlingCharge > 0 then

		local att = model:GetAttachment( model:LookupAttachment( "back" ) )
		local ang = self:GetAngles()
		local pos = att.Pos + ang:Forward() * -10 + ang:Up() * 5

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )

		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .15 )
			local w, h = 15, 50
			local x, y = -7, 0
			draw.RectFillBorder( x, y, w, h, 3, math.Clamp( FlingCharge / 1, .1, 1 ), Color( 0, 0, 0 ), Color( 0, 255, 0 ), true )
			draw.RectFillBorder( x-1, y-1, w, h, 3, math.Clamp( FlingCharge / 1, .1, 1 ), Color( 255, 255, 255 ), Color( 0, 0, 0, 0 ), true )
		cam.End3D2D()

	end

end )