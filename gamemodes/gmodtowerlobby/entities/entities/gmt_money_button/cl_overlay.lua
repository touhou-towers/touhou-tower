
-----------------------------------------------------

--Bring to localInfo to scope
local localInfo = localInfo_s

--More post-processing
local screenMaterial = CreateMaterial("renderScreenEffect_MoneyButton", "UnlitGeneric",
{
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$ignorez"] = 1,
	["$additive"] = 1,
})

local screenMaterial2 = CreateMaterial("renderScreenEffect_MoneyButton2", "UnlitGeneric",
{
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$ignorez"] = 1,
	["$additive"] = 0,
})

--Draws buttons to the screen effect rendertarget
local function UpdateRenderTargetFX()

	render.PushRenderTarget( render.GetScreenEffectTexture() )

		--Clear rendertarget
		render.Clear(0,0,0,255,true,true)

		--Don't write depth
		render.SetWriteDepthToDestAlpha( false )

		--Operate on all buttons that are doing things that require special FX
		for k,v in pairs( ents.FindByClass( "gmt_money_button" ) ) do
			if v:ShouldRenderFX() then
				local fraction = v:GetRenderingFraction()
				local fs = math.pow( fraction, 3 )

				--Shitty hack because Entity:DrawModel also calls the entity's Draw function >:(
				local tf = v.Draw
				v.Draw = function( self ) self:DrawModel() end

				render.SetColorModulation( fs, fs, fs )
				render.SuppressEngineLighting( true )
				render.ResetModelLighting( 1,1,1 )

				--Draw the model, then the progress bars
				v:DrawModel()
				v:DrawProgressBars()

				--Reset rendering state
				render.SuppressEngineLighting( false )
				render.SetColorModulation( 1,1,1 )

				--Restore entity's draw function
				v.Draw = tf
			end
		end

		--Blur the render target for a bloom effect
		render.BlurRenderTarget( render.GetScreenEffectTexture(), 1, 1, 4 )

	render.PopRenderTarget()

end

--Draws a textured rectangle over the screen, alignment fix added for rendertarget
local function DrawFullScreenRect( expand )

	local TEX_COORD_FIX = 0.016 --screen effect texture needs to be scaled down slightly

	expand = expand or 0
	surface.DrawTexturedRectUV( 0, 0, ScrW(), ScrH(), 
		-TEX_COORD_FIX + expand,
		-TEX_COORD_FIX + expand, 
		1.0 + TEX_COORD_FIX - expand, 
		1.0 + TEX_COORD_FIX - expand 
	)

end

--Draws screen effect rendertarget to the screen
local function DrawScreenOverlays()
	
	local localFrac = math.pow( localInfo.fraction, 6 )
	local localUse = IsValid( localInfo.usingButton )

	--Setup materials
	screenMaterial:SetTexture( "$basetexture", render.GetScreenEffectTexture() )
	screenMaterial2:SetTexture( "$basetexture", render.GetScreenEffectTexture() )

	--Start 2D rendering context
	cam.Start2D()

		if localUse then

			--If drawing locally fade in the opaque material (the void)
			surface.SetMaterial( screenMaterial2 )
			surface.SetDrawColor( 255,255,255,math.min( 255 * localFrac * 1.6, 255 ) )
			DrawFullScreenRect( localFrac/2.5 )

		end

		--Draw additive overlay of render target
		surface.SetMaterial( screenMaterial )
		surface.SetDrawColor( 255,255,255,255 )
		DrawFullScreenRect()

	cam.End2D()

end

--Optimization, Only do FX pass if buttons are being used here
local function ShouldDoFXPass()

	local buttonsInUse = false
	for k,v in pairs( ents.FindByClass( "gmt_money_button" ) ) do
		if v.ShouldRenderFX and v:ShouldRenderFX() then buttonsInUse = true end
	end
	if not buttonsInUse then return false end

	return true

end

--Draws screen overlays
local function DrawFX( drawingDepth, drawingSkybox )

	--Don't draw on the skybox ( saves a render pass we don't really need )
	if drawingSkybox or not ShouldDoFXPass() then return end

	UpdateRenderTargetFX()
	DrawScreenOverlays()

end
hook.Add("PostDrawTranslucentRenderables", "money_button_fx", DrawFX )