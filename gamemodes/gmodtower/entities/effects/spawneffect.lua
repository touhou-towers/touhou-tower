

-----------------------------------------------------

--COULD DO CUSTOM DURATION WITH SetRadius! But Whatever
--COULD DO CUSTOM COLOR WITH SetColor! But Whatever

--[[
USAGE:

function OnSpawnObject( object )
	local effectdata = EffectData()
		effectdata:SetEntity( object )
		effectdata:SetFlags(0)
	util.Effect( "spawneffect", effectdata, true, true )
end

function DoRemoveObject( object )
	object:SetSolid(SOLID_NONE)
	local effectdata = EffectData()
		effectdata:SetEntity( object )
		effectdata:SetFlags(1) --flag means use remove effect
	util.Effect( "spawneffect", effectdata, true, true )

	timer.Simple(.5, function()
		if IsValid(object) then object:Remove() end
	end)
end
]]

local matLight	 = Material( "models/spawn_effect2" )

function EFFECT:Init( data )

	self.duration = .5
	self.startTime = CurTime()
	self.endTime = self.startTime + self.duration
	
	local ent = data:GetEntity()
	
	if not IsValid( ent ) or not ent:GetModel() then return end
	
	self.parent = ent
	self:SetModel( ent:GetModel() )	
	self:SetPos( ent:GetPos() )
	self:SetAngles( ent:GetAngles() )
	self:SetParent( ent )

	local flags = data:GetFlags()
	self.removing = bit.band(flags,1) ~= 0

	self.parent.RenderOverride = self.RenderParent
	self.parent.SpawnEffect = self
end

function EFFECT:DT()
	return math.min( ( CurTime() - self.startTime ) / self.duration, 1 )
end

function EFFECT:Think( )

	if not IsValid( self.parent ) then return false end
	
	local pos = self.parent:GetPos()
	self:SetPos( pos + (EyePos() - pos):GetNormal() )
	
	if self.endTime > CurTime() then return true end
	
	self.parent.RenderOverride = nil
	self.parent.SpawnEffect = nil
			
	return false
	
end

function EFFECT:Render() end
function EFFECT:RenderParent()

	local effect = self.SpawnEffect
	local dt = effect:DT()
	local min, max = self:GetRenderBounds()
	local planeDir = Vector(0,0,1)
	local backPlaneDir = Vector(0,0,-1)

	min, max = self:GetRotatedAABB( self:OBBMins(), self:OBBMaxs() )

	min = min + self:GetPos()
	max = max + self:GetPos()

	local dist = max:Dot(planeDir) - min:Dot(planeDir)

	if effect.removing then
		dt = 1-dt
	end

	local bandSize = 5
	local bandPad = bandSize/dist

	dt = dt * (1 + bandPad*2) - bandPad

	bandSize = (dt * (1-dt)) * 16

	local function effect()
		local enabled = render.EnableClipping( true );

		render.PushCustomClipPlane( backPlaneDir, min:Dot(backPlaneDir) - dist * dt + bandSize );
		self:DrawModel()
		render.PopCustomClipPlane()

		render.PushCustomClipPlane( planeDir, min:Dot(planeDir) + dist * dt - bandSize );
		render.PushCustomClipPlane( backPlaneDir, max:Dot(backPlaneDir) + dist * (1-dt) );

		render.MaterialOverride( matLight )
		render.SetColorModulation(1,1,1,1)
		self:DrawModel()
		render.MaterialOverride( 0 )

		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		render.EnableClipping(enabled)
	end

	render.ClearStencil()
	render.SetStencilEnable(true)
	render.SetStencilWriteMask( 1 )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

	render.CullMode( MATERIAL_CULLMODE_CW )
	effect()
	render.CullMode( MATERIAL_CULLMODE_CCW )

	render.SetStencilReferenceValue( 1 )
	render.SetStencilWriteMask( 0 )
	render.SetStencilTestMask( 1 )
	render.SetStencilCompareFunction( STENCIL_EQUAL )

	local pos = Vector((max.x + min.x)/2, (max.y + min.y)/2, min.z + dist * dt)

	render.SetColorMaterial()
	render.OverrideDepthEnable( true, false )
	render.DrawQuadEasy( pos, planeDir, max.x - min.x, max.y - min.y, Color(80,255,255,20), 90 )

	local ox,oy = pos.x, pos.y
	pos.x = -math.fmod(ox, 16) + pos.x - (max.x - min.x)

	for i=0, math.floor((max.x - min.x) / 8) do
		pos.x = pos.x + 16
		render.DrawQuadEasy( pos, planeDir, 2, max.y - min.y, Color(80,255,255,20), 90 )
	end


	pos.x, pos.y = ox, oy
	pos.y = -math.fmod(oy, 16) + pos.y - (max.y - min.y)

	for i=0, math.floor((max.y - min.y) / 8) do
		pos.y = pos.y + 16
		render.DrawQuadEasy( pos, planeDir, max.x - min.x, 2, Color(80,255,255,20), 90 )
	end

	pos.x, pos.y = ox, oy

	render.OverrideDepthEnable( false, false )

	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilReferenceValue( 2 )
	render.SetStencilWriteMask( 3 )

	effect()

	render.SetStencilCompareFunction( STENCIL_EQUAL )

	local color = Color(80,255,255,100)
	dt = math.Clamp(dt, 0, 1)
	local dt2 = dt * (1-dt)

	local a = .2 * dt2
	local b = .2 * dt2
	render.SetColorMaterial()

	local function freakylines()
		pos.y = math.random(min.y, max.y)
		render.DrawQuadEasy( pos, planeDir, 128, 32 * a, color, 90 )
		pos.x, pos.y = ox, oy
		pos.x = math.random(min.x, max.x)
		render.DrawQuadEasy( pos, planeDir, 32 * b, 128, color, 90 )
	end

	freakylines()
	render.CullMode( MATERIAL_CULLMODE_CW )
	freakylines()
	render.CullMode( MATERIAL_CULLMODE_CCW )

	render.SetStencilEnable(false) 

end

--[[hook.Add( "PreDrawHalos", "AddSpawnEffectHalos", function()

	for k, v in pairs( ents.GetAll() ) do
		if v.SpawnEffect and v.SpawnEffect.DT then
			local edt = v.SpawnEffect:DT()
			local edt2 = edt * (1-edt)
			halo.Add( {v}, Color( 255, 255, 255, 255 * edt2 ), 8, 8, 3, true, false )
		end
	end

end )]]