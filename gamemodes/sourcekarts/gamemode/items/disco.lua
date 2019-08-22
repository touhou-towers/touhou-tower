
-----------------------------------------------------
local ITEM = {}

ITEM.Name = "Disco"
ITEM.Model = "models/gmod_tower/discoball.mdl"
ITEM.Material = Material( "gmod_tower/sourcekarts/cards/disco" )
ITEM.Entity = "sk_item_disco"
ITEM.MaxUses = 1
ITEM.Length = 15

ITEM.Battle = true
ITEM.Chance = items.RARE
ITEM.MaxPos = 3

function ITEM:Start( ply, kart )

	ply:SpawnItem( self.Entity )
	kart:SetIsInvincible( true )

	--music.SetVolume( ply, .1 )

	music.Play( 3, 0.1, ply )

end

function ITEM:End( ply, kart )

	ply:RemoveSpawnedItem()
	kart:SetIsInvincible( false )

	--music.SetVolume( ply, music.DefaultVolume )
	--music.Play( 3, music.DefaultVolume )

	local MusicID
	local t = GAMEMODE:GetTrack()

	if t < 4 then
		if t == 1 then MusicID = MUSIC_RACE1 elseif t == 2 then MusicID = MUSIC_RACE2 elseif t == 3 then MusicID = MUSIC_RACE3 end
	else
		if t == 4 then MusicID = MUSIC_BATTLE1 elseif t == 5 then MusicID = MUSIC_BATTLE2 end
	end

	music.Play( 1, MusicID, ply )

end

items.Register( ITEM )

if CLIENT then

	hook.Add( "DrawKart", "DrawDisco", function( self, model, ply )

		// Color for disco ball
		if self:GetIsInvincible() && ply:IsActiveItem( "Disco" ) then

			local color = colorutil.Rainbow( 300 )
			//model:SetMaterial( "models/debug/debugwhite" )
			//model:SetColor( color )

			if IsValid( model ) then
				model.GetPlayerColor = function()
					if IsValid( ply ) then
						return Vector( color.r/255, color.g/255, color.b/255 )
					end
				end
			end

			local dlight = DynamicLight( self:EntIndex() .. "neon" )
			if dlight then
				dlight.Pos = self:GetPos()
				dlight.r = color.r
				dlight.g = color.g
				dlight.b = color.b
				dlight.Brightness = .5
				dlight.Decay = 512
				dlight.size = 256
				dlight.DieTime = CurTime() + .1
			end

		end

	end )

end
