include( "shared.lua" )

surface.CreateFont( "PetFont", { font = "Arial", size = 100, weight = 400 } )
surface.CreateFont( "PetName", { font = "Arial", size = 50, weight = 400 } )
surface.CreateFont( "PetMsg", { font = "Arial", size = 24, weight = 300 } )

CreateClientConVar("gmt_petname","",true,true)

local MsgTime = 3

function ENT:Initialize()

	self:SharedInit()

end

function ENT:DrawText( text, font, x, y, alpha, xalign, yalign )
	if text then
		draw.DrawText( text, font, x + 2, y + 2, Color( 0, 0, 0, alpha ), xalign, yalign )
		draw.DrawText( text, font, x, y, Color( 255, 255, 255, alpha ), xalign, yalign )
	end
	
end

function ENT:DrawMessage()

	if !self.EmoteIndex then return end

	local diff = self.EmoteTime - CurTime()
	local perc = 1 - math.Clamp( ( MsgTime - diff ) / MsgTime, 0, 1 )

	local alpha = 255 * perc
	local yPos = 40 * perc
	
	local randText = Pets.GetQuote( "melon", self.EmoteIndex, self.SubIndex )
	self:DrawText( randText, "PetMsg", 50, yPos - 20, alpha, 0, 0 )
	
	if perc == 0 then
		self.EmoteIndex = nil
		return
	end
	
end

function ENT:Draw()

	self.Entity:DrawModel()
	
	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos()
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	pos.z = pos.z + 20
	
	if self.Emotion == 0 then return end
	
	local emoteText = Pets.GetEmotionString( self.Emotion )
	
	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
	
		self:DrawText( emoteText, "PetFont", 0, 0, 255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
		if self:GetPetName() and self:GetPetName() != "" then
			self:DrawText( self:GetPetName(), "PetName", 0, -30, 255, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		
		self:DrawMessage()
		
	cam.End3D2D()
	
end

function ENT:EmoteMsg( emote, index )

	self.EmoteIndex = emote
	self.SubIndex = index
	self.EmoteTime = CurTime() + MsgTime
	
end

usermessage.Hook( "PetMSG", function( um )
	local petEnt = um:ReadEntity()
	
	if !IsValid( petEnt ) then return end
	
	local emote = um:ReadChar()
	local index = um:ReadChar()
	
	if petEnt.EmoteMsg then
		petEnt:EmoteMsg( emote, index )
	end
end ) 