
DEBUG = DEBUG or {}


function DEBUG:HudEntities() 
	hook.Add("HUDPaint", "GtowerDebugPaint", function()
		local EntList = ents.GetAll()
	        
	    for _, v in pairs( EntList ) do
			local entitypos =  v:GetPos()
			local pos = entitypos:ToScreen()
			
			surface.SetTextColor( 255 , 255, 255 ,255 )
			surface.SetFont("small")
			surface.SetTextPos( pos.x, pos.y )
			surface.DrawText( v:GetClass() )
		end
	end)
end

function DEBUG:Box( vec1, vec2 )

	if GetConVarNumber("sv_cheats") == 1 then
		RunConsoleCommand(
			"box",
			vec1.x,
			vec1.y,
			vec1.z,
			vec2.x,
			vec2.y,
			vec2.z
		)
	end

end

function DEBUG:ShowRenderBoxes( ent )

	local entlist = ents.FindByClass( ent )
	
	if #entlist == 0 then
		Msg("No entities found with that class Name.\n")
		return
	end
	
	for _, v in pairs( entlist ) do
	
		local pos = v:GetPos()
		local min, max = v:GetRenderBounds()
		
		self:Box( v:LocalToWorld( min ), v:LocalToWorld( max ) )
		self:Box( pos - Vector(3,3,3), pos + Vector(3,3,3) )
		
	end

end