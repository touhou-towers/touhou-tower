surface.CreateFont( "ImpactType", { font = "Impact", size = 42, weight = 400 } )
surface.CreateFont( "ImpactName", { font = "Impact", size = 54, weight = 600 } )

surface.CreateFont( "AmmoBig", { font = "Impact", size = 60, weight = 300 } )
surface.CreateFont( "AmmoSmall", { font = "Impact", size = 50, weight = 600 } )
surface.CreateFont( "DamageNote", { font = "Impact", size = 28, weight = 200 } )

surface.CreateFont( "ImpactHud", { font = "Impact", size = 32, weight = 400 } )
surface.CreateFont( "ImpactHudBig", { font = "Impact", size = 42, weight = 500 } )

surface.CreateFont( "CountDown", { font = "Impact", size = 70, weight = 300 } )
surface.CreateFont( "GTowerHudCText", { font = "default", size = 35, weight = 700 } )

local HudColor = Color( 255, 255, 255, 255 )
local OutlineColor = Color( 0, 0, 0, 255 )

local HudVirRank = surface.GetTextureID( "gmod_tower/virus/hud_infected_rank" )
local HudVirScore = surface.GetTextureID( "gmod_tower/virus/hud_infected_score" )
local HudVirTime = surface.GetTextureID( "gmod_tower/virus/hud_infected_time" )
local HudVirRound = surface.GetTextureID( "gmod_tower/virus/hud_infected_round" )

local HudSurRank = surface.GetTextureID( "gmod_tower/virus/hud_survivor_rank" )
local HudSurScore = surface.GetTextureID( "gmod_tower/virus/hud_survivor_score" )
local HudSurTime = surface.GetTextureID( "gmod_tower/virus/hud_survivor_time" )
local HudSurRound = surface.GetTextureID( "gmod_tower/virus/hud_survivor_round" )

local HudAmmo = surface.GetTextureID( "gmod_tower/virus/hud_survivor_ammo" )

local ShowHud = CreateClientConVar( "gmt_virus_hud", 1, true )
local ShowDamageNotes = CreateClientConVar( "gmt_virus_damagenotes", 1, true )

local ScoreStageTime = 0
local ScoreStage = 0 // 0 - not displayed, 1 - scrolling right, 2 - static, 3 - scrolling left
local StageTime = 0.30

local Ranks = { "st", "nd", "rd" }
local function RankToString( rank )

	local suffix = Ranks[ rank ] or "th"
	return tostring( rank ) .. suffix
	
end

