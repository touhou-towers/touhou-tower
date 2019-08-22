

-----------------------------------------------------
include('shared.lua')



ENT.RenderGroup = RENDERGROUP_TRANSLUCENT



surface.CreateFont( "HalloweenFont", {

	font      = "Bebas Neue",

	size      = 100,

	weight    = 700,

	antialias = true

})



local OffsetUp = 110

local OffsetRight = 32

local OffsetForward = 0

local BoardWidth = 416

local BoardHeight = 730



function ENT:Initialize()



	/*local min, max = self:GetRenderBounds()

	self:SetRenderBounds( min * 1.0, max * 1.0 )*/

	self:SetRenderBounds( Vector( 0, 75, 0 ), Vector( 0, -75, 125 ) )



end



function ENT:DrawTranslucent()



	--self:DrawModel()



	local ang = self:GetAngles()

	ang:RotateAroundAxis( ang:Up(), 90 )

	ang:RotateAroundAxis( ang:Forward(), 90 )



	local pos = self:GetPos() + ( self:GetUp() * OffsetUp ) + ( self:GetForward() * OffsetForward ) + ( self:GetRight() * OffsetRight )

	

	if ( LocalPlayer():EyePos() - pos ):DotProduct( ang:Up() ) < 0 then

		ang:RotateAroundAxis( ang:Right(), 180 )

		pos = pos + self:GetRight() * -( OffsetRight * 2 )

	end

	

	cam.Start3D2D( pos, ang, .15 )

		pcall( self.DrawMain )

	cam.End3D2D()

	

end





local VignetteMat = Material("gmod_tower/halloween/vignette")

local StaticMat = Material("gmod_tower/halloween/static")

local Message = Material("decals/messages/intothemadness")

local Message2 = Material("decals/messages/youwilldie")

local Blood1 = Material("decals/blood1")

local Blood2 = Material("decals/blood2")

local Blood3 = Material("decals/blood3")



function ENT:DrawMain()



	local w, h = BoardWidth, BoardHeight



	local white = SinBetween(30,50, CurTime()*20)

	surface.SetDrawColor( white, white, white )

	surface.DrawRect( 0, 0, w, h )



	surface.SetDrawColor(255,255,255,255)



	surface.SetMaterial(Blood1)

	surface.DrawTexturedRect(50,50,w-100, h-100)

	surface.SetMaterial(Blood2)

	surface.DrawTexturedRect(60,0,128,128)

	surface.SetMaterial(Blood3)

	surface.DrawTexturedRect(0,0,256, 256)



	surface.SetDrawColor(255,255,255,255)

	surface.SetMaterial(Message)

	surface.DrawTexturedRect(50,SinBetween(0,5, CurTime()*100),w-100, h-100)

	surface.DrawTexturedRect(SinBetween(45,55, CurTime()*100),0,w-100, h-100)





	surface.SetDrawColor(255,255,255,255)

	surface.SetMaterial(Message2)

	surface.DrawTexturedRect(math.random(0, w-128), math.random(0,h-128),128,128)





	surface.SetDrawColor(255,255,255,30)

	surface.SetMaterial(StaticMat)

	surface.DrawTexturedRect(0,0,w, h)



	surface.SetDrawColor(0,0,0,255)

	surface.SetMaterial(VignetteMat)

	surface.DrawTexturedRect(0,0,w, h)



end



usermessage.Hook( "OpenHalloweenConnection", function( um ) 



	Derma_Query( 

		"Are you ready to enter the madness?\n\nNote: This will take you to another server and out of Lobby.",

		"Halloween 2014 Event",

		"Yes", function() RunConsoleCommand("gmt_multijoin", 18) end,

		"Yes (force connect)", function() LocalPlayer():ConCommand('connect join.gmodtower.org:27060') end,

		"No", EmptyFunction

	)



end )