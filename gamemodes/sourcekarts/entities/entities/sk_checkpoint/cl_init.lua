
-----------------------------------------------------
include( "shared.lua" )

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT
surface.CreateFont( "CheckpointFont", { font = "AlphaFridgeMagnets ", size = 48, weight = 500 } )

local devcvar = true

function ENT:Initialize()
	self:SetupDataTables()
end

function ENT:DrawTranslucent()

	if !DEBUG then return end
	if not devcvar:GetBool() then return end

	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + ang:Up() * SinBetween( -2, 2, RealTime() )

	if !LocalPlayer():InVehicle() then
		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
	else
		ang:RotateAroundAxis( ang:Right(), 180 )
	end

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .4 )
		draw.SimpleShadowText( "CHECKPOINT #" .. self:GetID(), "CheckpointFont", 0, 0, Color( 255, 255, 255, 255 ), Color( 0, 0, 0, 255 ) )
	cam.End3D2D()

end

function ENT:OnRemove()

end

function ENT:Think()


end

/*local traceDist = 10000
hook.Add( "PostDrawTranslucentRenderables", "CheckPointDebug", function()

	if not devcvar:GetBool() then return end

	for _, ent in pairs( ents.FindByClass( "sk_checkpoint") ) do

		local pos = ent:GetPos() + Vector( 0, 0, 64 )
		local angles = ent:GetAngles()

		local ltr = util.TraceLine( { start = pos, endpos = pos + angles:Right() * -traceDist, filter = self } )
		local rtr = util.TraceLine( { start = pos, endpos = pos + angles:Right() * traceDist, filter = self } )

		if ltr.HitPos && rtr.HitPos then
			for i=0, 5 do
				Debug3D.DrawLine( pos, ltr.HitPos, 10, Color( 255, 0, 0 ) )
				Debug3D.DrawLine( pos, rtr.HitPos, 10, Color( 255, 0, 0 ) )
				pos.z = pos.z + 16
				ltr.HitPos.z = ltr.HitPos.z + 16
				rtr.HitPos.z = rtr.HitPos.z + 16
			end

			--Debug3D.DrawSolidBox( pos, angles, ltr.HitPos + Vector( 0, 0, 500 ), rtr.HitPos, Color( 0, 255, 0 ) )
		end

	end

end )*/

/*hook.Add( "PostDrawTranslucentRenderables", "CheckPointDebug", function()

	if not devcvar:GetBool() then return end

	for _, ent in pairs( ents.FindByClass( "sk_checkpoint") ) do

		local pos = ent:GetPos()

		for _, kart in pairs( ents.FindByClass( "sk_kart" ) ) do

			if IsValid( kart ) then

				local poskart = kart:GetPos()

				if poskart:Distance( pos ) < ent.Distance then

					local color = Color( 255, 255, 255 )
					if ent:IsInFront( poskart ) then
						color = Color( 255, 0, 0 )
					end

					Debug3D.DrawLine( pos, poskart, 10, color )

				end

			end

		end

	end

end )*/
