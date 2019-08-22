-------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("player.lua")
include("shared.lua")
-------------------------------

function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetUseType( SIMPLE_USE )
    self:DrawShadow(false)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
      phys:Wake()
    end

end

function ENT:Use(act, ply)

  if ply:IsPlayer() and ply:Alive() and !ply:GetNWBool("DrivingBoat") and self:GetOwner() == NULL then
    CurUser = ply
    ply:SetNWBool("DrivingBoat",true)
    ply:SetRCBoat(self)
    ply:SetMoveType(MOVETYPE_NONE)
    ply:SetNoDraw(true)
    self:SetOwner(ply)
    ply:SetSolid(SOLID_NONE)

    self:SetNWVector("RespawnPos",ply:GetPos())

  end

end

function ENT:Think()
    if IsValid(self:GetOwner()) then
      local ply = self:GetOwner()

      if !ply:Alive() then ply:SetRCBoat(nil) self:SetOwner(nil) ply:SetSolid(SOLID_BBOX) ply:SetNWBool("DrivingBoat",false) end

      if ply:KeyDown(IN_FORWARD) then
        self:GetPhysicsObject():AddVelocity(ply:GetForward() * 50)
      end

      if ply:KeyDown(IN_BACK) then
        self:GetPhysicsObject():AddVelocity(ply:GetForward() * -50)
      end

    end
end

function ENT:OnRemove()
    for k,v in pairs(player.GetAll()) do
      if v:GetNWBool("DrivingBoat") then
        if v:GetRCBoat() == self then
          v:SetMoveType(MOVETYPE_WALK)
          v:SetNoDraw(false)
          v:SetRCBoat(nil)
          v:SetPos(self:GetNWVector("RespawnPos"))
          v:SetSolid(SOLID_BBOX)
          v:SetNWBool("DrivingBoat",false)
        end
      end
    end
end

hook.Add( "KeyPress", "LeaveRCBoat", function( ply, key )
	if ( key == IN_USE ) and ply:GetNWBool("DrivingBoat") then
    timer.Simple(0.1,function()
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetNoDraw(false)
    ply:GetRCBoat():SetOwner(nil)
    ply:SetPos(ply:GetRCBoat():GetNWVector("RespawnPos"))
    ply:SetRCBoat(nil)
    ply:SetSolid(SOLID_BBOX)
    ply:SetNWBool("DrivingBoat",false)
    end)
	end

  if ( key == IN_ATTACK ) and ply:GetNWBool("DrivingBoat") then
    if ply:GetRCBoat():GetNWBool("HornDelay") then return end
    local boat = ply:GetRCBoat()
    boat:EmitSound("passtime/horn_air1.wav",70,math.random(150,200))
    boat:SetNWBool("HornDelay",true)
    timer.Simple(5,function()
      boat:SetNWBool("HornDelay",false)
    end)
  end

  if ( key == IN_ATTACK2 ) and ply:GetNWBool("DrivingBoat") then
    if ply:GetRCBoat():GetNWBool("RocketDelay") then return end
    local fw = ents.Create( "firework_multi" )
    local boat = ply:GetRCBoat()
    if ( !IsValid( fw ) ) then return end
    fw:SetPos( boat:GetPos() + Vector(0,0,5) )
    fw:Spawn()
    fw:SetModelScale(0.25,0)
    fw:DoFirework()
    boat:SetNWBool("RocketDelay",true)
    timer.Simple(5,function()
      boat:SetNWBool("RocketDelay",false)
    end)
  end

  if ( key == IN_SPEED ) and ply:GetNWBool("DrivingBoat") then
    if ply:GetRCBoat():GetNWBool("BoostDelay") then return end
    local boat = ply:GetRCBoat()
    boat:GetPhysicsObject():AddVelocity(ply:GetForward() * 500)
    boat:EmitSound("weapons/bumper_car_speed_boost_start.wav",60,130)
    boat:SetNWBool("BoostDelay",true)
    timer.Simple(5,function()
      boat:SetNWBool("BoostDelay",false)
    end)
  end

end )
