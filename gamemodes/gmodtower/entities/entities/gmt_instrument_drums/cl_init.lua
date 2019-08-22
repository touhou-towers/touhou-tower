

-----------------------------------------------------
include("shared.lua")

ENT.MaterialDir	= ""

ENT.KeyMaterials = {
}

ENT.MainHUD = {
	Material = "gmod_tower/instruments/drumkit/drumkit",
	X = ( ScrW() / 2 ) - ( 313 / 2 ),
	Y = ScrH() - 316,
	TextureWidth = 512,
	TextureHeight = 256,
	Width = 313,
	Height = 195,
}

ENT.AdvMainHUD = {
}

ENT.BrowserHUD = {
}

ENT.SlightPitchChange = true

function ENT:ShiftMod()
	self:ToggleShiftMode()
end

function ENT:ToggleSheetMusic()
end

function ENT:SheetMusicForward()
end

function ENT:SheetMusicBack()
end


surface.CreateFont( "DrumsText", { font = "Bebas Neue", size = 80, weight = 500 } )
surface.CreateFont( "DrumsTextSmall", { font = "Bebas Neue", size = 60, weight = 500 } )

function ENT:DrawTranslucent()

	local ang = self:GetAngles()
	local pos = self:GetPos() + Vector( 0, 0, 60 ) + ang:Up() * ( math.sin( RealTime() ) * 1 )

	ang:RotateAroundAxis( ang:Up(), 270 )

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), .1 )

		draw.SimpleShadowText( "E", "DrumsTextSmall", -335, -50 )
		draw.SimpleShadowText( "HI-HAT", "DrumsText", -335, 0 )

		draw.SimpleShadowText( "G", "DrumsTextSmall", -235, 100 )
		draw.SimpleShadowText( "SNARE", "DrumsText", -235, 150 )

		draw.SimpleShadowText( "J", "DrumsTextSmall", 335, 100 )
		draw.SimpleShadowText( "TOM", "DrumsText", 335, 150 )

		draw.SimpleShadowText( "R", "DrumsTextSmall", -55, 0 )
		draw.SimpleShadowText( "TOM", "DrumsText", -55, 50 )

		draw.SimpleShadowText( "I", "DrumsTextSmall", 125, 0 )
		draw.SimpleShadowText( "TOM", "DrumsText", 125, 50 )

		draw.SimpleShadowText( "O", "DrumsTextSmall", 335, -100 )
		draw.SimpleShadowText( "CRASH", "DrumsText", 335, -50 )

		draw.SimpleShadowText( "SPACE", "DrumsTextSmall", 42.5, 350 )
		draw.SimpleShadowText( "KICK", "DrumsText", 42.5, 400 )


	cam.End3D2D()

end
