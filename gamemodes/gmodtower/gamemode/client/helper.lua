

ApproachSupport = function( cur, target, TarMulti )
	return SpecialApproach( cur , target, (math.abs( target - cur ) + 1) * (TarMulti or 1) * FrameTime() )
end
        
ApproachSupport2 = function ( cur, target, TarMulti )
	return math.Approach( cur , target, (math.abs( target - cur ) + 1) * (TarMulti or 1) * FrameTime() )
end

function SetDrawColor( color )
    surface.SetDrawColor( color.r, color.g, color.b, color.a )
end


function SpecialApproach(cur, target, inc)

    if (cur < target) then
		
		return math.Clamp( math.ceil( cur + inc ), cur, target )

	elseif (cur > target) then

		return math.Clamp( math.floor( cur - inc ) , target, cur )

	end

	return target

end


/*=======
	VOLUME SETTINGS
	========= */
do
	module("Volume", package.seeall )
	Var = "gmt_volume"
	ConVar = CreateClientConVar(Var, 75.0, true )

	function Get()
		return Volume.ConVar:GetFloat()
	end
	
	function GetNormal()
		return Get() / 100
	end

	function Set( val )
		RunConsoleCommand(Var , math.Clamp( val, 0, 100 ) )
	end
	
	function HookCall( CVar, previus, new )
		timer.Create("GMTChangeVolume", 0.5, 1, hook.Call, "Volume", GAMEMODE, tonumber( new ) )
	end
	
	cvars.AddChangeCallback(Var, HookCall)
end