
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.CoolDown = 0
ENT.CoolDownTime = 3

function ENT:Initialize()
    self:SetModel(self.Model)
    self:DrawShadow(false)
    self:SetSolid(SOLID_NONE)
end

function ENT:Think()

    if CurTime() < self.CoolDown then
		self:SetNoDraw(true)
		return
	end

	self:SetNoDraw(false)

    for k,v in pairs( ents.FindInSphere( self:GetPos() , 64 ) ) do
      if (v:GetClass() == "sk_kart") then
        if !IsValid( v:GetOwner() ) then return end
        self:DoPickup( v:GetOwner() )
      end
    end
end

function ENT:DoPickup( ply )

  if ply:GetItem() != 0 || ply:Team() != TEAM_PLAYING || ply:IsGhost() || GAMEMODE:GetState() == STATE_BATTLEENDING || GAMEMODE:GetState() == STATE_NEXTBATTLE then return end

  self.CoolDown = CurTime() + self.CoolDownTime

  local item = math.random( 1, #items.List )

  ply:GiveRandomItem()

	local vPoint = Vector( self:GetPos() )
	local effectdata = EffectData()
	effectdata:SetOrigin( vPoint )
	util.Effect( "pickup_explosion", effectdata )

end
