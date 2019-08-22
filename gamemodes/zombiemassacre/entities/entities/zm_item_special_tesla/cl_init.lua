include( "shared.lua" )
local matBeam = Material( "particle/bendibeam" )
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Shocks = {}
ENT.Size = 0
ENT.SpriteMat = Material( "sprites/powerup_effects" )
function ENT:Draw()
	local owner = self:GetOwner()
	if IsValid( owner ) then
		pos = util.GetCenterPos( owner )
		render.SetMaterial( self.SpriteMat )
		render.DrawSprite( pos, 128, 128, Color( math.random( 150, 200 ), math.random( 150, 200 ), math.random( 240, 255 ) ) )
	end
end
//local TeslaEnts = {}
function ENT:Think()
	if !self.Shocks then return end
	for id, shock in pairs( self.Shocks ) do
		if shock[3] < CurTime() || !IsValid( shock[1] ) || !IsValid( shock[2] ) then
			table.remove( self.Shocks, id )
			/*local tesla = table.KeyFromValue( TeslaEnts, shock[2] )
			if tesla then
				table.remove( TeslaEnts, tesla )
			end*/
		end
	end
end
/*hook.Add( "Think", "TeslaMaterials", function()
	if !TeslaEnts then return end
	for id, ent in pairs( TeslaEnts ) do
		if !IsValid( ent ) || ent.IsBoss then
			table.remove( TeslaEnts, id )
			continue
		end
		if !IsValid( ent.Tesla ) then
			ent:SetMaterial("")
			table.remove( TeslaEnts, id )
		else
			ent:SetMaterial( "models/props_combine/portalball001_sheet" )
		end
	end
end )*/
function ENT:DrawTranslucent()
	if !self.Shocks then return end
	for id, shock in pairs( self.Shocks ) do
		self:DrawShock( shock[1], shock[2] )
	end
end
function ENT:DrawShock( entstart, entend )
	if !IsValid( entstart ) || !IsValid( entend ) then return end
	local pos1 = self:GetEnemyPos( entstart )
	local pos2 = self:GetEnemyPos( entend )
	// Shock beam
	self.Size = math.Approach( self.Size, 1, .5 * FrameTime() )
	self.Dir = ( pos2 - pos1 )
	self.Inc = self.Dir:Length() / 12 * self.Size
	self.Dir = self.Dir:GetNormal()
	local color = Color( math.random( 50, 100 ), math.random( 50, 100 ), 255 )
	render.SetMaterial( matBeam )
	render.StartBeam( 10 )
		render.AddBeam( pos1, math.Clamp( self.Inc * 1.8, 20, 80 ), CurTime(), color )
		for i = 1, 8 do
			local length = self.Dir:Length() or 1
			local rnd = math.Rand( 1, length * 2 )
			self.Point = ( pos1 + self.Dir * ( i * self.Inc ) ) + VectorRand() * rnd
			self.Coord = CurTime() + ( 1 / 12 ) * i
			render.AddBeam( self.Point, math.Clamp( self.Inc * 1.8, 20, 80 ), self.Coord, color )
		end
		render.AddBeam( pos2, math.Clamp( self.Inc * 1.8, 6, 30 ), CurTime() + 1, color )
	render.EndBeam()
	if !self.NextEffects || self.NextEffects < CurTime() then
		self.NextEffects = CurTime() + .25
		// Sparks
		local eff = EffectData()
			eff:SetOrigin( pos2 )
			eff:SetNormal( entend:GetUp() )
		util.Effect( "ManhackSparks", eff, true, true )
		if ConVarDLights:GetInt() < 2 then return end
		// DLights
		local dlight_start = DynamicLight( self:EntIndex() .. "start" )
		if dlight_start then
			dlight_start.Pos = pos1
			dlight_start.r = 50
			dlight_start.g = 50
			dlight_start.b = 255
			dlight_start.Brightness = 1
			dlight_start.Decay = 128
			dlight_start.size = 80
			dlight_start.DieTime = CurTime() + .1
		end
		local dlight_end = DynamicLight( self:EntIndex() .. "end" )
		if dlight_end then
			dlight_end.Pos = pos2
			dlight_end.r = 50
			dlight_end.g = 50
			dlight_end.b = 255
			dlight_end.Brightness = 1
			dlight_end.Decay = 128
			dlight_end.size = 80
			dlight_end.DieTime = CurTime() + .1
		end
	end
end
function ENT:AddShock( entstart, entend, dietime )
	local shock = { entstart, entend, dietime }
	table.insert( self.Shocks, shock )
	//table.insert( TeslaEnts, entend )
	//entend.Tesla = self
end

net.Receive("zm_shock",function()
	local ent = net.ReadEntity()
	if !IsValid(ent) then return end
	local entstart = net.ReadEntity()
	local entend = net.ReadEntity()
	if !IsValid( entstart ) || !IsValid( entend ) then return end
	if ent.AddShock then
		ent:AddShock( entstart, entend, CurTime() + .5 )
	end
end)

/*usermessage.Hook( "Shock", function( um )
	local entid = um:ReadShort()
	local ent = ents.GetByIndex( entid )
	if !IsValid( ent ) then return end
	local entid1 = um:ReadShort()
	local entid2 = um:ReadShort()
	local entstart = ents.GetByIndex( entid1 )
	local entend = ents.GetByIndex( entid2 )
	if !IsValid( entstart ) || !IsValid( entend ) then return end
	if ent.AddShock then
		ent:AddShock( entstart, entend, CurTime() + .5 )
	end
end )*/
