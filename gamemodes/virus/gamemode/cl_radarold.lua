local Radar = {}

Radar.AlphaScale = 0.6

Radar.FriendlyColor = Color( 240, 240, 240, 255 )
Radar.EnemyColor = Color( 255, 20, 20, 255 )

Radar.Radius = 1250

local RadarVirus = surface.GetTextureID( "gmod_tower/virus/hud_infected_radar" )
local RadarHuman = surface.GetTextureID( "gmod_tower/virus/hud_survivor_radar" )


local ColorAScale = function( col, scale )
	return Color( col.r, col.g, col.b, col.a * math.pow( 1 - scale, 2 ) )
end

function DrawRadar()

	Radar.w = 256
	Radar.h = 128
	Radar.x = ScrW() - Radar.w - 32
	Radar.y = 32

	if !GAMEMODE:IsPlaying() then return end

	if LocalPlayer().IsVirus then
		surface.SetTexture( RadarVirus )
	else
		surface.SetTexture( RadarHuman )
	end

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( Radar.x, Radar.y, 256, 128 )

	for _, ply in pairs( player.GetAll() ) do
		if ((!LocalPlayer().IsVirus && !ply.IsVirus && ply:Alive()) || (LocalPlayer().IsVirus && ply.IsVirus && ply:Alive())) then
			DrawBlip( ply, Radar.FriendlyColor )
		elseif ply:Alive() then
			DrawBlip( ply, Radar.EnemyColor )
		end
	end

end

function DrawBlip( ent, color )

	if !IsValid( ent ) || LocalPlayer() == ent then return end

	local vdiff = ent:GetPos() - LocalPlayer():GetPos()
	if vdiff:Length() > Radar.Radius then return end

	local cx = Radar.x + Radar.w / 2
	local cy = Radar.y + Radar.h / 2

	local px = ( vdiff.x / Radar.Radius )
	local py = ( vdiff.y / Radar.Radius )

	local z = math.sqrt( px * px + py * py )
	local phi = math.rad( math.deg( math.atan2( px, py ) ) - math.deg( math.atan2( LocalPlayer():GetAimVector().x, LocalPlayer():GetAimVector().y ) ) - 90 )
	px = math.cos( phi ) * z
	py = math.sin( phi ) * z

	draw.RoundedBox( 4, ( cx + px * Radar.w / 2 - 4 ), cy + py * Radar.h / 2 - 4, 8, 8, ColorAScale( color, z ) )
	//draw.RoundedBox( 4, ( cx + px * Radar.w / 2 - 4 ), cy + py * Radar.h / 2 - 4, 8, 8, ColorAScale( color, 1 - z ) )

end
