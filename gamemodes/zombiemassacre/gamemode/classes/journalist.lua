
-----------------------------------------------------
local CLASS = {}

CLASS.Name = "Journalist"
CLASS.PlayerModel = ""

CLASS.SpecialItemName = "Radio Tower"
CLASS.SpecialItemDesc = "This novelty radio tower sends out a precisely tuned frequency that explodes zombie into the air."
CLASS.SpecialItem = "zm_item_special_radio"
CLASS.SpecialItemDelay = 60

CLASS.PowerName = "Camera Flash"
CLASS.PowerDesc = "The blinding flash damages every zombie around you. Say cheese."
CLASS.PowerLength = .1
CLASS.PowerGotSound = "GModTower/zom/powerups/powerup_journalist.wav"

if CLIENT then
	CLASS.SpecialItemMat = surface.GetTextureID( "gmod_tower/zom/hud_item_radio" )
	CLASS.PowerMat = surface.GetTextureID( "gmod_tower/zom/hud_power_camera" )
end

function CLASS:Setup( ply )

	self.Player = ply
	//ply:SetModel( self.PlayerModel )
end

function CLASS:PowerStart( ply )

	PostEvent( ply, "survivorCamera" )

	for _, ent in pairs( ents.FindInSphere( ply:GetPos(), 384 ) ) do

		if ent:IsNPC() then
			ent:TakeDamage( 250, ply )
			ply:AddAchivement( ACHIVEMENTS.ZMCAMERA, 1 )
		end

	end

	ply:EmitSound( "GModTower/zom/powerups/camera_flash.wav" )

	umsg.Start( "CameraFlash" )
		umsg.Entity( ply )
	umsg.End()

	ply:SetNWBool( "IsPowerCombo", false )
	ply:SetNWInt( "Combo", 0 )

end

function CLASS:PowerEnd( ply )
end

if CLIENT then

	usermessage.Hook( "CameraFlash", function( um )

		local ent = um:ReadEntity()

		if ConVarDLights:GetInt() < 1 then return end

		local dlight = DynamicLight( ent:EntIndex() .. "camera" )
		if dlight then
			dlight.Pos = ent:GetPos()
			dlight.r = 255
			dlight.g = 255
			dlight.b = 255
			dlight.Brightness = 5
			dlight.Decay = 400
			dlight.size = 512
			dlight.DieTime = CurTime() + .4
		end

	end )

end

classmanager.Register( "journalist", CLASS )
