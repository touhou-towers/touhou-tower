
include('shared.lua')

ENT.matBeam		 		= Material( "cable/physbeam" )
ENT.TeslaColor = Color( 255, 0, 0, 255 )
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

	self.BaseClass.Initialize( self )

	self.List = nil
	self.NextDisco = CurTime()

end

function ENT:DrawTranslucent()

	self:Position()

	local Owner = self:GetOwner()

	if IsValid( Owner ) then

		self:DrawExtraBeans( Owner )

	end

end

function ENT:DrawExtraBeans( ply )

	if !string.StartWith(ply:GetModel(),"models/player/redrabbit") then return end

	self.BaseClass.DrawBeans( self, ply )

end

function ENT:RecieveList( um )

	local Count = um:ReadChar()
	local TotalLenght = 0

	if Count == 0 then
		self.List = nil
		self.EndEntity = nil
		return
	end

	local List = {}
	local LastVector = nil

	for i=1, Count do
		local Vec = um:ReadVector()

		if LastVector then
			TotalLenght = TotalLenght + Vec:Distance( LastVector )
		end

		table.insert( List, Vec )
		LastVector = Vec
	end

	local Min, Max = self:WorldToLocal( List[1] ), self:WorldToLocal( List[#List] )

	OrderVectors( Min, Max )

	self.List = List
	self:SetRenderBounds( Min, Max )

end

usermessage.Hook( "rabbit_tesla", function( um )

	local Ent = um:ReadEntity()

	if IsValid( Ent ) && type( Ent.RecieveList ) == "function" then
		Ent:RecieveList( um )
	end

end )
