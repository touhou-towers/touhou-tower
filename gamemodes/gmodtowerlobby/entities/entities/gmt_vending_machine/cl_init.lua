
-----------------------------------------------------
include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Draw()
	self:DrawModel()
	self2 = self
	--self:DrawTranslucent()
end

hook.Add("StoreFinishBuy", "PlayBuySound", function()
	if GTowerStore.StoreId == 17 then
		self2:EmitSound("gmodtower/stores/purchase_vending.wav")
	end
end )

/*function ENT:DrawTranslucent()
	local NPCNAME = self.PrintName

	local offset = Vector( 0, 0, 110 )

	local ang = LocalPlayer():EyeAngles()
	local pos = self:GetPos() + offset + ang:Up() * ( math.sin( CurTime() ) * 4 )

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.14 )
		draw.DrawText( NPCNAME, "GTowerNPC", 2, 2, Color( 0, 0, 0, 225 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.DrawText( NPCNAME, "GTowerNPC", 0, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	cam.End3D2D()
end*/
