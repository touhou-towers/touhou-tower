

-----------------------------------------------------
cl_gmt_allowblood = CreateClientConVar( "gmt_allowblood", 1, true, false )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )

	if !cl_gmt_allowblood:GetBool() then
		return
	end
	
	local Pos = data:GetOrigin()
	local Normal = data:GetNormal()
	
	// Make Bloodstream effects
	for i= 0, 8 do
		local effectdata = EffectData()
			effectdata:SetOrigin( Pos + Vector(0,0, i * 4 ) )
			effectdata:SetNormal( Normal )
		util.Effect( "bloodstream", effectdata )
	end
	
end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )

	// Die instantly
	return false
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	// Do nothing - this effect is only used to spawn the particles in Init
	
end