function GM:HUDPaint()

	if ShowHud:GetBool() == false then
		return
	end
	
	DrawRadar()
	
	local spread
	
	local state = game.GetWorld().State
	local endtime = game.GetWorld().Time
	
	local currentRound = game.GetWorld().Round
	local maxRounds = game.GetWorld().MaxRounds
	
	local rank = RankToString( LocalPlayer().Rank )
	local score = tostring( LocalPlayer():Frags() )

	
	local timeleft = endtime - CurTime()
	
	if ( timeleft <= 0 ) then
		timeleft = 0
	end
	
	local timeformat = string.FormattedTime( timeleft, "%02i:%02i" )

	local hudRank = HudSurRank
	local hudScore = HudSurScore
	local hudTime = HudSurTime
	local hudRound = HudSurRound
	
	if ( LocalPlayer().IsVirus ) then
		hudRank = HudVirRank
		hudScore = HudVirScore
		hudTime = HudVirTime
		hudRound = HudVirRound
	end
	
	if state != STATUS_INFECTING then
		if ( state == STATUS_WAITING || state == STATUS_INTERMISSION || state == STATUS_PLAYING ) then
			
			local spread = 64
			if state == STATE_WAITING then
				spread = 0
			end

			surface.SetTexture( hudTime )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( ( ScrW() / 2) - (128 / 2) - 64, 0, 128, 128 )
			
			draw.SimpleTextOutlined( timeformat, "ImpactHudBig", ( ScrW() / 2 ) - spread, 70, HudColor, 1, 1, 2, OutlineColor )

			if state != STATE_WAITING then

				surface.SetTexture( hudRound )
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawTexturedRect( ( ScrW() / 2) - (128 / 2) + 64, 0, 128, 128 )
				
				draw.SimpleTextOutlined( currentRound .. "/" .. maxRounds, "ImpactHudBig", ( ScrW() / 2 ) + spread, 70, HudColor, 1, 1, 2, OutlineColor )
			
			end
			
			if #player.GetAll() == 1 && currentRound == 0 then
				draw.WaveyText( "WAITING FOR PLAYERS", "GTowerHudCText", ScrW()/2, ScrH()/1 - 25, Color( 255, 255, 255, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 5 )
			end

		end

		if state != STATE_WAITING then

			surface.SetTexture( hudRound )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( ( ScrW() / 2) - (128 / 2) + 64, 0, 128, 128 )
				
			draw.SimpleTextOutlined( currentRound .. "/" .. maxRounds, "ImpactHudBig", ( ScrW() / 2 ) + 64, 70, HudColor, 1, 1, 2, OutlineColor )

		end
		
		if ( state == STATUS_PLAYING || state == STATUS_INTERMISSION ) then
			
			local rankX = 0
			local diff = ScoreStageTime - CurTime()
			local perc = math.Clamp( (StageTime - diff) / StageTime, 0, 1 )
			local dest = 128 + 10
			
			if ( ScoreStage == 1 ) then
				
				rankX = dest * perc
				
				if ( perc == 1 ) then
					ScoreStageTime = CurTime() + StageTime + 3 // extra time for the static stage
					ScoreStage = 2
				end
				
			elseif ( ScoreStage == 2 ) then
			
				rankX = dest
				
				if ( perc == 1 ) then
					ScoreStageTime = CurTime() + StageTime
					ScoreStage = 3
				end
				
			elseif ( ScoreStage == 3 ) then
			
				rankX = dest - ( dest * perc )
				
			end
			
			scoreX = rankX - 128 - 10
			
			surface.SetTexture( hudRank )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( 10 + rankX, 0, 128, 128 )
			
			draw.SimpleTextOutlined( rank, "ImpactHudBig", 72 + rankX, 70, HudColor, 1, 1, 2, OutlineColor )
			
			surface.SetTexture( hudScore )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( 10 + scoreX, 0, 128, 128 )
			
			draw.SimpleTextOutlined( score, "ImpactHudBig", 72 + scoreX, 70, HudColor, 1, 1, 2, OutlineColor )

		end
	end	
	
	if state != STATE_INTERMISSION then
			
		if LocalPlayer().GetActiveWeapon then

			local activeWeapon = LocalPlayer():GetActiveWeapon()
				
			if IsValid( activeWeapon ) && activeWeapon:GetClass() != "weapon_adrenaline" then
				
				if activeWeapon:Clip1() != -1 then

					surface.SetTexture( HudAmmo )
					surface.SetDrawColor( 255, 255, 255, 255 )
						
					surface.DrawTexturedRect( ScrW() - 256 - 10, ScrH() - 128 - 10, 256, 128 )
						
					local ammo_left = activeWeapon:Clip1()
					local ammo_total = activeWeapon:Ammo1()
							
					draw.SimpleTextOutlined( ammo_left, "AmmoBig", ScrW() - 170, ScrH() - 75, HudColor, 1, 1, 2, OutlineColor )
					draw.SimpleTextOutlined( ammo_total, "AmmoSmall", ScrW() - 102, ScrH() - 70, HudColor, 1, 1, 2, OutlineColor )

				end

			end

		end

	end

	if ShowDamageNotes:GetBool() == true then
		self:DamageNotes()
	end	
	
end

DamageNotes = {}
GM.DamageNoteTime = 1.5

function GM:DamageNotes()

	for _, note in ipairs( DamageNotes ) do

		if ( note.Time + self.DamageNoteTime ) < CurTime() then
			table.remove( DamageNotes, _ )
			continue
		end

		local timer = CurTime() - note.Time
		if timer > self.DamageNoteTime then timer = self.DamageNoteTime end

		local scrpos = note.Pos:ToScreen()

		if ( note.Time + self.DamageNoteTime ) > CurTime() then
			timer = ( note.Time + self.DamageNoteTime ) - CurTime()
		end

		local y = scrpos.y + 20 * timer
		local c = Color( 50, 250, 50, 255 * timer )

		draw.SimpleTextOutlined( "-" .. note.Amount, "DamageNote", scrpos.x, y, c, 1, 1, 1, Color( 0, 0, 0, c.a ) )

	end

end

function AddDamageNote( um )

	local note 	= {}
	note.Amount = um:ReadFloat()
	note.Pos 	= um:ReadVector()
	note.Time 	= CurTime()

	table.insert( DamageNotes, note )

end
usermessage.Hook( "DamageNotes", AddDamageNote )

local HiddenHud = { "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudChat" }
function GM:HUDShouldDraw( name )

	for _, v in ipairs( HiddenHud ) do
		if ( name == v ) then return false end
	end
	
	return true
end


function GM:DrawName( ply )

	if !ply:Alive() then return end
	
	local pos = ply:GetPos()
	local ang = LocalPlayer():EyeAngles()
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	pos = pos + Vector( 0, 0, 60 )
	
	local dist = LocalPlayer():GetPos():Distance( ply:GetPos() )
	
	if ( dist >= 800 ) then return end // no need to draw anything if the player is far away
	
	local opacity = math.Clamp( 310.526 - ( 0.394737 * dist ), 0, 150 ) // woot mathematica
	
	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
	
		draw.DrawText( string.upper( ply:GetName() ), "ImpactName", 50, 0, Color( 255, 255, 255, opacity ) )
		
		if game.GetWorld().State == STATUS_WAITING then
			draw.DrawText( "WAITING", "ImpactType", 50, 40, Color( 175, 175, 175, opacity ) )
		end
		
		if ( ply.IsVirus ) then
			draw.DrawText( "INFECTED", "ImpactType", 50, 40, Color( 175, 200, 175, opacity ) )
		end
			
	cam.End3D2D()

end


function GM:DrawHealth( ply )

	if !ply:Alive() then return end
	
	if game.GetWorld().State != STATUS_PLAYING then return end

	
	local pos = ply:GetPos()
	local ang = LocalPlayer():EyeAngles()
	
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
	
	pos = pos + Vector( 0, 0, 60 )

	local health = ply:Health()
	local maxHealth = ply.MaxHealth
	
	local percHealth = math.Clamp( ( health / maxHealth ) * 100, 0, 100 )
	local colorPerc = math.Clamp( ( health / maxHealth ) * 255, 0, 100 )
	
	local colorScale = Color( 255 - ( colorPerc * ( health / maxHealth ) ), colorPerc, 0, math.Clamp( self.DamageFade, 0, 255 ) )
	
	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
	
		draw.RoundedBox( 4,
			49, -1,
			26, 101,
			Color( 50, 50, 50, math.Clamp( self.DamageFade, 0, 150 ) )
		)
		
		draw.RoundedBox( 6,
			50, 100 - percHealth,
			25, percHealth,
			colorScale
		)
	
	cam.End3D2D()
	
end

function GM:PostDrawTranslucentRenderables()

	for _, v in pairs( player.GetAll() ) do
		if ( v != LocalPlayer() ) then
			self:DrawName( v )
		else
			if ( v.IsVirus ) then
				self:DrawHealth( v )
			end
		end
	end
	
end

local function ClientScorePoint( um )

	ScoreStageTime = CurTime() + StageTime
	ScoreStage = 1

end

usermessage.Hook( "ScorePoint", ClientScorePoint )
