
include('shared.lua')

local MaxNameHeight = 1
surface.CreateFont( "GTowerHUDMainTiny2", { font = "Oswald", size = 42, weight = 400 } )
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()

	self.TotalPlacesHeight = 1
	
	self.CamScale = 0.05
	self.TotalSize = 9 / self.CamScale //Do not change
	
	self.BoxNameW = 1
	self.ChoosingItem = 1
	self.BoxNameH = 1
	
	self.ItemList = {}

	self:ProcessNames()
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:MyPlace()
	return 1
end

local MarkupBackup = {}

function ENT:ProcessNames()

	local HeightSpace = 4
	local ExtraSpace = 4
	local CurY = 0
	
	local StartPosX = -1 * self.TotalSize
	local TotalWidth = 2 * self.TotalSize
	
	local LocalPosition = GTowerLocation:DefaultLocation( self:GetPos() )
	--local LocalPosition = self:Location()

	surface.SetFont("GTowerHUDMainTiny2")

	for k, v in pairs( GTowerLocation.TeleportLocations ) do
	
		if LocalPosition != k then
	
			local w,h = surface.GetTextSize( v.name )
			local Markup = MarkupBackup[ k ]
			
			if !Markup then
				Markup = markup.Parse( "<font=GTowerHUDMainTiny2><color=white>" .. v.desc .. "</color></font>", TotalWidth - 2 )
				MarkupBackup[ k ] = Markup
			end
			
			if h > MaxNameHeight then
				MaxNameHeight = h
			end
			
			table.insert( self.ItemList, {
				["id"] = k,
				["TextWide"] = w,
				["name"] = v.name,
				["Markup"] = Markup
			} )
			
		end
	end
	
	local LocalSize = ( MaxNameHeight + ExtraSpace + HeightSpace ) * self.CamScale
	
	for k, v in pairs( self.ItemList ) do
		
		v.YPos = CurY
		
		v.XTextPos = StartPosX + TotalWidth * 0.5 - v.TextWide * 0.5
		v.YTextPos = v.YPos + (MaxNameHeight + ExtraSpace) * 0.5 - MaxNameHeight * 0.5
		
		v.StartYTrace = 67 - (k-1) * LocalSize
		v.EndYTrace   = 67 - k * LocalSize
		
		CurY = CurY + MaxNameHeight + ExtraSpace + HeightSpace
	end
		
	self.StartPosX = StartPosX
	self.BoxNameW = TotalWidth
	self.BoxNameH = MaxNameHeight + HeightSpace

end


function ENT:GetActivePlayer()

	if CLIENT && self:TestForPlayer( LocalPlayer() ) then
		return LocalPlayer()
	end
	
	for _, v in pairs( player.GetAll() ) do
		if self:TestForPlayer( v ) then
			return v
		end
	end

end

function ENT:GetTraceItem( forceplayer )

	local PlyTrace = forceplayer or self:GetActivePlayer()
	
	if !IsValid(PlyTrace) then
		return nil
	end
	
	local PlyTrace = PlyTrace:GetEyeTrace()
	
	if PlyTrace.Entity != self then
		return nil
	end
	
	local TraceHitPos = self:WorldToLocal( PlyTrace.HitPos )

	for k, v in pairs( self.ItemList ) do
		if k == 1 then
			if TraceHitPos.y > -18.4091 && TraceHitPos.y < -3.93 &&
				TraceHitPos.z < v.StartYTrace -0.21 &&
				TraceHitPos.z > v.EndYTrace -0.42 then
				return k
			end
		end
		if k == 2 then
			if TraceHitPos.y > -18.4091 && TraceHitPos.y < -3.93 &&
				TraceHitPos.z < v.StartYTrace -0.67 &&
				TraceHitPos.z > v.EndYTrace -0.85 then
				return k
			end
		end
	end

	return nil
end

function ENT:DrawTranslucent()

	local Vec = self:LocalToWorld( Vector(-10, -10, 67 ) )
	local Vec2 = self:LocalToWorld( Vector(-9, 10, 67 ) )
	local ang = self:GetAngles()
	
	ang:RotateAroundAxis( ang:Right(), -90 )
	ang:RotateAroundAxis( ang:Forward(), -45 )
	ang:RotateAroundAxis( ang:Up(), 90 )
	
	
	local HitItem = self:GetTraceItem()
	local ActiveHit = HitItem != nil
	
	if ActiveHit then
		self.ChoosingItem = HitItem	
	end
	
	surface.SetFont("GTowerHUDMainTiny2")
	surface.SetTextColor( 60,75,80,255 )

	cam.Start3D2D( Vec, ang, self.CamScale )
		
		for k, v in pairs( self.ItemList ) do
			
			if self.ChoosingItem == k then
				if ActiveHit then
					surface.SetTextColor( 255,255,255,150 )
					draw.RoundedBox( 0, self.StartPosX , v.YPos, self.BoxNameW, self.BoxNameH, Color(150,255,150,50) )					
				else
					draw.RoundedBox( 0, self.StartPosX , v.YPos, self.BoxNameW, self.BoxNameH, Color(130,140,145,200) )
				end
			else
				surface.SetTextColor( 60,75,80,255 )
				draw.RoundedBox( 0, self.StartPosX , v.YPos, self.BoxNameW, self.BoxNameH, Color(130,140,145,80) )
			end
			if v.XTextPos == -29 then
				//BAD TELE
				surface.SetTextPos( -69, v.YTextPos )
			else
				surface.SetTextPos( v.XTextPos, v.YTextPos )
			end
			surface.DrawText( v.name )
			
		end
	
	cam.End3D2D()
	
	local Markup = self.ItemList[ self.ChoosingItem ].Markup
	
	if Markup then
	
		ang:RotateAroundAxis( ang:Right(), 90 )
		
		cam.Start3D2D( Vec2, ang, self.CamScale )
		
			--draw.RoundedBox( 8, self.StartPosX, 0, self.BoxNameW, Markup:GetHeight() + 2 , Color(130,140,145,150) )
			
			Markup:Draw( self.StartPosX + 2 ,2 )
		
		cam.End3D2D()
	
	end
	
end

local function TeleporterTestForClick( ent )
	if !ent.GetTraceItem then return end

	local ItemTrace = ent:GetTraceItem( LocalPlayer() )
	
	if ItemTrace then
		--print(ent.ItemList[ ItemTrace ].id)
		RunConsoleCommand("gmt_cteleporter", ent:EntIndex(), ent.ItemList[ ItemTrace ].id )
		return true
	end

end

hook.Add("KeyRelease", "CheckPlayerTeleporter", function( ply, key )

	if ply == LocalPlayer() && IsValid(LocalPlayer()) && key == IN_USE then
		local Trace = LocalPlayer():GetEyeTrace()
		
		if IsValid( Trace.Entity ) && Trace.Entity:GetClass() == "gmt_teleporter" then
			TeleporterTestForClick( Trace.Entity )
		end
		
	end

end )

hook.Add("GtowerMouseEnt", "GtowerMouseTeleporter", function( ent, mc )

	if ent:GetClass() != "gmt_teleporter" then return end
	if TeleporterTestForClick( ent ) != true then return end
	
	return true
end ) 