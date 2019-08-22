
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
  self:SetModel( "models/nova/airboat_seat.mdl" )
  self:SetSolid( SOLID_NONE )
  self:DrawShadow( false )
  self:SetNoDraw( true )
end

function ENT:KeyValue( key, val )
    if key == "train" then
      self.Train = tostring( val )
    end

    if key == "angles" then
      self.Ang = tostring( val )
    end
end

local function HandleRollercoasterAnimation( vehicle, player )
	return player:SelectWeightedSequence( ACT_GMOD_SIT_ROLLERCOASTER )
end

function CreatePod( name, seat, cart )
  local ent = ents.Create("prop_vehicle_prisoner_pod")
	ent:SetModel("models/nova/airboat_seat.mdl")
	ent:SetKeyValue("vehiclescript","scripts/vehicles/prisoner_pod.txt")
	ent:SetPos( seat:GetPos() + Vector(0,0,20) + cart:GetForward() * 25 )
	ent:SetAngles( Angle( 0, -90, 0 ) )
	ent:SetNotSolid(true)
	ent:SetNoDraw(true)

	ent.HandleAnimation = HandleRollercoasterAnimation

	ent:Spawn()
	ent:Activate()

  ent:SetParent( cart )

  ent.Train = name

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

  seat:Remove()

	return ent
end

local function GetCartNum( name )
  print(name)
  for i=1, 6 do
    if string.EndsWith( name, tostring(i) ) then
      return i
    end
  end
  return 1
end

hook.Add("InitPostEntity","PodsInCarts",function()
  print("=========INITIALIZING CARTS=========")
  for _,cart in pairs( ents.FindByClass("func_tracktrain") ) do

    cart.Num = GetCartNum( cart:GetName() )

    for _,seat in pairs( ents.FindByClass("logic_trainseat") ) do
      if cart:GetName() == seat.Train then
        CreatePod( seat.Train, seat, cart )
        print("Created cart seat for cart #"..cart.Num..".\n")
      end
    end
  end
  print("=========DONE INITIALIZING CARTS=========")

  timer.Create("CartLoopStarter",20,0,function()
    for k,v in pairs( ents.FindByClass("func_tracktrain") ) do
      if !v.Going then
        v:Fire("StartForward","")
      end
    end
  end)

end)
