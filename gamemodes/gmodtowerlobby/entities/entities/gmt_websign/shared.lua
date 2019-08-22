AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "Web Screen"
ENT.Spawnable = true

ENT.RenderGroup = RENDERGROUP_BOTH

if ( CLIENT ) then
	ENT.Mat = nil
	ENT.Panel = nil
end

function ENT:Initialize()

	if ( SERVER ) then

		self:SetModel( "models/props_phx/rt_screen.mdl" )
		self:SetMoveType( MOVETYPE_NONE )
		--self:SetSolid( SOLID_NONE )

    self:DrawShadow( false )

		self:PhysicsInit( SOLID_VPHYSICS )

		self:Freeze()

	else

		-- Reset material and panel and load DHTML panel
		self.Mat = nil
		self.Panel = nil
		self:OpenPage()

    self:SetRenderBounds( Vector(-500,-500,-500), Vector(500,500,500) )

	end

end

function ENT:Freeze()
	local phys = self:GetPhysicsObject()
	if ( IsValid( phys ) ) then phys:EnableMotion( false ) end
end

-- Load the DHTML reference panel
function ENT:OpenPage()

	if ( self.Panel ) then

		self.Panel:Remove()
		self.Panel = nil

	end

	self.Panel = vgui.Create( "DHTML" )
  self.Panel:SetSize(1024/1.5,2048/1.5)

	local url = "http://gmodtower.org/changelog/index.php"

	self.Panel:OpenURL( url )

	-- Hide the panel
	self.Panel:SetAlpha( 0 )
	self.Panel:SetMouseInputEnabled( false )

	-- Disable HTML messages
	function self.Panel:ConsoleMessage( msg ) end

end

function ENT:DrawTranslucent()

	if self.Panel && !IsValid(self.Panel) then
		self:OpenPage()
		return
	end

	if ( self.Panel && self.Panel:GetHTMLMaterial() ) then

		-- Hides update sign when the player is too far away
		if LocalPlayer():EyePos():Distance( self:GetPos() ) > 3000 then return end

    cam.Start3D2D(self:GetPos(),self:GetAngles(),2)
      surface.SetDrawColor(255,255,255,255)
      surface.SetMaterial(self.Panel:GetHTMLMaterial())
      surface.DrawTexturedRect(0,0,1024/4,2048/4)
    cam.End3D2D()

	end

	-- Reset the material override or else everything will have a HTML material!
	render.ModelMaterialOverride( nil )

end

function ENT:OnRemove()
	-- Make sure the panel is removed too
	if ( self.Panel ) then self.Panel:Remove() end
end
